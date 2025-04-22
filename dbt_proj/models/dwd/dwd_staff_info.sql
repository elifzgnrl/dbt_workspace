-- models/dwd/dwd_staff_info.sql

{{
    config (
        materialized= 'table',
        unique_key= ['staff_id']

    )

}}

with staff_data as (
    select
        s.staff_id,
        s.first_name,
        s.last_name,
        s.address_id,
        s.email,
        s.store_id,
        s.active as status,
        s.last_update as staff_last_update,
        s.etl_date as staff_etl_date
    from {{ ref('stg_staff') }} s
),

location_data as (
    select
        loc.location_id, 
        loc.address_id,  
        loc.address,
        loc.district,
        loc.postal_code,
        loc.city,
        loc.country,
        loc.latest_update,
        loc.last_etl_date
    from {{ ref('dwd_location_info') }} loc
),

final as (
    select
        sd.staff_id,
        sd.first_name,
        sd.last_name,
        sd.email,
        sd.store_id,
        sd.status,
        ld.location_id,
        ld.address,
        ld.district,
        ld.postal_code,
        ld.city,
        ld.country,
        greatest( sd.staff_last_update, ld.latest_update) as latest_update,
        greatest( sd.staff_etl_date, ld.last_etl_date ) as last_etl_date
    from staff_data sd
    left join location_data ld on sd.address_id = ld.address_id
)

select * from final

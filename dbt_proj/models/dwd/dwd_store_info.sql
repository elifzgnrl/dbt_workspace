-- models/dwd/dwd_store.sql

{{
    config (
        materialized= 'table',
        unique_key= ['store_id']
    )
}}

with store_data as (
    select
        s.store_id,
        s.address_id, 
        s.manager_staff_id,
        s.last_update,
        s.etl_date
    from {{ ref('stg_store') }} s
),

manager_data as(
    select
        si.staff_id,
        si.store_id,
        si.first_name as manager_name,
        si.last_name as manager_surname,
        si.email,
        si.latest_update,
        si.last_etl_date
    from {{ ref("dwd_staff_info") }} si
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
        sd.store_id,
        md.staff_id,
        md.manager_name,
        md.manager_surname,
        md.email,
        ld.location_id, 
        ld.address,
        ld.district,
        ld.postal_code,
        ld.city,
        ld.country,
        greatest(sd.last_update, md.latest_update, ld.latest_update) as latest_update,
        greatest(sd.etl_date, md.last_etl_date, ld.last_etl_date) as last_etl_date 
    from store_data sd
    left join manager_data md on sd.manager_staff_id = md.staff_id and sd.store_id = md.store_id
    left join location_data ld on sd.address_id = ld.address_id
)

select * from final
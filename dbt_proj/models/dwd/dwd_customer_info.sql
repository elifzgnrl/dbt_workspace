-- models/dwh/dwd/dwd_customer_info.sql

{{ config(
    materialized='table',
    unique_key=['customer_id']
) }}


with customer_data as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.address_id,
        c.store_id,
        c.active as status,
        c.create_date,
        c.last_update as customer_last_update,
        c.etl_date as customer_etl_date
    from {{ ref('stg_customer') }} c
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
    from {{ ref("dwd_location_info") }} loc

),

final as (
    select
        c.customer_id,
        c.first_name,
        c.last_name,
        c.email,
        c.status,
        ld.location_id,
        ld.address,
        ld.district,
        ld.postal_code,
        ld.city,
        ld.country,
        c.store_id,
        c.create_date,
        greatest(c.customer_last_update, ld.latest_update) as latest_update,
        greatest(c.customer_etl_date,ld.last_etl_date) as last_etl_date
    from customer_data c
    left join location_data ld on c.address_id = ld.address_id
)

select * from final


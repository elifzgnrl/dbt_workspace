{{ 
    config(
        materialized = 'table',
        unique_key = ['inventory_id']
    ) 
}}

with final as (
    select
        inventory_id,
        film_id,
        store_id,
        last_update as latest_update,
    etl_date as last_etl_date
    from {{ ref('stg_inventory') }} inv
)

select * from final
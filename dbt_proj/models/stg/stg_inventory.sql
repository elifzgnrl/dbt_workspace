-- models/staging/stg_inventory.sql

{{
    config(
        materialized= 'table',
        unique_key=['inventory_id','last_update','etl_date']
    )
}}

with source as (

    select * from {{ source('dvdrental', 'inventory') }}

),

final as (

    select
        inventory_id,
        film_id,
        store_id,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source

)

select * from final

-- models/stg/stg_customer.sql

{{
    config(
        materialized= 'table',
        unique_key=['customer_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'customer') }}
),
final as (
    select 
        customer_id,
        store_id,
        first_name,
        last_name,
        email,
        address_id,
        coalesce(active, 0) as active, 
        create_date,  
        coalesce(last_update, current_timestamp) as last_update,  
        {{ dbt.current_timestamp() }} as etl_date
    from source
)
select * from final

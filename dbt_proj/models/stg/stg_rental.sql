-- models/stg/stg_rental.sql

{{
    config(
        materialized= 'table',
        unique_key=['rental_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'rental') }}
),
final as (
    select 
        rental_id,
        rental_date::timestamp as rental_date,
        inventory_id,
        customer_id,
        coalesce(return_date::timestamp, current_timestamp) as return_date,
        staff_id,
        last_update,  
        {{ dbt.current_timestamp() }} as etl_date
    from source
)
select * from final

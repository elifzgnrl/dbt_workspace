-- models/stg/stg_payment.sql

{{
    config(
        materialized= 'table',
        unique_key=['payment_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'payment') }}
),

final as (
    select
        payment_id,
        customer_id,
        staff_id,
        rental_id,
        amount,
        payment_date::timestamp as payment_date,  
        {{ dbt.current_timestamp() }} as etl_date
    from source
)

select * from final

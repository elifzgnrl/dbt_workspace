-- models/stg/stg_address.sql

{{
    config(
        materialized= 'table',
        unique_key=['address_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'address') }}
),

final as (
    select
        address_id,
        address,
        address2,
        district,
        city_id,
        postal_code,
        phone,
        last_update,
        {{ dbt.current_timestamp() }} AS etl_date
    from source
)

select * from final

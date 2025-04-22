--model/stg/stg_city.sql

{{
    config(
        materialized= 'table',
        unique_key=['city_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'city') }}
),

final as (
    select
        city_id,
        city,
        country_id,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source
)

select * from final

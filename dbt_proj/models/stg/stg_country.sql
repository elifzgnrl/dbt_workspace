--models/stg/stg_country.sql

{{
    config(
        materialized= 'table',
        unique_key=['country_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'country') }}
),

final as (
    select
        country_id,
        country,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source
)

select * from final

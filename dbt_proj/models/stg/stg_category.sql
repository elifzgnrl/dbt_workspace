--models/stg/stg_category.sql

{{
    config(
        materialized= 'table',
        unique_key=['category_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'category') }}
),

final as (
    select
        category_id,
        name,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source
)

select * from final

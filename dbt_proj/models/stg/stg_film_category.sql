--models/stg/stg_film_category.sql

{{
    config(
        materialized= 'table',
        unique_key=['film_id', 'category_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'film_category') }}
),

final as (
    select
        film_id,
        category_id,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source    
)

select * from final



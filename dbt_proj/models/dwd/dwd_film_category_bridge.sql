-- models/dwh/dwd/dwd_film_category_bridge.sql

{{
    config(
        materialized='table',
        unique_key=['film_id', 'category_id']
    )
}}

with final as (
    select
        fc.film_id,
        c.category_id,
        c.name as category,
        greatest(fc.last_update, c.last_update) as latest_update,
        greatest(fc.etl_date, c.etl_date) as last_etl_date
    from {{ ref('stg_film_category') }} fc
    join {{ ref('stg_category') }} c on fc.category_id = c.category_id
)

select * from final

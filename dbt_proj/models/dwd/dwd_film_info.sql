-- models/dwh/dwd/dwd_film_info.sql

{{
    config(
        materialized='table',
        unique_key='film_id'
    )
}}

with final as (
    select
        f.film_id,
        f.title as film_name,
        f.description,
        f.release_year,
        f.language_id,
        l.name as language,
        f.rental_duration,
        f.rental_rate,
        f.length,
        f.replacement_cost,
        f.rating,
        f.special_features,
        greatest(f.last_update, l.last_update) as latest_update,
        greatest(f.etl_date, l.etl_date) as last_etl_date
    from {{ ref('stg_film') }} f
    join {{ ref('stg_language') }} l on f.language_id = l.language_id
)

select * from final

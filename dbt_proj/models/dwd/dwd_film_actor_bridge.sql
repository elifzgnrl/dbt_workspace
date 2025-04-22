-- models/dwh/dwd/dwd_film_actor_bridge.sql

{{
    config(
        materialized='table',
        unique_key=['film_id', 'actor_id']
    )
}}

with final as (
    select
        fa.film_id,
        a.actor_id,
        a.first_name as actor_name,
        a.last_name as actor_surname,
        greatest(fa.last_update, a.last_update) as latest_update,
        greatest(fa.etl_date, a.etl_date) as last_etl_date
    from {{ ref('stg_film_actor') }} fa
    join {{ ref('stg_actor') }} a on fa.actor_id = a.actor_id
)

select * from final

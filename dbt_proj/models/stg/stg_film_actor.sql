--modesl/stg/stg_film_actor.sql

{{
    config(
        materialized= 'table',
        unique_key=['actor_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'film_actor') }}
),

final as (
    select
        actor_id,
        film_id,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source    
)

select * from final

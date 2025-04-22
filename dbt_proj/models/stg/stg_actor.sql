-- models/stg/stg_actor.sql

{{
    config(
        materialized = 'table',
        unique_key = ['actor_id', 'last_update', 'etl_date']
    )
}}

with source as (
    select * 
    from {{ source('dvdrental', 'actor') }}
),

final as (
    select
        actor_id,
        first_name,
        last_name,
        last_update,
        {{dbt.current_timestamp()}} as etl_date
    from source
)

select * from final

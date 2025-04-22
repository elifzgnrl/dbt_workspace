-- models/stg/stg_film.sql

{{
    config(
        materialized= 'table',
        unique_key=['film_id','last_update','etl_date']
    )
}}

with source as (
    select * from {{ source('dvdrental', 'film') }}
),

final as (
    select
        film_id,
        title,
        description,
        release_year, 
        language_id,
        rental_duration,
        rental_rate,
        length,
        replacement_cost,
        rating::text as rating, 
        special_features,
        fulltext::text as fulltext, 
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source    
)

select * from final

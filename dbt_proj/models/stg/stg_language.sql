-- models/staging/stg_language.sql

{{
    config(
        materialized= 'table',
        unique_key=['language_id','last_update','etl_date']
    )
}}

with source as (

    select * from {{ source('dvdrental', 'language') }}

),

final as (

    select
        language_id,
        name,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source

)

select * from final

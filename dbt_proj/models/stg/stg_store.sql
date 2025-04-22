-- models/staging/stg_store.sql

{{
    config(
        materialized= 'table',
        unique_key=['store_id','last_update','etl_date']
    )
}}

with source as (

    select * from {{ source('dvdrental', 'store') }}

),

final as (

    select
        store_id,
        manager_staff_id,
        address_id,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source

)

select * from final

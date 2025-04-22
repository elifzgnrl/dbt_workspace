-- models/staging/stg_staff.sql

{{
    config(
        materialized= 'table',
        unique_key=['staff_id','last_update','etl_date']
    )
}}

with source as (

    select * from {{ source('dvdrental', 'staff') }}

),

final as (

    select
        staff_id,
        first_name,
        last_name,
        address_id,
        email,
        store_id,
        active,
        /*
        --active için case yazılabilir:
        case active
            when 'Active' then 1
            when 'Inactive' then 0
        end as active
        */
        username,
        password,
        encode(picture, 'base64') as picture,
        last_update,
        {{ dbt.current_timestamp() }} as etl_date
    from source

)

select * from final

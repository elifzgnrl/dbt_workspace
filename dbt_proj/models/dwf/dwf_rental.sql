{{ 
    config(
        materialized = 'table',
        unique_key = ['rental_id']
    ) 
}}

with rental_data as (
    select
        r.rental_id,
        r.customer_id,
        r.inventory_id,
        r.staff_id,
        r.rental_date,
        r.return_date,
        (r.return_date::date - r.rental_date::date) as rental_duration_days,
        case 
            when r.return_date is not null then 1
            else 0
        end as is_returned,
        r.last_update as latest_update,
        r.etl_date as last_etl_date
    from {{ ref('stg_rental') }} r
),

final as (
    select
        rental_id,
        customer_id,
        inventory_id,
        staff_id,
        rental_date,
        return_date,
        rental_duration_days,
        is_returned,
        latest_update,
        last_etl_date
    from rental_data
)

select * from final

{{ 
    config(
        materialized='table',
        unique_key=['staff_id']
    ) 
}}

with payment_data as (
    select
        staff_id,
        count(payment_id) as total_payments,
        SUM(case when enhancement = 'SMALL' THEN 1 ELSE 0 end) small_scale,
        SUM(case when enhancement = 'MEDIUM' THEN 1 ELSE 0 end) medium_scale,
        SUM(case when enhancement = 'LARGE' THEN 1 ELSE 0 end) large_scale,
        sum(amount) as total_payment_amount,
        max(payment_date) as last_payment_date,
        max(last_etl_date) as last_etl_date
    from {{ ref('dwf_payment') }}
    group by staff_id
),

rental_data as (
    select
        staff_id,
        count(rental_id) as total_rentals,
        count(distinct customer_id) as unique_customers,
        max(latest_update) as latest_rental_update,
        max(last_etl_date) as last_etl_date
    from {{ ref('dwf_rental') }}
    group by staff_id
),

final as (
    select
        coalesce(p.staff_id, r.staff_id) as staff_id,
        coalesce(p.total_payments, 0) as total_payments,
        coalesce(p.small_scale, 0) as small_scale,
        coalesce(p.medium_scale, 0) as medium_scale,
        coalesce(p.large_scale, 0) as large_scale,
        coalesce(p.total_payment_amount, 0) as total_payment_amount,
        coalesce(r.total_rentals, 0) as total_rentals,
        coalesce(r.unique_customers, 0) as unique_customers,
        greatest(coalesce(p.last_payment_date, '1900-01-01'), coalesce(r.latest_rental_update, '1900-01-01')) as last_activity_date,
        greatest(p.last_etl_date, r.last_etl_date) as last_etl_date
    from payment_data p
    full outer join rental_data r on p.staff_id = r.staff_id
)

select * from final

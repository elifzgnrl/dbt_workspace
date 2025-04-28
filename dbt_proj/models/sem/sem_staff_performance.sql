{{ 
    config(
        materialized='table',
        unique_key=['staff_id']
    ) 
}}

with rental_data as (
    select
        staff_id,
        count(rental_id) as total_rentals,
        count(distinct customer_id) as unique_customers,
        max(latest_update) as latest_rental_update,
        max(last_etl_date) as last_etl_date
    from {{ ref('dwf_rental') }}
    group by staff_id
),

payment_data as (
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

final as (
    select
        coalesce(p.staff_id, r.staff_id) as staff_id,
        p.total_payments total_payments,
        p.small_scale small_scale,
        p.medium_scale medium_scale,
        p.large_scale large_scale,
        p.total_payment_amount total_payment_amount,
        r.total_rentals total_rentals,
        r.unique_customers unique_customers,
        p.last_payment_date,
        greatest(p.last_payment_date, r.latest_rental_update) latest_update,
        greatest(p.last_etl_date, r.last_etl_date) as last_etl_date
    from  rental_data r
    left join payment_data p on r.staff_id = p.staff_id
)

select * from final

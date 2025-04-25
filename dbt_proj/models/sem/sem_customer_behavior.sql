--sem_customer_behavior

{{
    config(
        materialized='table',
        unique_key= ['customer_id']
    )
}}

with rental_data as (
    select
        customer_id,
        count(rental_id) total_rentals,
        sum(is_returned) as total_returned,
        (count(distinct rental_id) - sum(is_returned)) rented_and_not_returned,
        max(rental_duration_days) max_rental_duration,
        case
            when max(rental_duration_days) > 15 then 'overdue'
            else 'on_time'
        end customer_critics,
        sum(case when rental_duration_days > 15 then 1 else 0 end) total_overdue,
        max(latest_update) latest_update,
        max(last_etl_date) last_etl_date
    from {{ref('dwf_rental')}}
    group by customer_id
),

payment_data as (
    select
        customer_id, 
        sum(case when enhancement = 'SMALL' then 1 else 0 end) small_payment_count,
        sum(case when enhancement = 'MEDIUM' then 1 else 0 end) medium_payment_count,
        sum(case when enhancement = 'LARGE' then 1 else 0 end) large_payment_count,
        count(payment_id) total_payment,
        sum(case when enhancement = 'SMALL' then amount else 0 end) small_total_amount,
        sum(case when enhancement = 'MEDIUM' then amount else 0 end) medium_total_amount,
        sum(case when enhancement = 'LARGE' then amount else 0 end) large_total_amount,
        sum(amount) total_payment_amount,
        max(payment_date) max_payment_date,
        max(last_etl_date) last_etl_date
    from {{ref('dwf_payment')}}
    group by customer_id
),

final as (
    select 
        rd.customer_id,
        pd.customer_id as payment_customer_id,
        rd.total_rentals,
        rd.total_returned,
        rd.rented_and_not_returned,
        rd.max_rental_duration,
        rd.customer_critics,
        rd.total_overdue,
        pd.small_payment_count,
        pd.medium_payment_count,
        pd.large_payment_count,
        pd.total_payment,
        pd.small_total_amount,
        pd.medium_total_amount,
        pd.large_total_amount,
        pd.total_payment_amount,
        -- Calculating total overdue with unpaid as a boolean check
        rd.total_overdue + 
        sum(case when pd.customer_id is null then 1 else 0 end) as total_overdue_with_unpaid,
        -- payment_status based on the presence of customer_id in payment_data
        case
            when pd.customer_id is not null then 'paid'
            else 'unpaid'
        end as payment_status,
        pd.max_payment_date,
        greatest(rd.latest_update, pd.max_payment_date) as latest_update,
        greatest(rd.last_etl_date, pd.last_etl_date) as last_etl_date
    from rental_data rd
    left join payment_data pd on rd.customer_id = pd.customer_id
    group by 
        rd.customer_id,
        pd.customer_id,  
        rd.total_rentals,
        rd.total_returned,
        rd.rented_and_not_returned,
        rd.max_rental_duration,
        rd.customer_critics,
        rd.total_overdue,
        pd.small_payment_count,
        pd.medium_payment_count,
        pd.large_payment_count,
        pd.total_payment,
        pd.small_total_amount,
        pd.medium_total_amount,
        pd.large_total_amount,
        pd.total_payment_amount,
        pd.max_payment_date,
        rd.latest_update,
        rd.last_etl_date,
        pd.last_etl_date
)

select * from final

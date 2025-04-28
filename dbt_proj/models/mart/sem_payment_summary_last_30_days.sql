{{ config(
    materialized = 'table',
    unique_key = 'customer_id'
) }}

WITH final AS (
    SELECT
        customer_id,
        customer_full_name,
        email,
        staff_id,
        staff_full_name,
        total_payment_amount,
        total_payment,
        first_payment_date,
        last_payment_date,
        latest_update,
        last_etl_date
    FROM {{ ref('sem_payment_summary') }} p
    WHERE p.first_payment_date > CURRENT_DATE - INTERVAL '30 DAY'  
)

select * from final
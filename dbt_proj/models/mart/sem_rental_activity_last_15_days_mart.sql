{{ config(
    materialized = 'table',
    unique_key = 'rental_id'
) }}

WITH final AS (
    SELECT
        rental_id,
        rental_date,
        return_date,
        customer_full_name,
        staff_full_name,
        total_payment_amount,
        total_rental,
        film_id,
        film_name,
        latest_update,
        last_etl_date
    FROM {{ ref('sem_rental_activity') }} r
    WHERE r.rental_date > CURRENT_DATE - INTERVAL '15 DAYS'
)


select * from final
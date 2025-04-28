{{ config (
    materialized = 'table',
    unique_key = 'customer_id'

)}}


WITH payment_data AS (
    SELECT
        customer_id,
        staff_id,
        SUM(amount) AS total_payment_amount,
        COUNT(distinct payment_id) AS total_payment,
        MIN(payment_date) AS first_payment_date,
        MAX(payment_date) AS last_payment_date,
        MAX(last_etl_date) last_etl_date
    FROM {{ ref('dwf_payment') }}
    GROUP BY customer_id, staff_id
),

final as (
        SELECT
        c.customer_id,
        c.first_name || ' ' || c.last_name customer_full_name,
        c.email,
        p.staff_id,
        s.first_name || ' ' || s.last_name staff_full_name,
        p.total_payment_amount,
        p.total_payment,
        p.first_payment_date,
        p.last_payment_date,
        c.latest_update,
        greatest(c.last_etl_date, p.last_etl_date) last_etl_date
    FROM payment_data p
    LEFT JOIN {{ ref('dwd_customer_info') }} c ON p.customer_id = c.customer_id
    LEFT JOIN {{ ref('dwd_staff_info') }} s ON p.staff_id = s.staff_id
)

select * from final
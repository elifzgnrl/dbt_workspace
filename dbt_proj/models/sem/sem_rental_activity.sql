{{ config(
    materialized = 'table',
    unique_key = 'rental_id'
) }}

WITH rental_data AS (
    SELECT
        r.rental_id,
        r.rental_date,
        r.return_date,
        r.staff_id,
        r.customer_id,
        r.inventory_id,
        count(distinct r.rental_id) total_rental,
        sum(p.amount) total_payment_amount,
        max(r.latest_update) latest_update,
        max(greatest(r.last_etl_date, p.last_etl_date)) last_etl_date
    FROM {{ ref('dwf_rental') }} r
    LEFT JOIN {{ ref('dwf_payment') }} p ON r.rental_id = p.rental_id
    GROUP BY r.rental_id, r.rental_date, r.return_date, r.staff_id, r.customer_id, r.inventory_id
),

final AS (
    SELECT
        r.rental_id,
        r.rental_date,
        r.return_date,
        c.first_name || ' ' || c.last_name customer_full_name,
        s.first_name || ' ' || s.last_name staff_full_name,
        r.total_payment_amount,
        r.total_rental,
        i.film_id,
        f.film_name,
        greatest(r.latest_update, c.latest_update, s.latest_update, i.latest_update, f.latest_update) latest_update,
        greatest(r.last_etl_date, c.last_etl_date, s.last_etl_date, i.last_etl_date, f.last_etl_date) last_etl_date
    FROM rental_data r
    LEFT JOIN {{ ref('dwd_customer_info') }} c ON r.customer_id = c.customer_id
    LEFT JOIN {{ ref('dwd_staff_info') }} s ON r.staff_id = s.staff_id
    LEFT JOIN {{ ref('dwd_inventory_info') }} i ON r.inventory_id = i.inventory_id
    LEFT JOIN {{ ref('dwd_film_info') }} f ON i.film_id = f.film_id
)

SELECT * FROM final

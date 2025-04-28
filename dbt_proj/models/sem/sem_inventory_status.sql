{{ config(
    materialized = 'table',
    unique_key = 'inventory_id'
) }}

WITH inventory_data AS (
    SELECT
        i.inventory_id,
        i.film_id,
        i.store_id,
        COUNT(i.inventory_id) AS total_inventory,
        MAX(i.latest_update) AS latest_update,
        MAX(i.last_etl_date) last_etl_date
    FROM {{ ref('dwd_inventory_info') }} i
    GROUP BY i.inventory_id, i.film_id, i.store_id
),

final AS (
    SELECT
        i.inventory_id,
        f.film_name,
        i.store_id,
        i.total_inventory,
        CASE
            WHEN i.total_inventory > 0 THEN 'Available'
            ELSE 'Not Available'
        END inventory_status,
        MAX(greatest(i.latest_update, f.latest_update)) latest_update,
        MAX(greatest(i.last_etl_date, f.last_etl_date)) last_etl_date
    FROM inventory_data i
    LEFT JOIN {{ ref('dwd_film_info') }} f ON i.film_id = f.film_id
    GROUP BY i.inventory_id,
        f.film_name,
        i.store_id,
        i.total_inventory,
        CASE
            WHEN i.total_inventory > 0 THEN 'Available'
            ELSE 'Not Available'
        END
)

SELECT * FROM final

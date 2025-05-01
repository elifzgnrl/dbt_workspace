{{ config(
    materialized = 'table',
    unique_key = 'inventory_id'
) }}


with final AS (
    SELECT
        inventory_id,
        film_name,
        store_id,
        total_inventory,
        inventory_status,
        latest_update,
        last_etl_date
    FROM {{ ref('sem_inventory_status') }} 
    WHERE latest_update > (CURRENT_TIMESTAMP - INTERVAL '30 day')
)

SELECT * FROM final

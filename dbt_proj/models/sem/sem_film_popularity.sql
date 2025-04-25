-- sem_film_popularity

{{
    config(
        materialized='table',
        unique_key= ['film_id']
    )
}}

with final as (
    select
        i.film_id,
        count(distinct i.inventory_id) total_inventory,
        count(distinct r.rental_id) rented_inventory,
        sum(r.is_returned) returned_inventory,
        (count(distinct r.rental_id) - sum(r.is_returned)) rented_and_not_returned,
        (count(distinct i.inventory_id) - count(distinct r.inventory_id)) unrented_inventory,
        avg(r.rental_duration_days) avg_rental_duration,
        case
            when avg(r.rental_duration_days) <= 5 then 'short'
            when avg(r.rental_duration_days) between 6 and 10 then 'average'
            when avg(r.rental_duration_days) between 11 and 15 then 'long'
            else 'overdue'
        end rental_critics,
        sum(p.amount) total_revenue,
        count(distinct r.rental_id) * 1.0 / count(distinct i.inventory_id) as popularity_score,
        max(greatest(r.latest_update, i.latest_update)) latest_update,
        max(greatest(r.last_etl_date, p.last_etl_date, i.last_etl_date)) last_etl_date
    from {{ref('dwf_rental')}} r
    left join {{ref('dwf_payment')}} p on r.rental_id = p.rental_id
    left join {{ref('dwd_inventory_info')}} i on r.inventory_id = i.inventory_id
    group by i.film_id
)

select * from final

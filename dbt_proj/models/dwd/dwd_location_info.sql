-- models/dwd/dwd_location_info.sql

{{
    config (
        materialized= 'table',
        unique_key= ['location_id']
    )
}}

with address_data as (
    select
        a.address_id,
        a.city_id,
        a.address,
        a.district,
        a.postal_code,
        a.last_update,
        a.etl_date
    from {{ ref('stg_address') }} a
),

city_data as (
    select
        ci.city_id,
        ci.city,
        ci.country_id,
        ci.last_update,
        ci.etl_date
    from {{ ref('stg_city') }} ci
),

country_data as (
    select
        co.country_id,
        co.country,
        co.last_update,
        co.etl_date
    from {{ ref('stg_country') }} co
),

joined_data as (
    select
        ad.address_id,
        ad.address,
        ad.district,
        ad.postal_code,
        ci.city_id,
        ci.city,
        co.country_id,
        co.country,
        greatest(ad.last_update, ci.last_update, co.last_update) as latest_update,
        greatest(ad.etl_date, ci.etl_date, co.etl_date) as last_etl_date
    from address_data ad
    left join city_data ci on ci.city_id = ad.city_id
    left join country_data co on co.country_id = ci.country_id
),

final as ( 
    select
        {{ dbt_utils.generate_surrogate_key(['address_id']) }} as location_id,
        jd.address_id, 
        jd.address,
        jd.district,
        jd.postal_code,
        jd.city_id,
        jd.city,
        jd.country_id,
        jd.country,
        jd.latest_update,
        jd.last_etl_date
    from joined_data jd
)

select * from final 
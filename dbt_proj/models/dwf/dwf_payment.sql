-- models/dwh/dwf/dwf_payment.sql

{{
    config(
        materialized='table',
        unique_key=['payment_id']
    )
}}

with payment_data as (
    select
        p.payment_id,
        p.customer_id,
        p.staff_id,
        p.rental_id, 
        p.amount,
        case    
            when p.amount<2 then 'SMALL'
            when p.amount>=2 and p.amount<=5 then 'MEDIUM'
            when p.amount>5 then 'LARGE'
        end enhancement,
        p.payment_date, 
        case 
            when p.payment_date is not null and (p.rental_id is not null or p.customer_id is not null )
            then 'paid'
            else 'unpaid'
        end payment_status,
        p.etl_date as last_etl_date  
    from {{ ref('stg_payment') }} p
),
/*
-- Tarih Boyutundan date_key'i alıyoruz
date_data as (
    select
        date_key
    from {{ ref('dwd_date') }}
),
*/

final as (
    select
        pd.payment_id,
        pd.customer_id, 
        pd.staff_id,   
        pd.rental_id,   
        pd.amount,     
        pd.enhancement,
        pd.payment_status,
        pd.payment_date,
        pd.last_etl_date 
    from payment_data pd
    --left join date_data dd on cast(pd.payment_date as date) = dd.date_key
)

select * from final

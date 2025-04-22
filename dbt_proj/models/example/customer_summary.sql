-- customer_summary.sql

select 
    customer_id,
    first_name,
    last_name,
    email
from 
    {{ source('dvdrental', 'customer') }}  -- Dış kaynağı referans alıyoruz

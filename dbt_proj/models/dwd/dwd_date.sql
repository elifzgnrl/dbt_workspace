-- models/dwd/dwd_date.sql

{{
    config (
        materialized= 'table',
        unique_key= 'date_key'
    )
}}

with dates as (
    select
        cast(date_day as date) as date_key, -- Tarih anahtarı
        extract(day from date_day) as day_of_month, -- Ayın günü (sadece 'day' bazı sistemlerde rezerve kelime olabilir)
        extract(month from date_day) as month_number, -- Ayın numarası
        to_char(date_day, 'Month') as month_name, -- Ayın adı (Örn: April)
        extract(quarter from date_day) as quarter_number, -- Çeyrek numarası
        extract(year from date_day) as year_number, -- Yıl numarası
        to_char(date_day, 'Day') as day_name, -- Haftanın günü adı (Örn: Monday)
        extract(isodow from date_day) as day_of_week, -- Haftanın günü numarası (ISO: Pzt=1, Paz=7)
        case when extract(isodow from date_day) in (6, 7) then true else false end as is_weekend, -- Haftasonu mu?
        cast(date_day - interval '1 day' as date) as prior_date_key, -- Bir önceki gün
        cast(date_day + interval '1 day' as date) as next_date_key -- Bir sonraki gün
    from generate_series(
        '2000-01-01'::date, 
        '2030-12-31'::date, 
        interval '1 day'
    ) as date_day
)

select * from dates
{{ config(materialized='table') }}

SELECT

    event_date,

    category_group,

    CASE
        WHEN category_group='electronics'
        THEN 1
        ELSE 0
    END as is_treatment,

    CASE
        WHEN event_date >= DATE '2019-11-15'
        THEN 1
        ELSE 0
    END as is_post,

    total_sessions,

    purchase_sessions,

    CAST(purchase_sessions AS DOUBLE)
    / NULLIF(total_sessions,0)
    as session_conversion_rate

FROM {{ ref('int_daily_category_metrics') }}

WHERE category_group IN (
    'electronics',
    'appliances'
)
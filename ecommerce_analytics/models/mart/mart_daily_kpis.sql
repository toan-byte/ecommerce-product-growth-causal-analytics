{{ config(materialized='table') }}

SELECT

    event_date,

    total_sessions,

    total_users,

    total_views,

    total_carts,

    total_purchases,

    total_revenue,

    CAST(total_purchases AS DOUBLE)
    / NULLIF(total_sessions,0)
    as session_conversion_rate,

    total_revenue
    / NULLIF(total_purchases,0)
    as average_order_value

FROM {{ ref('int_daily_metrics') }}
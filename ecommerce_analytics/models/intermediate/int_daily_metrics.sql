{{ config(materialized='table') }}

SELECT
    CAST(event_timestamp AS DATE) as event_date,

    COUNT(DISTINCT session_id) as total_sessions,
    COUNT(DISTINCT user_id) as total_users,

    COUNT(
        CASE
            WHEN event_type='view'
            THEN 1
        END
    ) as total_views,

    COUNT(
        CASE
            WHEN event_type='cart'
            THEN 1
        END
    ) as total_carts,

    COUNT(
        CASE
            WHEN event_type='purchase'
            THEN 1
        END
    ) as total_purchases,

    SUM(
        CASE
            WHEN event_type='purchase'
            THEN price
            ELSE 0
        END
    ) as total_revenue

FROM {{ ref('stg_events') }}

GROUP BY 1
{{ config(materialized='table') }}

WITH session_events AS (

    SELECT
        session_id,
        user_id,
        event_timestamp,
        event_type,
        price
    FROM {{ ref('stg_events') }}

),

session_aggregates AS (

    SELECT
        session_id,
        user_id,

        MIN(event_timestamp) as session_start_at,
        MAX(event_timestamp) as session_end_at,

        COUNT(*) as total_event_count,

        SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END) as view_count,
        SUM(CASE WHEN event_type='cart' THEN 1 ELSE 0 END) as cart_count,
        SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END) as purchase_count,

        SUM(
            CASE
                WHEN event_type='purchase'
                THEN COALESCE(price,0)
                ELSE 0
            END
        ) as session_revenue

    FROM session_events
    GROUP BY 1,2

)

SELECT

    session_id,
    user_id,

    session_start_at,
    session_end_at,

    CAST(session_start_at AS DATE) as session_date,

    date_diff(
        'second',
        session_start_at,
        session_end_at
    ) as session_duration_seconds,

    total_event_count,

    view_count,
    cart_count,
    purchase_count,

    session_revenue,

    CASE
        WHEN purchase_count > 0 THEN 1
        ELSE 0
    END as is_purchase_converted,

    CASE
        WHEN purchase_count > 0 THEN 'purchase'
        WHEN cart_count > 0 THEN 'cart'
        WHEN view_count > 0 THEN 'view'
        ELSE 'unknown'
    END as funnel_stage

FROM session_aggregates
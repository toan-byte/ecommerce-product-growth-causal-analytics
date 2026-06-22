{{ config(materialized='table') }}

WITH daily_category_metrics AS (

    SELECT

        CAST(e.event_timestamp AS DATE) as event_date,

        p.category_group,

        COUNT(DISTINCT e.session_id) as total_sessions,

        COUNT(
            DISTINCT CASE
                WHEN e.event_type='cart'
                THEN e.session_id
            END
        ) as cart_sessions,

        COUNT(
            DISTINCT CASE
                WHEN e.event_type='purchase'
                THEN e.session_id
            END
        ) as purchase_sessions,

        ROUND(
            SUM(
                CASE
                    WHEN e.event_type='purchase'
                    THEN e.price
                    ELSE 0
                END
            ),
            2
        ) as revenue

    FROM {{ ref('stg_events') }} e

    INNER JOIN {{ ref('stg_products') }} p
        ON e.product_id = p.product_id

    WHERE p.category_group IN (
        'electronics',
        'beauty'
    )

    GROUP BY 1,2

)

SELECT

    event_date,

    category_group,

    CASE
        WHEN category_group='electronics'
        THEN 1
        ELSE 0
    END as is_treatment,

    CASE
        WHEN event_date >= '2019-11-15'
        THEN 1
        ELSE 0
    END as is_post,

    total_sessions,

    cart_sessions,

    purchase_sessions,

    revenue,

    CASE
        WHEN total_sessions = 0 THEN 0
        ELSE purchase_sessions * 1.0 / total_sessions
    END as session_conversion_rate,

    CASE
        WHEN cart_sessions = 0 THEN 0
        ELSE purchase_sessions * 1.0 / cart_sessions
    END as cart_to_purchase_cr

FROM daily_category_metrics
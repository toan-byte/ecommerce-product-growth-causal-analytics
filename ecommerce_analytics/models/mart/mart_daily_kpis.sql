{{ config(materialized='table') }}

SELECT

    CAST(event_timestamp AS DATE) as event_date,

    COUNT(DISTINCT session_id) as total_sessions,
    COUNT(DISTINCT user_id) as total_users,

    SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) as total_views,
    SUM(CASE WHEN event_type = 'cart' THEN 1 ELSE 0 END) as total_carts,
    SUM(CASE WHEN event_type = 'purchase' THEN 1 ELSE 0 END) as total_purchases,

    ROUND(
        SUM(
            CASE
                WHEN event_type='purchase'
                THEN COALESCE(price,0)
                ELSE 0
            END
        ),
        2
    ) as total_revenue,

    COUNT(
        DISTINCT CASE
            WHEN event_type='purchase'
            THEN session_id
        END
    ) as converted_sessions,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN event_type='purchase'
                THEN session_id
            END
        ) * 1.0
        /
        COUNT(DISTINCT session_id),
        4
    ) as session_conversion_rate,

    ROUND(
        SUM(
            CASE
                WHEN event_type='purchase'
                THEN COALESCE(price,0)
                ELSE 0
            END
        )
        /
        NULLIF(
            COUNT(
                DISTINCT CASE
                    WHEN event_type='purchase'
                    THEN session_id
                END
            ),
            0
        ),
        2
    ) as average_order_value

FROM {{ ref('stg_events') }}

GROUP BY 1
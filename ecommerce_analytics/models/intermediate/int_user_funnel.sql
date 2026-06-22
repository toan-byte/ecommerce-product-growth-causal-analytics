{{ config(materialized='table') }}

SELECT

    user_id,

    SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END) as total_views,

    SUM(CASE WHEN event_type='cart' THEN 1 ELSE 0 END) as total_carts,

    SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END) as total_purchases,

    SUM(
        CASE
            WHEN event_type='purchase'
            THEN COALESCE(price,0)
            ELSE 0
        END
    ) as total_revenue,

    CASE
        WHEN SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END) > 0
        THEN 1 ELSE 0
    END as has_viewed,

    CASE
        WHEN SUM(CASE WHEN event_type='cart' THEN 1 ELSE 0 END) > 0
        THEN 1 ELSE 0
    END as has_carted,

    CASE
        WHEN SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END) > 0
        THEN 1 ELSE 0
    END as has_purchased,

    CASE
        WHEN SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END) > 0
        THEN 1 ELSE 0
    END as is_converted,

    CASE
        WHEN SUM(CASE WHEN event_type='purchase' THEN 1 ELSE 0 END) > 0
            THEN 'Purchased'
        WHEN SUM(CASE WHEN event_type='cart' THEN 1 ELSE 0 END) > 0
            THEN 'Cart Abandoner'
        WHEN SUM(CASE WHEN event_type='view' THEN 1 ELSE 0 END) > 0
            THEN 'Viewer Only'
        ELSE 'Unknown'
    END as user_final_stage

FROM {{ ref('stg_events') }}

GROUP BY 1
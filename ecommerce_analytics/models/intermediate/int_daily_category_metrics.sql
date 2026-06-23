{{ config(materialized='table') }}

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
    ) as purchase_sessions

FROM {{ ref('stg_events') }} e

INNER JOIN {{ ref('stg_products') }} p
ON e.product_id = p.product_id

GROUP BY 1,2
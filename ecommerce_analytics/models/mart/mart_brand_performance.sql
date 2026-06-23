{{ config(materialized='table') }}

SELECT
    p.brand,
    COUNT(*) as purchases,
    SUM(e.price) as revenue
FROM {{ ref('stg_events') }} e
JOIN {{ ref('stg_products') }} p
ON e.product_id = p.product_id
WHERE e.event_type='purchase'
AND p.brand != 'unknown'
GROUP BY 1
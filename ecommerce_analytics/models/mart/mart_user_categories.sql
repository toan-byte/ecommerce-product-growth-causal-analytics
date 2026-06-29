-- dbt_project/models/marts/mart_user_categories.sql
{{ config(materialized='table') }}

SELECT DISTINCT
    e.user_id,
    p.category_group
FROM {{ ref('stg_events') }} e
INNER JOIN {{ ref('stg_products') }} p ON e.product_id = p.product_id
WHERE e.event_type = 'purchase' 
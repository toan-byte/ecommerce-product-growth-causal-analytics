{{ config(materialized='table') }}

WITH funnel AS (

    SELECT

        COUNT(DISTINCT CASE WHEN has_viewed = 1 THEN user_id END) as viewed_users,

        COUNT(DISTINCT CASE WHEN has_carted = 1 THEN user_id END) as carted_users,

        COUNT(DISTINCT CASE WHEN has_purchased = 1 THEN user_id END) as purchased_users

    FROM {{ ref('int_user_funnel') }}

)

SELECT
    'View' as stage_name,
    viewed_users as user_count,
    1.0 as conversion_rate
FROM funnel

UNION ALL

SELECT
    'Cart',
    carted_users,
    ROUND(carted_users * 1.0 / viewed_users, 4)
FROM funnel

UNION ALL

SELECT
    'Purchase',
    purchased_users,
    ROUND(purchased_users * 1.0 / viewed_users, 4)
FROM funnel
{{ config(materialized='table') }}

WITH user_first_active AS (

    SELECT
        user_id,
        date_trunc('week', first_active_at) as cohort_week

    FROM {{ ref('stg_users') }}

),

user_activity AS (

    SELECT DISTINCT

        user_id,

        date_trunc(
            'week',
            event_timestamp
        ) as active_week,

        MAX(
            CASE
                WHEN event_type='purchase'
                THEN 1
                ELSE 0
            END
        ) as is_purchase_active

    FROM {{ ref('stg_events') }}

    GROUP BY 1,2

)

SELECT

    a.user_id,

    c.cohort_week,

    a.active_week,

    date_diff(
        'week',
        CAST(c.cohort_week AS DATE),
        CAST(a.active_week AS DATE)
    ) as cohort_index,

    a.is_purchase_active

FROM user_activity a

INNER JOIN user_first_active c
    ON a.user_id = c.user_id

WHERE a.active_week >= c.cohort_week
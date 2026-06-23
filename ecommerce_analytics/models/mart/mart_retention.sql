-- models/marts/mart_retention.sql

{{ config(materialized='table') }}

WITH cohort_size AS (

    SELECT
        cohort_week,
        COUNT(DISTINCT user_id) as cohort_users

    FROM {{ ref('int_retention') }}

    WHERE cohort_index = 0

    GROUP BY 1

),

retention_metrics AS (

    SELECT

        cohort_week,

        cohort_index,

        COUNT(DISTINCT user_id) as active_users

    FROM {{ ref('int_retention') }}

    GROUP BY 1,2

)

SELECT

    r.cohort_week,

    r.cohort_index,

    c.cohort_users,

    r.active_users,

    ROUND(
        CAST(r.active_users AS DOUBLE)
        / c.cohort_users,
        4
    ) as retention_rate

FROM retention_metrics r

INNER JOIN cohort_size c
ON r.cohort_week = c.cohort_week

ORDER BY
    r.cohort_week,
    r.cohort_index
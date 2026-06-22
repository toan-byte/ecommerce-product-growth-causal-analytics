{{ config(materialized='table') }}

WITH base_cohort AS (

    SELECT

        cohort_date,

        COUNT(DISTINCT user_id) as cohort_size

    FROM {{ ref('int_retention') }}

    WHERE days_since_first_active = 0

    GROUP BY 1

),

retention_by_day AS (

    SELECT

        cohort_date,

        days_since_first_active,

        COUNT(DISTINCT user_id) as active_users

    FROM {{ ref('int_retention') }}

    GROUP BY 1,2

)

SELECT

    r.cohort_date,

    c.cohort_size,

    r.days_since_first_active,

    r.active_users,

    ROUND(
        r.active_users * 1.0
        / c.cohort_size,
        4
    ) as retention_rate

FROM retention_by_day r

INNER JOIN base_cohort c
    ON r.cohort_date = c.cohort_date

WHERE r.days_since_first_active BETWEEN 0 AND 30
-- models/intermediate/int_rfm.sql

{{ config(materialized='table') }}

WITH user_purchase_metrics AS (

    SELECT

        user_id,

        date_diff(
            'day',
            MAX(event_timestamp),
            CAST('2019-12-01 00:00:00' AS TIMESTAMP)
        ) as recency_days,

        COUNT(*) as total_orders,

        COUNT(DISTINCT session_id) as frequency,

        ROUND(
            SUM(price),
            2
        ) as monetary

    FROM {{ ref('stg_events') }}

    WHERE event_type = 'purchase'

    GROUP BY 1

),

rfm_scores AS (
    
    SELECT

    *,

    6 - ntile(5) OVER (
        ORDER BY recency_days ASC
    ) as r_score,

    ntile(5) OVER (
        ORDER BY frequency ASC
    ) as f_score,

    ntile(5) OVER (
        ORDER BY monetary ASC
    ) as m_score

FROM user_purchase_metrics
)

SELECT

    user_id,

    recency_days,

    total_orders,

    frequency,

    monetary,

    r_score,

    f_score,

    m_score,

    (r_score + f_score + m_score) as rfm_score,

    CONCAT(
        CAST(r_score AS VARCHAR),
        CAST(f_score AS VARCHAR),
        CAST(m_score AS VARCHAR)
    ) as rfm_cell

FROM rfm_scores
{{ config(materialized='table') }}

SELECT

    user_id,
    recency_days,
    frequency,
    monetary,

    r_score,
    f_score,
    m_score,

    rfm_cell,

    CASE

        -- Best Customers
        WHEN r_score >= 4
         AND f_score >= 4
         AND m_score >= 4
        THEN 'Champions'

        -- Strong repeat customers
        WHEN r_score >= 3
         AND f_score >= 3
         AND m_score >= 3
        THEN 'Loyal Customers'

        -- Recently acquired
        WHEN r_score >= 4
         AND f_score <= 2
        THEN 'New Customers'

        -- Previously valuable, now inactive
        WHEN r_score <= 2
         AND f_score >= 3
         AND m_score >= 3
        THEN 'At Risk'

        -- Starting to disengage
        WHEN r_score = 3
         AND f_score <= 2
        THEN 'About To Sleep'

        -- Low recency + low frequency
        WHEN r_score <= 2
         AND f_score <= 2
        THEN 'Lost Customers'

        ELSE 'Needs Attention'

    END as customer_segment

FROM {{ ref('int_rfm') }}
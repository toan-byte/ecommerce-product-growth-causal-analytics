-- dbt_project/models/staging/stg_events.sql
{{ config(materialized='view') }}

WITH base_data AS (
    SELECT
        md5(concat_ws('-', 
            COALESCE(CAST(event_time AS VARCHAR), ''), 
            COALESCE(event_type, ''), 
            COALESCE(CAST(user_id AS VARCHAR), ''), 
            COALESCE(CAST(product_id AS VARCHAR), ''), 
            COALESCE(user_session, ''),
            COALESCE(CAST(price AS VARCHAR), ''),
            COALESCE(CAST(category_id AS VARCHAR), '')
        )) as event_id,
        CAST(event_time AS TIMESTAMP) as event_timestamp,
        event_type,
        product_id,
        user_id,
        user_session as session_id,
        CAST(price AS DOUBLE) as price
    FROM {{ source('raw_source', 'events') }}
    WHERE user_id IS NOT NULL 
      AND user_session IS NOT NULL
),

deduped_events AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY event_id 
               ORDER BY event_timestamp ASC
           ) as row_num
    FROM base_data
),

session_velocity AS (
    SELECT 
        session_id,
        date_trunc('minute', event_timestamp) as minute_bucket,
        COUNT(*) as event_count
    FROM deduped_events
    GROUP BY 1, 2
),

bot_threshold AS (
    SELECT 
        quantile_cont(event_count, 0.99) as p99_threshold
    FROM session_velocity
),

bot_sessions AS (
    SELECT DISTINCT session_id
    FROM session_velocity
    WHERE event_count > (SELECT p99_threshold FROM bot_threshold)
      AND event_count > 150 
)

SELECT 
    e.event_id,
    e.event_timestamp,
    e.event_type,
    e.product_id,
    e.user_id,
    e.session_id,
    e.price
FROM deduped_events e
LEFT JOIN bot_sessions b ON e.session_id = b.session_id
WHERE e.row_num = 1
  AND b.session_id IS NULL
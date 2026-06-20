-- dbt_project/models/staging/stg_users.sql
{{ config(materialized='view') }}

SELECT
    user_id,
    MIN(CAST(event_time AS TIMESTAMP)) as first_active_at,
    MAX(CAST(event_time AS TIMESTAMP)) as last_active_at,
    COUNT(*) as total_events,
    COUNT(DISTINCT user_session) as total_sessions
FROM {{ source('raw_source', 'events') }}
WHERE user_id IS NOT NULL
GROUP BY user_id
-- dbt_project/models/staging/stg_products.sql
{{ config(materialized='view') }}

WITH product_prices AS (
    SELECT 
        product_id,
        category_id,
        category_code,
        LOWER(TRIM(COALESCE(brand, 'unknown'))) as brand,
        CAST(price AS DOUBLE) as price,
        CAST(event_time AS TIMESTAMP) as event_timestamp,
        -- Lấy dòng dữ liệu mới nhất của sản phẩm để lấy giá bán hiện tại
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY CAST(event_time AS TIMESTAMP) DESC
        ) as row_num
    FROM {{ source('raw_source', 'events') }}
    WHERE product_id IS NOT NULL
)

SELECT 
    product_id,
    category_id,
    brand,
    COALESCE(category_code, 'unknown') as category_full_path,
    split_part(category_code, '.', 1) as category_group,
    split_part(category_code, '.', 2) as category_sub_group,
    price as latest_price
FROM product_prices
WHERE row_num = 1
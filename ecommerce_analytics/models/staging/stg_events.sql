select
    cast(event_time as timestamp) as event_timestamp,
    event_type,
    product_id,
    category_id,
    category_code,
    brand,
    price,
    user_id,
    user_session
from events
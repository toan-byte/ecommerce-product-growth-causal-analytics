from pathlib import Path
import duckdb

Path("data/warehouse").mkdir(
    parents=True,
    exist_ok=True
)

con = duckdb.connect(
    "data/warehouse/ecommerce.duckdb"
)

print("Loading parquet into DuckDB...")

con.execute("""
CREATE OR REPLACE TABLE events AS
SELECT *
FROM read_parquet(
'data/parquet/log_tracking.parquet'
)
""")

rows = con.execute("""
SELECT COUNT(*)
FROM events
""").fetchone()[0]

print(f"Rows: {rows:,}")

con.close()
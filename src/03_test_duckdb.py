import duckdb

con = duckdb.connect(
    "data/warehouse/ecommerce.duckdb"
)

print(
    con.execute("""
    SELECT event_type,
           COUNT(*)
    FROM events
    GROUP BY 1
    """).fetchdf()
)
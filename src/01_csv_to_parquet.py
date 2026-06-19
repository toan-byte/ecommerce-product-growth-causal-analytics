from pathlib import Path
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
from tqdm import tqdm

INPUT_FILE = "data/raw/01-log-tracking.csv"
OUTPUT_FILE = "data/parquet/log_tracking.parquet"

Path("data/parquet").mkdir(parents=True, exist_ok=True)

chunksize = 1_000_000

writer = None

for chunk in tqdm(
    pd.read_csv(
        INPUT_FILE,
        chunksize=chunksize
    )
):

    # tối ưu datatype
    chunk["event_type"] = chunk["event_type"].astype("category")
    chunk["brand"] = chunk["brand"].astype("string")
    chunk["category_code"] = chunk["category_code"].astype("string")
    chunk["category_id"] = chunk["category_id"].astype("string")

    table = pa.Table.from_pandas(
        chunk,
        preserve_index=False
    )

    if writer is None:
        writer = pq.ParquetWriter(
            OUTPUT_FILE,
            table.schema,
            compression="snappy"
        )

    writer.write_table(table)

if writer:
    writer.close()

print("Parquet conversion completed.")
import gdown
from pathlib import Path

Path("data/raw").mkdir(parents=True, exist_ok=True)

FILE_ID = "1N744AnNIz7GNkfBNqMAk5zru7svIWn12"

url = f"https://drive.google.com/uc?id={FILE_ID}"

gdown.download(
    url,
    "data/raw/01-log-tracking.csv",
    quiet=False
)

print("Download completed.")
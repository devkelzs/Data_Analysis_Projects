from pathlib import Path
import pandas as pd 

folder = Path(r"C:\Users\we\Downloads")

files = sorted(folder.glob("yellow_tripdata_2025-*.parquet"))

print("Files found:", len(files))

for file in files:
    print("Processing:", file.name)

    df = pd.read_parquet(file)

    output_file = file.with_suffix(".csv")
    df.to_csv(output_file, index=False)
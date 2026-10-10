# Data Source and Dataset Documentation

## 1. Project Dataset

**Project:** NYC Yellow Taxi Analytics — 2025

**Dataset:** NYC Yellow Taxi Trip Records

**Data Provider:** New York City Taxi and Limousine Commission (NYC TLC)

**Official Data Source:** https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

**Analysis Period:** January 1, 2025 – December 31, 2025

**File Format:** Parquet (original format), converted to CSV for SQL Server ingestion

**Database Platform:** Microsoft SQL Server 2025 Express Edition

## 2. Dataset Description

The NYC Yellow Taxi Trip Records dataset contains trip-level records for yellow taxi journeys in New York City.

Each record generally represents a reported taxi trip and includes information about pickup and drop-off times, trip distance, location identifiers, passenger counts, fare amounts, tips, tolls, surcharges, payment types, and other trip-related attributes.

The dataset is suitable for analyzing taxi demand patterns, trip characteristics, fare-related metrics, geographic activity, and operational trends.

The data reflects the information recorded in the trip records. It should not automatically be interpreted as a complete representation of all taxi activity or as a direct measure of company profit.

## 3. Data Files Used

The project uses the 12 monthly Yellow Taxi Trip Records files for 2025:

- January 2025
- February 2025
- March 2025
- April 2025
- May 2025
- June 2025
- July 2025
- August 2025
- September 2025
- October 2025
- November 2025
- December 2025

The original monthly files were downloaded from the official NYC TLC website. The Parquet files were converted to CSV and imported into SQL Server for analysis.

The monthly data was stored in separate SQL tables and combined into an annual dataset after import and validation.

**Annual table:** `raw.yellow_tripdata_2025`

**Monthly tables:** `raw.yellow_tripdata_2025_01` through `raw.yellow_tripdata_2025_12`

## 4. Supplementary Data

### Taxi Zone Lookup Table

**Source:** NYC Taxi and Limousine Commission

**Official Data Source:** https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

The Taxi Zone Lookup Table provides descriptive information about taxi location identifiers, including location names, boroughs, and service zones.

It can be joined to the trip records using:

- `PULocationID` for pickup locations
- `DOLocationID` for drop-off locations

This lookup allows the analysis to identify popular pickup and drop-off zones and compare trip activity across boroughs and geographic areas.

The lookup table should be downloaded from the official source and its actual column names verified before joining it to the trip data.

## 5. Important Dataset Fields

The trip records include fields such as:

| Field | Description |
|---|---|
| `VendorID` | Identifier for the technology provider that supplied the trip record |
| `tpep_pickup_datetime` | Date and time the trip started |
| `tpep_dropoff_datetime` | Date and time the trip ended |
| `passenger_count` | Recorded number of passengers |
| `trip_distance` | Recorded trip distance |
| `PULocationID` | Pickup taxi-zone identifier |
| `DOLocationID` | Drop-off taxi-zone identifier |
| `fare_amount` | Metered fare amount |
| `tip_amount` | Recorded tip amount |
| `tolls_amount` | Recorded toll charges |
| `total_amount` | Total recorded trip charges, subject to the dataset's field definitions |
| `payment_type` | Encoded payment method |

The monthly files may include additional fields. The actual schema and data dictionary should be checked against the files used in this project.

## 6. Data Preparation

The following preparation steps were performed or planned as part of the project:

1. Downloaded the 2025 monthly Yellow Taxi Trip Records from the official NYC TLC website.
2. Converted the monthly Parquet files to CSV using Python and pandas.
3. Imported the monthly CSV files into Microsoft SQL Server.
4. Stored the monthly tables in the `raw` schema.
5. Planned to combine the monthly tables into a single annual table.
6. Planned to profile and validate the data before performing cleaning and business analysis.
7. Planned to create SQL views for the final Power BI analysis.

Cleaning decisions, data-quality findings, and transformations will be documented in the SQL scripts and project report.

## 7. Data Quality Considerations

Potential data-quality issues to investigate include:

- Missing passenger counts or rate codes
- Missing or invalid pickup and drop-off timestamps
- Zero or negative trip distances
- Zero or negative fare amounts
- Unusually long or short trip durations
- Duplicate or potentially duplicated records
- Invalid or unmatched taxi-zone identifiers
- Differences in column types or missing fields between monthly files

Missing values and unusual records should be investigated before deciding whether to exclude, retain, or transform them. Not every unusual record is necessarily invalid.

## 8. Limitations

- The records describe reported yellow taxi trips, not every form of transportation in New York City.
- Missing or inaccurate values may affect some metrics.
- Trip records alone do not establish why demand changes or prove that one factor caused another.
- Fare and charge fields should not be treated as net profit or driver earnings without additional cost and accounting information.
- Geographic analysis depends on the completeness and accuracy of the taxi-zone lookup.
- Findings are limited to the 2025 period and may not represent other years.

## 9. Reproducibility and Attribution

The original data is provided by the New York City Taxi and Limousine Commission.

Anyone reproducing this project should obtain the relevant 2025 monthly files and Taxi Zone Lookup Table from the official NYC TLC website and review any applicable data-use terms.

The raw CSV and Parquet files are not included in this repository because of their size. The SQL scripts, documentation, and Power BI report are intended to explain the analysis workflow and support reproducibility.

**Official source:** https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page
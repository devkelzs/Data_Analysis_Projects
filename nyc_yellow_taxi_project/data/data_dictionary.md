# Data Dictionary — NYC Yellow Taxi Analytics 2025

## 1. Dataset Overview

This project analyzes New York City Yellow Taxi trip records for January through December 2025. The dataset contains information about trip times, passenger counts, distances, fare amounts, additional charges, payment methods, and pickup and drop-off locations.

**Source:** NYC Taxi and Limousine Commission (TLC)

**Official data page:** https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

## 2. Column Definitions

| Column | Description | Data Type | Analytical Use |
|---|---|---|---|
| `VendorID` | Identifier for the technology provider that recorded the trip | Integer | Compare records by vendor |
| `tpep_pickup_datetime` | Date and time the meter was engaged | Datetime | Analyze demand by hour, day, month, and season |
| `tpep_dropoff_datetime` | Date and time the meter was disengaged | Datetime | Calculate trip duration |
| `passenger_count` | Number of passengers recorded for the trip | Numeric | Examine passenger-count patterns |
| `trip_distance` | Trip distance reported by the taximeter | Numeric | Analyze trip length |
| `RatecodeID` | Rate code in effect at the end of the trip | Numeric | Compare trips by rate category |
| `store_and_fwd_flag` | Indicates whether the trip record was held before being sent to the vendor | Text | Examine record-transmission patterns |
| `PULocationID` | TLC Taxi Zone ID for the pickup location | Integer | Analyze pickup demand by zone |
| `DOLocationID` | TLC Taxi Zone ID for the drop-off location | Integer | Analyze destination patterns |
| `payment_type` | Code representing the payment method | Integer | Analyze payment-method distribution |
| `fare_amount` | Time-and-distance fare calculated by the meter | Numeric | Analyze base fares |
| `extra` | Miscellaneous extras and surcharges | Numeric | Examine additional charges |
| `mta_tax` | MTA tax recorded for the trip | Numeric | Analyze recorded tax charges |
| `tip_amount` | Tip amount recorded for the trip | Numeric | Analyze recorded tips |
| `tolls_amount` | Total toll charges recorded for the trip | Numeric | Analyze toll-related charges |
| `improvement_surcharge` | Improvement surcharge recorded for the trip | Numeric | Examine additional charges |
| `total_amount` | Total amount charged to passengers, including recorded fares and applicable charges | Numeric | Analyze recorded trip totals |
| `congestion_surcharge` | Congestion surcharge recorded for the trip | Numeric | Examine congestion-related charges |
| `Airport_fee` | Airport-related fee recorded for the trip | Numeric | Analyze airport-related trips and charges |
| `cbd_congestion_fee` | Central Business District congestion fee recorded for the trip | Numeric | Analyze recorded CBD congestion fees |

*Note: Confirm the column definitions and code values against the TLC documentation for the 2025 data before finalizing this file.*

## 3. Derived Analytical Fields

The following fields may be created during analysis. They are not necessarily present in the original raw files.

| Derived Field | Description | Purpose |
|---|---|---|
| `trip_duration_minutes` | Difference between pickup and drop-off timestamps, in minutes | Analyze trip duration |
| `pickup_date` | Date extracted from pickup datetime | Daily trend analysis |
| `pickup_hour` | Hour extracted from pickup datetime | Hourly demand analysis |
| `pickup_day_of_week` | Day of week derived from pickup datetime | Weekday versus weekend analysis |
| `pickup_month` | Month extracted from pickup datetime | Monthly trends |
| `pickup_year` | Year extracted from pickup datetime | Time-based comparisons |
| `fare_per_mile` | Fare amount divided by trip distance when distance is valid and greater than zero | Compare fare patterns by distance |
| `tip_percentage` | Tip amount expressed as a percentage of an explicitly defined fare or charge base | Analyze tipping patterns |

## 4. Data Quality Considerations

The following checks should be considered during data profiling and cleaning:

- Missing values in important fields, including timestamps, location IDs, trip distance, and monetary amounts.
- Trips with drop-off timestamps earlier than pickup timestamps.
- Zero or negative trip distances.
- Zero or negative trip durations.
- Unusually long trips or unusually high distances and charges.
- Negative fare or total amounts, which may represent adjustments or reversals rather than automatically invalid records.
- Passenger counts that are missing, zero, or otherwise unusual.
- Duplicate records.
- Changes in column availability or schema across monthly files.

Do not remove unusual records automatically. Investigate them first and document the rules used to retain, flag, or exclude records.

## 5. Location Lookup Data

The project may use the TLC Taxi Zone lookup table to translate `PULocationID` and `DOLocationID` into readable zone names, boroughs, and service-zone descriptions.

The lookup data should be documented separately, including its source and the fields used in joins.

## 6. Important Limitations

- Taxi-zone IDs represent designated zones, not necessarily exact street addresses.
- Recorded trip totals should not be treated as company profit or driver earnings.
- Recorded tip amounts may not represent every form of tipping.
- Missing or unusual values may affect analysis results.
- Findings describe patterns in the available records and do not, by themselves, establish causation.

## 7. Maintenance

Update this dictionary whenever new fields are created, existing fields are transformed, or data-cleaning rules change. Clearly distinguish original source columns from derived analytical fields.
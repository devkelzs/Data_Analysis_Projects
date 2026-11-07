# Data Quality Rules — NYC Yellow Taxi Analytics 2025

## 1. Purpose

This document defines the data quality rules used in the NYC Yellow Taxi Analytics 2025 project. The rules were established through profiling of `raw.vw_yellow_tripdata_2025`, which combines the twelve monthly NYC Yellow Taxi trip tables.

### Dataset overview

- **Dataset:** NYC Yellow Taxi Trip Records — 2025
- **Source view:** `raw.vw_yellow_tripdata_2025`
- **Clean analytical view:** `analytics.vw_yellow_tripdata_2025_clean`
- **Profiled dataset size:** 48,722,602 records
- **Reporting period:** January 1, 2025, through December 31, 2025
- **Approach:** Preserve source records and values while exposing potential data quality issues through flags and derived columns.

### General implementation principles

1. Do not modify the raw source tables or source view.
2. Preserve original source values in the clean analytical view.
3. Use binary flags consistently: `1` means the defined condition is detected; `0` means it is not detected.
4. Keep missing-value checks separate from validity checks.
5. Do not automatically delete every flagged record. Some flagged values may be legitimate or may require investigation.
6. SQL `NULL`, zero, undocumented codes, and documented codes such as `RatecodeID = 99` are different conditions.
7. A profiling result is not automatically a formal validation result. Validation status should reflect checks actually executed.
8. The clean analytical view is a non-destructive transformation layer. It adds labels, flags, and derived fields without automatically removing source records.

---

## 2. DQR-001: Payment Type Code Validity

- **Column:** `payment_type`
- **Data quality dimension:** Validity
- **Quality flag:** `InvalidPaymentTypeFlag`

### Rule definition

Valid payment type codes are:

| Code | Description |
|---:|---|
| 0 | Flex Fare |
| 1 | Credit card |
| 2 | Cash |
| 3 | No charge |
| 4 | Dispute |
| 5 | Unknown |
| 6 | Voided trip |

Flag a non-`NULL` value if it is outside `{0, 1, 2, 3, 4, 5, 6}`.

### Profiling and validation findings

- Total records: 48,722,602.
- SQL `NULL` values: 0.
- Initial profiling observed codes `0`, `1`, `2`, `3`, `4`, and `5`.
- Code `6` is included in the accepted code list.

The formal validation previously reported **0 invalid payment type records**.

### Flag interpretation

- `1` = A non-`NULL` payment type outside the accepted code list is detected.
- `0` = No invalid payment type is detected.

### Handling approach

Preserve the original code. Investigate any unexpected values against the relevant NYC TLC documentation before deciding how they should be handled.

### Derived label

The view includes `PaymentTypeName` to provide a readable description of the payment type.

---

## 3. DQR-002: RatecodeID Validity

- **Column:** `RatecodeID`
- **Data quality dimension:** Validity
- **Quality flag:** `InvalidRateCodeIdFlag`
- **Missing-value flag:** `IsMissing_RatecodeID`

### Rule definition

The accepted codes are:

| Code | Description |
|---:|---|
| 1 | Standard rate |
| 2 | JFK |
| 3 | Newark |
| 4 | Nassau or Westchester |
| 5 | Negotiated fare |
| 6 | Group ride |
| 99 | Null/unknown |

Flag any non-`NULL` value outside `{1, 2, 3, 4, 5, 6, 99}`.

SQL `NULL` values are handled separately by the missing-value flag. The documented code `99` must not be treated as SQL `NULL`.

### Profiling and validation findings

- Total records: 48,722,602.
- SQL `NULL` values: 11,611,894.
- Records with `RatecodeID = 99`: 804,397.
- Initial profiling observed codes `1`, `2`, `3`, `4`, `5`, `6`, and `99`.
- Formal validation reported **0 invalid rate code records**.

### Flag interpretation

- `InvalidRateCodeIdFlag = 1`: A non-`NULL` value outside the accepted code list is detected.
- `InvalidRateCodeIdFlag = 0`: No invalid rate code is detected.
- `IsMissing_RatecodeID = 1`: `RatecodeID` is SQL `NULL`.
- `IsMissing_RatecodeID = 0`: `RatecodeID` is present.

### Derived label

The view includes `RatecodeDescription` to make the code easier to interpret.

### Handling approach

Preserve the original code. Do not replace code `99` with SQL `NULL` or automatically remove records with missing rate codes.

---

## 4. DQR-003: VendorID Validity

- **Column:** `VendorID`
- **Data quality dimension:** Validity
- **Quality flag:** `InvalidVendorIDFlag`

### Rule definition

The accepted vendor codes are:

| Code | Vendor |
|---:|---|
| 1 | Creative Mobile Technologies, LLC |
| 2 | Curb Mobility, LLC |
| 6 | Myle Technologies Inc. |
| 7 | Helix |

Flag any non-`NULL` value outside `{1, 2, 6, 7}`.

### Profiling and validation findings

- Total records: 48,722,602.
- SQL `NULL` values: 0.
- Initial profiling observed vendor codes `1`, `2`, `6`, and `7`.
- Formal validation reported **0 invalid vendor records**.

### Flag interpretation

- `1` = A non-`NULL` vendor code outside the accepted list is detected.
- `0` = No invalid vendor code is detected.

### Derived label

The view includes `VendorName` to provide a readable vendor description.

### Handling approach

Preserve the original vendor code. Do not classify a vendor as invalid simply because it has fewer records than other vendors.

---

## 5. DQR-004: Trip Timestamp Validity

- **Columns:** `tpep_pickup_datetime`, `tpep_dropoff_datetime`
- **Data quality dimension:** Validity
- **Quality flag:** `TripTimestampQualityFlag`
- **Derived column:** `TripDurationMinutes`

### Rule definition

A trip's drop-off timestamp should not precede its pickup timestamp.

Flag a record when:

`tpep_dropoff_datetime < tpep_pickup_datetime`

### Profiling and validation findings

- Total records: 48,722,602.
- Missing pickup timestamps: 0.
- Missing drop-off timestamps: 0.
- Records where drop-off precedes pickup: 2,235.
- The quality flag was validated, with **2,235 records flagged**.

### Flag interpretation

- `1` = Drop-off precedes pickup.
- `0` = Drop-off does not precede pickup.

### Derived duration handling

The view calculates `TripDurationMinutes` using SQL Server's `DATEDIFF` function. If the drop-off timestamp precedes the pickup timestamp, the derived duration is set to SQL `NULL` rather than a negative value.

`DATEDIFF(MINUTE, ...)` counts minute boundaries crossed; it does not calculate fractional elapsed minutes.

### Handling approach

Preserve both original timestamps and all source records. Exclude invalid timestamp records from trip-duration analysis where appropriate, rather than deleting them from the clean analytical view.

---

## 6. DQR-005: Trip Distance Quality

- **Column:** `trip_distance`
- **Data quality dimension:** Validity and anomaly detection
- **Quality flag:** `TripDistanceQualityFlag`

### Rule definition

Flag a record if either condition is true:

- `trip_distance <= 0`
- `trip_distance > 100`

The 100-mile threshold is a project-defined screening threshold, not an official NYC TLC validity limit.

### Profiling and validation findings

- Total records: 48,722,602.
- Negative distances: 0.
- Zero distances: 1,402,958.
- Distances greater than 100 miles: 2,870.
- Missing distances: 0.
- Maximum observed distance: 397,994.37 miles.
- The combined quality flag returned **1,405,828 flagged records**, matching the sum of zero-distance and over-100-mile records.

### Flag interpretation

- `1` = Distance is zero, negative, or greater than 100 miles.
- `0` = None of those conditions is detected.

### Handling approach

Preserve original distance values. Investigate flagged records before deciding whether to exclude them from a particular analysis. Zero distance may occur in unusual but explainable situations, so the flag alone does not prove that a record is erroneous.

---

## 7. DQR-006: Monetary Value Quality

- **Columns:** `fare_amount`, `total_amount`, `tip_amount`, `Airport_fee`, `mta_tax`, `extra`, `tolls_amount`, `improvement_surcharge`, `congestion_surcharge`, `cbd_congestion_fee`
- **Data quality dimension:** Validity and anomaly detection

### Rule A: Negative monetary values

Each monetary column has its own negative-value flag in the clean analytical view.

| Source column | Quality flag |
|---|---|
| `fare_amount` | `fare_amount_negative_flag` |
| `total_amount` | `total_amount_negative_flag` |
| `tip_amount` | `tip_amount_negative_flag` |
| `Airport_fee` | `Airport_fee_negative_flag` |
| `mta_tax` | `mta_tax_negative_flag` |
| `extra` | `extra_negative_flag` |
| `tolls_amount` | `tolls_amount_negative_flag` |
| `improvement_surcharge` | `improvement_surcharge_negative_flag` |
| `congestion_surcharge` | `congestion_surcharge_negative_flag` |
| `cbd_congestion_fee` | `cbd_congestion_fee_negative_flag` |

### Rule definition

For each listed column, set its flag to `1` when the value is below zero; otherwise set it to `0`.

### Profiling findings

The initial profiling reported the following negative-value counts:

| Source column | Negative values |
|---|---:|
| `fare_amount` | 2,848,620 |
| `total_amount` | 414,216 |
| `tip_amount` | 762,381 |
| `Airport_fee` | 1,693 |
| `mta_tax` | 72,894 |
| `extra` | 804,443 |
| `tolls_amount` | 973,721 |
| `improvement_surcharge` | 635,917 |
| `congestion_surcharge` | 166,785 |
| `cbd_congestion_fee` | 509,663 |

These counts may overlap because a single record can contain negative values in multiple monetary columns.

Negative values are treated as review signals rather than automatic proof of bad data. Refunds, adjustments, and other unusual trip circumstances may need to be considered.

### Rule B: Zero fare and zero total

| Source column | Quality flag |
|---|---|
| `fare_amount` | `fare_amount_zero_flag` |
| `total_amount` | `total_amount_zero_flag` |

Set the corresponding flag to `1` when the source value equals zero; otherwise set it to `0`.

Initial profiling found:

- `fare_amount = 0`: 21,614 records.
- `total_amount = 0`: 6,801 records.

Zero tips, tolls, taxes, and surcharges do not trigger these two zero-value flags unless the fare or total itself is zero.

### Missing-value treatment

SQL `NULL` values must not be treated as zero or as negative values. Missingness is assessed separately.

### Handling approach

Preserve original monetary values and records. Investigate flagged values and apply analysis-specific exclusions only when justified. The view intentionally keeps separate monetary flags so analysts can identify the specific field that triggered a condition.

---

## 8. DQR-007: Passenger Count Quality

- **Column:** `passenger_count`
- **Data quality dimensions:** Completeness and validity
- **Quality flag:** `ZeroPassengerCountFlag`
- **Missing-value flag:** `IsMissing_PassengerCount`

### Rule A: Zero passenger count

Set `ZeroPassengerCountFlag` to `1` when `passenger_count = 0`; otherwise set it to `0`.

### Rule B: Missing passenger count

Set `IsMissing_PassengerCount` to `1` when `passenger_count IS NULL`; otherwise set it to `0`.

### Profiling findings

- Total records: 48,722,602.
- SQL `NULL` values: 11,611,894.
- Records with `passenger_count = 0`: 260,062.
- Observed non-`NULL` values ranged from 0 to 9.

### Handling approach

Keep zero and missing values separate. Preserve source records and values. Do not automatically replace missing passenger counts with zero or delete records with zero or missing passenger counts.

---

## 9. DQR-008: Missing Rate, Store-and-Forward, and Surcharge Values

- **Data quality dimension:** Completeness

### Columns and missing-value flags

| Source column | Missing-value flag |
|---|---|
| `RatecodeID` | `IsMissing_RatecodeID` |
| `store_and_fwd_flag` | `IsMissing_StoreAndFwdFlag` |
| `congestion_surcharge` | `IsMissing_CongestionSurcharge` |
| `Airport_fee` | `IsMissing_AirportFee` |

### Rule definition

For each column, set its missing-value flag to `1` when the source value is SQL `NULL`; otherwise set it to `0`.

### Profiling findings

- `RatecodeID`: 11,611,894 SQL `NULL` values.
- `store_and_fwd_flag`: 11,611,894 SQL `NULL` values.
- `congestion_surcharge`: 11,611,894 SQL `NULL` values.
- `Airport_fee`: 11,611,894 SQL `NULL` values.

These four columns were observed to have the same missing-record pattern as `passenger_count`.

### Handling approach

Preserve the original values and records. Do not replace missing values with zero without a justified business rule. The flags support transparent filtering and help distinguish missing values from valid zero values or undocumented codes.

---

## 10. DQR-009: Pickup Year Validity

- **Column:** `tpep_pickup_datetime`
- **Data quality dimension:** Validity
- **Quality flag:** `PickupYearQualityFlag`

### Rule definition

Flag records where the pickup year is not 2025.

### Profiling findings

- Total records: 48,722,602.
- Records with pickup year 2025: 48,722,573.
- Records with pickup years outside 2025: 29.
  - 2024: 21 records.
  - 2009: 6 records.
  - 2008: 1 record.
  - 2007: 1 record.

### Flag interpretation

- `1` = Pickup year is not 2025.
- `0` = Pickup year is 2025.

### Handling approach

Preserve the original timestamps and records. For analyses specifically covering calendar year 2025, exclude or separately report records outside the reporting year as appropriate. Do not automatically delete them from the source or clean view.

---

## 11. DQR-010: Store-and-Forward Flag Validity

- **Column:** `store_and_fwd_flag`
- **Data quality dimension:** Validity
- **Quality flag:** `InvalidStoreAndFwdFlag`
- **Missing-value flag:** `IsMissing_StoreAndFwdFlag`

### Rule definition

The accepted non-`NULL` values are:

| Code | Description |
|---|---|
| `Y` | Store-and-forward trip |
| `N` | Not a store-and-forward trip |

Flag a value when it is not `Y` or `N` and is not SQL `NULL`.

### Flag interpretation

- `1` = An unexpected non-`NULL` value is detected.
- `0` = The value is `Y`, `N`, or SQL `NULL`.

### Validation finding

Formal validation reported **0 invalid non-`NULL` store-and-forward values**.

The 11,611,894 SQL `NULL` values are handled separately by `IsMissing_StoreAndFwdFlag`.

### Handling approach

Preserve the original value. Investigate any unexpected code if one appears in future data. Do not classify SQL `NULL` as an invalid non-`NULL` code.

---

## 12. Derived Analytical Columns

The clean analytical view adds derived columns to simplify downstream analysis. These columns do not replace the original timestamps.

| Derived column | Definition and purpose |
|---|---|
| `PickupDate` | Date portion of `tpep_pickup_datetime`, used for daily analysis. |
| `TripDurationMinutes` | Difference between pickup and drop-off timestamps in minute boundaries; `NULL` when drop-off precedes pickup. |
| `PickupHour` | Hour component of pickup time, from 0 to 23. |
| `PickupMonth` | Month number, from 1 to 12. |
| `PickupMonthName` | Month name derived from pickup time. |
| `PickupDayOfWeek` | Weekday name derived from pickup time. |

Month and weekday names depend on SQL Server's language settings. `DATEDIFF(MINUTE, ...)` counts minute boundaries rather than fractional elapsed minutes.

---

## 13. Final View Validation

The final analytical view is:

`analytics.vw_yellow_tripdata_2025_clean`

### Structural validation

The view's column metadata was inspected using `INFORMATION_SCHEMA.COLUMNS`. The output includes:

- Original source columns.
- Descriptive vendor, rate-code, and payment-type labels.
- Invalid-code and trip-quality flags.
- Individual monetary negative-value flags.
- Zero fare and zero total flags.
- Passenger-count and missing-value flags.
- Pickup-year and store-and-forward validity flags.
- Six derived analytical columns.

### Row-count reconciliation

The following counts were confirmed:

| Dataset | Row count |
|---|54:|
| Raw source view | 48,722,602 |
| Clean analytical view | 48,722,602 |
| Difference | 0 |

This confirms that the view preserves the source row count. Matching row counts alone do not prove that every individual source value is unchanged, so the non-destructive design should also be maintained in the view definition.

### Implementation approach

- Preserve source rows.
- Expose quality issues through flags.
- Retain original source values.
- Add readable labels and derived analytical fields.
- Apply exclusions at the analysis stage only when justified and documented.

---

## 14. Status Summary

| Rule ID | Rule | Status |
|---|---|---|
| DQR-001 | Payment type code validity | Validated — 0 invalid records |
| DQR-002 | RatecodeID validity | Validated — 0 invalid records |
| DQR-003 | VendorID validity | Validated — 0 invalid records |
| DQR-004 | Trip timestamp validity | Validated — 2,235 reversed timestamps |
| DQR-005 | Trip distance quality | Flag implemented and count reconciled |
| DQR-006 | Monetary value quality | Individual negative and zero-value flags implemented |
| DQR-007 | Passenger count quality | Zero and missing-value flags implemented |
| DQR-008 | Missing rate, flag, and surcharge values | Missing-value flags implemented |
| DQR-009 | Pickup year validity | Flag implemented; 29 out-of-year records identified |
| DQR-010 | Store-and-forward flag validity | Validated — 0 invalid non-`NULL` records |

### Overall status

The profiling, data quality rule definition, and non-destructive analytical view have been implemented. The view's structure and row-count reconciliation have also been checked.

The quality flags make the identified conditions visible without automatically deleting records. Any further data exclusions, corrections, or business-specific treatment should be documented in the analysis where they are applied.


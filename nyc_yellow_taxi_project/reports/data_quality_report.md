# Data Quality Report — NYC Yellow Taxi Data Analysis 2025

## 1. Purpose

This report evaluates the reliability of the **48,722,573 NYC Yellow Taxi trips recorded during 2025** and documents how data-quality issues may affect analytical KPIs.

Data quality was treated as part of the analytical process rather than as a one-time cleanup step.

## 2. Quality Summary

| Data-quality issue | Result |
|---|---:|
| Total 2025 trips | 48,722,573 |
| Drop-off before pickup | 2,235 |
| Non-positive distance | 1,402,958 |
| Trips >100 miles | 2,870 |
| Missing passenger count | 11,611,894 |
| Negative fare amount | 2,848,620 |
| Negative total amount | 973,721 |
| Negative tip amount | 1,693 |
| Missing pickup timestamp | 0 |
| Missing drop-off timestamp | 0 |
| Missing trip distance | 0 |
| Missing fare amount | 0 |
| Missing total amount | 0 |
| Exact duplicate records | 0 |

## 3. Temporal Quality

There were **2,235 trips where drop-off occurred before pickup**, approximately **0.0046%** of the annual population.

This matters for:

- trip duration
- implied speed
- duration-based analysis

It was therefore explicitly measured and screened.

## 4. Distance Quality

There were **1,402,958 non-positive-distance trips**, approximately **2.88%** of the annual population.

There were also **2,870 trips above 100 miles**, approximately **0.0059%** of the dataset.

Distance was handled using explicit analytical screening rather than assuming every recorded value represented a normal trip.

The project uses different distance screens depending on the analytical question, including:

- positive distance
- positive distance up to 100 miles
- predefined distance categories

## 5. Passenger-Count Completeness

There were **11,611,894 trips with missing passenger counts**, approximately **23.83%** of the annual population.

This limits conclusions about:

- occupancy
- passenger demand
- passenger-count distributions
- relationships between passenger count and distance

SQL aggregate functions such as `AVG` ignore NULL values. Therefore, an average calculated from recorded passenger counts does not automatically represent all trips.

## 6. Financial Quality

There were **2,848,620 negative fare records**, approximately **5.85%** of the annual population.

There were **973,721 negative total-amount records**, approximately **2.00%** of the annual population.

The Q9 analysis found that negative total amounts reduced the recorded annual total by approximately **$24.81M** compared with a non-negative-only calculation.

These records were not automatically deleted.

Possible explanations include:

- refunds
- adjustments
- corrections
- other transactional behavior

Without source-system documentation, automatically classifying all negative amounts as errors would be inappropriate.

## 7. Tip Quality

There were **1,693 negative tip records**, approximately **0.0035%** of the annual population.

Negative tips are rare compared with the overall dataset but were retained and reported as a quality indicator.

## 8. Missing-Value Pattern

There were zero missing values for:

- pickup timestamps
- drop-off timestamps
- trip distance
- fare amount
- total amount

Several fields had missing values associated with approximately **11.61 million Flex Fare records**, including:

- RatecodeID
- store_and_fwd_flag
- congestion_surcharge
- Airport_fee

This pattern is important because it suggests that the missingness is structured rather than necessarily random.

## 9. Duplicate Records

The project found **zero exact duplicate records**.

This supports the conclusion that exact duplication is not a major issue in the consolidated 2025 dataset.

It does not prove that every record represents a unique real-world trip because exact duplicate testing cannot identify all possible semantic duplicates.

## 10. KPI Impact

### Distance

The project compared:

- all recorded distances
- positive distances
- positive distances up to 100 miles

This showed that extreme and non-positive values can materially affect the mean distance.

The median was much less sensitive than the mean.

### Revenue

The presence of negative total amounts changes the recorded annual total.

Therefore, revenue-related KPIs should clearly state whether they represent:

- recorded amounts
- non-negative amounts
- adjusted amounts

The current project primarily reports recorded values while documenting the impact of negative observations.

### Passenger Counts

Because approximately **23.83%** of trips have missing passenger counts, passenger-related KPIs should be interpreted as statistics of the recorded passenger-count population unless the denominator is explicitly adjusted.

## 11. Data-Quality Treatment Philosophy

The project follows four principles:

### 1. Measure before removing

Anomalies are quantified before any analytical screening is applied.

### 2. Preserve source information

The original observations are not silently deleted simply because they appear unusual.

### 3. Screen according to the analytical question

For example, speed calculations require meaningful positive duration, while distance analysis may require positive distances.

### 4. Document the effect on KPIs

The objective is not merely to report the number of problematic records but to understand whether the issues materially change the business conclusion.

## 12. Quality Recommendations

Future production use should include automated monitoring of:

- missing-value rates
- temporal anomalies
- non-positive distances
- extreme distances
- negative financial values
- passenger completeness
- duplicate rates

A production pipeline should also distinguish between:

- raw recorded values
- validated values
- screened analytical values

This would make downstream KPI interpretation more transparent.

## 13. Overall Assessment

The dataset is sufficiently large and complete for substantial demand, geographic, payment, vendor, and trip-characteristic analysis.

However, several limitations must remain visible:

- missing passenger counts
- non-positive distances
- negative financial records
- temporal anomalies
- extreme trip values

These issues do not invalidate the project, but they affect how individual KPIs should be interpreted.

The correct analytical response is therefore **not to hide the anomalies, but to quantify them, understand their impact, and document the assumptions used in each analysis**.
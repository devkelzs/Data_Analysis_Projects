# NYC Yellow Taxi Data Analysis — 2025

## Project Overview

This project analyzes the **NYC Yellow Taxi Trip Records for 2025** to understand taxi demand, geographic patterns, trip characteristics, charges, payment behavior, vendor differences, and data quality.

The project was designed as a portfolio-level **Data Analyst / Business Intelligence project**, using:

- **SQL Server 2025 Express** for data preparation, profiling, analysis, and reporting views
- **SQL Server Management Studio (SSMS)** for querying and validation
- **Power BI Desktop** for interactive dashboards and business communication
- **Python / Jupyter Notebook** as part of the broader analytical environment

The analysis covers approximately **48.72 million taxi trips recorded during 2025**.

The objective was not simply to produce statistics. The project focuses on converting a large transportation dataset into **business-relevant insights and actionable recommendations**, while explicitly documenting data-quality limitations.

---

## Business Problem

Taxi demand in New York City varies substantially by:

- month
- weekday
- hour
- pickup and drop-off location
- origin-destination route
- trip distance
- passenger count
- payment method
- rate code
- vendor
- and recorded trip characteristics

The analysis was designed to answer ten major business questions:

1. How does taxi trip demand change throughout 2025?
2. Which pickup and drop-off zones account for the greatest trip activity?
3. How do recorded fares and trip charges vary by month, distance, and trip type?
4. How do payment methods and recorded tipping patterns differ?
5. How do trip duration, distance, and implied speed vary by time of day?
6. How do passenger counts relate to trip distances?
7. Which origin-destination pairs show the strongest demand, and how do their characteristics compare?
8. How do trip characteristics and charges differ by vendor?
9. How reliable is the dataset, and how do data-quality issues affect KPIs?
10. Which combinations of time, location, and trip characteristics are useful for operational planning?

---

# Dataset

## Source

The project uses the **NYC Yellow Taxi Trip Records for January–December 2025**.

The raw monthly data was consolidated into:

`raw.yellow_tripdata_2025`

The cleaned analytical source is:

`analytics.vw_yellow_tripdata_2025_clean`

The taxi-zone lookup is:

`analytics.taxi_zone_lookup`

The taxi-zone lookup was used in SQL reporting views for zone and borough enrichment. It was **not imported as a separate table into the Power BI model**.

## Annual Population

The main 2025 population is:

**48,722,573 trips**

The standard date boundary used throughout the project is:

- Pickup datetime >= `2025-01-01`
- Pickup datetime < `2026-01-01`

This ensures that the analysis covers the full 2025 calendar year.

---

# Project Architecture

```text
Raw Monthly Taxi Data
        ↓
raw.yellow_tripdata_2025
        ↓
analytics.vw_yellow_tripdata_2025_clean
        ↓
SQL Data Profiling & Business Analysis
        ↓
Q1–Q10 Analytical Reporting Views
        ↓
Power BI Import Model
        ↓
5 Interactive Dashboards
        ↓
Business Insights & Recommendations
```

Because the dataset contains approximately **48.7 million rows**, the project does not import the complete raw dataset into Power BI.

Instead, SQL Server performs the heavy aggregation and Power BI consumes purpose-built reporting views. This keeps the BI layer more manageable and avoids repeatedly scanning tens of millions of raw records for dashboard visuals.

---

# Data Quality and Profiling

Data quality was treated as a core part of the project.

Important findings:

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

### Interpretation

Unusual values were not automatically deleted.

For example, negative fare and total amounts may represent refunds, adjustments, corrections, or other legitimate transactional behavior. The project therefore reports these values as data-quality observations and evaluates their KPI impact instead of silently removing them.

The same principle was applied to extreme distances, durations, and implied speeds.

---

# Analytical SQL Layer

The project was organized around ten analytical question groups.

## Q1 — Demand

**Question:** How does taxi trip demand change throughout 2025?

Views:

- `analytics.vw_q1_monthly_trip_demand`
- `analytics.vw_q1_weekday_trip_demand`
- `analytics.vw_q1_hourly_trip_demand`

Analysis included monthly demand, month-over-month change, weekday demand, hourly demand, observed service days, and average daily demand.

## Q2 — Geography

**Question:** Which pickup and drop-off zones account for the greatest trip activity?

Views:

- `analytics.vw_q2_pickup_zone_demand`
- `analytics.vw_q2_dropoff_zone_demand`
- `analytics.vw_q2_origin_destination_demand`

The project intentionally did **not** create a separate borough-to-borough view.

## Q3 — Charges

**Question:** How do recorded fares and trip charges vary by month, distance, and trip type?

Views:

- `analytics.vw_q3_monthly_charge_analysis`
- `analytics.vw_q3_distance_charge_analysis`
- `analytics.vw_q3_distance_charge_components`
- `analytics.vw_q3_ratecode_charge_analysis`

The analysis covers fares, tips, tolls, total charges, distance groups, charge components, and rate codes.

## Q4 — Payment and Tips

**Question:** How do payment methods and recorded tipping patterns differ?

View:

- `analytics.vw_q4_payment_tip_analysis`

The analysis covers payment distribution, average tips, median tips, positive tips, number of recorded tips, and tip behavior.

## Q5 — Duration and Speed

**Question:** How do trip duration, distance, and implied speed vary by time of day?

Views:

- `analytics.vw_q5_hourly_trip_duration`
- `analytics.vw_q5_hourly_trip_speed`

The analysis includes duration, median duration, non-positive duration, extreme-duration screening, implied speed, and speed screening.

## Q6 — Passenger Counts

**Question:** How do passenger counts relate to trip distances?

Views:

- `analytics.vw_q6_passenger_distance_analysis`
- `analytics.vw_q6_passenger_distance_bands`

The analysis includes passenger-count groups, average/median distance, distance bands, missing passenger counts, trips over 100 miles, and non-positive distance.

## Q7 — Routes

**Question:** Which origin-destination pairs show the strongest demand, and how do their characteristics compare?

Views:

- `analytics.vw_q7_origin_destination_demand`
- `analytics.vw_q7_origin_destination_quality`

The analysis covers route volume, route share, distance, duration, fare, total amount, and route-level quality indicators.

## Q8 — Vendors

**Question:** How do trip characteristics and charges differ by vendor?

View:

- `analytics.vw_q8_vendor_trip_characteristics`

The analysis covers vendor trip volume, vendor share, screened average distance, average total charge, and vendor-level quality indicators.

Vendor IDs are treated as **data-provider identifiers**, not direct measures of driver or service quality.

## Q9 — Reliability

**Question:** How reliable is the dataset, and how do data-quality issues affect KPIs?

Views:

- `analytics.vw_q9_overall_data_quality`
- `analytics.vw_q9_missing_values`
- `analytics.vw_q9_kpi_impact`

The analysis evaluates missing values, invalid temporal relationships, distance anomalies, negative charges, passenger-count completeness, revenue impact, and KPI sensitivity.

## Q10 — Operational Planning

**Question:** Which combinations of time, location, and trip characteristics are useful for operational planning?

Views:

- `analytics.vw_q10_hourly_location_demand`
- `analytics.vw_q10_weekday_hour_demand`
- `analytics.vw_q10_location_distance`
- `analytics.vw_q10_location_payment`

The analysis combines time and location to identify recurring demand patterns.

---

# Power BI Modeling Approach

The Power BI model uses aggregated SQL reporting views rather than the full 48.7-million-row dataset.

The Q1–Q10 reporting views intentionally remain **independent reporting tables** because they have different grains, including:

- monthly
- hourly
- weekday
- zone
- route
- payment type
- vendor
- passenger group

Therefore, the model intentionally has **0 relationships between the Q1–Q10 reporting views**.

This is deliberate. Creating relationships between unrelated aggregate tables could create ambiguous filtering and incorrect calculations.

---

# Calculation Methodology

## Weighted averages

When a reporting view contains subgroup averages, an overall average is calculated using trip volume as the weight:

`Overall Average = Σ(Subgroup Average × Subgroup Trips) ÷ Σ(Subgroup Trips)`

This was used for metrics such as:

- average trip duration
- average trip charge
- average fare
- average tip
- average trip distance where the existing analytical structure supports it

This prevents a low-volume hour or month from having the same influence as a high-volume period.

## Medians

A median cannot generally be reconstructed by averaging subgroup medians.

Therefore, where the existing aggregate view did not contain enough information to calculate an exact overall median, the project did **not** manufacture an overall median from subgroup medians.

## Percentage fields

Several SQL views already store percentage values as percentage points.

For example:

`63.74` = **63.74%**

These fields should not be formatted as Power BI Percentage unless they are first divided by 100.

---

# Final Power BI Dashboard Suite

The final project contains **five dashboards**.

---

# Dashboard 1 — Executive Overview

## Title

**NYC Yellow Taxi — 2025 Executive Overview**

## Subtitle

**A high-level view of taxi demand, trip characteristics, revenue, and payment behavior across New York City in 2025**

## Purpose

This dashboard answers:

> **How did NYC taxi activity perform across 2025?**

## KPI Cards

1. **Total Trips** — 48.72M
2. **Average Daily Trips** — approximately 133K
3. **Peak Month Trips** — 4.59M
4. **Peak Hour Trips**
5. **Average Trip Distance** — 3.51 miles
6. **Average Trip Duration** — 17.19 minutes
7. **Average Total Amount** — $26.91
8. **Credit Card Trip Share** — 63.74%

## Visuals

### Monthly Trip Demand
Line chart showing January–December trip demand.

### Hourly Trip Demand
Line chart showing demand across the 24 hours.

### Weekday Trip Demand
Column chart showing Monday–Sunday demand.

### Monthly Demand Change
Line chart showing month-over-month change.

## Key Findings

- May recorded the highest monthly demand at approximately **4.59M trips**.
- August recorded the lowest monthly demand at approximately **3.57M trips**.
- September showed a strong month-over-month increase of approximately **18.94%**.
- Demand increased strongly during spring, weakened during parts of summer, and strengthened again during autumn.

## Dashboard Image


![Dashboard 1 — Executive Overview](powerbi_dashboards/Screenshot%202026-11-06%20120428.png)

# Dashboard 2 — Demand & Geographic Analysis

## Title

**NYC Yellow Taxi — Demand & Geographic Analysis**

## Subtitle

**Where and when taxi demand is concentrated across New York City in 2025**

## Purpose

This dashboard answers:

> **Where and when is taxi demand concentrated?**

## KPI Cards

1. **Total Trips** — 48.72M
2. **Top Pickup Zone Trips**
3. **Top Drop-off Zone Trips** — 1.94M
4. **Top Origin-Destination Pair Trips** — 302.26K
5. **Peak Hour Trips** — approximately 3.47M

## Visuals

1. Monthly Trip Demand
2. Top Pickup Zones
3. Top Drop-off Zones
4. Top Origin-Destination Pairs
5. Demand by Hour
6. Weekday Demand

## Key Findings

- East Village and Lower Manhattan show strong overnight demand between approximately 00:00 and 04:00.
- JFK shows important early-morning activity around 05:00–06:00 and late-night activity around 23:00.
- JFK → Outside NYC recorded approximately **95,267 trips**, with a median distance of approximately **17.96 miles** and median duration of approximately **37 minutes**.
- Upper East Side North is particularly important between approximately 07:00 and 10:00.
- Upper East Side South is prominent from approximately 11:00 to 15:00.
- Upper East Side South → Upper East Side North recorded approximately **302,261 trips**, while the reverse route recorded approximately **259,469 trips**.
- Midtown Center is particularly important between 17:00 and 20:00.
- Around 18:00, Midtown Center recorded approximately **187,567 pickups**, representing about **5.40% of hourly demand**.
- Friday and Saturday late-night demand is particularly important around 22:00–23:00.

## Operational Interpretation

These patterns support time-and-location-specific planning around airports, Manhattan business districts, commuter periods, evening activity, and late-night demand.

However, trip volume alone does **not** prove that a location has a taxi shortage. Supply, waiting-time, availability, and rejected-trip data would be required for that conclusion.

## Dashboard Image

![Dashboard 1 — Executive Overview](powerbi_dashboards/Screenshot%202026-11-06%20120428.png)


# Dashboard 3 — Revenue & Payment Analytics

## Title

**NYC Yellow Taxi — Revenue & Payment Analytics**

## Subtitle

**Trip charges, fares, tips, and payment behavior across New York City in 2025**

## Purpose

This dashboard examines trip charges and payment behavior.

## KPI Cards

1. **Total Amount**
2. **Average Trip Charge**
3. **Average Fare**
4. **Average Tip** — $2.84
5. **Credit Card Trip Share** — 63.74%
6. **Positive Tip Rate** — 60.71%

## Visuals

1. Monthly Revenue / Charges
2. Revenue by Distance Category
3. Charge Components by Distance
4. Charges by Rate Code
5. Payment Method & Tip Behavior

## Key Findings

Credit card transactions represented approximately **63.74% of trips**.

Payment method was strongly associated with recorded tipping behavior:

- Credit card trips had substantially stronger positive tipping activity.
- Cash trips had almost no positive recorded tipping.
- Flex Fare represented a substantial portion of the population but had much lower positive tipping activity than credit-card trips.

The average recorded tip was approximately **$2.84**.

## Revenue Caveat

The Q9 analysis identified **973,721 negative total amounts**.

Negative amounts reduced the recorded total amount by approximately **$24.81M** relative to a non-negative-only total.

These values were not automatically removed because they may represent adjustments or refunds.

Therefore, the dashboard should be interpreted as **recorded trip charges/total amount**, not accounting profit.

## Dashboard Image

![Dashboard 3 — Revenue & Payment Analytics](powerbi_dashboards/Revenue.png)


# Dashboard 4 — Trip Characteristics & Speed Analysis

## Title

**NYC Yellow Taxi — Trip Characteristics & Speed Analysis**

## Subtitle

**How trip duration, distance, and implied speed vary across time and passenger patterns**

## Purpose

This dashboard examines the physical and temporal characteristics of taxi trips.

## KPI Cards

1. **Average Trip Duration** — 17.19 minutes
2. **Average Trip Distance** — 3.51 miles
3. **Trips Over 100 Miles** — 2,870
4. **Average Implied Speed**
5. **Non-Positive Distance Trips** — 1.40M
6. **Missing Passenger Rate** — 23.83%

## Visuals

1. Trip Duration by Hour
2. Implied Speed by Hour
3. Trip Distance by Passenger Count
4. Distance Distribution by Passenger Count
5. Trip Volume by Passenger Count

## Key Findings

- Average trip duration is approximately **17.19 minutes**.
- Average trip distance is approximately **3.51 miles**.
- **2,870 trips** exceeded 100 miles.
- **1,402,958 trips** had non-positive distance, approximately **2.88%** of the dataset.
- **23.83%** of trips have missing passenger counts.
- Average duration is highest around the afternoon period, approximately 15:00–16:00.
- Average duration is shortest around 02:00–03:00.
- Extreme implied speeds were screened because anomalous duration or distance records can create unrealistic calculated speeds.

## Dashboard Image

![Dashboard 4 — Trip Characteristics & Speed Analysis](powerbi_dashboards/Trip%20characteristics.png)


# Dashboard 5 — Vendor & Data Quality Analysis

## Title

**NYC Yellow Taxi — Vendor & Data Quality Analysis**

## Subtitle

**How trip characteristics vary by vendor and how data quality issues affect the 2025 dataset**

## Purpose

This dashboard combines vendor analysis with data-quality indicators.

It answers:

> **How do recorded trip characteristics differ across vendors, and what quality issues should be considered when interpreting the dataset?**

## KPI Cards

1. **Total Trips** — 48.72M
2. **Top Vendor Trip Share** — 79.17%
3. **Total Vendors** — 4
4. **Top Vendor Trips** — 38.58M
5. **Non-Positive Distance Rate** — 2.88%
6. **Missing Passenger Rate** — 23.83%

## Vendor Distribution

| Vendor | Trips | Share |
|---|---:|---:|
| Curb Mobility LLC | 38,575,817 | 79.17% |
| Creative Mobile Technologies LLC | 9,586,873 | 19.68% |
| Helix | 535,901 | 1.10% |
| Myle Technologies Inc | 23,982 | 0.05% |

## Visuals

1. Trips by Vendor
2. Average Trip Distance by Vendor
3. Data Quality Issues by Vendor
4. Average Total Charge by Vendor

## Important Interpretation

Vendor IDs identify data providers.

They should not automatically be interpreted as measures of:

- driver performance,
- customer satisfaction,
- safety,
- or service quality.

Differences may reflect reporting systems, trip mix, data capture, and vendor coverage.

## Dashboard Image

![Dashboard 5 — Vendor & Data Quality Analysis](powerbi_dashboards/vendor.png)


# Key Findings Across the Project

## 1. Demand is strongly time-dependent

Taxi activity varies substantially by month, weekday, and hour.

May was the highest-demand month, while August was the lowest.

A single annual average therefore cannot adequately describe operational demand.

## 2. Demand is geographically concentrated

Specific Manhattan zones and airport-related locations repeatedly appear among high-demand locations.

Demand is not evenly distributed across NYC.

## 3. Demand changes by location and time

Different areas dominate different periods:

- Lower Manhattan overnight
- JFK during airport-related periods
- Upper East Side during daytime
- Midtown during evening periods
- Times Square and JFK during late-night activity

## 4. Credit cards dominate recorded payment behavior

Approximately **63.74% of trips** were paid by credit card.

Payment method is also strongly associated with recorded tipping behavior.

## 5. Typical trip distance is short

The overall analytical average trip distance is approximately **3.51 miles**.

## 6. Data quality materially affects interpretation

The dataset includes:

- 23.83% missing passenger counts
- 2.88% non-positive distances
- negative fares
- negative total amounts
- temporal anomalies
- extreme distances

These issues should be reported rather than hidden.

## 7. Vendor concentration is high

One vendor accounts for approximately **79.17%** of trips.

Vendor comparisons should therefore consider differences in sample size and reporting coverage.

---

# Recommendations

## Recommendation 1 — Use time-and-location demand planning

Operational planning should focus on combinations of **hour + location**, rather than treating NYC as one homogeneous market.

Priority periods identified by the analysis include:

- overnight Lower Manhattan
- early-morning JFK
- daytime Upper East Side
- evening Midtown
- Friday/Saturday late-night periods

### Business implication

Fleet positioning and dispatch planning can be prioritized around recurring demand windows.

However, supply-side data is required before claiming a shortage of available taxis.

## Recommendation 2 — Create airport-specific planning windows

JFK shows distinct early-morning and late-night demand.

Airport trips can also have longer distances and durations than many local trips.

### Business implication

Airport-focused planning should use dedicated demand windows rather than relying only on citywide hourly averages.

## Recommendation 3 — Use route-level analysis for targeted planning

High-volume origin-destination pairs provide more actionable information than citywide averages.

The Upper East Side South ↔ Upper East Side North routes are examples of recurring high-volume movement.

### Business implication

High-volume routes can be monitored for:

- recurring demand
- distance
- duration
- charges
- payment behavior

## Recommendation 4 — Incorporate seasonality into planning

May reached approximately **4.59M trips**, while August recorded approximately **3.57M**.

### Business implication

Planning models should incorporate seasonal demand rather than relying on a static annual assumption.

## Recommendation 5 — Monitor payment and tipping behavior

Credit cards dominate the payment mix and have much stronger recorded tipping activity than cash.

### Business implication

Payment analysis can help understand digital-payment adoption, customer payment behavior, and tipping patterns.

## Recommendation 6 — Establish a continuous data-quality monitoring framework

Recommended monitoring metrics include:

- missing-value rate
- anomaly rate
- invalid-duration rate
- negative-charge rate
- extreme-distance rate
- duplicate rate

### Business implication

Data quality should be monitored continuously in a production analytics environment.

## Recommendation 7 — Do not automatically delete anomalous financial records

Negative fare and total-charge records should be investigated before removal.

They may represent refunds, adjustments, corrections, or other legitimate behavior.

A future production model should consider maintaining:

- recorded KPIs
- clearly documented adjusted KPIs

## Recommendation 8 — Investigate vendor reporting differences

The large differences in vendor volume and trip characteristics warrant further investigation.

Before interpreting vendor differences as operational performance, examine:

- reporting systems
- coverage
- trip mix
- data capture rules
- missingness
- anomaly rates

## Recommendation 9 — Improve passenger-count completeness

Approximately **23.83% of trips have missing passenger counts**.

If the source system can be improved, passenger-count capture should be prioritized because it affects occupancy and passenger-demand analysis.

## Recommendation 10 — Build a future supply-and-demand model

The current project measures **recorded demand**, not actual taxi supply.

A future analysis could integrate:

- vehicle availability
- dispatch data
- passenger waiting times
- weather
- events
- traffic
- public-transit disruptions
- airport schedules

This would allow the analysis to progress from:

> **Where is demand high?**

to:

> **Where and when is demand likely to exceed available supply?**

Trip volume alone cannot prove a supply shortage.

---

# Limitations

## Recorded trips are not total transportation demand

The dataset represents recorded Yellow Taxi trips and does not capture every transportation mode or every unmet taxi request.

## Supply is not directly measured

The project does not contain enough information to determine:

- available taxis
- waiting passengers
- driver shortages
- rejected trips
- passenger abandonment

## Data anomalies remain part of the dataset

Some unusual values may represent genuine adjustments or reporting behavior.

## Passenger count is incomplete

Approximately **23.83%** of trips have missing passenger counts.

## Implied speed is derived

Speed is calculated from recorded distance and duration and is therefore sensitive to errors in either field.

## Aggregate views limit some calculations

Some reporting views contain subgroup averages rather than the underlying trip-level observations.

Exact overall medians cannot always be reconstructed from subgroup medians.

## Vendor comparisons require caution

Vendor IDs represent data providers and should not be treated as direct measures of service quality.

---

# Recommended Repository Structure

```text
NYC-Yellow-Taxi-2025/
│
├── README.md
│
├── data/
│   ├── raw/
│   ├── processed/
│   └── lookup/
│
├── sql/
│   ├── profiling/
│   ├── business_questions/
│   ├── reporting_views/
│   └── validation/
│
├── powerbi/
│   └── NYC_Yellow_Taxi_Analysis.pbix
│
├── images/
│   ├── dashboard_1_executive_overview.png
│   ├── dashboard_2_demand_geographic.png
│   ├── dashboard_3_revenue_payment.png
│   ├── dashboard_4_trip_characteristics.png
│   └── dashboard_5_vendor_quality.png
│
├── notebooks/
│   └── exploratory_analysis.ipynb
│
└── documentation/
    ├── data_dictionary.md
    ├── methodology.md
    └── data_quality.md
```

The raw dataset should not be committed to GitHub if its size or distribution terms make that inappropriate.

---

# Dashboard Screenshot Checklist

Before publishing the project, capture clean screenshots of all five dashboards.

Recommended filenames:

```text
dashboard_1_executive_overview.png
dashboard_2_demand_geographic.png
dashboard_3_revenue_payment.png
dashboard_4_trip_characteristics.png
dashboard_5_vendor_quality.png
```

Store them under:

`images/`

The README image placeholders can then render automatically on GitHub.

---

# Value

This project demonstrates the ability to:

- work with tens of millions of records
- profile a large dataset
- identify data-quality problems
- define business questions
- build analytical SQL views
- optimize heavy queries
- use aggregation to reduce BI workload
- calculate weighted metrics
- understand statistical limitations
- design Power BI dashboards
- communicate analytical findings
- translate analysis into operational recommendations
- document assumptions and limitations


# Final Project Outcome

The completed project consists of:

- **48.72M 2025 taxi trips analyzed**
- **10 structured business questions**
- **Q1–Q10 SQL reporting views**
- **data-quality profiling**
- **5 Power BI dashboards**
- **executive KPIs**
- **time, geography, route, payment, vendor, distance, duration, and passenger analysis**
- **business recommendations**
- **documented analytical limitations**

The final dashboard suite follows a clear analytical progression:

```text
Executive Overview
        ↓
Demand & Geography
        ↓
Revenue & Payment
        ↓
Trip Characteristics
        ↓
Vendor & Data Quality
```

Together, the five dashboards provide a comprehensive analytical view of NYC Yellow Taxi activity in 2025.

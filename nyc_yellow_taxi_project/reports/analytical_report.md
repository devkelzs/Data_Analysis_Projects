# Analytical Report — NYC Yellow Taxi Data Analysis 2025

## 1. Project Overview

This report documents the complete data engineering, data preparation, SQL analytics, data-quality assessment, and business intelligence workflow used to analyze the **NYC Yellow Taxi dataset for 2025**.

The project was designed as an end-to-end analytical pipeline rather than simply a Power BI visualization exercise.

The workflow began with twelve monthly NYC Yellow Taxi data files stored in **Parquet format**. Python was used to process the monthly files and convert them into CSV format. The resulting CSV files were then loaded into SQL Server, where the monthly datasets were stored separately and subsequently combined through a SQL view.

The consolidated dataset was then cleaned and profiled before being used to answer ten major business questions covering:

- taxi demand
- geographic activity
- fares and charges
- payment methods
- tipping behavior
- trip duration
- implied speed
- passenger counts
- origin-destination patterns
- vendor characteristics
- data quality
- operational planning

The final analytical outputs were delivered through **Power BI dashboards** built on purpose-specific SQL reporting views.

---

# 2. End-to-End Data Pipeline

The overall architecture of the project can be summarized as:

```text
NYC Yellow Taxi 2025
12 Monthly Parquet Files
        ↓
Python Data Preparation
        ↓
Parquet → CSV Conversion
        ↓
12 Monthly CSV Files
        ↓
SQL Server Import
        ↓
12 Monthly SQL Tables
        ↓
raw.yellow_tripdata_2025
        ↓
analytics.vw_yellow_tripdata_2025_clean
        ↓
Data Profiling & Quality Assessment
        ↓
Q1–Q10 SQL Business Analysis
        ↓
Purpose-Built Reporting Views
        ↓
Power BI Import
        ↓
Dashboards & Business Insights
```

This architecture separates the project into distinct layers:

1. **Data acquisition and file preparation**
2. **Database ingestion**
3. **Data consolidation**
4. **Data cleaning**
5. **Data profiling**
6. **Analytical processing**
7. **Business intelligence and visualization**

This separation made the workflow easier to validate, troubleshoot, and maintain.

---

# 3. Source Data

The project used the **NYC Yellow Taxi Trip Records for 2025**.

The original annual dataset was distributed as **twelve monthly Parquet files**, representing January through December 2025.

Instead of treating the annual dataset as one large file, each month was handled separately during the initial ingestion process.

The twelve monthly files were processed individually before being loaded into SQL Server.

This approach provided several advantages:

- smaller files were easier to process
- individual months could be validated independently
- ingestion problems could be isolated to a specific month
- monthly SQL tables provided a clear staging structure
- the data could later be consolidated into a single analytical view

---

# 4. Python Data Preparation

## 4.1 Why Python Was Used

Python was used during the initial data preparation stage to work with the original Parquet files.

The purpose of Python was not to replace SQL Server as the primary analytical engine.

Instead, Python was used as a **data preparation and file-conversion layer**.

The original files were stored in Parquet format, while the subsequent SQL Server ingestion workflow used CSV files.

Therefore, Python provided the bridge between the source-file format and the database-loading process.

---

## 4.2 Parquet-to-CSV Conversion

The twelve monthly Parquet files were processed using Python.

Each monthly Parquet file was read and converted into a corresponding CSV file.

The resulting structure followed the monthly organization of the original data:

```text
January Parquet
      ↓
January CSV

February Parquet
      ↓
February CSV

March Parquet
      ↓
March CSV

...

December Parquet
      ↓
December CSV
```

This produced twelve monthly CSV files that could be loaded into SQL Server.

The Python stage therefore served primarily as an **ETL preparation step**:

**Extract → Transform file format → Prepare for database loading**

The conversion also made the files easier to inspect and work with during the SQL Server ingestion process.

---

# 5. SQL Server Data Ingestion

After the Parquet-to-CSV conversion, the twelve CSV files were imported into **SQL Server 2025 Express**.

SQL Server was selected as the primary analytical engine because the project involved approximately **48.7 million trip records**.

Rather than loading the entire annual dataset into Power BI, the data was first stored and processed inside SQL Server.

The monthly files were loaded into separate SQL tables.

Conceptually, the structure was:

```text
January CSV   → January SQL table
February CSV  → February SQL table
March CSV     → March SQL table
...
December CSV  → December SQL table
```

This created a monthly raw-data layer inside SQL Server.

The monthly tables preserved the original monthly structure while allowing the complete annual dataset to be reconstructed later.

---

# 6. Combining the Twelve Monthly Tables

After the twelve monthly datasets had been loaded into SQL Server, they were consolidated into an annual dataset.

Instead of physically merging the twelve tables into one massive table, the project used a **SQL view** to combine them.

The resulting view was:

`raw.yellow_tripdata_2025`

The purpose of this view was to provide a single logical representation of the 2025 dataset while keeping the underlying monthly tables separate.

Conceptually:

```text
January Table
February Table
March Table
...
December Table
        ↓
UNION ALL
        ↓
raw.yellow_tripdata_2025
```

Using a view provided several benefits.

### 6.1 Preserved Monthly Raw Tables

The original monthly tables remained available for validation and troubleshooting.

### 6.2 Single Analytical Interface

Downstream SQL analysis could work against one annual dataset instead of twelve separate tables.

### 6.3 Reduced Duplication

The project did not need to physically copy approximately 48.7 million records into another consolidated table.

### 6.4 Easier Maintenance

If a monthly table needed to be inspected or corrected, it could be handled independently while the annual view continued to provide the consolidated analytical interface.

---

# 7. Clean Analytical View

The raw annual view was followed by a dedicated analytical cleaning layer:

`analytics.vw_yellow_tripdata_2025_clean`

This view served as the main source for the project's analytical queries.

The purpose of the clean view was to provide a consistent analytical representation of the annual dataset before applying the Q1–Q10 business logic.

The annual population used throughout the project was:

**48,722,573 trips**

The standard annual date boundary was:

- pickup datetime >= `2025-01-01`
- pickup datetime < `2026-01-01`

Using an explicit inclusive/exclusive date boundary helped ensure that the analysis covered exactly the 2025 calendar year.

---

# 8. Why SQL Server Was the Main Analytical Engine

The dataset contains approximately **48.7 million records**, making it inappropriate to perform every analytical operation directly inside a visualization tool.

SQL Server was therefore used for the majority of the computational work.

The SQL layer handled:

- filtering
- aggregation
- grouping
- joins
- window functions
- date analysis
- distance categorization
- payment analysis
- vendor analysis
- route analysis
- data-quality profiling
- KPI preparation
- statistical summaries
- reporting-view creation

Power BI was then used primarily as the presentation and business intelligence layer.

This architecture allowed computationally intensive operations to occur before the data reached Power BI.

---

# 9. Data Profiling

Before building the dashboards, the dataset was extensively profiled.

The profiling stage was important because the dataset contained unusual and potentially problematic records.

The analysis examined:

- missing values
- duplicate records
- invalid timestamps
- negative durations
- non-positive distances
- extreme distances
- negative fares
- negative total amounts
- negative tips
- passenger-count completeness
- payment information
- rate-code completeness
- vendor distributions

The objective was not to automatically delete unusual records.

Instead, the project followed a **measure first, interpret second** approach.

This meant that unusual records were quantified and their potential impact on analytical results was investigated before deciding whether they should be screened from a particular calculation.

---

# 10. Data-Quality Philosophy

A central principle of the project was to distinguish between:

**Observed data**

and

**Analytically screened data**

For example, a trip with a negative distance was not automatically deleted from the dataset.

Instead, the project measured:

- how many such records existed
- what percentage of the dataset they represented
- how they affected averages or totals
- whether they should be excluded from a particular analytical calculation

This approach preserves transparency and prevents the analyst from silently changing the source data.

---

# 11. Q1–Q10 Analytical Framework

The business analysis was organized into ten major analytical questions.

This structure transformed the project from a collection of SQL queries into a coherent analytical framework.

---

## Q1 — Taxi Demand

### Business Question

**How does taxi trip demand change throughout 2025?**

Reporting views:

- `analytics.vw_q1_monthly_trip_demand`
- `analytics.vw_q1_weekday_trip_demand`
- `analytics.vw_q1_hourly_trip_demand`

The analysis examined demand by:

- month
- weekday
- hour

Key findings included:

- May recorded the highest monthly trip volume at approximately **4.59 million trips**.
- August recorded the lowest monthly volume at approximately **3.57 million trips**.
- September recorded a strong month-over-month increase of approximately **18.94%**.

---

# Q2 — Geographic Demand

### Business Question

**Which pickup and drop-off zones account for the greatest trip activity?**

Reporting views:

- `analytics.vw_q2_pickup_zone_demand`
- `analytics.vw_q2_dropoff_zone_demand`
- `analytics.vw_q2_origin_destination_demand`

The analysis examined:

- pickup zones
- drop-off zones
- origin-destination pairs

The project intentionally did not create a separate borough-to-borough view because zone-level and origin-destination analysis provided the required geographic detail.

---

# Q3 — Fares and Charges

### Business Question

**How do recorded fares and trip charges vary by month, distance, and trip type?**

Reporting views:

- `analytics.vw_q3_monthly_charge_analysis`
- `analytics.vw_q3_distance_charge_analysis`
- `analytics.vw_q3_distance_charge_components`
- `analytics.vw_q3_ratecode_charge_analysis`

The analysis examined:

- fare amounts
- tips
- tolls
- total charges
- distance categories
- rate codes
- individual charge components

Distance categories were deliberately defined to distinguish ordinary trips from extreme and potentially anomalous records.

---

# Q4 — Payments and Tips

### Business Question

**How do payment methods and recorded tipping patterns differ?**

Reporting view:

- `analytics.vw_q4_payment_tip_analysis`

The analysis compared:

- payment types
- trip volume
- percentage of trips
- average total amount
- average tip
- median tip
- positive tips
- positive-tip rates

Credit-card transactions represented approximately **63.74% of all trips**.

This analysis also demonstrated that tipping behavior varies substantially by payment method.

---

# Q5 — Duration and Speed

### Business Question

**How do trip duration, distance, and implied speed vary by time of day?**

Reporting views:

- `analytics.vw_q5_hourly_trip_duration`
- `analytics.vw_q5_hourly_trip_speed`

The analysis examined:

- average duration
- median duration
- non-positive durations
- extremely long durations
- implied speed
- unusually high speeds

Because extreme speed values can result from data-quality anomalies, speed analysis included screening thresholds rather than treating every recorded value as equally reliable.

---

# Q6 — Passenger Counts and Distance

### Business Question

**How do passenger counts relate to trip distances?**

Reporting views:

- `analytics.vw_q6_passenger_distance_analysis`
- `analytics.vw_q6_passenger_distance_bands`

The analysis examined:

- passenger-count groups
- trip volume
- percentage of annual trips
- average distance
- median distance
- maximum distance
- minimum distance
- missing passenger counts
- trips exceeding 100 miles
- non-positive distance
- distance distributions

A major data-quality finding was that **11,611,894 trips**, approximately **23.83% of the annual population**, had missing passenger counts.

---

# Q7 — Origin-Destination Analysis

### Business Question

**Which origin-destination pairs show the strongest demand, and how do their characteristics compare?**

Reporting views:

- `analytics.vw_q7_origin_destination_demand`
- `analytics.vw_q7_origin_destination_quality`

The analysis combined pickup and drop-off zone information to evaluate:

- route demand
- trip distance
- trip duration
- fare
- total amount
- unusual distance
- unusual duration

The route-quality analysis also screened extreme distances and durations to prevent anomalous records from dominating route comparisons.

---

# Q8 — Vendor Analysis

### Business Question

**How do trip characteristics and charges differ by vendor?**

Primary reporting view:

- `analytics.vw_q8_vendor_trip_characteristics`

The analysis compared vendors using:

- trip volume
- percentage of annual trips
- average distance
- median distance
- non-positive fare
- non-positive total amount
- percentage of affected trips

Vendor identifiers were treated as **data-provider identifiers**.

They were not interpreted as direct measures of driver quality, customer satisfaction, or operational performance.

The vendor distribution was highly concentrated, with Vendor 2 accounting for approximately **79.17%** of the annual trips.

---

# Q9 — Data Reliability and KPI Impact

### Business Question

**How reliable is the dataset, and how do data-quality issues affect KPIs?**

Reporting views:

- `analytics.vw_q9_overall_data_quality`
- `analytics.vw_q9_missing_values`
- `analytics.vw_q9_kpi_impact`

The analysis measured:

- timestamp anomalies
- non-positive distance
- extreme distance
- missing passenger counts
- negative fares
- negative total amounts
- negative tips
- missing values
- duplicate records
- KPI sensitivity

Important findings included:

- **2,235** trips had drop-off timestamps earlier than pickup timestamps.
- **1,402,958** trips had non-positive distance.
- **2,870** trips exceeded 100 miles.
- **2,848,620** trips had negative fare amounts.
- **973,721** trips had negative total amounts.
- **11,611,894** trips had missing passenger counts.
- Exact duplicates were not identified.

The analysis also showed that negative total amounts reduced the recorded annual total by approximately **$24.81 million**.

Importantly, these negative values were not automatically classified as errors because they may represent adjustments, refunds, or other legitimate transaction behavior.

---

# Q10 — Operational Planning

### Business Question

**Which combinations of time, location, and trip characteristics are useful for operational planning?**

Reporting views:

- `analytics.vw_q10_hourly_location_demand`
- `analytics.vw_q10_weekday_hour_demand`
- `analytics.vw_q10_location_distance`
- `analytics.vw_q10_location_payment`

The analysis combined:

- hour
- weekday
- pickup location
- distance category
- payment behavior

The resulting patterns were used to identify operationally relevant demand periods and locations.

Examples included:

- overnight demand around East Village and Lower Manhattan
- early-morning JFK activity
- morning demand around Upper East Side North
- afternoon demand around Upper East Side South
- evening concentration around Midtown Center
- late-night Friday and Saturday activity

The analysis identifies demand patterns but does not claim actual supply shortages because the dataset does not directly measure waiting time, vehicle availability, or unmet demand.

---

# 12. SQL Analytical Techniques

The SQL layer used a range of analytical techniques appropriate for a large-scale transportation dataset.

These included:

### Aggregation

Used for:

- monthly demand
- hourly demand
- zone demand
- vendor analysis
- payment analysis
- revenue calculations

### Conditional Aggregation

Used to calculate:

- data-quality counts
- screened averages
- positive-tip counts
- extreme-distance counts
- issue percentages

### Joins

Zone lookup data was joined to trip records to translate location IDs into meaningful:

- zone names
- boroughs

### Window Functions

Window functions were used for analytical tasks such as:

- month-over-month comparisons
- ranking locations
- ranking demand within hours
- ranking demand within weekdays

For example, Q1 used `LAG()` to compare monthly trip volume with the previous month.

Q10 used ranking logic to identify the highest-demand pickup locations within each hour.

### CASE-Based Categorization

Conditional logic was used to create analytical categories such as:

- distance groups
- payment classifications
- passenger groups
- quality categories

These categories made the raw trip-level values easier to interpret in aggregated analysis.

---

# 13. Weighted Average Methodology

Several Power BI KPIs required combining subgroup-level averages.

A simple average of subgroup averages would incorrectly give every subgroup equal importance.

Instead, trip volume was used as the weighting factor.

The general methodology was:

**Overall Average = Σ(Subgroup Average × Subgroup Trips) ÷ Σ(Subgroup Trips)**

This approach was used for metrics such as:

- overall trip duration
- overall trip charge
- other metrics derived from grouped reporting views

For example, a month containing millions of trips should contribute more to an annual average than a subgroup containing only a small number of trips.

---

# 14. Median Methodology

Median values were treated differently from averages.

Subgroup medians cannot generally be averaged to produce an exact overall median.

For this reason, the project did not calculate an overall median by simply averaging the monthly, hourly, vendor, or passenger-group medians.

Where an exact overall median could not be reconstructed from the aggregate reporting view, the project retained the subgroup medians instead.

This prevents misleading statistical conclusions.

---

# 15. Percentage Methodology

SQL percentage outputs were stored as **percentage points**.

For example:

**63.74 = 63.74%**

rather than:

**0.6374 = 63.74%**

This distinction was maintained when transferring the SQL results into Power BI.

The reporting layer therefore avoided treating already-calculated percentage-point values as decimal proportions.

---

# 16. Query Optimization

Working with approximately 48.7 million records introduced significant query-performance considerations.

Some SQL operations were computationally expensive, particularly analyses involving:

- large aggregations
- distance calculations
- median calculations
- multiple conditional expressions
- large intermediate result sets

One major optimization occurred in the Q3 distance-charge analysis.

The original query selected more columns than were actually required for the final calculation.

The query was then optimized so that the intermediate dataset contained only the fields necessary for:

- trip distance
- fare
- tip
- total amount
- distance classification

This reduced unnecessary data movement and processing.

The optimized reporting view subsequently imported successfully into Power BI.

The project therefore adopted several performance principles:

- avoid unnecessary `SELECT *`
- select only required columns
- filter to the required annual population
- aggregate before Power BI
- use purpose-built reporting views
- test expensive queries before dashboard implementation

---

# 17. Power BI Architecture

Power BI was used as the visualization and business intelligence layer rather than as the primary data-processing engine.

The Q1–Q10 reporting views were imported into Power BI as aggregate analytical tables.

The full 48.7-million-row trip-level dataset was not imported into the Power BI model for dashboard reporting.

This significantly reduced the amount of data required by the visualization layer.

---

# 18. Why the Reporting Views Were Kept Independent

The Q1–Q10 reporting views operate at different analytical grains.

Examples include:

- monthly grain
- hourly grain
- weekday grain
- zone grain
- origin-destination grain
- payment-type grain
- vendor grain
- passenger-group grain

Because these tables do not represent the same dimensional model, relationships were intentionally not created between them.

The final Power BI model therefore contains **0 relationships between the Q1–Q10 reporting views**.

This was a deliberate architectural decision.

Creating relationships between unrelated aggregate tables could produce:

- ambiguous filtering
- incorrect aggregations
- misleading cross-dashboard calculations

The dashboards instead use each reporting view for the analytical purpose for which it was designed.

---

# 19. Power BI KPI Development

Some dashboard KPIs were calculated directly from the reporting views.

Where a reporting view contained subgroup averages, weighted calculations were used where appropriate.

Examples of executive KPIs included:

- Total Trips
- Average Daily Trips
- Peak Month Trips
- Peak Hour Trips
- Average Trip Distance
- Average Trip Duration
- Average Total Amount
- Credit Card Trip Share

The calculated results were then presented through KPI cards and supporting charts.

---

# 20. Dashboard Architecture

The project ultimately organized the analysis into multiple Power BI dashboards.

### Dashboard 1 — Executive Overview

Focus:

- annual performance
- demand trends
- key trip characteristics
- payment behavior

### Dashboard 2 — Demand & Geographic Analysis

Focus:

- pickup zones
- drop-off zones
- origin-destination pairs
- hourly demand
- weekday demand
- geographic concentration

### Dashboard 3 — Revenue & Payment Analytics

Focus:

- total charges
- average trip charge
- fares
- tips
- payment methods
- positive tipping behavior

### Dashboard 4 — Trip Characteristics & Speed Analysis

Focus:

- duration
- distance
- implied speed
- extreme trips
- data-quality-related trip characteristics

### Dashboard 5 — Vendor & Data Quality

Focus:

- vendor distribution
- vendor trip characteristics
- financial anomalies
- data-quality indicators

Together, the dashboards transform the SQL analysis into a business-facing analytical product.

---

# 21. Key Analytical Findings

The completed analysis produced several important findings.

### Demand

The dataset contained:

**48,722,573 trips**

May was the strongest month with approximately:

**4.59 million trips**

August was the lowest with approximately:

**3.57 million trips**

September experienced a strong month-over-month increase of approximately:

**18.94%**

---

### Trip Characteristics

The overall dashboard metrics included approximately:

- **3.51 miles** average trip distance
- **17.19 minutes** average trip duration
- **$26.91** average total amount

These figures are based on the project's reporting-view methodology and should be interpreted alongside the data-quality screening described elsewhere in this report.

---

### Distance Quality

The dataset contained:

**1,402,958 non-positive-distance trips**

and:

**2,870 trips exceeding 100 miles**

These records represent different analytical concerns and were therefore not treated as a single anomaly category.

---

### Passenger Completeness

There were:

**11,611,894 trips with missing passenger counts**

representing approximately:

**23.83% of the annual dataset**

This is one of the most significant completeness limitations identified in the project.

---

### Payment Behavior

Credit-card trips accounted for approximately:

**63.74% of annual trips**

The analysis also showed substantial differences in recorded tipping behavior between payment categories.

---

### Financial Quality

There were:

**973,721 trips with negative total amounts**

Negative total amounts reduced the recorded annual total by approximately:

**$24.81 million**

The project did not automatically remove these values because their business meaning cannot be determined solely from the trip record.

---

# 22. Data Engineering and Analytical Design Principles

Several principles guided the project.

## Principle 1 — Separate ingestion from analysis

Raw monthly data was first loaded into SQL Server before analytical transformations were performed.

## Principle 2 — Preserve the source data

Unusual records were measured rather than silently deleted.

## Principle 3 — Use SQL for large-scale processing

The database handled the heavy aggregation and analytical workload.

## Principle 4 — Use Python where it adds value

Python was used for file-format conversion and data preparation rather than unnecessarily duplicating SQL analysis.

## Principle 5 — Aggregate before visualization

Power BI received purpose-built reporting views instead of the complete 48.7-million-row dataset.

## Principle 6 — Design around business questions

The Q1–Q10 structure ensured that SQL development was driven by analytical questions rather than isolated technical exercises.

## Principle 7 — Make data-quality effects visible

Data-quality problems were treated as analytical findings rather than hidden imperfections.

## Principle 8 — Avoid misleading calculations

Weighted averages, screened metrics, and subgroup medians were handled according to their statistical properties.

---

# 23. Role of Python in the Overall Project

Python played a supporting but important role in the project.

Its primary contribution was the preparation of the original monthly Parquet files for SQL Server ingestion.

The workflow was:

**Parquet files → Python processing → CSV files → SQL Server**

Python was therefore part of the project's data engineering pipeline.

However, SQL Server remained the primary analytical environment because it was better suited to the project's large-scale relational aggregation, joins, window functions, and reporting-view architecture.

This division of responsibilities created a practical hybrid workflow:

| Tool | Primary Role |
|---|---|
| Python | File preparation and Parquet-to-CSV conversion |
| SQL Server | Data storage, cleaning, profiling, transformation, and analytics |
| SSMS | SQL development, testing, profiling, and performance analysis |
| Power BI | Visualization, KPI presentation, and business storytelling |

---

# 24. Why the Architecture Was Effective

The final architecture provided a clear separation of responsibilities.

### Python

Prepared the source files.

### SQL Server

Handled the large-scale data engineering and analytical workload.

### Reporting Views

Converted complex SQL analysis into reusable business-ready datasets.

### Power BI

Converted the analytical outputs into interactive dashboards.

This architecture avoided placing the entire computational burden on a visualization tool.

It also created a reproducible analytical workflow in which each layer had a defined responsibility.

---

# 25. Final Analytical Outcome

The project transformed twelve monthly Parquet files containing approximately **48.7 million NYC Yellow Taxi records** into a complete analytical and business intelligence workflow.

The process can be summarized as:

```text
12 Monthly Parquet Files
        ↓
Python Conversion
        ↓
12 Monthly CSV Files
        ↓
SQL Server
        ↓
Monthly Raw Tables
        ↓
Annual UNION ALL View
        ↓
Clean Analytical View
        ↓
Data Profiling
        ↓
Q1–Q10 Business Analysis
        ↓
Reporting Views
        ↓
Power BI
        ↓
Five Analytical Dashboards
```

The resulting system provides a structured analysis of:

- taxi demand
- geographic concentration
- fares
- charges
- payments
- tipping
- trip duration
- implied speed
- passenger behavior
- origin-destination patterns
- vendor characteristics
- data quality
- operational planning

More importantly, the project demonstrates an end-to-end analytical workflow rather than simply producing charts from a dataset.

It demonstrates the ability to move from **raw files → data preparation → database ingestion → data modeling → SQL analytics → data-quality assessment → KPI development → Power BI dashboards → business recommendations**.

That end-to-end workflow is the central technical outcome of the project.
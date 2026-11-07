# Dashboard Report — NYC Yellow Taxi Data Analysis 2025

## 1. Purpose

This report documents the five Power BI dashboards developed from the SQL Server analytical reporting layer.

The dashboards transform the Q1–Q10 SQL analysis into an executive and business-facing reporting experience.

The dashboards use aggregated SQL reporting views rather than importing the full **48.72 million trip records** into Power BI.

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

| KPI | Value |
|---|---:|
| Total Trips | 48.72M |
| Average Daily Trips | approximately 133K |
| Peak Month Trips | 4.59M |
| Peak Hour Trips | See dashboard |
| Average Trip Distance | 3.51 miles |
| Average Trip Duration | 17.19 minutes |
| Average Total Amount | $26.91 |
| Credit Card Trip Share | 63.74% |

## Visuals

- Monthly Trip Demand
- Hourly Trip Demand
- Weekday Trip Demand
- Monthly Demand Change

## Key Findings

- May recorded the highest monthly demand at approximately **4.59M trips**.
- August recorded the lowest monthly demand at approximately **3.57M trips**.
- September showed a month-over-month increase of approximately **18.94%**.
- Demand weakened during parts of summer and strengthened again during autumn.

## Screenshot

`images/dashboard_1_executive_overview.png`

---

# Dashboard 2 — Demand & Geographic Analysis

## Title

**NYC Yellow Taxi — Demand & Geographic Analysis**

## Subtitle

**Where and when taxi demand is concentrated across New York City in 2025**

## Purpose

This dashboard answers:

> **Where and when is taxi demand concentrated?**

## KPI Cards

| KPI | Value |
|---|---:|
| Total Trips | 48.72M |
| Top Pickup Zone Trips | See dashboard |
| Top Drop-off Zone Trips | 1.94M |
| Top Origin-Destination Pair Trips | 302.26K |
| Peak Hour Trips | approximately 3.47M |

## Visuals

- Monthly Trip Demand
- Top Pickup Zones
- Top Drop-off Zones
- Top Origin-Destination Pairs
- Demand by Hour
- Weekday Demand

## Key Findings

Important recurring demand patterns include:

- Lower Manhattan and East Village during overnight hours
- JFK during early-morning and late-night periods
- Upper East Side during daytime periods
- Midtown Center during evening periods
- Times Square during late-night activity

Additional route findings:

- JFK → Outside NYC: approximately **95,267 trips**
- JFK → Outside NYC median distance: approximately **17.96 miles**
- JFK → Outside NYC median duration: approximately **37 minutes**
- Upper East Side South → Upper East Side North: approximately **302,261 trips**
- Reverse route: approximately **259,469 trips**
- Midtown Center around 18:00: approximately **187,567 pickups**

## Operational Interpretation

These findings support time-and-location-specific planning.

However, high recorded trip volume does not by itself prove that a location has insufficient taxi supply.

## Screenshot

`images/dashboard_2_demand_geographic.png`

---

# Dashboard 3 — Revenue & Payment Analytics

## Title

**NYC Yellow Taxi — Revenue & Payment Analytics**

## Subtitle

**Trip charges, fares, tips, and payment behavior across New York City in 2025**

## Purpose

This dashboard examines trip charges and payment behavior.

## KPI Cards

The dashboard includes KPIs covering:

- Total Amount
- Average Trip Charge
- Average Fare
- Average Tip
- Credit Card Trip Share
- Positive Tip Rate

The exact values displayed in the dashboard should be treated as the authoritative presentation values.

## Visuals

- Monthly Revenue / Charges
- Revenue by Distance Category
- Charge Components by Distance
- Charges by Rate Code
- Payment Method and Tip Behavior

## Key Findings

Credit card transactions represented approximately **63.74% of trips**.

Recorded tipping behavior varies substantially by payment method.

Credit card trips show much stronger positive tipping activity than cash trips.

The Q9 analysis also identified **973,721 negative total amounts**, which reduced the recorded total amount by approximately **$24.81M** compared with a non-negative-only calculation.

## Revenue Caveat

The dashboard represents recorded trip charges rather than accounting profit.

Negative values may represent refunds, adjustments, corrections, or other transactional behavior.

## Screenshot

`images/dashboard_3_revenue_payment.png`

---

# Dashboard 4 — Trip Characteristics & Speed Analysis

## Title

**NYC Yellow Taxi — Trip Characteristics & Speed Analysis**

## Subtitle

**How trip duration, distance, and implied speed vary across time and passenger patterns**

## Purpose

This dashboard examines physical and temporal trip characteristics.

## KPI Cards

| KPI | Value |
|---|---:|
| Average Trip Duration | 17.19 minutes |
| Average Trip Distance | 3.51 miles |
| Trips Over 100 Miles | 2,870 |
| Average Implied Speed | See dashboard |
| Non-Positive Distance Trips | 1.40M |
| Missing Passenger Rate | 23.83% |

## Visuals

- Trip Duration by Hour
- Implied Speed by Hour
- Trip Distance by Passenger Count
- Distance Distribution by Passenger Count
- Passenger-Count Distribution

## Key Findings

- Average trip duration is approximately **17.19 minutes**.
- Average trip distance is approximately **3.51 miles**.
- **2,870 trips** exceeded 100 miles.
- **1,402,958 trips** had non-positive distance.
- **23.83%** of trips have missing passenger counts.
- Average duration is highest around 15:00–16:00.
- Average duration is shortest around 02:00–03:00.
- Extreme implied speeds require caution because speed is derived from recorded distance and duration.

## Screenshot

`images/dashboard_4_trip_characteristics.png`

---

# Dashboard 5 — Vendor & Data Quality Analysis

## Title

**NYC Yellow Taxi — Vendor & Data Quality Analysis**

## Subtitle

**How trip characteristics vary by vendor and how data quality issues affect the 2025 dataset**

## Purpose

This dashboard combines vendor analysis with important data-quality indicators.

## Vendor Distribution

| Vendor | Trips | Share |
|---|---:|---:|
| Curb Mobility LLC | 38,575,817 | 79.17% |
| Creative Mobile Technologies LLC | 9,586,873 | 19.68% |
| Helix | 535,901 | 1.10% |
| Myle Technologies Inc | 23,982 | 0.05% |

## Main Analysis

- Trips by vendor
- Average trip distance by vendor
- Vendor-level quality indicators
- Average total charge by vendor

## Important Interpretation

Vendor IDs identify data providers.

They should not automatically be interpreted as measures of:

- driver performance
- customer satisfaction
- safety
- service quality

Differences may reflect reporting systems, vendor coverage, trip mix, and data capture behavior.

## Screenshot

`images/dashboard_5_vendor_quality.png`

---

# Power BI Modeling Approach

The Power BI model uses aggregated SQL reporting views.

The Q1–Q10 reporting views intentionally remain independent because they have different analytical grains.

The model therefore contains **0 relationships between the Q1–Q10 reporting views**.

This is deliberate.

Creating relationships between unrelated aggregate tables could create ambiguous filtering and incorrect calculations.

Power BI is used primarily for:

- visualization
- KPI presentation
- dashboard composition
- sorting
- business storytelling

---

# Dashboard Design Philosophy

The dashboards follow a progressive analytical structure:

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

This progression moves from:

**What happened?**

to:

**Where did it happen?**

to:

**How much was recorded?**

to:

**What were the trip characteristics?**

to:

**How reliable are the results and how do providers differ?**

---

# Business Communication Principles

The dashboards intentionally avoid overstating conclusions.

For example:

- High demand does not automatically mean insufficient supply.
- Vendor differences do not automatically mean differences in service quality.
- Negative charges are not automatically errors.
- Implied speed is not direct GPS speed.
- Missing passenger counts limit occupancy conclusions.

The dashboards therefore combine quantitative findings with explicit analytical caveats.

---

# Dashboard Screenshot Directory

Final screenshots should be stored under:

```text
images/
├── dashboard_1_executive_overview.png
├── dashboard_2_demand_geographic.png
├── dashboard_3_revenue_payment.png
├── dashboard_4_trip_characteristics.png
└── dashboard_5_vendor_quality.png
```
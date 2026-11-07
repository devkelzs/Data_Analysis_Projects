# Executive Report — NYC Yellow Taxi Data Analysis 2025

![Dashboard 1 — Executive Overview](powerbi_dashboards/Screenshot%202026-11-06%20120428.png)

## Executive Summary

This project analyzes approximately **48.72 million NYC Yellow Taxi trips recorded during 2025** to understand demand, geography, trip characteristics, charges, payment behavior, vendor differences, and data quality.

The analysis shows that taxi demand is strongly shaped by **time, location, seasonality, and payment behavior**. Demand is concentrated in particular zones and recurring time windows rather than being evenly distributed across New York City.

May was the highest-demand month at approximately **4.59 million trips**, while August was the lowest at approximately **3.57 million trips**. September recorded a strong month-over-month increase of approximately **18.94%**.

The analysis also shows substantial geographic concentration around Manhattan and airport-related locations. Important recurring demand patterns were identified around Lower Manhattan, JFK, the Upper East Side, Midtown, and Times Square.

Payment behavior is also concentrated. Credit card trips represented approximately **63.74% of the annual trip population** and showed substantially stronger recorded positive tipping behavior than cash trips.

Data quality is an important consideration. Approximately **23.83% of trips have missing passenger counts**, while approximately **2.88% have non-positive trip distances**. Negative fare and total-amount records are also present. These observations were not automatically removed because they may represent legitimate adjustments, refunds, or other transactional behavior.

## Key Findings

### Demand

- Annual 2025 trips: **48,722,573**
- Highest month: **May — approximately 4.59M trips**
- Lowest month: **August — approximately 3.57M trips**
- Strong September month-over-month increase: **approximately 18.94%**
- Demand varies substantially by hour and weekday.

### Geography

Demand is concentrated in specific locations and changes by time of day.

Important patterns include:

- Lower Manhattan and East Village during overnight hours
- JFK during early-morning and late-night periods
- Upper East Side during daytime periods
- Midtown Center during evening periods
- Times Square during late-night activity

The Upper East Side South → Upper East Side North route recorded approximately **302,261 trips**, while the reverse route recorded approximately **259,469 trips**.

JFK → Outside NYC recorded approximately **95,267 trips**, with a median distance of approximately **17.96 miles** and median duration of approximately **37 minutes**.

### Trip Characteristics

- Average trip distance: **3.51 miles**
- Average trip duration: **17.19 minutes**
- Trips over 100 miles: **2,870**
- Non-positive distance trips: **1,402,958**
- Missing passenger count: **11,611,894**

### Revenue and Payment

Credit card trips represented approximately **63.74%** of trips.

Recorded tipping behavior differs strongly by payment method. Credit card trips show much stronger positive tipping activity than cash trips.

The analysis also identified **973,721 negative total-amount records**. These reduced the recorded total amount by approximately **$24.81M** relative to a non-negative-only total.

These values should not automatically be interpreted as errors because they may represent adjustments, refunds, or corrections.

### Vendors

Vendor activity is highly concentrated:

| Vendor | Trips | Share |
|---|---:|---:|
| Curb Mobility LLC | 38,575,817 | 79.17% |
| Creative Mobile Technologies LLC | 9,586,873 | 19.68% |
| Helix | 535,901 | 1.10% |
| Myle Technologies Inc | 23,982 | 0.05% |

Vendor IDs represent data providers and should not automatically be treated as measures of driver or service quality.

## Recommendations

1. Use **hour-and-location demand planning** rather than citywide averages.
2. Create dedicated planning windows for **JFK airport demand**.
3. Use high-volume origin-destination pairs for targeted operational planning.
4. Incorporate seasonality into demand planning.
5. Monitor payment and tipping behavior.
6. Establish continuous data-quality monitoring.
7. Investigate negative financial records before removing them.
8. Investigate differences in vendor reporting and coverage.
9. Improve passenger-count completeness.
10. Integrate future supply, waiting-time, weather, traffic, and event data to build a true supply-and-demand model.

## Important Limitation

This project measures **recorded taxi demand**, not unmet demand or taxi supply.

Trip volume alone cannot prove that a location has a taxi shortage. Supply availability, waiting time, rejected trips, and passenger abandonment data would be required.

## Conclusion

The project demonstrates that large-scale taxi data can be transformed into actionable business intelligence by combining SQL-based analysis, data-quality assessment, and Power BI visualization.

The most important conclusion is that taxi demand is **highly time- and location-dependent**, while the reliability of individual KPIs depends on understanding the underlying data-quality limitations.
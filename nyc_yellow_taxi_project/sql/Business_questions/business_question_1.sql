---Q1. How does taxi trip demand change throughout 2025?

---Monthly trip demand
CREATE OR ALTER VIEW analytics.vw_q1_monthly_trip_demand
AS
WITH Monthly_trip_demand AS 
(
    SELECT 
        DATEPART(MONTH, tpep_pickup_datetime) AS PickupMonth,
        DATENAME(MONTH, tpep_pickup_datetime) AS PickupMonthName,
        COUNT(*) AS total_trips,
        COUNT(DISTINCT CAST(tpep_pickup_datetime AS DATE)) AS distinct_service_dates
    FROM analytics.vw_yellow_tripdata_2025_clean
    WHERE 
        tpep_pickup_datetime >= '2025-01-01'
    AND tpep_pickup_datetime < '2026-01-01'
    GROUP BY
        DATEPART(MONTH, tpep_pickup_datetime),
        DATENAME(MONTH, tpep_pickup_datetime)
),
MonthlyComparison AS
(
    SELECT 
        *,
        LAG(total_trips) OVER (ORDER BY PickupMonth) AS PreviousMonthTrips
    FROM Monthly_trip_demand
)
SELECT 
    PickupMonth,
    PickupMonthName,
    total_trips,
    PreviousMonthTrips,
    distinct_service_dates,
    total_trips - PreviousMonthTrips AS ChangeInTrips,
    CAST(100.0 * (total_trips - PreviousMonthTrips) /  
        NULLIF(PreviousMonthTrips, 0) AS DECIMAL(10,2)) AS mon_percentage_change
FROM MonthlyComparison;

/*1 B weekday demand
How does trip demand vary by day of the week?
*/
CREATE OR ALTER VIEW analytics.vw_q1_weekday_trip_demand
AS
WITH weekday_demand AS
(
    SELECT
        (
            DATEDIFF(
                DAY,
                '19000101',
                CAST(tpep_pickup_datetime AS DATE)
            ) % 7
        ) + 1 AS pickup_weekday,

        DATENAME(WEEKDAY, tpep_pickup_datetime) AS pickup_weekday_Name,

        COUNT(*) AS total_trips,

        COUNT(DISTINCT CAST(tpep_pickup_datetime AS DATE))
            AS distinct_service_dates

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        (
            DATEDIFF(
                DAY,
                '19000101',
                CAST(tpep_pickup_datetime AS DATE)
            ) % 7
        ) + 1,

        DATENAME(WEEKDAY, tpep_pickup_datetime)
)

SELECT
    *,
    CAST(
        total_trips * 1.0 /
        NULLIF(distinct_service_dates, 0)
        AS DECIMAL(10, 2)
    ) AS average_daily_demand

FROM weekday_demand;

/* C: hourly demand
Which hours of the day have the highest and lowest taxi trip demand?
*/
CREATE OR ALTER VIEW analytics.vw_q1_hourly_trip_demand
AS
WITH hourly_demand AS
(
    SELECT
        DATEPART(HOUR, tpep_pickup_datetime) AS pickup_hour,
        COUNT(*) AS total_trips,

        COUNT(DISTINCT CAST(tpep_pickup_datetime AS DATE))
            AS distinct_service_dates

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'

    GROUP BY DATEPART(HOUR, tpep_pickup_datetime)
),

annual_demand AS
(
    SELECT SUM(total_trips) AS annual_total_trips
    FROM hourly_demand
)

SELECT
    h.pickup_hour,
    h.total_trips,

    CAST(
        h.total_trips * 100.0 / a.annual_total_trips
        AS DECIMAL(10,4)
    ) AS percentage_trips_per_hour,

    h.distinct_service_dates,

    CAST(
        h.total_trips * 1.0 / NULLIF(h.distinct_service_dates, 0)
        AS DECIMAL(10,2)
    ) AS avg_hourly_demand

FROM hourly_demand AS h
CROSS JOIN annual_demand AS a;


----DATE COVERAGE VALIDATION 
---Check for earliest date, latest date, and distinct dates
SELECT
    MIN(CAST(tpep_pickup_datetime AS DATE)) AS earliest_pickup_date,
    MAX(CAST(tpep_pickup_datetime AS DATE)) AS latest_pickup_date,
    COUNT(DISTINCT CAST(tpep_pickup_datetime AS DATE))
        AS distinct_pickup_dates
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE tpep_pickup_datetime >= '2025-01-01'
  AND tpep_pickup_datetime < '2026-01-01';

--how many dates have no trips
SELECT
    365 - COUNT(DISTINCT CAST(tpep_pickup_datetime AS DATE)) AS dates_without_trips
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE tpep_pickup_datetime >= '2025-01-01'
  AND tpep_pickup_datetime < '2026-01-01';
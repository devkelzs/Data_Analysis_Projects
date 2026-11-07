-------Q3. How do recorded fares and trip charges vary by month, distance, and trip type?
CREATE OR ALTER VIEW analytics.vw_q3_monthly_charge_analysis
AS
WITH monthly_fare_analysis AS 
(
    SELECT 
        YEAR(tpep_pickup_datetime) AS Year,
        DATEPART(MONTH, tpep_pickup_datetime) AS PickupMonth,
        DATENAME(MONTH, tpep_pickup_datetime) AS PickupMonthName,
        COUNT(*) AS total_trips,
        SUM(tip_amount) AS total_tip_amount,
        SUM(fare_amount) AS total_fare_amount,
        SUM(tolls_amount) AS total_tolls_amount,
        SUM(total_amount) AS total_amount,
        APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) AS median_total_amount,
        ROUND(AVG(fare_amount),3 ) AS avg_fare_amount,
        ROUND(AVG(tip_amount),3 ) AS avg_tip_amount,
        ROUND(AVG(tolls_amount),3 ) AS avg_tolls_amount,
        ROUND(AVG(total_amount),3 ) AS avg_total_amount
    FROM analytics.vw_yellow_tripdata_2025_clean
    WHERE 
        tpep_pickup_datetime >= '2025-01-01'
    AND tpep_pickup_datetime < '2026-01-01'
    GROUP BY 
        YEAR(tpep_pickup_datetime),
        DATEPART(MONTH, tpep_pickup_datetime),
        DATENAME(MONTH, tpep_pickup_datetime)
)
SELECT 
    *
FROM monthly_fare_analysis;

-----how recorded fares and charges vary by trip distance
CREATE OR ALTER VIEW analytics.vw_q3_distance_charge_analysis
AS
WITH trips_band AS 
(
SELECT 
     *,
    CASE 
        WHEN trip_distance <= 0 THEN 'Non-positive'
        WHEN trip_distance <= 1 THEN 'Very Short'
        WHEN trip_distance < 3 THEN 'Short'
        WHEN trip_distance < 5 THEN 'Medium'
        WHEN trip_distance < 10 THEN 'Long'
        WHEN trip_distance < 20 THEN 'Very Long'
        WHEN trip_distance <= 50 THEN 'Extreme'
        WHEN trip_distance <= 100 THEN 'Outlier'
        ELSE 'Suspect'
    END AS distance_group,

    CASE
        WHEN trip_distance <= 0 THEN 0
        WHEN trip_distance <= 1 THEN 1
        WHEN trip_distance < 3 THEN 2
        WHEN trip_distance < 5 THEN 3
        WHEN trip_distance < 10 THEN 4
        WHEN trip_distance < 20 THEN 5
        WHEN trip_distance <= 50 THEN 6
        WHEN trip_distance <= 100 THEN 7
        ELSE 8
    END AS distance_sort
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE tpep_pickup_datetime >= '2025-01-01'
AND tpep_pickup_datetime < '2026-01-01'
)
SELECT 
    distance_group,
    COUNT(*) AS total_trips,
    ROUND(AVG(fare_amount), 3) AS avg_fare_amount,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fare_amount) AS median_fare_amount,
    ROUND(AVG(tip_amount), 3) AS avg_tip_amount,
    ROUND(AVG(total_amount), 3) AS avg_total_amount
FROM trips_band
GROUP BY 
    distance_group,
    distance_sort;

-----------how the recorded components contribute to trip totals.
CREATE OR ALTER VIEW analytics.vw_q3_distance_charge_components
AS
WITH trips_band_charged AS 
(
SELECT 
     *,
    CASE 
        WHEN trip_distance <= 0 THEN 'Non-positive'
        WHEN trip_distance <= 1 THEN 'Very Short'
        WHEN trip_distance < 3 THEN 'Short'
        WHEN trip_distance < 5 THEN 'Medium'
        WHEN trip_distance < 10 THEN 'Long'
        WHEN trip_distance < 20 THEN 'Very Long'
        WHEN trip_distance <= 50 THEN 'Extreme'
        WHEN trip_distance <= 100 THEN 'Outlier'
        ELSE 'Suspect'
    END AS distance_group,

    CASE
        WHEN trip_distance <= 0 THEN 0
        WHEN trip_distance <= 1 THEN 1
        WHEN trip_distance < 3 THEN 2
        WHEN trip_distance < 5 THEN 3
        WHEN trip_distance < 10 THEN 4
        WHEN trip_distance < 20 THEN 5
        WHEN trip_distance <= 50 THEN 6
        WHEN trip_distance <= 100 THEN 7
        ELSE 8
    END AS distance_sort
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE tpep_pickup_datetime >= '2025-01-01'
AND tpep_pickup_datetime < '2026-01-01'
)
SELECT 
    distance_group,
    COUNT(*) AS total_trips,
    ROUND(AVG(fare_amount), 3) AS avg_fare_amount,
    ROUND(AVG(extra), 3) AS avg_extra,
    ROUND(AVG(mta_tax), 3) AS avg_mta_tax,
    ROUND(AVG(tip_amount), 3) AS avg_tip_amount,
    ROUND(AVG(tolls_amount), 3) AS avg_tolls_amount,
    ROUND(AVG(improvement_surcharge), 3) AS avg_improvement_surcharge,
    ROUND(AVG(congestion_surcharge), 3) AS avg_congestion_surcharge,
    ROUND(AVG(Airport_fee), 3) AS avg_Airport_fee,
    ROUND(AVG(total_amount), 3) AS avg_total_amount
FROM trips_band_charged
GROUP BY
    distance_group,
    distance_sort;

---charges by rate code
CREATE OR ALTER VIEW analytics.vw_q3_ratecode_charge_analysis
AS
SELECT 
    RatecodeID,
    RatecodeDescription,
    COUNT(*) AS total_trips,
    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            (
                SELECT COUNT(*)
                FROM analytics.vw_yellow_tripdata_2025_clean
                WHERE tpep_pickup_datetime >= '2025-01-01'
                  AND tpep_pickup_datetime < '2026-01-01'
            ),
            0
        )
        AS DECIMAL(10, 3)
    ) AS percentage_of_trips,
    ROUND(AVG(fare_amount), 3) AS avg_fare_amount,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fare_amount) AS median_fare,
    ROUND(AVG(tip_amount), 3) AS avg_tip_amount,
    ROUND(AVG(tolls_amount), 3) AS avg_tolls_amount,
    ROUND(AVG(total_amount), 3) AS avg_total_amount
FROM analytics.vw_yellow_tripdata_2025_clean 
WHERE 
    tpep_pickup_datetime >= '2025-01-01'
AND 
    tpep_pickup_datetime < '2026-01-01'
AND RatecodeDescription IS NOT NULL
GROUP BY 
    RatecodeID,
    RatecodeDescription;

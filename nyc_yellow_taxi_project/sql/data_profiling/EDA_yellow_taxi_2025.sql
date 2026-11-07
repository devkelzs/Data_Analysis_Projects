-----------------------------------------------EDA DATA ANALYSIS--------------------------------------------------
-----------CHECK FOR DATATYPE, COL NAME, CHARCATER MAX LENGTH--
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'analytics'
AND 
    TABLE_NAME = 'vw_yellow_tripdata_2025_clean'
ORDER BY
    ORDINAL_POSITION;

/*
summary statistics for trip_distance
TripDurationMinutes
fare_amount
tip_amount
total_amount
passenger_count
*/
SELECT 
    'trip_distance' AS [COLUMN],
    COUNT(trip_distance) AS COUNT,
    ROUND(AVG(CAST(trip_distance AS FLOAT)), 3) AS MEAN,
    MAX(CAST(trip_distance AS FLOAT)) AS MAX,
    MIN(CAST(trip_distance AS FLOAT)) AS MIN,
    SUM(CAST(trip_distance AS FLOAT)) AS SUM,
    STDEV(CAST(trip_distance as FLOAT)) AS [std Dev]
FROM analytics.vw_yellow_tripdata_2025_clean

UNION ALL

SELECT 
    'TripDurationMinutes' AS [COLUMN],
    COUNT(TripDurationMinutes) AS COUNT,
    ROUND(AVG(CAST(TripDurationMinutes AS FLOAT)), 3) AS MEAN,
    MAX(CAST(TripDurationMinutes AS FLOAT)) AS MAX,
    MIN(CAST(TripDurationMinutes AS FLOAT)) AS MIN,
    SUM(CAST(TripDurationMinutes AS FLOAT)) AS SUM,
    STDEV(CAST(TripDurationMinutes as FLOAT)) AS [std Dev]
FROM analytics.vw_yellow_tripdata_2025_clean

UNION ALL

SELECT 
    'fare_amount' AS [COLUMN],
    COUNT(fare_amount) AS COUNT,
    ROUND(AVG(CAST(fare_amount AS FLOAT)), 3) AS MEAN,
    MAX(CAST(fare_amount AS FLOAT)) AS MAX,
    MIN(CAST(fare_amount AS FLOAT)) AS MIN,
    SUM(CAST(fare_amount AS FLOAT)) AS SUM,
    STDEV(CAST(fare_amount as FLOAT)) AS [std Dev]
FROM analytics.vw_yellow_tripdata_2025_clean

UNION ALL

SELECT 
    'tip_amount' AS [COLUMN],
    COUNT(tip_amount) AS COUNT,
    ROUND(AVG(CAST(tip_amount AS FLOAT)), 3) AS MEAN,
    MAX(CAST(tip_amount AS FLOAT)) AS MAX,
    MIN(CAST(tip_amount AS FLOAT)) AS MIN,
    SUM(CAST(tip_amount AS FLOAT)) AS SUM,
    STDEV(CAST(tip_amount as FLOAT)) AS [std Dev]
FROM analytics.vw_yellow_tripdata_2025_clean

UNION ALL

SELECT 
    'total_amount' AS [COLUMN],
    COUNT(total_amount) AS COUNT,
    ROUND(AVG(CAST(total_amount AS FLOAT)), 3) AS MEAN,
    MAX(CAST(total_amount AS FLOAT)) AS MAX,
    MIN(CAST(total_amount AS FLOAT)) AS MIN,
    SUM(CAST(total_amount AS FLOAT)) AS SUM,
    STDEV(CAST(total_amount as FLOAT)) AS [std Dev]
FROM analytics.vw_yellow_tripdata_2025_clean

UNION ALL

SELECT 
    'passenger_count' AS [COLUMN],
    COUNT(passenger_count) AS COUNT,
    ROUND(AVG(CAST(passenger_count AS FLOAT)), 3) AS MEAN,
    MAX(CAST(passenger_count AS FLOAT)) AS MAX,
    MIN(CAST(passenger_count AS FLOAT)) AS MIN,
    SUM(CAST(passenger_count AS FLOAT)) AS SUM,
    STDEV(CAST(passenger_count as FLOAT)) AS [std Dev]
FROM analytics.vw_yellow_tripdata_2025_clean;

----Univariate analysis-------------------
SELECT 
    'trip_distance' AS [COLUMN],
    APPROX_PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY trip_distance)  AS P25,
    APPROX_PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY trip_distance)  AS P50,
    APPROX_PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY trip_distance)  AS P75
FROM analytics.vw_yellow_tripdata_2025_clean

UNION ALL

SELECT 
    'TripDurationMinutes' AS [COLUMN],
    APPROX_PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TripDurationMinutes)  AS P25,
    APPROX_PERCENTILE_CONT(0.50)WITHIN GROUP (ORDER BY TripDurationMinutes) AS P50,
    APPROX_PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TripDurationMinutes) AS P75
    
FROM analytics.vw_yellow_tripdata_2025_clean

UNION ALL

SELECT 
    'total_amount' AS [COLUMN],
    APPROX_PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_amount) AS P25,
    APPROX_PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_amount)  AS P50,
    APPROX_PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_amount)  AS P75
FROM analytics.vw_yellow_tripdata_2025_clean;

--------------------BIVARIATE ANALYSIS --------------
WITH trip_dis_group AS
(
SELECT 
    *,
    CASE 
        WHEN trip_distance < 1 THEN 'Very Short'
        WHEN trip_distance < 3 THEN 'Short'
        WHEN trip_distance < 5 THEN 'Medium'
        WHEN trip_distance < 10 THEN 'Long'
        WHEN trip_distance < 20 THEN 'Very Long'
        WHEN trip_distance < 50 THEN 'Extreme'
        WHEN trip_distance < 100 THEN 'Outlier'
        ELSE 'Suspect'
    END AS distance_group
FROM analytics.vw_yellow_tripdata_2025_clean
)
SELECT 
    distance_group,
    COUNT(*) AS total_count, 
    ROUND(AVG(trip_distance), 3) AS avg_distance,
    ROUND(AVG(total_amount),3) AS Avg_amount,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) median_amount
FROM trip_dis_group
GROUP BY
    distance_group;

--------Do longer trips also tend to take longer?
WITH trips_band AS 
(
SELECT 
     *,
    CASE 
        WHEN trip_distance < 1 THEN 'Very Short'
        WHEN trip_distance < 3 THEN 'Short'
        WHEN trip_distance < 5 THEN 'Medium'
        WHEN trip_distance < 10 THEN 'Long'
        WHEN trip_distance < 20 THEN 'Very Long'
        WHEN trip_distance < 50 THEN 'Extreme'
        WHEN trip_distance < 100 THEN 'Outlier'
        ELSE 'Suspect'
    END AS distance_group
FROM analytics.vw_yellow_tripdata_2025_clean
)
SELECT 
    distance_group,
    COUNT(TripDurationMinutes) AS count_with_duration,
    COUNT(*) AS total_records_in_group,
    ROUND(AVG(TripDurationMinutes), 3) AS avg_trip_duration,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TripDurationMinutes) AS media_duration,
    ROUND(AVG(trip_distance), 3) AS avg_trip_distance
FROM trips_band
GROUP BY
    distance_group;

------passenger count versus fare
SELECT 
    passenger_count,
    COUNT(passenger_count) AS total_count,
    ROUND(AVG(fare_amount), 3) AS avg_fare_amount,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fare_amount) AS median_fare,
    ROUND(AVG(trip_distance),3) AS avg_trip_distance
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE passenger_count IS NOT NULL
GROUP BY
    passenger_count;

----payment type and trip economics
SELECT 
    PaymentTypeName,
    COUNT(*) AS total_count,
    ROUND(AVG(total_amount), 3) AS avg_total_amount,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) AS median_amount,
    ROUND(AVG(tip_amount), 3 ) AS avg_tip_amount,
    SUM(CASE WHEN tip_amount > 0  THEN 1 ELSE 0 END) * 100.00 / COUNT(*) AS pct_with_positive_tip
FROM analytics.vw_yellow_tripdata_2025_clean
GROUP BY 
    PaymentTypeName;

SELECT 
    PaymentTypeName,
    COUNT(*) AS total_trips,
    SUM(CASE WHEN passenger_count IS NOT NULL THEN 1 ELSE 0 END) AS trips_not_null_passenger_count,
    SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END ) AS trips_null_passenger_count,
    SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END ) * 100.00 / COUNT(*) as Percentage_null_cols
FROM analytics.vw_yellow_tripdata_2025_clean
GROUP BY
    PaymentTypeName;

-----monthly trip-volume analysis

SELECT 
    YEAR(tpep_pickup_datetime) AS Pickup_year,
    DATENAME(Month, tpep_pickup_datetime) AS pickup_month,
    COUNT(*) AS total_trips_per_month,
    ROUND(AVG(trip_distance), 3) AS avg_trip_distance_per_month,
    ROUND(AVG(TripDurationMinutes), 3) AS avg_trip_duration_per_month,
    ROUND(AVG(total_amount), 3) AS avg_total_amount_per_month
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE 
    YEAR(tpep_pickup_datetime) = 2025
GROUP BY 
    YEAR(tpep_pickup_datetime),
    DATENAME(Month, tpep_pickup_datetime),
     MONTH(tpep_pickup_datetime)
ORDER BY 
    MONTH(tpep_pickup_datetime);

-----------Hour-of-day analysis--------
SELECT
    DATEPART(HOUR, tpep_pickup_datetime) AS pickup_hour,
    COUNT(*) AS total_trips,
    ROUND(AVG(TripDurationMinutes), 3) AS avg_trip_duration,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TripDurationMinutes) AS median_trip_duration,
    ROUND(AVG(trip_distance), 3) AS avg_trip_distance,
    ROUND(AVG(total_amount), 3) AS avg_total_amount
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE 
    YEAR(tpep_pickup_datetime) = 2025
GROUP BY
    DATEPART(HOUR, tpep_pickup_datetime)
ORDER BY
    DATEPART(HOUR, tpep_pickup_datetime);

---day-of-week analysis
SELECT
    DATEPART(WEEKDAY, tpep_pickup_datetime) AS pickup_weekday,
    DATENAME(WEEKDAY, tpep_pickup_datetime) AS pickup_weekday,
    COUNT(*) AS total_trips,
    ROUND(AVG(TripDurationMinutes), 3) AS avg_trip_duration,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TripDurationMinutes) AS median_trip_duration,
    ROUND(AVG(trip_distance), 3) AS avg_trip_distance,
    ROUND(AVG(total_amount), 3) AS avg_total_amount
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE 
    YEAR(tpep_pickup_datetime) = 2025
GROUP BY
    DATEPART(WEEKDAY, tpep_pickup_datetime),
    DATENAME(WEEKDAY, tpep_pickup_datetime)
ORDER BY
    DATEPART(WEEKDAY, tpep_pickup_datetime);

---Geographical eda using pikcup and drop-off locations to understand where taxi activity is concentrated
----PULOCATIONID
SELECT TOP 10
    PULocationID,
    COUNT(*) AS total_trips_per_pulocation,
    COUNT(*) * 100.0 /(SELECT COUNT(*) 
                       FROM analytics.vw_yellow_tripdata_2025_clean
                       WHERE YEAR(tpep_pickup_datetime) = 2025)
                        AS percentage_per_pulocation
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE 
    YEAR(tpep_pickup_datetime) = 2025
GROUP BY 
    PULocationID
ORDER BY 
    total_trips_per_pulocation DESC;
    
--DOLOCATIONID
SELECT TOP 10
    DOLocationID,
    COUNT(*) AS total_trips_per_DOLocationID,
    COUNT(*) * 100.0 /(SELECT COUNT(*) 
                       FROM analytics.vw_yellow_tripdata_2025_clean
                       WHERE YEAR(tpep_dropoff_datetime) = 2025)
                        AS percentage_per_DOLocationID
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE 
    YEAR(tpep_dropoff_datetime) = 2025
GROUP BY 
    DOLocationID
ORDER BY 
    total_trips_per_DOLocationID DESC;

---mapping both pickup and drop-off IDs to their respective boroughs and zone names
SELECT TOP 10
    yt.PULocationID,
    pickup.Borough AS PickupBorough,
    pickup.Zone AS PickupZone,
    yt.DOLocationID,
    dropoff.Borough AS DropoffBorough,
    dropoff.Zone AS DropoffZone,
    COUNT(*) AS TotalTrips
FROM analytics.vw_yellow_tripdata_2025_clean AS yt
INNER JOIN analytics.taxi_zone_lookup AS pickup
    ON yt.PULocationID = pickup.LocationID
INNER JOIN analytics.taxi_zone_lookup AS dropoff
    ON yt.DOLocationID = dropoff.LocationID
WHERE yt.tpep_pickup_datetime >= '2025-01-01'
  AND yt.tpep_pickup_datetime < '2026-01-01'
GROUP BY
    yt.PULocationID,
    pickup.Borough,
    pickup.Zone,
    yt.DOLocationID,
    dropoff.Borough,
    dropoff.Zone
ORDER BY TotalTrips DESC;

---Which boroughs account for the most pickups and drop-offs?
---the busiest borough-to-borough routes
SELECT TOP 15
    pickup.Borough AS PickupBorough,
    dropoff.Borough AS DropoffBorough,
    COUNT(*) AS total_trips,
    CAST(COUNT(*) * 100.00 / (SELECT COUNT(*)   
                            FROM analytics.vw_yellow_tripdata_2025_clean
                            WHERE YEAR(tpep_pickup_datetime ) = 2025
                                    ) AS DECIMAL(16,4)) AS count_percentage
FROM analytics.vw_yellow_tripdata_2025_clean AS yt
INNER JOIN analytics.taxi_zone_lookup AS pickup
    ON yt.PULocationID = pickup.LocationID
INNER JOIN analytics.taxi_zone_lookup AS dropoff
    ON yt.DOLocationID = dropoff.LocationID  
WHERE 
    YEAR(yt.tpep_pickup_datetime) = 2025
GROUP BY 
    pickup.Borough,
    dropoff.Borough 
ORDER BY
    total_trips DESC;

----pickup activity by borough
SELECT 
    pickup.Borough AS pickup_borough,
    COUNT(*) AS total_count,
    CAST(COUNT(*) * 100.00 / (SELECT COUNT(*)   
                            FROM analytics.vw_yellow_tripdata_2025_clean
                            WHERE YEAR(tpep_pickup_datetime ) = 2025
                                    ) AS DECIMAL(16,4)) AS count_percentage
FROM analytics.vw_yellow_tripdata_2025_clean AS yt
INNER JOIN analytics.taxi_zone_lookup AS pickup
    ON yt.PULocationID = pickup.LocationID
WHERE 
    YEAR(yt.tpep_pickup_datetime) = 2025
GROUP BY
    pickup.Borough
ORDER BY
    total_count DESC;

----drop-off activity by borough
SELECT 
    dropoff.Borough AS DOLocationID_borough,
    COUNT(*) AS total_count,
    CAST(COUNT(*) * 100.00 / (SELECT COUNT(*)   
                            FROM analytics.vw_yellow_tripdata_2025_clean
                            WHERE YEAR(tpep_pickup_datetime ) = 2025
                                    ) AS DECIMAL(16,4))AS count_percentage
FROM analytics.vw_yellow_tripdata_2025_clean AS yt
INNER JOIN analytics.taxi_zone_lookup AS dropoff

    ON yt.DOLocationID = dropoff.LocationID
WHERE 
    YEAR(yt.tpep_dropoff_datetime) = 2025
GROUP BY
    dropoff.Borough
ORDER BY
    total_count DESC;

----average trip distance, average duration, and average total amount across pickup boroughs
SELECT 
    pickup.borough,
    COUNT(*) AS trip_count,
    ROUND(AVG(yt.trip_distance), 3) AS avg_trip_distance,
    ROUND(AVG(yt.TripDurationMinutes), 3) AS avg_trip_duration,
    ROUND(AVG(yt.total_amount), 3) AS avg_total_amount,
     -- Filtered average
    AVG(
        CASE
            WHEN yt.trip_distance > 0
             AND yt.trip_distance <= 100
            THEN yt.trip_distance
            ELSE NULL
        END
    ) AS FilteredAvgTripDistance,

    -- Approximate median
    APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY yt.trip_distance)
        AS ApproxMedianTripDistance,

    -- Count excluded distance records
    SUM(
        CASE
            WHEN yt.trip_distance = 0
              OR yt.trip_distance > 100
            THEN 1
            ELSE 0
        END
    ) AS ExcludedDistanceRecords
FROM analytics.vw_yellow_tripdata_2025_clean AS yt
INNER JOIN analytics.taxi_zone_lookup AS pickup
    ON yt.PULocationID = pickup.LocationID  
WHERE 
    YEAR(yt.tpep_pickup_datetime) = 2025
GROUP BY 
    pickup.borough

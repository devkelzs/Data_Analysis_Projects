/*Trip duration, distance, and implied speed
How do trip duration, distance, and implied speed vary by time of day?
*/
CREATE OR ALTER VIEW analytics.vw_q5_hourly_trip_duration
AS
SELECT 
    DATEPART(HOUR, tpep_pickup_datetime) AS Hour_of_day,
    COUNT(*) AS total_trips,
    ROUND(AVG(TripDurationMinutes), 3) AS avg_trip_duration,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TripDurationMinutes) AS median_trip_duration,
    SUM(CASE WHEN TripDurationMinutes <= 0 THEN 1 ELSE 0 END ) AS trips_with_negative_zero_duration,
    SUM(CASE WHEN TripDurationMinutes > 300 THEN 1 ELSE 0 END ) AS extreme_trip_duration,
    CAST(SUM(CASE WHEN TripDurationMinutes > 300 THEN 1 ELSE 0 END ) * 100.00 / COUNT(*) AS DECIMAL(10,2)) AS trips_morethan_300mins,
    AVG(
    CASE
        WHEN TripDurationMinutes > 0
        THEN TripDurationMinutes
    END
    ) AS avg_duration_minutes,
    APPROX_PERCENTILE_CONT(0.5) 
        WITHIN GROUP (
                ORDER BY CASE
                     WHEN TripDurationMinutes > 0  
                     THEN TripDurationMinutes 
                     END )  AS median_duration_minutes
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE 
    tpep_pickup_datetime >= '2025-01-01'
AND 
    tpep_pickup_datetime < '2026-01-01'
GROUP BY
    DATEPART(HOUR, tpep_pickup_datetime);

--------implied speed
CREATE OR ALTER VIEW analytics.vw_q5_hourly_trip_speed
AS
WITH implied_speed AS (
    SELECT 
        DATEPART(HOUR, tpep_pickup_datetime) AS Hour_of_day,
        trip_distance,
        TripDurationMinutes,
        (trip_distance * 60.0 / NULLIF(TripDurationMinutes, 0) ) AS speed_mph
    FROM analytics.vw_yellow_tripdata_2025_clean
    WHERE 
          tpep_pickup_datetime >= '2025-01-01'
    AND 
        tpep_pickup_datetime < '2026-01-01'
    AND 
        TripDurationMinutes > 0
    AND 
        TripDurationMinutes <= 300 
    AND 
        trip_distance > 0 
),

speed_statisitcs AS 
(
     SELECT
        Hour_of_day,
        COUNT(*) AS total_trips,
        AVG(speed_mph) AS avg_speed,
        APPROX_PERCENTILE_CONT(0.5)
            WITHIN GROUP (ORDER BY speed_mph) AS median_speed,
        SUM(CASE WHEN speed_mph > 60 THEN 1 ELSE 0 END ) AS implied_speed_60p,
        SUM(CASE WHEN speed_mph > 80 THEN 1 ELSE 0 END ) AS implied_speed_80p,
        SUM(CASE WHEN speed_mph > 100 THEN 1 ELSE 0 END ) AS implied_speed_100p,
        SUM(CASE WHEN speed_mph > 150 THEN 1 ELSE 0 END ) AS implied_speed_150p,
        MAX(speed_mph) AS max_implied_speed,
        APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY speed_mph) AS median_implied_speed
    FROM implied_speed
    GROUP BY Hour_of_day
)
SELECT 
    Hour_of_day, 
    total_trips,
    ROUND(avg_speed, 2) AS avg_speed,
    ROUND(median_speed, 2) AS median_speed,
    implied_speed_60p,
    implied_speed_80p,
    implied_speed_100p,
    implied_speed_150p,
    max_implied_speed
FROM speed_statisitcs;








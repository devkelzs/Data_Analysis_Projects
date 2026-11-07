/*Which origin-destination pairs show the strongest demand, 
and how do their characteristics compare?
*/
CREATE OR ALTER VIEW analytics.vw_q7_origin_destination_demand
AS
WITH Origin_destination_analysis AS 
(
    SELECT 
        yt.PULocationID AS PULocationID,
        pickup.zone AS pickupzone,
        pickup.Borough AS PickupBorough,
        yt.DOLocationID AS DOLocationID,
        dropoff.zone AS dropoffzone,
        dropoff.Borough AS dropoff_borough,

        COUNT(*) AS total_trips,
        COUNT(*) * 100.00 / NULLIF((SELECT COUNT(*)
                                     FROM analytics.vw_yellow_tripdata_2025_clean
                                     WHERE tpep_pickup_datetime >= '2025-01-01'
                                     AND tpep_pickup_datetime < '2026-01-01'), 0) AS percentage_trips,
        --trip_distance---
        AVG(trip_distance) AS avg_trip_distance, 
        APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY trip_distance) AS median_trip_distance,
        ---ftrip duration--
        AVG(TripDurationMinutes) AS avg_trip_duration,
        APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY TripDurationMinutes) AS median_trip_duration,
        ---fare amount
        AVG(fare_amount) AS avg_fare_amount,
        APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY fare_amount) AS median_fare_amount,
        ---total_amount
        AVG(total_amount) AS avg_total_amount,
        APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_amount) AS median_total_amount
    FROM 
        analytics.vw_yellow_tripdata_2025_clean AS yt  
    INNER JOIN 
        analytics.taxi_zone_lookup AS pickup  
    ON 
        yt.PULocationID = pickup.LocationID
    INNER JOIN 
        analytics.taxi_zone_lookup AS dropoff 
    ON  
        yt.DOLocationID = dropoff.LocationID
    WHERE 
        tpep_pickup_datetime >= '2025-01-01'
    AND 
        tpep_pickup_datetime < '2026-01-01'
    GROUP BY 
        yt.PULocationID,
        pickup.zone,
        pickup.Borough,
        yt.DOLocationID,
        dropoff.zone,
        dropoff.Borough
)
SELECT
        PULocationID,
        pickupzone,
        PickupBorough,
        DOLocationID,
        dropoffzone,
        dropoff_borough,
        total_trips,
        percentage_trips,
        avg_trip_distance,
        median_trip_distance,
        avg_trip_duration,
        median_trip_duration,
        avg_fare_amount,
        median_fare_amount,
        avg_total_amount,
        median_total_amount
FROM Origin_destination_analysis;


----Data-quality screening of the top 20 routes
CREATE OR ALTER VIEW analytics.vw_q7_origin_destination_quality
AS
WITH DQ_Origin_destination_analysis AS 
(
    SELECT 
        yt.PULocationID AS PULocationID,
        pickup.zone AS pickupzone,
        pickup.Borough AS PickupBorough,
        yt.DOLocationID AS DOLocationID,
        dropoff.zone AS dropoffzone,
        dropoff.Borough AS dropoff_borough,
        COUNT(*) AS total_trips,
        SUM(CASE WHEN yt.trip_distance <= 0 THEN 1 ELSE 0 END ) AS non_positive_trip_distance,
        SUM(CASE WHEN yt.trip_distance > 100 THEN 1 ELSE 0 END ) as trip_distance_gt_100miles,
        SUM(CASE WHEN yt.TripDurationMinutes > 300 THEN 1 ELSE 0 END) AS trip_duration_gt_300mins,
        SUM(CASE WHEN yt.TripDurationMinutes < 0 THEN 1 ELSE 0 END ) AS negtative_tripduration,
        AVG(CASE WHEN yt.trip_distance > 0 
                AND yt.trip_distance <=100 
                THEN yt.trip_distance
            END ) AS avg_trip_distance_positive_up_to_100_miles,

        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP ( ORDER BY 
            CASE 
                WHEN yt.trip_distance > 0
                AND yt.trip_distance <= 100
                THEN yt.trip_distance
            END 
        ) AS  median_trip_distance_positive_up_to_100_miles,

        AVG(CASE WHEN yt.TripDurationMinutes > 0 
                AND yt.TripDurationMinutes <=300 
                THEN yt.TripDurationMinutes
            END ) AS avg_TripDurationMinutes_positive_up_to_100_miles,
        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP ( ORDER BY 
            CASE 
                WHEN yt.TripDurationMinutes > 0
                AND yt.TripDurationMinutes <= 300
                THEN yt.TripDurationMinutes
            END 
        ) AS  median_TripDurationMinutes_positive_up_to_100_miles
    FROM 
        analytics.vw_yellow_tripdata_2025_clean AS yt  
    INNER JOIN 
        analytics.taxi_zone_lookup AS pickup  
    ON 
        yt.PULocationID = pickup.LocationID
    INNER JOIN 
        analytics.taxi_zone_lookup AS dropoff 
    ON  
        yt.DOLocationID = dropoff.LocationID
    WHERE 
        tpep_pickup_datetime >= '2025-01-01'
    AND 
        tpep_pickup_datetime < '2026-01-01'
    GROUP BY 
        yt.PULocationID,
        pickup.zone,
        pickup.Borough,
        yt.DOLocationID,
        dropoff.zone,
        dropoff.Borough
)
SELECT
        PULocationID,
        pickupzone,
        PickupBorough,
        DOLocationID,
        dropoffzone,
        dropoff_borough,
        total_trips,
        non_positive_trip_distance,
        trip_distance_gt_100miles,
        trip_duration_gt_300mins,
        negtative_tripduration,
        avg_trip_distance_positive_up_to_100_miles,
        median_trip_distance_positive_up_to_100_miles,
        avg_TripDurationMinutes_positive_up_to_100_miles,
        median_TripDurationMinutes_positive_up_to_100_miles
FROM DQ_Origin_destination_analysis
/*
Q6 - Passenger counts and trip distances
Business question: How do passenger counts relate to trip distances?
Business objective: Understand the distribution of recorded passenger counts 
and examine how trip distances differ across passenger-count categories.
*/
CREATE OR ALTER VIEW analytics.vw_q6_passenger_distance_analysis
AS
WITH passenger_count_distribution AS (
         SELECT
            passenger_count,
            COUNT(*) AS total_trips,

            COUNT(*) * 100.0 /
            NULLIF(
                (SELECT COUNT(*)
                FROM analytics.vw_yellow_tripdata_2025_clean
                WHERE tpep_pickup_datetime >= '2025-01-01'
                AND tpep_pickup_datetime < '2026-01-01'),
                0
            ) AS percentage_trips,
            AVG(trip_distance) AS avg_trip_distance,
            APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY trip_distance) AS median_trip_distance,
            MAX(trip_distance) AS maximum_trip_distance,
            MIN(trip_distance) AS minimum_trip_distance,
            SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END) AS missing_passenger_count,
            SUM(CASE WHEN trip_distance > 100 THEN 1 ELSE 0 END ) AS trip_greater_100_miles,
            SUM(CASE WHEN trip_distance < 0 THEN 1 ELSE 0 END ) AS negative_trip_distance,
            AVG(
            CASE
                WHEN trip_distance > 0
                AND trip_distance <= 100
                THEN trip_distance
            END
        ) AS  avg_trip_distance_positive_up_to_100_miles,
            APPROX_PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY
                    CASE
                        WHEN trip_distance > 0
                        AND trip_distance <= 100
                        THEN trip_distance
                    END
            ) AS median_trip_distance_positive_up_to_100_miles
    FROM analytics.vw_yellow_tripdata_2025_clean
    WHERE tpep_pickup_datetime >= '2025-01-01'
    AND tpep_pickup_datetime < '2026-01-01'
    GROUP BY
         passenger_count
)
SELECT 
    passenger_count,
    total_trips,
    ROUND(percentage_trips, 2) AS percentage_trips,
    ROUND(avg_trip_distance, 2) AS avg_trip_distance,
    ROUND(median_trip_distance, 2) AS median_trip_distance,
    maximum_trip_distance,
    minimum_trip_distance,
    missing_passenger_count,
    trip_greater_100_miles,
    negative_trip_distance,
    avg_trip_distance_positive_up_to_100_miles,
    median_trip_distance_positive_up_to_100_miles
FROM passenger_count_distribution;


-------------------

---How does trip distance distribution vary by passenger count?
CREATE OR ALTER VIEW analytics.vw_q6_passenger_distance_bands
AS
WITH passenger_distance_bands AS
(
    SELECT
        passenger_count,

        COUNT(*) AS total_trips,

        -- Non-positive distances
        SUM(CASE
            WHEN trip_distance <= 0 THEN 1 ELSE 0
        END) AS non_positive_trips,

        -- Very short: 0 to 1 mile
        SUM(CASE
            WHEN trip_distance > 0 AND trip_distance <= 1
            THEN 1 ELSE 0
        END) AS very_short_trips,

        -- Short: 1 to 3 miles
        SUM(CASE
            WHEN trip_distance > 1 AND trip_distance <= 3
            THEN 1 ELSE 0
        END) AS short_trips,

        -- Medium: 3 to 5 miles
        SUM(CASE
            WHEN trip_distance > 3 AND trip_distance <= 5
            THEN 1 ELSE 0
        END) AS medium_trips,

        -- Long: 5 to 10 miles
        SUM(CASE
            WHEN trip_distance > 5 AND trip_distance <= 10
            THEN 1 ELSE 0
        END) AS long_trips,

        -- Very long: 10 to 20 miles
        SUM(CASE
            WHEN trip_distance > 10 AND trip_distance <= 20
            THEN 1 ELSE 0
        END) AS very_long_trips,

        -- Extreme: 20 to 50 miles
        SUM(CASE
            WHEN trip_distance > 20 AND trip_distance <= 50
            THEN 1 ELSE 0
        END) AS extreme_trips,

        -- Outlier: 50 to 100 miles
        SUM(CASE
            WHEN trip_distance > 50 AND trip_distance <= 100
            THEN 1 ELSE 0
        END) AS outlier_trips,

        -- Suspect: greater than 100 miles
        SUM(CASE
            WHEN trip_distance > 100 THEN 1 ELSE 0
        END) AS suspect_trips,

        -- Missing distance
        SUM(CASE
            WHEN trip_distance IS NULL THEN 1 ELSE 0
        END) AS missing_distance_trips

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'

    GROUP BY passenger_count
),

passenger_distance_percentages AS
(
    SELECT
        *,

        -- Percentage distribution within each passenger category
        ROUND(non_positive_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_non_positive,

        ROUND(very_short_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_very_short,

        ROUND(short_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_short,

        ROUND(medium_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_medium,

        ROUND(long_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_long,

        ROUND(very_long_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_very_long,

        ROUND(extreme_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_extreme,

        ROUND(outlier_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_outlier,

        ROUND(suspect_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_suspect,

        ROUND(missing_distance_trips * 100.0 / NULLIF(total_trips, 0), 2)
            AS percentage_missing_distance

    FROM passenger_distance_bands
)

SELECT *
FROM passenger_distance_percentages;

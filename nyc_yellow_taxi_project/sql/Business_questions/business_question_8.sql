----Business question: How do trip characteristics and charges differ by vendor?
CREATE OR ALTER VIEW analytics.vw_q8_vendor_trip_characteristics
AS
WITH vendor_trip_characteristics AS
(
    SELECT
        VendorID,
        VendorName,

        -- Volume characteristics
        COUNT(*) AS total_trips,

        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*)
             FROM analytics.vw_yellow_tripdata_2025_clean
             WHERE tpep_pickup_datetime >= '2025-01-01'
               AND tpep_pickup_datetime < '2026-01-01'),
            0
        ) AS percentage_trips,

        -- Trip distance: > 0 and <= 100 miles
        AVG(
            CASE
                WHEN trip_distance > 0
                 AND trip_distance <= 100
                THEN trip_distance
            END
        ) AS avg_trip_distance_positive_up_to_100_miles,

        APPROX_PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY
                    CASE
                        WHEN trip_distance > 0
                         AND trip_distance <= 100
                        THEN trip_distance
                    END
            ) AS median_trip_distance_positive_up_to_100_miles,

        -- Trip duration: > 0 and <= 300 minutes
        AVG(
            CASE
                WHEN TripDurationMinutes > 0
                 AND TripDurationMinutes <= 300
                THEN TripDurationMinutes
            END
        ) AS avg_trip_duration_1_to_300_minutes,

        APPROX_PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY
                    CASE
                        WHEN TripDurationMinutes > 0
                         AND TripDurationMinutes <= 300
                        THEN TripDurationMinutes
                    END
            ) AS median_trip_duration_1_to_300_minutes,

        -- Fare amount: positive values
        AVG(
            CASE
                WHEN fare_amount > 0
                THEN fare_amount
            END
        ) AS avg_fare_amount,

        APPROX_PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY
                    CASE
                        WHEN fare_amount > 0
                        THEN fare_amount
                    END
            ) AS median_fare_amount,

        -- Total amount: positive values
        AVG(
            CASE
                WHEN total_amount > 0
                THEN total_amount
            END
        ) AS avg_total_amount,

        APPROX_PERCENTILE_CONT(0.5)
            WITHIN GROUP (
                ORDER BY
                    CASE
                        WHEN total_amount > 0
                        THEN total_amount
                    END
            ) AS median_total_amount

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        VendorID,
        VendorName
)

SELECT *
FROM vendor_trip_characteristics;


-- How does data quality differ by vendor?
CREATE OR ALTER VIEW analytics.vw_q8_vendor_data_quality
AS
WITH vendor_data_quality AS
(
    SELECT
        VendorID,
        VendorName,
        COUNT(*) AS total_trips,

        -- 1. Missing trip duration
        SUM(CASE
            WHEN TripDurationMinutes IS NULL THEN 1
            ELSE 0
        END) AS missing_trip_duration,

        -- 2. Zero or negative trip distance
        SUM(CASE
            WHEN trip_distance <= 0 THEN 1
            ELSE 0
        END) AS non_positive_trip_distance,

        -- 3. Trip distance above 100 miles
        SUM(CASE
            WHEN trip_distance > 100 THEN 1
            ELSE 0
        END) AS trips_above_100_miles,

        -- 4. Zero or negative fare amounts
        SUM(CASE
            WHEN fare_amount <= 0 THEN 1
            ELSE 0
        END) AS non_positive_fare_amount,

        -- 5. Zero or negative total amounts
        SUM(CASE
            WHEN total_amount <= 0 THEN 1
            ELSE 0
        END) AS non_positive_total_amount

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        VendorID,
        VendorName
)

SELECT
    VendorID,
    VendorName,
    total_trips,

    -- Missing duration percentage
    missing_trip_duration,
    CAST(missing_trip_duration * 100.0 /
        NULLIF(total_trips, 0) AS DECIMAL(10,2))
        AS percentage_missing_trip_duration,

    -- Non-positive distance percentage
    non_positive_trip_distance,
    CAST(non_positive_trip_distance * 100.0 /
        NULLIF(total_trips, 0) AS DECIMAL(10,2))
        AS percentage_non_positive_trip_distance,

    -- Distance above 100 miles percentage
    trips_above_100_miles,
    CAST(trips_above_100_miles * 100.0 /
        NULLIF(total_trips, 0) AS DECIMAL(10,2))
        AS percentage_trips_above_100_miles,

    -- Non-positive fare percentage
    non_positive_fare_amount,
    CAST(non_positive_fare_amount * 100.0 /
        NULLIF(total_trips, 0) AS DECIMAL(10,2))
        AS percentage_non_positive_fare_amount,

    -- Non-positive total amount percentage
    non_positive_total_amount,
    CAST(non_positive_total_amount * 100.0 /
        NULLIF(total_trips, 0) AS DECIMAL(10,2))
        AS percentage_non_positive_total_amount

FROM vendor_data_quality;
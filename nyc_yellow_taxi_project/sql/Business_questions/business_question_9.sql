---------How reliable is the dataset, and how do data-quality issues affect KPIs?
CREATE OR ALTER VIEW analytics.vw_q9_overall_data_quality
AS
SELECT
    -- 1. TOTAL TRIPS
    COUNT(*) AS total_2025_trips,

    -- 2. MISSING PICKUP TIMESTAMPS
    SUM(CASE
        WHEN tpep_pickup_datetime IS NULL
        THEN 1 ELSE 0
    END) AS missing_pickup_timestamps,

    -- 3. MISSING DROP-OFF TIMESTAMPS
    SUM(CASE
        WHEN tpep_dropoff_datetime IS NULL
        THEN 1 ELSE 0
    END) AS missing_dropoff_timestamps,

    -- 4. DROP-OFF EARLIER THAN PICKUP
    SUM(CASE
        WHEN tpep_pickup_datetime IS NOT NULL
         AND tpep_dropoff_datetime IS NOT NULL
         AND tpep_dropoff_datetime < tpep_pickup_datetime
        THEN 1 ELSE 0
    END) AS dropoff_before_pickup,

    -- 5. MISSING TRIP DISTANCES
    SUM(CASE
        WHEN trip_distance IS NULL
        THEN 1 ELSE 0
    END) AS missing_trip_distances,

    -- 6. NON-POSITIVE TRIP DISTANCES
    SUM(CASE
        WHEN trip_distance <= 0
        THEN 1 ELSE 0
    END) AS non_positive_trip_distances,

    -- 7. TRIP DISTANCES ABOVE 100 MILES
    SUM(CASE
        WHEN trip_distance > 100
        THEN 1 ELSE 0
    END) AS trips_above_100_miles,

    -- 8. MISSING PASSENGER COUNTS
    SUM(CASE
        WHEN passenger_count IS NULL
        THEN 1 ELSE 0
    END) AS missing_passenger_counts,

    -- 9. MISSING FARE AMOUNTS
    SUM(CASE
        WHEN fare_amount IS NULL
        THEN 1 ELSE 0
    END) AS missing_fare_amounts,

    -- 10. MISSING TOTAL AMOUNTS
    SUM(CASE
        WHEN total_amount IS NULL
        THEN 1 ELSE 0
    END) AS missing_total_amounts,

    -- 11. NEGATIVE FARE AMOUNTS
    SUM(CASE
        WHEN fare_amount < 0
        THEN 1 ELSE 0
    END) AS negative_fare_amounts,

    -- 12. NEGATIVE TOTAL AMOUNTS
    SUM(CASE
        WHEN total_amount < 0
        THEN 1 ELSE 0
    END) AS negative_total_amounts,

    -- 13. NEGATIVE TIP AMOUNTS
    SUM(CASE
        WHEN tip_amount < 0
        THEN 1 ELSE 0
    END) AS negative_tip_amounts

FROM analytics.vw_yellow_tripdata_2025_clean;

-------Missing values analysis
CREATE OR ALTER VIEW analytics.vw_q9_missing_values
AS
WITH missing_value_profile AS
(
    SELECT
        COUNT(*) AS total_2025_trips,

        SUM(CASE WHEN VendorID IS NULL
            THEN 1 ELSE 0 END) AS missing_VendorID,

        SUM(CASE WHEN RatecodeID IS NULL
            THEN 1 ELSE 0 END) AS missing_RatecodeID,

        SUM(CASE WHEN store_and_fwd_flag IS NULL
            THEN 1 ELSE 0 END) AS missing_store_and_fwd_flag,

        SUM(CASE WHEN payment_type IS NULL
            THEN 1 ELSE 0 END) AS missing_payment_type,

        SUM(CASE WHEN PULocationID IS NULL
            THEN 1 ELSE 0 END) AS missing_PULocationID,

        SUM(CASE WHEN DOLocationID IS NULL
            THEN 1 ELSE 0 END) AS missing_DOLocationID,

        SUM(CASE WHEN congestion_surcharge IS NULL
            THEN 1 ELSE 0 END) AS missing_congestion_surcharge,

        SUM(CASE WHEN Airport_fee IS NULL
            THEN 1 ELSE 0 END) AS missing_Airport_fee,

        SUM(CASE WHEN tolls_amount IS NULL
            THEN 1 ELSE 0 END) AS missing_tolls_amount,

        SUM(CASE WHEN tip_amount IS NULL
            THEN 1 ELSE 0 END) AS missing_tip_amount

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'
)

SELECT
    total_2025_trips,
    field_name,
    missing_records,

    CAST(
        missing_records * 100.0 / NULLIF(total_2025_trips, 0)
        AS DECIMAL(10,4)
    ) AS percentage_missing

FROM missing_value_profile

CROSS APPLY
(
    VALUES
        ('VendorID', missing_VendorID),
        ('RatecodeID', missing_RatecodeID),
        ('store_and_fwd_flag', missing_store_and_fwd_flag),
        ('payment_type', missing_payment_type),
        ('PULocationID', missing_PULocationID),
        ('DOLocationID', missing_DOLocationID),
        ('congestion_surcharge', missing_congestion_surcharge),
        ('Airport_fee', missing_Airport_fee),
        ('tolls_amount', missing_tolls_amount),
        ('tip_amount', missing_tip_amount)
) AS missing_fields(field_name, missing_records);

--------------KPI impact assessment
---trip distance
CREATE OR ALTER VIEW analytics.vw_q9_kpi_impact
AS
SELECT
    COUNT(*) AS total_2025_trips,

    -- 1. ALL AVAILABLE DISTANCES
    AVG(trip_distance) AS avg_all_available_distance,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY trip_distance
    ) AS median_all_available_distance,

    -- 2. POSITIVE DISTANCES ONLY
    AVG(
        CASE
            WHEN trip_distance > 0
            THEN trip_distance
        END
    ) AS avg_positive_distance,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY
            CASE
                WHEN trip_distance > 0
                THEN trip_distance
            END
    ) AS median_positive_distance,

    -- 3. POSITIVE DISTANCES UP TO 100 MILES
    AVG(
        CASE
            WHEN trip_distance > 0
             AND trip_distance <= 100
            THEN trip_distance
        END
    ) AS avg_screened_distance,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY
            CASE
                WHEN trip_distance > 0
                 AND trip_distance <= 100
                THEN trip_distance
            END
    ) AS median_screened_distance

FROM analytics.vw_yellow_tripdata_2025_clean

WHERE tpep_pickup_datetime >= '2025-01-01'
  AND tpep_pickup_datetime < '2026-01-01';


--------Revenue KPI impact

CREATE OR ALTER VIEW analytics.vw_q9_kpi_impact
AS

WITH total_population AS
(
    SELECT
        COUNT(*) AS total_2025_trips
    FROM analytics.vw_yellow_tripdata_2025_clean
    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'
),

-- =========================================
-- 1. TRIP-DISTANCE KPI IMPACT
-- =========================================
distance_kpis AS
(
    SELECT
        COUNT(trip_distance) AS all_available_count,

        AVG(trip_distance) AS avg_all_available_distance,

        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY trip_distance)
        AS median_all_available_distance,

        COUNT(CASE
            WHEN trip_distance > 0 THEN 1
        END) AS positive_distance_count,

        AVG(
            CASE
                WHEN trip_distance > 0
                THEN trip_distance
            END
        ) AS avg_positive_distance,

        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY
                CASE
                    WHEN trip_distance > 0
                    THEN trip_distance
                END
        ) AS median_positive_distance,

        COUNT(CASE
            WHEN trip_distance > 0
             AND trip_distance <= 100
            THEN 1
        END) AS screened_distance_count,

        AVG(
            CASE
                WHEN trip_distance > 0
                 AND trip_distance <= 100
                THEN trip_distance
            END
        ) AS avg_screened_distance,

        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY
                CASE
                    WHEN trip_distance > 0
                     AND trip_distance <= 100
                    THEN trip_distance
                END
        ) AS median_screened_distance

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'
),

-- =========================================
-- 2. REVENUE KPI IMPACT
-- =========================================
revenue_kpis AS
(
    SELECT

        COUNT(total_amount) AS all_amount_count,

        SUM(total_amount) AS revenue_all_amounts,

        AVG(total_amount) AS avg_total_amount_all,

        COUNT(CASE
            WHEN total_amount > 0 THEN 1
        END) AS positive_amount_count,

        SUM(
            CASE
                WHEN total_amount > 0
                THEN total_amount
            END
        ) AS revenue_positive_amounts,

        AVG(
            CASE
                WHEN total_amount > 0
                THEN total_amount
            END
        ) AS avg_positive_total_amount,

        COUNT(CASE
            WHEN total_amount >= 0 THEN 1
        END) AS non_negative_amount_count,

        SUM(
            CASE
                WHEN total_amount >= 0
                THEN total_amount
            END
        ) AS revenue_non_negative_amounts,

        AVG(
            CASE
                WHEN total_amount >= 0
                THEN total_amount
            END
        ) AS avg_non_negative_total_amount

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'
),

-- =========================================
-- 3. PASSENGER-COUNT KPI IMPACT
-- =========================================
passenger_kpis AS
(
    SELECT

        -- ALL TRIPS, INCLUDING MISSING COUNTS
        COUNT(*) AS all_passenger_trips,

        AVG(CAST(passenger_count AS DECIMAL(10,2)))
            AS avg_all_passenger_count,

        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY passenger_count
        ) AS median_all_passenger_count,

        -- RECORDED PASSENGER COUNTS
        COUNT(passenger_count) AS recorded_passenger_trips,

        AVG(CAST(passenger_count AS DECIMAL(10,2)))
            AS avg_recorded_passenger_count,

        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY passenger_count
        ) AS median_recorded_passenger_count,

        -- POSITIVE PASSENGER COUNTS ONLY
        SUM(
            CASE
                WHEN passenger_count > 0
                THEN 1 ELSE 0
            END
        ) AS positive_passenger_trips,

        AVG(
            CASE
                WHEN passenger_count > 0
                THEN CAST(passenger_count AS DECIMAL(10,2))
            END
        ) AS avg_positive_passenger_count,

        APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (
            ORDER BY
                CASE
                    WHEN passenger_count > 0
                    THEN passenger_count
                END
        ) AS median_positive_passenger_count

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'
)

-- =========================================
-- COMMON REPORTING STRUCTURE
-- =========================================
SELECT
    'Trip Distance' AS kpi_section,
    'All Available Distances' AS population,
    p.total_2025_trips,
    d.all_available_count AS population_trips,

    CAST(
        d.all_available_count * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ) AS percentage_of_total_trips,

    CAST(d.avg_all_available_distance AS DECIMAL(20,4))
        AS average_value,

    CAST(d.median_all_available_distance AS DECIMAL(20,4))
        AS median_value,

    CAST(NULL AS DECIMAL(28,2)) AS total_value

FROM distance_kpis d
CROSS JOIN total_population p

UNION ALL

SELECT
    'Trip Distance',
    'Positive Distances Only',
    p.total_2025_trips,
    d.positive_distance_count,

    CAST(
        d.positive_distance_count * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(d.avg_positive_distance AS DECIMAL(20,4)),
    CAST(d.median_positive_distance AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(28,2))

FROM distance_kpis d
CROSS JOIN total_population p

UNION ALL

SELECT
    'Trip Distance',
    'Positive Distances Up To 100 Miles',
    p.total_2025_trips,
    d.screened_distance_count,

    CAST(
        d.screened_distance_count * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(d.avg_screened_distance AS DECIMAL(20,4)),
    CAST(d.median_screened_distance AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(28,2))

FROM distance_kpis d
CROSS JOIN total_population p

UNION ALL

SELECT
    'Revenue',
    'All Recorded Total Amounts',
    p.total_2025_trips,
    r.all_amount_count,

    CAST(
        r.all_amount_count * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(r.avg_total_amount_all AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(20,4)),
    CAST(r.revenue_all_amounts AS DECIMAL(28,2))

FROM revenue_kpis r
CROSS JOIN total_population p

UNION ALL

SELECT
    'Revenue',
    'Positive Total Amounts Only',
    p.total_2025_trips,
    r.positive_amount_count,

    CAST(
        r.positive_amount_count * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(r.avg_positive_total_amount AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(20,4)),
    CAST(r.revenue_positive_amounts AS DECIMAL(28,2))

FROM revenue_kpis r
CROSS JOIN total_population p

UNION ALL

SELECT
    'Revenue',
    'Non-Negative Total Amounts',
    p.total_2025_trips,
    r.non_negative_amount_count,

    CAST(
        r.non_negative_amount_count * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(r.avg_non_negative_total_amount AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(20,4)),
    CAST(r.revenue_non_negative_amounts AS DECIMAL(28,2))

FROM revenue_kpis r
CROSS JOIN total_population p

UNION ALL

SELECT
    'Passenger Count',
    'All Trips Including Missing Counts',
    p.total_2025_trips,
    k.all_passenger_trips,

    CAST(
        k.all_passenger_trips * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(k.avg_all_passenger_count AS DECIMAL(20,4)),
    CAST(k.median_all_passenger_count AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(28,2))

FROM passenger_kpis k
CROSS JOIN total_population p

UNION ALL

SELECT
    'Passenger Count',
    'Recorded Passenger Counts',
    p.total_2025_trips,
    k.recorded_passenger_trips,

    CAST(
        k.recorded_passenger_trips * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(k.avg_recorded_passenger_count AS DECIMAL(20,4)),
    CAST(k.median_recorded_passenger_count AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(28,2))

FROM passenger_kpis k
CROSS JOIN total_population p

UNION ALL

SELECT
    'Passenger Count',
    'Positive Passenger Counts Only',
    p.total_2025_trips,
    k.positive_passenger_trips,

    CAST(
        k.positive_passenger_trips * 100.0 /
        NULLIF(p.total_2025_trips, 0)
        AS DECIMAL(10,4)
    ),

    CAST(k.avg_positive_passenger_count AS DECIMAL(20,4)),
    CAST(k.median_positive_passenger_count AS DECIMAL(20,4)),
    CAST(NULL AS DECIMAL(28,2))

FROM passenger_kpis k
CROSS JOIN total_population p;




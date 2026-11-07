SELECT
    -- fare_amount
    SUM(CASE WHEN fare_amount < 0 THEN 1 ELSE 0 END)
        AS negative_fare_amount,

    -- extra
    SUM(CASE WHEN extra < 0 THEN 1 ELSE 0 END)
        AS negative_extra,

    -- mta_tax
    SUM(CASE WHEN mta_tax < 0 THEN 1 ELSE 0 END)
        AS negative_mta_tax,

    -- tip_amount
    SUM(CASE WHEN tip_amount < 0 THEN 1 ELSE 0 END)
        AS negative_tip_amount,

    -- tolls_amount
    SUM(CASE WHEN tolls_amount < 0 THEN 1 ELSE 0 END)
        AS negative_tolls_amount,

    -- improvement_surcharge
    SUM(CASE WHEN improvement_surcharge < 0 THEN 1 ELSE 0 END)
        AS negative_improvement_surcharge,

    -- total_amount
    SUM(CASE WHEN total_amount < 0 THEN 1 ELSE 0 END)
        AS negative_total_amount,

    -- congestion_surcharge
    SUM(CASE WHEN congestion_surcharge < 0 THEN 1 ELSE 0 END)
        AS negative_congestion_surcharge,

    -- Airport_fee
    SUM(CASE WHEN Airport_fee < 0 THEN 1 ELSE 0 END)
        AS negative_airport_fee,

    -- cbd_congestion_fee
    SUM(CASE WHEN cbd_congestion_fee < 0 THEN 1 ELSE 0 END)
        AS negative_cbd_congestion_fee

FROM raw.vw_yellow_tripdata_2025;



SELECT 
    (SELECT COUNT(*) FROM raw.vw_yellow_tripdata_2025) AS raw_count,
    (SELECT COUNT(*) FROM analytics.vw_yellow_tripdata_2025_clean) AS clean_count

SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'analytics'
AND TABLE_NAME = 'vw_yellow_tripdata_2025_clean'
ORDER BY ORDINAL_POSITION
------
SELECT
    DATEPART(HOUR, tpep_pickup_datetime) AS pickup_hour,
    COUNT(DISTINCT CAST(tpep_pickup_datetime AS DATE))
        AS distinct_service_dates
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE tpep_pickup_datetime >= '2025-01-01'
  AND tpep_pickup_datetime < '2026-01-01'
GROUP BY DATEPART(HOUR, tpep_pickup_datetime)
ORDER BY pickup_hour;


--- duration anomalities
SELECT
    VendorID,
    VendorName,

    COUNT(*) AS total_trips,

    SUM(CASE
        WHEN TripDurationMinutes IS NULL
        THEN 1 ELSE 0
    END) AS missing_durations,

    SUM(CASE
        WHEN TripDurationMinutes = 0
        THEN 1 ELSE 0
    END) AS zero_durations,

    SUM(CASE
        WHEN TripDurationMinutes < 0
        THEN 1 ELSE 0
    END) AS negative_durations,

    SUM(CASE
        WHEN TripDurationMinutes > 0
        THEN 1 ELSE 0
    END) AS positive_durations,

    SUM(CASE
        WHEN TripDurationMinutes > 300
        THEN 1 ELSE 0
    END) AS durations_above_300_minutes

FROM analytics.vw_yellow_tripdata_2025_clean

WHERE tpep_pickup_datetime >= '2025-01-01'
  AND tpep_pickup_datetime < '2026-01-01'

GROUP BY
    VendorID,
    VendorName

ORDER BY total_trips DESC;


SELECT
    VendorID,
    VendorName,
    COUNT(*) AS total_trips,

    -- FARE AMOUNT COUNTS
    SUM(CASE
        WHEN fare_amount IS NULL THEN 1 ELSE 0
    END) AS missing_fare_amount,

    SUM(CASE
        WHEN fare_amount = 0 THEN 1 ELSE 0
    END) AS zero_fare_amount,

    SUM(CASE
        WHEN fare_amount < 0 THEN 1 ELSE 0
    END) AS negative_fare_amount,

    SUM(CASE
        WHEN fare_amount > 0 THEN 1 ELSE 0
    END) AS positive_fare_amount,

    -- POSITIVE FARE STATISTICS
    AVG(CASE
        WHEN fare_amount > 0 THEN fare_amount
    END) AS avg_positive_fare,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY CASE
            WHEN fare_amount > 0 THEN fare_amount
        END
    ) AS median_positive_fare,

    -- ZERO FARE STATISTICS
    AVG(CASE
        WHEN fare_amount = 0 THEN fare_amount
    END) AS avg_zero_fare,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY CASE
            WHEN fare_amount = 0 THEN fare_amount
        END
    ) AS median_zero_fare,

    -- NEGATIVE FARE STATISTICS
    AVG(CASE
        WHEN fare_amount < 0 THEN fare_amount
    END) AS avg_negative_fare,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY CASE
            WHEN fare_amount < 0 THEN fare_amount
        END
    ) AS median_negative_fare,

    -- TOTAL AMOUNT COUNTS
    SUM(CASE
        WHEN total_amount IS NULL THEN 1 ELSE 0
    END) AS missing_total_amount,

    SUM(CASE
        WHEN total_amount = 0 THEN 1 ELSE 0
    END) AS zero_total_amount,

    SUM(CASE
        WHEN total_amount < 0 THEN 1 ELSE 0
    END) AS negative_total_amount,

    SUM(CASE
        WHEN total_amount > 0 THEN 1 ELSE 0
    END) AS positive_total_amount,

    -- POSITIVE TOTAL AMOUNT STATISTICS
    AVG(CASE
        WHEN total_amount > 0 THEN total_amount
    END) AS avg_positive_total_amount,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY CASE
            WHEN total_amount > 0 THEN total_amount
        END
    ) AS median_positive_total_amount,

    -- ZERO TOTAL AMOUNT STATISTICS
    AVG(CASE
        WHEN total_amount = 0 THEN total_amount
    END) AS avg_zero_total_amount,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY CASE
            WHEN total_amount = 0 THEN total_amount
        END
    ) AS median_zero_total_amount,

    -- NEGATIVE TOTAL AMOUNT STATISTICS
    AVG(CASE
        WHEN total_amount < 0 THEN total_amount
    END) AS avg_negative_total_amount,

    APPROX_PERCENTILE_CONT(0.5)
    WITHIN GROUP (
        ORDER BY CASE
            WHEN total_amount < 0 THEN total_amount
        END
    ) AS median_negative_total_amount

FROM analytics.vw_yellow_tripdata_2025_clean

WHERE tpep_pickup_datetime >= '2025-01-01'
  AND tpep_pickup_datetime < '2026-01-01'

GROUP BY
    VendorID,
    VendorName

ORDER BY total_trips DESC;

WITH quality_metrics AS
(
    SELECT
        COUNT(*) AS total_2025_trips,

        SUM(CASE
            WHEN tpep_dropoff_datetime < tpep_pickup_datetime
            THEN 1 ELSE 0
        END) AS dropoff_before_pickup,

        SUM(CASE
            WHEN trip_distance <= 0
            THEN 1 ELSE 0
        END) AS non_positive_trip_distance,

        SUM(CASE
            WHEN trip_distance > 100
            THEN 1 ELSE 0
        END) AS distance_above_100_miles,

        SUM(CASE
            WHEN passenger_count IS NULL
            THEN 1 ELSE 0
        END) AS missing_passenger_count,

        SUM(CASE
            WHEN fare_amount < 0
            THEN 1 ELSE 0
        END) AS negative_fare_amount,

        SUM(CASE
            WHEN total_amount < 0
            THEN 1 ELSE 0
        END) AS negative_total_amount,

        SUM(CASE
            WHEN tip_amount < 0
            THEN 1 ELSE 0
        END) AS negative_tip_amount

    FROM analytics.vw_yellow_tripdata_2025_clean

    WHERE tpep_pickup_datetime >= '2025-01-01'
      AND tpep_pickup_datetime < '2026-01-01'
)

SELECT
    total_2025_trips,

    metric,
    record_count,

    CAST(
        record_count * 100.0 / NULLIF(total_2025_trips, 0)
        AS DECIMAL(10,4)
    ) AS percentage_of_total_trips

FROM quality_metrics

CROSS APPLY
(
    VALUES
        ('Drop-off before pickup', dropoff_before_pickup),
        ('Non-positive trip distance', non_positive_trip_distance),
        ('Distance above 100 miles', distance_above_100_miles),
        ('Missing passenger count', missing_passenger_count),
        ('Negative fare amount', negative_fare_amount),
        ('Negative total amount', negative_total_amount),
        ('Negative tip amount', negative_tip_amount)
) AS metrics(metric, record_count)

ORDER BY metric;

WITH ZonePaymentDemand AS
(
    SELECT
        yt.PULocationID,
        pickup.Zone,
        pickup.Borough,
        yt.payment_type,
        yt.PaymentTypeName,
        COUNT(*) AS total_trips
    FROM analytics.vw_yellow_tripdata_2025_clean AS yt

    LEFT JOIN analytics.taxi_zone_lookup AS pickup
        ON yt.PULocationID = pickup.LocationID

    WHERE yt.tpep_pickup_datetime >= '2025-01-01'
      AND yt.tpep_pickup_datetime < '2026-01-01'

    GROUP BY
        yt.PULocationID,
        pickup.Zone,
        pickup.Borough,
        yt.payment_type,
        yt.PaymentTypeName
)
SELECT
    *,
    SUM(total_trips) OVER (
        PARTITION BY PULocationID
    ) AS zone_total_trips,

    total_trips * 100.0 /
    SUM(total_trips) OVER (
        PARTITION BY PULocationID
    ) AS percentage_of_zone_demand

FROM ZonePaymentDemand

ORDER BY
    PULocationID,
    total_trips DESC;

-- 1. Overall data quality
SELECT *
FROM analytics.vw_q9_overall_data_quality;


-- 2. Missing-value analysis
SELECT *
FROM analytics.vw_q9_missing_values
ORDER BY missing_records DESC;


-- 3. KPI impact assessment
SELECT *
FROM analytics.vw_q9_kpi_impact
ORDER BY
    CASE kpi_section
        WHEN 'Trip Distance' THEN 1
        WHEN 'Revenue' THEN 2
        WHEN 'Passenger Count' THEN 3
    END,
    population;


----------------------

CREATE OR ALTER VIEW analytics.vw_q3_distance_charge_analysis
AS

WITH trips_band AS
(
    SELECT
        trip_distance,
        fare_amount,
        tip_amount,
        total_amount,

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

    APPROX_PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY fare_amount)
        AS median_fare_amount,

    ROUND(AVG(tip_amount), 3) AS avg_tip_amount,
    ROUND(AVG(total_amount), 3) AS avg_total_amount

FROM trips_band

GROUP BY
    distance_group,
    distance_sort;


SELECT * FROM analytics.vw_q3_distance_charge_analysis
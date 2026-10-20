-------------------------------------------------Data Profling--------------------------------------------------------
SELECT TOP 10 * FROM raw.vw_yellow_tripdata_2025;

--- Inspect available table---
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'vw_yellow_tripdata_2025'
ORDER BY ORDINAL_POSITION;

-----Total records check on tridata 2025---
SELECT 
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025;

-----earliest and latest tpep_pickup_datetime --: Check pickup date coverage
SELECT 
    MAX(tpep_pickup_datetime) AS latest_pickupDate,
    MIN(tpep_pickup_datetime) AS earliest_pickupDate
FROM raw.vw_yellow_tripdata_2025;

---Investing the coverage date 
SELECT 
    tpep_pickup_datetime,
    VendorID,
    trip_distance,
    fare_amount,
    total_amount
FROM raw.vw_yellow_tripdata_2025
WHERE 
    tpep_pickup_datetime < '2025-01-01 00:00:00';

SELECT 
    tpep_pickup_datetime,
    VendorID,
    trip_distance,
    fare_amount,
    total_amount
FROM raw.vw_yellow_tripdata_2025
WHERE 
    tpep_pickup_datetime > '2025-12-31 23:59:59';

--records belonging to pickup year
SELECT 
    YEAR(tpep_pickup_datetime) AS pickup_year,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
GROUP BY
     YEAR(tpep_pickup_datetime)

---Pickup and drop up validation
SELECT TOP 10
---COUNT(*) AS time_anomality
*
FROM raw.vw_yellow_tripdata_2025
WHERE 
    tpep_dropoff_datetime < tpep_pickup_datetime

---checking for null values 

SELECT 
    SUM(CASE WHEN VendorID IS NULL OR TRIM(VendorID) = '' OR LOWER(TRIM(VendorID)) = 'null' THEN 1 ELSE 0 END ) AS missing_vendorID,
    SUM(CASE WHEN tpep_pickup_datetime IS NULL THEN 1 ELSE 0 END) AS missing_pickup_date,
    SUM(CASE WHEN tpep_dropoff_datetime IS NULL THEN 1 ELSE 0 END) AS missing_dropoff_date,
    SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END) AS missing_passenger_count,
    SUM(CASE WHEN trip_distance IS NULL THEN 1 ELSE 0 END ) AS missing_trip_distance,
    SUM(CASE WHEN RatecodeID IS NULL THEN 1 ELSE 0 END ) AS missing_rarwcodeID,
    SUM(CASE WHEN store_and_fwd_flag IS NULL OR TRIM(store_and_fwd_flag) = '' OR LOWER(TRIM(store_and_fwd_flag)) = 'null' THEN 1 ELSE 0 END ) AS missing_store_and_fwd_flag,
    SUM(CASE WHEN PULocationID IS NULL THEN 1 ELSE 0 END ) AS missing_pulocatinID,
    SUM(CASE WHEN DOLocationID IS NULL THEN 1 ELSE 0 END ) AS missing_DolactionID,
    SUM(CASE WHEN payment_type IS NULL OR TRIM(payment_type) = '' OR LOWER(TRIM(payment_type)) = 'null' THEN 1 ELSE 0 END ) AS missing_payment_type,
    SUM(CASE WHEN fare_amount IS NULL THEN 1 ELSE 0 END ) AS missing_fare_amount,
    SUM(CASE WHEN extra IS NULL THEN 1 ELSE 0 END ) AS missing_extra,
    SUM(CASE WHEN mta_tax IS NULL THEN 1 ELSE 0 END ) AS missing_mta_tax,
    SUM(CASE WHEN tip_amount IS NULL THEN 1 ELSE 0 END ) AS missing_tip_amount,
    SUM(CASE WHEN tolls_amount IS NULL THEN 1 ELSE 0 END ) AS missing_tolls_amount,
    SUM(CASE WHEN improvement_surcharge IS NULL THEN  1 ELSE 0 END ) AS missing_improvement_surcharge,
    SUM(CASE WHEN total_amount IS NULL THEN 1 ELSE 0 END ) AS missing_total_amount,
    SUM(CASE WHEN congestion_surcharge IS NULL THEN 1 ELSE 0 END ) AS missing_congestion_surcharge,
    SUM(CASE WHEN Airport_fee IS NULL THEN 1 ELSE 0 END ) AS missing_airport_fee,
    SUM(CASE WHEN cbd_congestion_fee IS NULL THEN 1 ELSE 0 END ) AS missing_cbd_congestion_fee
FROM raw.vw_yellow_tripdata_2025;

----Investigating the null values 
SELECT 
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
WHERE
    passenger_count IS NULL 
    AND RatecodeID IS NULL 
    AND store_and_fwd_flag IS NULL
    AND congestion_surcharge IS NULL
    AND Airport_fee IS NULL;

SELECT 
    YEAR(tpep_pickup_datetime) AS pickup_year,
    MONTH(tpep_pickup_datetime) AS pickup_month,
    COUNT(*) AS total_count,
    (SELECT COUNT(*))
FROM raw.vw_yellow_tripdata_2025
WHERE
    passenger_count IS NULL 
    AND RatecodeID IS NULL 
    AND store_and_fwd_flag IS NULL
    AND congestion_surcharge IS NULL
    AND Airport_fee IS NULL
GROUP BY 
      YEAR(tpep_pickup_datetime),
      MONTH(tpep_pickup_datetime);

SELECT 
    YEAR(tpep_pickup_datetime) AS pickup_year,
    MONTH(tpep_pickup_datetime) AS pickup_month,
    --total count of records where all specific fields are NULL
    SUM(CASE WHEN passenger_count IS NULL
                AND RatecodeID IS NULL
                AND store_and_fwd_flag IS NULL 
                AND congestion_surcharge IS NULL
                AND Airport_fee IS NULL THEN 1 ELSE 0 END) AS total_null_count,
    COUNT(*) AS total_count,
    FORMAT(CAST(SUM(CASE WHEN passenger_count IS NULL 
                  AND RatecodeID IS NULL 
                  AND store_and_fwd_flag IS NULL 
                  AND congestion_surcharge IS NULL 
                  AND Airport_fee IS NULL THEN 1.0 ELSE 0.0 END) / COUNT(*) AS DECIMAL(10,4)), 'P2') AS null_percentage
FROM raw.vw_yellow_tripdata_2025
GROUP BY 
      YEAR(tpep_pickup_datetime), 
    MONTH(tpep_pickup_datetime)
ORDER BY 
    pickup_year, 
    pickup_month;

---CHECK FOR DUPLICATED RECORS OR SUSPECTED DUPLICATES 
SELECT 
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    trip_distance,
    PULocationID,
    DOLocationID,
    total_amount,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
GROUP BY 
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    trip_distance,
    PULocationID,
    DOLocationID,
    total_amount
HAVING COUNT(*) > 1;

---Investigating duplicates 
SELECT 
*
FROM raw.vw_yellow_tripdata_2025
WHERE tpep_pickup_datetime IN  ('2025-07-05 17:19:29.0000000', '2025-06-23 07:27:34.0000000')
    AND tpep_dropoff_datetime IN ('2025-07-05 17:19:34.0000000', '2025-06-23 07:27:43.0000000')
    AND trip_distance = 0;


WITH exact_duplicate AS (
    SELECT 
        VendorID,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        passenger_count,
        trip_distance,
        RatecodeID,
        store_and_fwd_flag,
        PULocationID,
        DOLocationID,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        congestion_surcharge,
        Airport_fee,
        cbd_congestion_fee,
        COUNT(*) AS group_row_count
    FROM raw.vw_yellow_tripdata_2025
    GROUP BY 
          VendorID,
        tpep_pickup_datetime,
        tpep_dropoff_datetime,
        passenger_count,
        trip_distance,
        RatecodeID,
        store_and_fwd_flag,
        PULocationID,
        DOLocationID,
        payment_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        improvement_surcharge,
        total_amount,
        congestion_surcharge,
        Airport_fee,
        cbd_congestion_fee
    HAVING COUNT(*) > 1
)

SELECT 
    COUNT(*) AS number_of_duplicated_groups,
    SUM(group_row_count) AS total_rows_in_duplicate_groups,
    SUM(group_row_count - 1) AS total_excess_duplicate_rows
FROM exact_duplicate;

----trip distance profiling
SELECT 
    MAX(trip_distance) AS highest_distance,
    MIN(trip_distance) AS lowest_distance,
    SUM(CASE WHEN trip_distance < 0 THEN 1 ELSE 0 END ) AS negative_trip_distance,
    SUM(CASE WHEN trip_distance = 0 THEN 1 ELSE 0 END) AS zero_trip_distance,
    SUM(CASE WHEN trip_distance > 0 THEN 1 ELSE 0 END ) AS postive_trip_distance,
    SUM(CASE WHEN trip_distance IS NULL THEN 1 ELSE 0 END ) AS missing_trip_distance
FROM raw.vw_yellow_tripdata_2025;

---Investigate extreme trip distances
SELECT TOP 20
    *
FROM raw.vw_yellow_tripdata_2025
ORDER BY 
    trip_distance DESC;

SELECT
    COUNT(*) AS total_trips_above_100Miles,
    (SELECT COUNT(*) FROM raw.vw_yellow_tripdata_2025) AS number_of_trips,
    CAST(COUNT(*) * 100.0 /  (SELECT COUNT(*) FROM raw.vw_yellow_tripdata_2025) AS DECIMAL(10,4)) AS percentage_of_trips
FROM raw.vw_yellow_tripdata_2025
WHERE 
    trip_distance > 100;


--Investigating negative fare amounts and total_amount
SELECT 
    SUM(CASE WHEN fare_amount < 0 THEN 1 ELSE 0 END) AS negative_fare_amounts,
    MIN(fare_amount) AS lowest_fare_amount,
    SUM(CASE WHEN total_amount < 0 THEN 1 ELSE 0 END) AS negative_total_amount,
    MIN(total_amount) AS lowest_total_amount
FROM raw.vw_yellow_tripdata_2025;

---PROFILE THE distribution of fare amount and total_amount into different catgories, negative, zero, positive 
SELECT 
    SUM(CASE WHEN fare_amount < 0 THEN 1 ELSE 0 END) AS count_of_negative_fare,
    SUM(CASE WHEN fare_amount = 0 THEN 1 ELSE 0 END) AS count_of_zero_fare_amount,
    SUM(CASE WHEN fare_amount > 0 THEN 1 ELSE 0 END ) AS positive_fare
FROM raw.vw_yellow_tripdata_2025;

SELECT 
    SUM(CASE WHEN total_amount < 0 THEN 1 ELSE 0 END) AS count_of_negative_totaal_amount,
    SUM(CASE WHEN total_amount = 0 THEN 1 ELSE 0 END) AS count_of_zero_total_amount,
    SUM(CASE WHEN total_amount > 0 THEN 1 ELSE 0 END ) AS positive_amount
FROM raw.vw_yellow_tripdata_2025;

SELECT
    -- extra
    SUM(CASE WHEN extra < 0 THEN 1 ELSE 0 END) AS negative_extra,
    SUM(CASE WHEN extra = 0 THEN 1 ELSE 0 END) AS zero_extra,
    SUM(CASE WHEN extra > 0 THEN 1 ELSE 0 END) AS positive_extra,

    -- mta_tax
    SUM(CASE WHEN mta_tax < 0 THEN 1 ELSE 0 END) AS negative_mta_tax,
    SUM(CASE WHEN mta_tax = 0 THEN 1 ELSE 0 END) AS zero_mta_tax,
    SUM(CASE WHEN mta_tax > 0 THEN 1 ELSE 0 END) AS positive_mta_tax,

    -- tip_amount
    SUM(CASE WHEN tip_amount < 0 THEN 1 ELSE 0 END) AS negative_tip_amount,
    SUM(CASE WHEN tip_amount = 0 THEN 1 ELSE 0 END) AS zero_tip_amount,
    SUM(CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END) AS positive_tip_amount,

    -- tolls_amount
    SUM(CASE WHEN tolls_amount < 0 THEN 1 ELSE 0 END) AS negative_tolls_amount,
    SUM(CASE WHEN tolls_amount = 0 THEN 1 ELSE 0 END) AS zero_tolls_amount,
    SUM(CASE WHEN tolls_amount > 0 THEN 1 ELSE 0 END) AS positive_tolls_amount,

    -- improvement_surcharge
    SUM(CASE WHEN improvement_surcharge < 0 THEN 1 ELSE 0 END) AS negative_improvement_surcharge,
    SUM(CASE WHEN improvement_surcharge = 0 THEN 1 ELSE 0 END) AS zero_improvement_surcharge,
    SUM(CASE WHEN improvement_surcharge > 0 THEN 1 ELSE 0 END) AS positive_improvement_surcharge,

    -- congestion_surcharge
    SUM(CASE WHEN congestion_surcharge < 0 THEN 1 ELSE 0 END) AS negative_congestion_surcharge,
    SUM(CASE WHEN congestion_surcharge = 0 THEN 1 ELSE 0 END) AS zero_congestion_surcharge,
    SUM(CASE WHEN congestion_surcharge > 0 THEN 1 ELSE 0 END) AS positive_congestion_surcharge,

    -- Airport_fee
    SUM(CASE WHEN Airport_fee < 0 THEN 1 ELSE 0 END) AS negative_airport_fee,
    SUM(CASE WHEN Airport_fee = 0 THEN 1 ELSE 0 END) AS zero_airport_fee,
    SUM(CASE WHEN Airport_fee > 0 THEN 1 ELSE 0 END) AS positive_airport_fee,

    -- cbd_congestion_fee
    SUM(CASE WHEN cbd_congestion_fee < 0 THEN 1 ELSE 0 END) AS negative_cbd_congestion_fee,
    SUM(CASE WHEN cbd_congestion_fee = 0 THEN 1 ELSE 0 END) AS zero_cbd_congestion_fee,
    SUM(CASE WHEN cbd_congestion_fee > 0 THEN 1 ELSE 0 END) AS positive_cbd_congestion_fee

FROM raw.vw_yellow_tripdata_2025;

SELECT
    -- extra
    MIN(extra) AS min_extra,
    MAX(extra) AS max_extra,
    SUM(CASE WHEN extra IS NULL THEN 1 ELSE 0 END) AS null_extra,

    -- mta_tax
    MIN(mta_tax) AS min_mta_tax,
    MAX(mta_tax) AS max_mta_tax,
    SUM(CASE WHEN mta_tax IS NULL THEN 1 ELSE 0 END) AS null_mta_tax,

    -- tip_amount
    MIN(tip_amount) AS min_tip_amount,
    MAX(tip_amount) AS max_tip_amount,
    SUM(CASE WHEN tip_amount IS NULL THEN 1 ELSE 0 END) AS null_tip_amount,

    -- tolls_amount
    MIN(tolls_amount) AS min_tolls_amount,
    MAX(tolls_amount) AS max_tolls_amount,
    SUM(CASE WHEN tolls_amount IS NULL THEN 1 ELSE 0 END) AS null_tolls_amount,

    -- improvement_surcharge
    MIN(improvement_surcharge) AS min_improvement_surcharge,
    MAX(improvement_surcharge) AS max_improvement_surcharge,
    SUM(CASE WHEN improvement_surcharge IS NULL THEN 1 ELSE 0 END) AS null_improvement_surcharge,

    -- congestion_surcharge
    MIN(congestion_surcharge) AS min_congestion_surcharge,
    MAX(congestion_surcharge) AS max_congestion_surcharge,
    SUM(CASE WHEN congestion_surcharge IS NULL THEN 1 ELSE 0 END) AS null_congestion_surcharge,

    -- Airport_fee
    MIN(Airport_fee) AS min_airport_fee,
    MAX(Airport_fee) AS max_airport_fee,
    SUM(CASE WHEN Airport_fee IS NULL THEN 1 ELSE 0 END) AS null_airport_fee,

    -- cbd_congestion_fee
    MIN(cbd_congestion_fee) AS min_cbd_congestion_fee,
    MAX(cbd_congestion_fee) AS max_cbd_congestion_fee,
    SUM(CASE WHEN cbd_congestion_fee IS NULL THEN 1 ELSE 0 END) AS null_cbd_congestion_fee

FROM raw.vw_yellow_tripdata_2025;

--profiling passeger count
SELECT 
    SUM(CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END) AS null_passenger_count,
    MIN(passenger_count)  AS lowest_passenger_count,
    MAX(passenger_count) AS highest_passenger_count    
FROM raw.vw_yellow_tripdata_2025;

SELECT 
    passenger_count,
    COUNT(*) AS frquency_passenger_count
FROM raw.vw_yellow_tripdata_2025
WHERE passenger_count IS NOT NULL
GROUP BY
    passenger_count
ORDER BY 
    frquency_passenger_count;

--investigating different passemger count groups 
SELECT TOP 20
    passenger_count,
    tpep_pickup_datetime,
    tpep_dropoff_datetime,
    trip_distance,
    fare_amount,
    total_amount,
    payment_type
FROM raw.vw_yellow_tripdata_2025
WHERE passenger_count IN (0,7,8,9);

---profiling vendorID
SELECT 
    SUM(CASE WHEN VendorID IS NULL OR TRIM(VendorID) = '' OR LOWER(TRIM(VendorID)) = 'null' THEN 1 ELSE 0 END ) AS missing_vendor_ID
FROM raw.vw_yellow_tripdata_2025;

SELECT 
    VendorID,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
GROUP BY 
    VendorID;

---profiling payment type
SELECT 
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END ) AS missing_payment_type
FROM raw.vw_yellow_tripdata_2025;

SELECT 
    payment_type,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
GROUP BY
    payment_type
ORDER BY
    total_count DESC;

---profiling RatecodeID
SELECT 
    SUM(CASE WHEN RatecodeID IS NULL THEN 1 ELSE 0 END ) AS missing_RatecodeID,
    MIN(RatecodeID) AS lowest_ratecode,
    MAX(RatecodeID) AS highest_ratecode
FROM raw.vw_yellow_tripdata_2025;

SELECT 
    RatecodeID,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
GROUP BY
    RatecodeID
ORDER BY
    total_count DESC;

---Profile pickup and drop-off location IDs
SELECT 
    SUM(CASE WHEN PULocationID IS NULL THEN 1 ELSE 0 END ) AS missing_PULocationID ,
    MIN(PULocationID ) AS lowest_PULocationID ,
    MAX(PULocationID ) AS highest_PULocationID 
FROM raw.vw_yellow_tripdata_2025;

SELECT 
    PULocationID ,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
GROUP BY
    PULocationID 
ORDER BY
    total_count DESC;

SELECT 
    SUM(CASE WHEN DOLocationID IS NULL THEN 1 ELSE 0 END ) AS missing_DOLocationID ,
    MIN(DOLocationID ) AS lowest_DOLocationID ,
    MAX(DOLocationID ) AS highest_DOLocationID 
FROM raw.vw_yellow_tripdata_2025;

SELECT 
    DOLocationID,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
GROUP BY
    DOLocationID
ORDER BY
    total_count DESC;
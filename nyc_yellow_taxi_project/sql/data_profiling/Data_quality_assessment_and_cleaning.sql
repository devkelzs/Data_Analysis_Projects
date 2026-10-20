----------------------------------------------Quality assesment--------------------------------------------------
------payment type code validity (0,1,2,3,4,5,6) -------------
SELECT 
    payment_type,
    COUNT(*) AS total_count
FROM raw.vw_yellow_tripdata_2025
WHERE 
    payment_type NOT IN (0,1,2,3,4,5,6)
GROUP BY 
    payment_type
ORDER BY 
    total_count DESC;
---quality flag for payment type 
WITH invalid_payment_type  AS 
(
SELECT 
    CASE WHEN payment_type NOT IN (0,1,2,3,4,5,6) AND payment_type IS NOT NULL THEN 1 ELSE 0 END AS InvalidPaymentTypeFlag
FROM raw.vw_yellow_tripdata_2025
)
--validating the flag
SELECT 
    COUNT(*) AS total_count
FROM invalid_payment_type
WHERE InvalidPaymentTypeFlag = 1;

-----quality flag for RatecodeId 

WITH invalid_RateCodeId AS 
(
    SELECT 
        CASE WHEN RatecodeID NOT IN  (1,2,3,4,5,6,99) AND RatecodeID IS NOT NULL THEN 1 ELSE 0 END AS InvalidRateCodeIdFlag
    FROM raw.vw_yellow_tripdata_2025
)
---validating ratecode flag
SELECT 
    COUNT(*) AS total_count
FROM invalid_RateCodeId
WHERE InvalidRateCodeIdFlag = 1;

----Quality flag for VendorID
WITH   VendorFlag AS 
(
SELECT 
    CASE WHEN VendorID NOT IN (1,2,6,7) AND VendorID IS NOT NULL THEN 1 ELSE 0 END AS InvalidVendorIDFlag
FROM raw.vw_yellow_tripdata_2025
)
SELECT 
    count(*) AS total_count
FROM VendorFlag
WHERE InvalidVendorIDFlag = 1;

---Trip Timestamp Validity
WITH TimestampValidation AS
(
SELECT 
    CASE WHEN tpep_dropoff_datetime < tpep_pickup_datetime THEN 1 ELSE 0 END AS TripTimestampQualityFlag
FROM raw.vw_yellow_tripdata_2025
)
SELECT 
COUNT(*) AS total_count
FROM TimestampValidation
WHERE 
    TripTimestampQualityFlag =1;

-------------Trip Distance Validity
WITH trip_distance_Validity AS 
(
SELECT 
    CASE 
        WHEN trip_distance <= 0 OR trip_distance > 100 THEN 1 ELSE 0
    END AS TripDistanceQualityFlag
FROM raw.vw_yellow_tripdata_2025
)
SELECT 
    COUNT(*) AS total_count
FROM trip_distance_Validity
WHERE 
    TripDistanceQualityFlag = 1;

-----Validate negative monetary values
SELECT
    -- 1. fare_amount
    CASE WHEN fare_amount < 0 THEN 1 ELSE 0 END AS fare_amount_negative_flag,

    -- 2. total_amount
    CASE WHEN total_amount < 0 THEN 1 ELSE 0 END AS total_amount_negative_flag,

    -- 3. tip_amount
    CASE WHEN tip_amount < 0 THEN 1 ELSE 0 END AS tip_amount_negative_flag,

    -- 4. Airport_fee
    CASE WHEN Airport_fee < 0 THEN 1 ELSE 0 END AS Airport_fee_negative_flag,

    -- 5. mta_tax
    CASE WHEN mta_tax < 0 THEN 1 ELSE 0 END AS mta_tax_negative_flag,

    -- 6. extra
    CASE WHEN extra < 0 THEN 1 ELSE 0 END AS extra_negative_flag,

    -- 7. tolls_amount
    CASE WHEN tolls_amount < 0 THEN 1 ELSE 0 END AS tolls_amount_negative_flag,

    -- 8. improvement_surcharge
    CASE WHEN improvement_surcharge < 0 THEN 1 ELSE 0 END AS improvement_surcharge_negative_flag,

    -- 9. congestion_surcharge
    CASE WHEN congestion_surcharge < 0 THEN 1 ELSE 0 END AS congestion_surcharge_negative_flag,

    -- 10. cbd_congestion_fee
    CASE WHEN cbd_congestion_fee < 0 THEN 1 ELSE 0 END AS cbd_congestion_fee_negative_flag,
    -- Zero fare flag
    CASE
        WHEN fare_amount = 0 THEN 1
        ELSE 0
    END AS fare_amount_zero_flag,

    -- Zero total amount flag
    CASE
        WHEN total_amount = 0 THEN 1
        ELSE 0
    END AS total_amount_zero_flag

FROM raw.vw_yellow_tripdata_2025;

----- Passenger Count Quality
SELECT 
    CASE WHEN passenger_count = 0 THEN 1 ELSE 0 END AS ZeroPassengerCountFlag,
    CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END AS IsMissing_PassengerCount
FROM raw.vw_yellow_tripdata_2025;

----Missing Values in Rate, Flag, and Surcharge Columns
SELECT 
    -- 1. RatecodeID
    CASE
        WHEN RatecodeID IS NULL THEN 1
        ELSE 0
    END AS IsMissing_RatecodeID,

    -- 2. store_and_fwd_flag
    CASE
        WHEN store_and_fwd_flag IS NULL THEN 1
        ELSE 0
    END AS IsMissing_StoreAndFwdFlag,

    -- 3. congestion_surcharge
    CASE
        WHEN congestion_surcharge IS NULL THEN 1
        ELSE 0
    END AS IsMissing_CongestionSurcharge,

    -- 4. Airport_fee
    CASE
        WHEN Airport_fee IS NULL THEN 1
        ELSE 0
    END AS IsMissing_AirportFee
FROM raw.vw_yellow_tripdata_2025;

------Pickup Year Validity
SELECT
    CASE WHEN YEAR(tpep_pickup_datetime) <> 2025 THEN 1 ELSE 0 END AS PickupYearQualityFlag
FROM raw.vw_yellow_tripdata_2025;

----Store-and-Forward Flag Validity
WITH store_fw AS 
(
    SELECT 
        CASE WHEN store_and_fwd_flag NOT IN ('Y', 'N') AND store_and_fwd_flag IS NOT NULL THEN 1 ELSE 0 END AS InvalidStoreAndFwdFlag
    FROM raw.vw_yellow_tripdata_2025
)
SELECT 
COUNT(*) AS total_count
FROM store_fw
WHERE 
    InvalidStoreAndFwdFlag = 1;



/* Creates the clean 2025 Yellow Taxi view with descriptive columns, 
data quality flags, and derived trip metrics.
*/
CREATE OR ALTER VIEW analytics.vw_yellow_tripdata_2025_clean
AS
SELECT 
     VendorID,
     CASE 
        WHEN VendorID = 1 THEN 'Creative Mobile Technologies, LLC'
        WHEN VendorID = 2 THEN 'Curb Mobility, LLC'
        WHEN VendorID = 6 THEN 'Myle Technologies Inc.'
        WHEN VendorID = 7 THEN 'Helix'
        ELSE NULL
    END AS VendorName,
    tpep_pickup_datetime,
    CAST(tpep_pickup_datetime AS DATE) AS PickupDate,
    tpep_dropoff_datetime,
    passenger_count,
    trip_distance,
    RatecodeID,
      CASE 
        WHEN RatecodeID = 1 THEN 'Standard rate'
        WHEN RatecodeID = 2 THEN 'JFK'
        WHEN RatecodeID = 3 THEN 'Newark'
        WHEN RatecodeID = 4 THEN 'Nassau or Westchester'
        WHEN RatecodeID = 5 THEN 'Negotiated fare'
        WHEN RatecodeID = 6 THEN 'Group ride'
        WHEN RatecodeID = 99 THEN 'Null/unknown'
        ELSE NULL
    END AS RatecodeDescription,
    store_and_fwd_flag,
    PULocationID,
    DOLocationID,
    payment_type,
     CASE 
        WHEN payment_type = 0 THEN 'Flex Fare'
        WHEN payment_type = 1 THEN 'Credit card'
        WHEN payment_type = 2 THEN 'Cash'
        WHEN payment_type = 3 THEN 'No charge'
        WHEN payment_type = 4 THEN 'Dispute'
        WHEN payment_type = 5 THEN 'Unknown'
        WHEN payment_type = 6 THEN 'Voided trip'
        ELSE NULL
    END AS PaymentTypeName,
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
    CASE WHEN payment_type NOT IN (0,1,2,3,4,5,6) AND payment_type IS NOT NULL THEN 1 ELSE 0 END AS InvalidPaymentTypeFlag,
    CASE WHEN RatecodeID NOT IN  (1,2,3,4,5,6,99) AND RatecodeID IS NOT NULL THEN 1 ELSE 0 END AS InvalidRateCodeIdFlag,
    CASE WHEN VendorID NOT IN (1,2,6,7) AND VendorID IS NOT NULL THEN 1 ELSE 0 END AS InvalidVendorIDFlag,
    CASE WHEN tpep_dropoff_datetime < tpep_pickup_datetime THEN 1 ELSE 0 END AS TripTimestampQualityFlag,
    CASE 
        WHEN trip_distance <= 0 OR trip_distance > 100 THEN 1 ELSE 0
    END AS TripDistanceQualityFlag,
    -- 1. fare_amount
    CASE WHEN fare_amount < 0 THEN 1 ELSE 0 END AS fare_amount_negative_flag,

    -- 2. total_amount
    CASE WHEN total_amount < 0 THEN 1 ELSE 0 END AS total_amount_negative_flag,

    -- 3. tip_amount
    CASE WHEN tip_amount < 0 THEN 1 ELSE 0 END AS tip_amount_negative_flag,

    -- 4. Airport_fee
    CASE WHEN Airport_fee < 0 THEN 1 ELSE 0 END AS Airport_fee_negative_flag,

    -- 5. mta_tax
    CASE WHEN mta_tax < 0 THEN 1 ELSE 0 END AS mta_tax_negative_flag,

    -- 6. extra
    CASE WHEN extra < 0 THEN 1 ELSE 0 END AS extra_negative_flag,

    -- 7. tolls_amount
    CASE WHEN tolls_amount < 0 THEN 1 ELSE 0 END AS tolls_amount_negative_flag,

    -- 8. improvement_surcharge
    CASE WHEN improvement_surcharge < 0 THEN 1 ELSE 0 END AS improvement_surcharge_negative_flag,

    -- 9. congestion_surcharge
    CASE WHEN congestion_surcharge < 0 THEN 1 ELSE 0 END AS congestion_surcharge_negative_flag,

    -- 10. cbd_congestion_fee
    CASE WHEN cbd_congestion_fee < 0 THEN 1 ELSE 0 END AS cbd_congestion_fee_negative_flag,
    -- Zero fare flag
    CASE
        WHEN fare_amount = 0 THEN 1
        ELSE 0
    END AS fare_amount_zero_flag,

    -- Zero total amount flag
    CASE
        WHEN total_amount = 0 THEN 1
        ELSE 0
    END AS total_amount_zero_flag,
    CASE WHEN passenger_count = 0 THEN 1 ELSE 0 END AS ZeroPassengerCountFlag,
    CASE WHEN passenger_count IS NULL THEN 1 ELSE 0 END AS IsMissing_PassengerCount,

    -- 1. RatecodeID
    CASE
        WHEN RatecodeID IS NULL THEN 1
        ELSE 0
    END AS IsMissing_RatecodeID,

    -- 2. store_and_fwd_flag
    CASE
        WHEN store_and_fwd_flag IS NULL THEN 1
        ELSE 0
    END AS IsMissing_StoreAndFwdFlag,

    -- 3. congestion_surcharge
    CASE
        WHEN congestion_surcharge IS NULL THEN 1
        ELSE 0
    END AS IsMissing_CongestionSurcharge,

    -- 4. Airport_fee
    CASE
        WHEN Airport_fee IS NULL THEN 1
        ELSE 0
    END AS IsMissing_AirportFee,

    CASE WHEN YEAR(tpep_pickup_datetime) <> 2025 THEN 1 ELSE 0 END AS PickupYearQualityFlag,
    CASE WHEN store_and_fwd_flag NOT IN ('Y', 'N') AND store_and_fwd_flag IS NOT NULL THEN 1 ELSE 0 END AS InvalidStoreAndFwdFlag,
    ----cols derieved rom original dataset 
    CASE
    WHEN tpep_dropoff_datetime < tpep_pickup_datetime THEN NULL
    ELSE DATEDIFF(
        MINUTE,
        tpep_pickup_datetime,
        tpep_dropoff_datetime
    )
    END AS TripDurationMinutes,
    DATEPART(HOUR, tpep_pickup_datetime) AS PickupHour,
    DATEPART(MONTH, tpep_pickup_datetime) AS PickupMonth,
    DATENAME(MONTH, tpep_pickup_datetime) AS PickupMonthName,
    DATENAME(WEEKDAY, tpep_pickup_datetime) as PickupDayOfWeek
FROM raw.vw_yellow_tripdata_2025;





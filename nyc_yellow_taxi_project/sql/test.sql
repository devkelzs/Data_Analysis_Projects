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
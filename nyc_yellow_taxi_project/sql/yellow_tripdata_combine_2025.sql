
SET NOCOUNT ON;

DECLARE @Month INT = 1;
DECLARE @MonthText CHAR(2);
DECLARE @TableName NVARCHAR(256);
DECLARE @FilePath NVARCHAR(500);
DECLARE @SQL NVARCHAR(MAX);

WHILE @Month <= 12
BEGIN
    SET @MonthText = RIGHT('0' + CAST(@Month AS VARCHAR(2)), 2);

    SET @TableName =
        N'raw.yellow_tripdata_2025_' + @MonthText;

    SET @FilePath =
        N'C:\Users\we\Downloads\yellow_tripdata_2025-'
        + @MonthText + N'.csv';

    -- Create the monthly table if it does not exist.
    IF OBJECT_ID(@TableName, 'U') IS NULL
    BEGIN
        SET @SQL = N'
        CREATE TABLE ' + @TableName + N' (
            VendorID NVARCHAR(100) NULL,
            tpep_pickup_datetime DATETIME2 NULL,
            tpep_dropoff_datetime DATETIME2 NULL,
            passenger_count FLOAT NULL,
            trip_distance FLOAT NULL,
            RatecodeID FLOAT NULL,
            store_and_fwd_flag NVARCHAR(100) NULL,
            PULocationID INT NULL,
            DOLocationID INT NULL,
            payment_type NVARCHAR(100) NULL,
            fare_amount FLOAT NULL,
            extra FLOAT NULL,
            mta_tax FLOAT NULL,
            tip_amount FLOAT NULL,
            tolls_amount FLOAT NULL,
            improvement_surcharge FLOAT NULL,
            total_amount FLOAT NULL,
            congestion_surcharge FLOAT NULL,
            Airport_fee FLOAT NULL,
            cbd_congestion_fee FLOAT NULL
        );';

        EXEC sys.sp_executesql @SQL;
    END;

    PRINT 'Importing month ' + @MonthText
        + ' from ' + @FilePath;

    SET @SQL = N'
    BULK INSERT ' + @TableName + N'
    FROM ''' + @FilePath + N'''
    WITH (
        FORMAT = ''CSV'',
        FIRSTROW = 2,
        FIELDQUOTE = ''"'',
        BATCHSIZE = 50000,
        TABLOCK,
        MAXERRORS = 10,
        CODEPAGE = ''65001''
    );';

    EXEC sys.sp_executesql @SQL;

    PRINT 'Finished month ' + @MonthText;

    SET @Month = @Month + 1;
END;
GO


---joining all 12 months into one table using a view instead of creating a copy fo all 12 months 


CREATE VIEW raw.vw_yellow_tripdata_2025 AS

SELECT * FROM raw.yellow_tripdata_2025_01
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_02
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_03
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_04
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_05
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_06
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_07
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_08
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_09
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_10
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_11
UNION ALL
SELECT * FROM raw.yellow_tripdata_2025_12;
GO


SELECT
    SUM(total_trips) AS total_trips,
    SUM(percentage_of_trips) AS total_percentage
FROM analytics.vw_q2_dropoff_zone_demand;
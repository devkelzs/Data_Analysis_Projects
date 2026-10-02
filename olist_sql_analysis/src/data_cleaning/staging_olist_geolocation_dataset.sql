SELECT * FROM RAW.olist_geolocation_dataset;

-----chck datatypes 
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'olist_geolocation_dataset'
ORDER BY ORDINAL_POSITION;

----
SELECT 
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END ) AS missing_zip_code_prefix,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END ) AS missing_geolocation_lat,
    SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END ) AS missing_geolocation_lng,
    SUM(CASE WHEN LOWER(TRIM(geolocation_city)) = 'null' OR TRIM(geolocation_city) = '' THEN 1 ELSE 0 END) AS missing_geo_city,
    SUM(CASE WHEN LOWER(TRIM(geolocation_state)) = 'null' OR TRIM(geolocation_state) = '' THEN 1 ELSE 0 END) AS missing_geo_state
FROM raw.olist_geolocation_dataset

---check for duplicates 
SELECT TOP 10
    geolocation_zip_code_prefix,
    geolocation_lat,
    geolocation_lng,
    geolocation_city,
    geolocation_state,
    COUNT(*) AS total_count
FROM raw.olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix,
            geolocation_lat,
            geolocation_lng,
            geolocation_city,
            geolocation_state
HAVING COUNT(*) > 1

SELECT
    COUNT(*) AS Total_rows,
    (
        SELECT COUNT(*) 
        FROM (
            SELECT DISTINCT 
                geolocation_zip_code_prefix,
                geolocation_lat, 
                geolocation_lng, 
                geolocation_city, 
                geolocation_state
            FROM raw.olist_geolocation_dataset
        ) AS X
    ) AS distinct_comb
FROM raw.olist_geolocation_dataset;

WITH geo_frequency AS (
    SELECT
        geolocation_zip_code_prefix, 
        geolocation_lat, 
        geolocation_lng, 
        geolocation_city, 
        geolocation_state,
        COUNT(*) AS frequency
    FROM raw.olist_geolocation_dataset
    GROUP BY
        geolocation_zip_code_prefix, 
        geolocation_lat, 
        geolocation_lng, 
        geolocation_city, 
        geolocation_state
)
SELECT
    frequency,
    COUNT(*) AS number_of_combinations
FROM geo_frequency
GROUP BY frequency
ORDER BY frequency;

--Latitude and longitude validity
---Does the geolocation table contain invalid geographic values?
SELECT
    SUM(CASE WHEN geolocation_lat NOT BETWEEN -90 AND 90 THEN 1 ELSE 0 END ) AS invalid_lat,
    SUM(CASE WHEN geolocation_lng NOT BETWEEN -180 AND 180 THEN 1 ELSE 0 END) AS inavlid_lng
FROM raw.olist_geolocation_dataset;


--- zip code validity check 
WITH zip_status AS 
(
    SELECT 
        CASE
            WHEN geolocation_zip_code_prefix < 0 THEN 'negative' 
            ELSE 'GOOD'
        END AS negative_status,

        CASE 
            WHEN  LEFT(geolocation_zip_code_prefix, 5) NOT LIKE '%[^0-9]%' THEN 'VALID'
            ELSE 'INVALID'
        END AS valid_status
    FROM raw.olist_geolocation_dataset
)
SELECT 
    *
FROM zip_status
WHERE negative_status = 'negative'
OR valid_status = 'INVALID';

---Brazilian state validity
SELECT 
*
FROM raw.olist_geolocation_dataset
WHERE 
    LEN(TRIM(geolocation_state)) > 2
OR
    TRIM(UPPER(geolocation_state)) NOT IN (
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO' 
    );


---Does one ZIP prefix appear in more than one state?
SELECT 
    geolocation_zip_code_prefix,
    COUNT(DISTINCT geolocation_state) AS number_of_states
FROM raw.olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_state) > 1;

WITH zip_code_inconsistent AS 
(
    SELECT 
        geolocation_zip_code_prefix,
        geolocation_state,
        geolocation_city,
        geolocation_lat
    FROM  raw.olist_geolocation_dataset
    WHERE geolocation_zip_code_prefix IN (
        SELECT 
            geolocation_zip_code_prefix
        FROM raw.olist_geolocation_dataset
        GROUP BY geolocation_zip_code_prefix
        HAVING COUNT(DISTINCT geolocation_state) > 1
    )
)
SELECT 
    COUNT(*) as total_zipcode_inconsistency
FROM zip_code_inconsistent;

---how many individual records are actually inconsistent with the dominant state for their ZIP prefix

WITH zip_state_counts AS
(
    SELECT
        geolocation_zip_code_prefix,
        geolocation_state,
        COUNT(*) AS state_count
    FROM raw.olist_geolocation_dataset
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_state
),

dominant_state AS
(
    SELECT
        geolocation_zip_code_prefix,
        geolocation_state AS dominant_state,
        state_count,
        ROW_NUMBER() OVER
        (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY state_count DESC
        ) AS rn
    FROM zip_state_counts
)

SELECT
    geolocation_state,
    geolocation_city,
    geolocation_lat,
    geolocation_lng
FROM raw.olist_geolocation_dataset AS g
INNER JOIN dominant_state AS d
    ON g.geolocation_zip_code_prefix = d.geolocation_zip_code_prefix
WHERE d.rn = 1
  AND g.geolocation_state <> d.dominant_state;

  -- This view contains the analysis-ready Geolocation data while preserving the original raw values.
-- It identifies the dominant state associated with each ZIP code prefix and adds a
-- data-quality flag for records whose state differs from that dominant state.
-- The state values are not corrected or overwritten; the anomaly is only flagged
-- for further analysis.
-- The view preserves the original row count of 1,000,163 records, with 8 records
-- expected to be flagged as ZIP/state inconsistencies.

CREATE VIEW analysis.vw_geolocation_clean
AS

WITH zip_state_counts AS
(
    SELECT
        geolocation_zip_code_prefix,
        geolocation_state,
        COUNT(*) AS state_count
    FROM raw.olist_geolocation_dataset
    GROUP BY
        geolocation_zip_code_prefix,
        geolocation_state
),

dominant_state AS
(
    SELECT
        geolocation_zip_code_prefix,
        geolocation_state AS dominant_state,
        state_count,
        ROW_NUMBER() OVER
        (
            PARTITION BY geolocation_zip_code_prefix
            ORDER BY state_count DESC
        ) AS rn
    FROM zip_state_counts
)

SELECT
    g.geolocation_zip_code_prefix,
    g.geolocation_lat,
    g.geolocation_lng,
    g.geolocation_city,
    g.geolocation_state,

    CASE
        WHEN d.rn = 1
             AND g.geolocation_state <> d.dominant_state
        THEN 1
        ELSE 0
    END AS is_zip_state_inconsistent

FROM raw.olist_geolocation_dataset AS g

LEFT JOIN dominant_state AS d
    ON g.geolocation_zip_code_prefix = d.geolocation_zip_code_prefix
    AND d.rn = 1;

SELECT COUNT(*) AS clean_count
FROM analysis.vw_geolocation_clean;

SELECT
    is_zip_state_inconsistent,
    COUNT(*) AS record_count
FROM analysis.vw_geolocation_clean
GROUP BY is_zip_state_inconsistent;
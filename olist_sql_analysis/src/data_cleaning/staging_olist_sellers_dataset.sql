-----------------------------------------------------------PROFILLING sllers table------------------------------------------
SELECT * FROM raw.olist_sellers_dataset;

---DATA TYPE CHECK FOR EACH COL
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'olist_sellers_dataset'
ORDER BY ORDINAL_POSITION;


---CHECK FOR MISSING OR NULL VALUES 

SELECT 
    SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id) = '' OR LOWER(TRIM(seller_id)) = 'null' THEN 1 ELSE 0 END) AS missing_seller_id,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS missing_zip_code,
    SUM(CASE WHEN seller_city IS NULL OR TRIM(seller_city) = '' OR LOWER(TRIM(seller_city)) = 'null' THEN 1 ELSE 0 END) AS missing_seller_city,
    SUM(CASE WHEN seller_state IS NULL OR TRIM(seller_state) = '' OR LOWER(TRIM(seller_state)) = 'null' THEN 1 ELSE 0 END) AS missing_seller_state
FROM raw.olist_sellers_dataset;

--check for duplicates 
SELECT 
    seller_id,
    COUNT(*) AS total_count
FROM raw.olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;

----zip code validation for negative and invalid values 
WITH zip_status AS 
(
    SELECT 
        CASE
            WHEN seller_zip_code_prefix < 0 THEN 'negative' 
            ELSE 'GOOD'
        END AS negative_status,

        CASE 
            WHEN  LEFT(seller_zip_code_prefix, 5) NOT LIKE '%[^0-9]%' THEN 'VALID'
            ELSE 'INVALID'
        END AS valid_status
    FROM raw.olist_sellers_dataset
)
SELECT 
    *
FROM zip_status
WHERE negative_status = 'negative'
OR valid_status = 'INVALID'

/*check for invalid seller_state abbreviation since brazil 
use a standard of 2 letter abbreviation for all its 26 states 
*/

SELECT 
*
FROM raw.olist_sellers_dataset
WHERE 
    LEN(TRIM(seller_state)) > 2
OR
    TRIM(UPPER(seller_state)) NOT IN (
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO' 
    )

----Referential integrity 
SELECT 
    *
FROM raw.olist_order_items_dataset o  
LEFT JOIN raw.olist_sellers_dataset  s  
ON o.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- Final validation for the Sellers analysis view.
-- Confirms that analysis.vw_sellers_clean preserves the same number of records
-- as the raw Sellers table, ensuring no rows were added or removed during
-- the creation of the analysis-ready view.
CREATE VIEW analysis.vw_sellers_clean
AS 
SELECT 
    seller_id,
    seller_zip_code_prefix,
    seller_city,
    seller_state
FROM raw.olist_sellers_dataset;

SELECT 
    (SELECT COUNT(*) FROM raw.olist_sellers_dataset) AS raw_count,
    (SELECT COUNT(*) FROM analysis.vw_sellers_clean) AS clean_count
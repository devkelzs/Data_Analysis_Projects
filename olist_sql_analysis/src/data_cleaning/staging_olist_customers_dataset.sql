--------------------------------------------------PROFILING--------------------------------------------------------
SELECT * FROM raw.olist_customers_dataset;

---CHECKINF DATA TYPE FOR EACH COL
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'olist_customers_dataset'
ORDER BY ORDINAL_POSITION;

---checks for null-- count for each col
SELECT 
    SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id) = '' OR LOWER(TRIM(customer_id))= 'null' THEN 1 ELSE 0 END ) AS missing_customer_id,
    SUM(CASE WHEN customer_unique_id IS NULL OR TRIM(customer_unique_id)= '' OR LOWER(TRIM(customer_unique_id)) = 'null' THEN 1 ELSE 0 END) AS missing_cus_unique_id,
    SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END ) AS missing_zip_code,
    SUM(CASE WHEN customer_city IS NULL OR TRIM(customer_city)= '' OR LOWER(TRIM(customer_city)) = 'null' THEN 1 ELSE 0 END) AS missing_customer_city,
    SUM(CASE WHEN customer_state IS NULL OR TRIM(customer_state)= '' OR LOWER(TRIM(customer_state)) = 'null' THEN 1 ELSE 0 END) AS missing_customer_state
FROM raw.olist_customers_dataset;

-----CHECKS FOR DUPLICATE 
SELECT 
    customer_id,
    COUNT(*) AS total_count
FROM raw.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;

---Customer identity relationship
WITH customer_identity AS
(
    SELECT 
        customer_unique_id,
        COUNT(DISTINCT customer_id) as unique_count
    FROM raw.olist_customers_dataset
    GROUP BY customer_unique_id
    HAVING COUNT(DISTINCT customer_id) > 1
) 
SELECT COUNT(*) AS total_count 
FROM customer_identity;

---check customer zip codes for negative values , outside brazilian zip code prefix range, unexpected zeros / unusual values.
WITH customer_prefix AS 
(
SELECT 
    CASE 
        WHEN customer_zip_code_prefix < 0 THEN 'negative_value'
        ELSE 'GOOD'
    END AS negative_check,

    CASE 
        WHEN LEFT(customer_zip_code_prefix, 5) NOT LIKE '%[^0-9]%' THEN 'Valid Prefix'
        ELSE 'Invalid Prefix'
    END AS prefix_status
FROM raw.olist_customers_dataset
)
SELECT 
    *
FROM customer_prefix
WHERE prefix_status = 'Invalid Prefix'
OR negative_check = 'negative_value';

/*check for invalid customer_state abbreviation since brazil 
use a standard of 2 letter abbreviation for all its 26 states 
*/

SELECT 
*
FROM raw.olist_customers_dataset
WHERE 
    LEN(TRIM(customer_state)) > 2
OR
    TRIM(UPPER(customer_state)) NOT IN (
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO' 
    )

---REFERENTIAL INTEGRITY CHECK 
SELECT
    *
FROM raw.olist_orders_dataset o  
LEFT JOIN raw.olist_customers_dataset c  
ON o.customer_id = c.customer_id
WHERE C.customer_id IS NULL;

-- This view contains the validated, analysis-ready Customers data.
-- It preserves the original customer identifiers, location attributes,
-- and customer relationship information without changing the raw values
-- or altering the customer-level grain.
-- No additional transformations or data-quality flags are required for Customers.
-- The raw Customers table remains unchanged, and the view should preserve
-- the same number of records as the raw table.
CREATE VIEW analysis.vw_customers_clean
AS
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    customer_city,
    customer_state
FROM raw.olist_customers_dataset;
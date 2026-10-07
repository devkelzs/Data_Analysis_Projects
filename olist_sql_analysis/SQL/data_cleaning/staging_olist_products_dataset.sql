------------------------------------------------------PROFILING----------------------------------------------------------------

SELECT * FROM raw.olist_products_dataset;

--check datatypes for each col
SELECT 
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'olist_products_dataset';


-----check for nulls (total number of nulls in each col) and investigate

SELECT 
    SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' OR LOWER(TRIM(product_id)) = 'null' THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN product_category_name IS NULL OR TRIM(product_category_name) = '' OR LOWER(TRIM(product_category_name)) = 'null' THEN 1 ELSE 0 END) AS missing_product_category,
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END ) AS missing_name_length,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS missing_description_length,
    SUM(CASE WHEN product_photos_qty IS NULL OR TRIM(product_photos_qty) = '' OR LOWER(TRIM(product_photos_qty)) = 'null' THEN 1 ELSE 0 END) AS missing_photos,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END ) AS missing_weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END ) AS missing_length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END ) AS missing_height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END ) AS missing_width
FROM raw.olist_products_dataset;

---shows all 610 with null values for name, photos, description length and nameLength
SELECT 
    COUNT(*) AS total_count
FROM raw.olist_products_dataset
WHERE product_category_name IS NULL
AND product_name_lenght IS NULL 
AND product_description_lenght IS NULL 
AND product_photos_qty IS NULL;

-----chekcing how many appear in order_items
SELECT 
    count(*) AS total_count
FROM raw.olist_products_dataset p  
LEFT JOIN raw.olist_order_items_dataset o  
ON p.product_id = o.product_id
WHERE p.product_category_name IS NULL
AND p.product_name_lenght IS NULL 
AND p.product_description_lenght IS NULL 
AND p.product_photos_qty IS NULL;

---percentage of all products that have these four fields missing
SELECT 
    COUNT(*) AS total_count,
    (SELECT COUNT(*) 
    FROM raw.olist_products_dataset 
    WHERE product_category_name IS NULL 
    AND product_description_lenght IS NULL
    AND product_name_lenght IS NULL
    AND product_photos_qty IS NULL ) AS missing_product_category,
    ROUND((SELECT COUNT(*) 
    FROM raw.olist_products_dataset 
    WHERE product_category_name IS NULL 
    AND product_description_lenght IS NULL
    AND product_name_lenght IS NULL
    AND product_photos_qty IS NULL ) * 100.0 / COUNT(*), 2)AS perc_of_missing_products_category
FROM raw.olist_products_dataset;

/*INVESTING NULLS FROM product_id (2)
product_weight_g
*/
SELECT 
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM raw.olist_products_dataset
WHERE product_weight_g IS NULL;

SELECT 
    p.product_id,
    COUNT(o.product_id) AS total_product,
    SUM(O.price) AS total_price,
    SUM(O.freight_value) AS total_freight
FROM raw.olist_products_dataset p  
LEFT JOIN raw.olist_order_items_dataset o   
ON p.product_id = o.product_id
WHERE p.product_weight_g IS NULL
GROUP BY p.product_id;

--checkign negative values for numerical validity 
SELECT 
    SUM(CASE WHEN product_name_lenght < 0 THEN 1 ELSE 0 END) negative_product_name,
    SUM(CASE WHEN product_description_lenght < 0 THEN 1 ELSE 0 END) negative_product_description_lenght,
    SUM(CASE WHEN TRY_CAST(product_photos_qty AS INT) < 0 THEN 1 ELSE 0 END) negative_product_photos_qty,
    SUM(CASE WHEN product_weight_g < 0 THEN 1 ELSE 0 END) negative_product_weight_g,
    SUM(CASE WHEN product_length_cm < 0 THEN 1 ELSE 0 END) negative_product_length_cm,
    SUM(CASE WHEN product_height_cm < 0 THEN 1 ELSE 0 END) negative_product_height_cm,
    SUM(CASE WHEN product_width_cm < 0 THEN 1 ELSE 0 END) negative_product_width_cm
FROM raw.olist_products_dataset;

---determine whether every non-null value is actually numeric BEFORE COVERTING TO INT 
SELECT
    product_photos_qty,
    COUNT(*) AS total_count
FROM raw.olist_products_dataset
GROUP BY product_photos_qty
ORDER BY product_photos_qty;



-- This view contains the cleaned, analysis-ready Products data.
-- It preserves the original product identifiers and attributes while converting
-- product_photos_qty from NVARCHAR to INT for proper analysis.
-- It also adds two data-quality flags:
--   1. Incomplete_catalog_attributes - flags products with incomplete catalog information.
--   2. Missing_physical_dimensions   - flags products with missing physical dimensions.
-- The raw Products table remains unchanged.
CREATE VIEW analysis.vw_products_clean
AS
SELECT 
    product_id,
    product_category_name,
    product_name_lenght,
    product_description_lenght,
    TRY_CAST(product_photos_qty AS INT) AS product_photos_qty,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm,
    CASE 
        WHEN product_category_name IS NULL 
        AND product_name_lenght IS NULL
        AND product_description_lenght IS NULL 
        AND product_photos_qty IS NULL 
      THEN 1 
      ELSE 0 
    END AS Incomplete_catalog_attributes,

    CASE WHEN product_weight_g IS NULL 
         OR product_length_cm IS NULL 
         OR product_height_cm IS NULL 
         OR product_width_cm IS NULL 
       THEN 1 
       ELSE 0 
    END AS Missing_physical_dimensions

FROM raw.olist_products_dataset;

SELECT TOP 10 *
FROM analysis.vw_products_clean;

SELECT
    COUNT(*) AS total_products,
    SUM(Incomplete_catalog_attributes) AS incomplete_catalog,
    SUM(Missing_physical_dimensions) AS missing_dimensions
FROM analysis.vw_products_clean;
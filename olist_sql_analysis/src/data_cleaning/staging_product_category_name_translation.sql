EXEC sp_rename 
    'RAW.product_category_name_translation.column1',
    'product_category_name',
    'COLUMN';

EXEC sp_rename 
    'RAW.product_category_name_translation.column2',
    'product_category_name_english',
    'COLUMN';


/*DELETE FROM RAW.product_category_name_translation
WHERE product_category_name = 'product_category_name'
  AND product_category_name_english = 'product_category_name_english';
*/
SELECT * FROM RAW.product_category_name_translation

-----CHECK FOR DATATYPE

SELECT 
    COLUMN_NAME,
    DATA_TYPE, 
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'product_category_name_translation'
ORDER BY ORDINAL_POSITION;

---------CHECK FOR MISSING OR NULL VALUES 
SELECT 
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END ) AS missing_product_name,
    SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END ) AS missing_product_name_english
FROM raw.product_category_name_translation

--DUPLICATE CHECK
SELECT 
    product_category_name,
    COUNT(*) AS total_count
FROM raw.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;

SELECT
    product_category_name_english,
    COUNT(*) AS total_count
FROM raw.product_category_name_translation
GROUP BY product_category_name_english
HAVING COUNT(*) > 1;

---Does every product category in the products table have a corresponding translation?
SELECT 
    p.product_category_name,
    pc.product_category_name_english
FROM raw.olist_products_dataset p  
LEFT JOIN raw.product_category_name_translation  pc 
ON p.product_category_name = pc.product_category_name
WHERE PC.product_category_name_english IS NULL 

SELECT
    COUNT(DISTINCT p.product_category_name) AS untranslated_categories
FROM analysis.vw_products_clean AS p
LEFT JOIN raw.product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL;


CREATE OR ALTER VIEW analysis.vw_product_category_translation
AS
SELECT
    product_category_name,
    product_category_name_english
FROM raw.product_category_name_translation

UNION ALL

SELECT
    'pc_gamer',
    'Gaming PC'

UNION ALL

SELECT
    'portateis_cozinha_e_preparadores_de_alimentos',
    'Portable Kitchen and Food Preparers';


SELECT
    product_category_name,
    product_category_name_english,
    COUNT(*) AS row_count
FROM analysis.vw_product_category_translation
WHERE product_category_name IN
(
    'pc_gamer',
    'portateis_cozinha_e_preparadores_de_alimentos'
)
GROUP BY
    product_category_name,
    product_category_name_english;
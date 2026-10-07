--------------------------------------------------PROFILING-------------------------------------------------------------
SELECT TOP 2 * FROM raw.olist_order_items_dataset;
SELECT TOP 2 * FROM analysis.vw_orders_clean;
SelECT TOP 2 * FROM raw.olist_products_dataset

SELECT 
    COUNT(DISTINCT order_item_id) AS total_items
FROM raw.olist_order_items_dataset;

--Checks for null values in all columns 
SELECT 
    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END ) AS missing_order_item_id,
    SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END ) AS missing_product_id,
    SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id) = '' THEN 1 ELSE 0 END ) AS missing_seller_id,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS missing_shipping_limit_date,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END ) AS missing_freight_value
FROM raw.olist_order_items_dataset;

---checks for duplicate values using business key (order_id, order_item) because order_item_id is not necessarily globally unique

SELECT 
    order_id,
    order_item_id,
    COUNT(*) AS duplicate_count
FROM raw.olist_order_items_dataset
GROUP BY order_id,
        order_item_id
HAVING  COUNT(*) > 1;
        
--Validating Numeric Values 
SELECT 
    SUM(CASE WHEN price < 0 THEN 1 ELSE 0 END) AS negative_price,
    SUM(CASE WHEN price = 0 THEN 1 ELSE 0 END ) AS zero_price,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS negative_freight,
    SUM(CASE WHEN freight_value = 0 THEN 1 ELSE 0  END) AS zero_freight
FROM raw.olist_order_items_dataset;

SELECT TOP 20 
    order_id,
    order_item_id,
    price,
    freight_value,
    seller_id
FROM raw.olist_order_items_dataset
WHERE 
    freight_value = 0;

SELECT 
    ot.order_id,
    ot.seller_id,
    ot.shipping_limit_date,
    oc.order_purchase_timestamp
FROM raw.olist_order_items_dataset ot  
INNER JOIN analysis.vw_orders_clean oc  
ON ot.order_id = oc.order_id
WHERE ot.shipping_limit_date < oc.order_purchase_timestamp;

----------------------Referential integrity
--product relationship
SELECT 
    COUNT(*) AS missing_product_id
FROM raw.olist_order_items_dataset  ot  
LEFT JOIN raw.olist_products_dataset p  
ON ot.product_id = p.product_id
WHERE p.product_id IS NULL ;

--Seller relationship 
--Are there any order-item records whose seller_id does not exist in raw.olist_sellers_dataset?
SELECT * FROM raw.olist_sellers_dataset;

SELECT 
    COUNT(*) as missing_seller_id
FROM raw.olist_order_items_dataset ot  
LEFT JOIN raw.olist_sellers_dataset s  
ON ot.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

----For delivered orders, is shipping_limit_date later than the actual customer delivery date?
SELECT 
    COUNT(*) 
FROM raw.olist_order_items_dataset ot  
LEFT JOIN analysis.vw_orders_clean oc  
ON ot.order_id = oc.order_id
WHERE ot.shipping_limit_date > oc.order_delivered_customer_date;

SELECT 
    COUNT(*) AS missing_order_id
FROM raw.olist_order_items_dataset ot
LEFT JOIN analysis.vw_orders_clean oc
    ON ot.order_id = oc.order_id
WHERE oc.order_id IS NULL;


-- This view contains the validated, analysis-ready Order Items data.
-- It preserves the original fields without adding calculated columns or data-quality flags,
-- since the assessment found no confirmed data-quality conditions requiring additional flags.
-- The view includes order, item, product, seller, shipping-limit, price, and freight-value information.
-- Zero-freight records and shipping-limit dates occurring after delivery were investigated
-- and retained because they were determined to be legitimate business patterns.
CREATE VIEW analysis.vw_order_items_clean
AS 
SELECT 
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price,
    freight_value
FROM raw.olist_order_items_dataset

--check for the created view 
SELECT
    (SELECT COUNT(*) FROM raw.olist_order_items_dataset) AS raw_count,
    (SELECT COUNT(*) FROM analysis.vw_order_items_clean) AS view_count;












SELECT 
    COLUMN_NAME,
    DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'olist_order_items_dataset'
--------------------------------------Structural Exploration-------------------------------------------------------

SELECT COUNT(*) AS total_customers FROM raw.olist_customers_dataset;
SELECT COUNT(*) AS total_items FROM raw.olist_order_items_dataset;
SELECT COUNT(*) AS total_orders FROM raw.olist_orders_dataset;
SELECT COUNT(*) AS total_products FROM raw.olist_products_dataset;
SELECT COUNT(*) AS total_reviews FROM raw.olist_order_reviews_dataset;
SELECT COUNT(*) AS total_sellers FROM raw.olist_sellers_dataset;

SELECT 
    COUNT(order_id) as total_ids,
    COUNT(DISTINCT order_id) AS Unique_ids
FROM raw.olist_orders_dataset;

SELECT
    COUNT(product_id) AS total_products,
    COUNT(DISTINCT product_id) AS unique_products
FROM raw.olist_products_dataset;


SELECT 
    COLUMN_NAME,
    DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
    AND TABLE_NAME IN ('olist_orders_dataset', 'olist_products_dataset', 'olist_order_items_dataset', 'olist_order_reviews_dataset', 'olist_sellers_dataset' )
ORDER BY ORDINAL_POSITION;


-----------------------------Missing Data and Integrity -------------------------------------------------------------
SELECT * FROM raw.olist_products_dataset;

--Missing product categories
SELECT 
    COUNT(*) AS missing_products 
FROM raw.olist_products_dataset
WHERE 
    product_category_name IS NULL 
    OR LOWER(TRIM(product_category_name)) IN ('null', 'unknown', 'n/a');

---missing prices 
SELECT
    COUNT(*) AS missing_invalid_prices
FROM raw.olist_order_items_dataset
WHERE 
    price IS NULL 
    OR price <= 0;

-----Orphaned records

SELECT 
    COUNT(*) AS orphaned_records
FROM raw.olist_order_items_dataset ot  
LEFT JOIN raw.olist_orders_dataset o  
ON ot.order_id = o.order_id
WHERE o.order_id IS NULL;

---------------------------------------------Volumetric & Boundary Analysis---------------------------------------
SELECT * FROM raw.olist_orders_dataset

----Timeline ----
SELECT 
    MAX(order_purchase_timestamp) AS latest_order_date,
    MIN(order_purchase_timestamp) AS earliest_order_date,
    DATEDIFF(day, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp) ) AS dataset_duration_days,
    MIN(order_approved_at) AS earliest_approval_date,
    MAX(order_approved_at) AS latest_approval_date,
    MIN(order_delivered_carrier_date) AS earliest_carrier_delivery_date,
    MAX(order_delivered_carrier_date) AS latest_carrier_delivery_date,
    MIN(order_delivered_customer_date) AS earliest_customer_delivery_date,
    MAX(order_delivered_customer_date) AS latest_customer_delivery_date,
    MIN(order_estimated_delivery_date) AS earliest_estimated_delivery_date,
    MAX(order_estimated_delivery_date) AS latest_estimated_delivery_date
FROM raw.olist_orders_dataset;


---Order Status Distribution
SELECT * FROM raw.olist_orders_dataset;

SELECT 
    DISTINCT(order_status) As Order_status
FROM raw.olist_orders_dataset;

SELECT 
    order_status,
    COUNT(*) AS status_total,
    (SELECT COUNT(*) FROM raw.olist_orders_dataset) AS grand_total,
    CAST(ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM raw.olist_orders_dataset), 3) AS FLOAT) AS status_percentage
FROM raw.olist_orders_dataset
GROUP BY order_status;

---Price Distribution--
SELECT TOP 200 * 
FROM raw.olist_order_items_dataset
ORDER BY price DESC;

SELECT 
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price,
    AVG(price) AS Average_price
FROM raw.olist_order_items_dataset


WITH price_band_distribution AS
(
    SELECT 
            CASE 
                WHEN price < 100 THEN 'Very Low'
                WHEN price >=100 AND price <= 500 THEN 'Low'
                WHEN price > 500 AND price <= 2000 THEN 'Medium'
                WHEN price > 2000 AND price <= 4000 THEN 'High'
                ELSE 'Very High'
            END AS price_band
    FROM raw.olist_order_items_dataset
)

SELECT 
    price_band,
    COUNT(*) AS total_items
FROM price_band_distribution
GROUP BY  price_band;


------------------------------------Geography and Category Variety----------------------------------------------
SELECT * FROM raw.olist_products_dataset

--Distinct Product Categories 
SELECT 
    COUNT(DISTINCT product_category_name) AS total_categories
FROM raw.olist_products_dataset

---DISTINCT STATES 
SELECT
    COUNT(DISTINCT customer_state) as total_states 
FROM raw.olist_customers_dataset
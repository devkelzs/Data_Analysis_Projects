-------------------------------------------------------------PROFILING--------------------------------------------------------------------------------------------------------------

SELECT * FROM raw.olist_orders_dataset;

SELECT 
        SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' OR LOWER(TRIM(order_id)) IN ('null', 'unknwon') THEN 1 ELSE 0 END) AS missing_invalid_order_id,
        SUM(CASE WHEN  customer_id IS NULL OR TRIM(customer_id) = '' OR LOWER(TRIM(customer_id)) IN ('null', 'unknwon') THEN 1 ELSE 0 END) AS missing_invalid_customer_id, 
        SUM(CASE WHEN  order_status IS NULL OR TRIM(order_status) = '' OR LOWER(TRIM(order_status)) IN ('null', 'unknwon') THEN 1 ELSE 0 END) AS missing_invalid_order_status,
        SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END ) AS missing_order_purchase_timestamp,
        SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END ) AS missing_order_approved_at,
        SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END ) AS missing_order_delivered_carrier_date,
        SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END ) AS missing_order_delivered_customer_date,
        SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END ) AS missing_order_estimated_delivery_date
FROM raw.olist_orders_dataset


SELECT 
    order_status,
    COUNT(*) AS total_count
FROM raw.olist_orders_dataset
WHERE order_approved_at IS NULL
GROUP BY order_status;

---Ccheck relationship of the nulls and see if other lifecycle dates are populated 

SELECT 
    *
FROM raw.olist_orders_dataset
WHERE order_status = 'delivered'
AND order_approved_at IS NULL;

SELECT 
    order_status,
    COUNT(*)  AS total_count
FROM raw.olist_orders_dataset
WHERE order_delivered_carrier_date IS NULL 
GROUP BY order_status;

SELECT 
    *
FROM raw.olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_carrier_date IS NULL;

SELECT 
    order_status,
    COUNT(*) AS total_count
FROM raw.olist_orders_dataset
WHERE order_delivered_customer_date IS NULL 
GROUP BY order_status;

SELECT 
    *
FROM raw.olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;

SELECT 
    SUM(CASE WHEN order_approved_at IS NOT NULL AND order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END ) AS invalid_approve_date,
    SUM(CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END ) AS invalid_deliveryCarier_date,
    SUM(CASE WHEN order_delivered_customer_date IS NOT NULL AND order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS invalid_deliveryCustomer_date,
    SUM(CASE WHEN order_estimated_delivery_date IS NOT NULL AND order_estimated_delivery_date < order_delivered_customer_date THEN 1 ELSE 0 END) AS late_deliveries
FROM raw.olist_orders_dataset;

-----Potential lifecycle sequencing anomaly: 1,359 records
SELECT TOP 30
*
FROM raw.olist_orders_dataset
WHERE order_delivered_carrier_date IS NOT NULL
    AND order_delivered_carrier_date < order_approved_at;

-----INVALID_DELIVERY_SEQUENCE 23 records 
SELECT 
*
FROM raw.olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
    AND order_delivered_customer_date < order_delivered_carrier_date;

---Duplicate orders check 
SELECT 
    order_id,
    COUNT(*) AS duplicate_candidate
FROM raw.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1


SELECT 
    order_status,
    COUNT(*) as status_total
FROM raw.olist_orders_dataset
GROUP BY 
    order_status
ORDER BY   
    status_total DESC;

---Categorical text formating--
---Are there any order_status values where TRIM(order_status) is different from the original value?

SELECT
    order_status,
    COUNT(*) AS total_count
FROM raw.olist_orders_dataset
WHERE order_status <> TRIM(order_status)
GROUP BY 
    order_status;

-------business-rule validation
--How many delivered orders have order_delivered_customer_date IS NULL
--How many delivered orders have order_delivered_carrier_date IS NULL?
--How many canceled orders have a non-NULL order_delivered_customer_date?
--How many canceled orders have a carrier delivery date?
SELECT 
    SUM(CASE WHEN order_status = 'delivered' AND order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery_date,
    SUM(CASE WHEN order_status = 'shipped' AND order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS missing_carrier_date,
    SUM(CASE WHEN order_status = 'deilvered' AND order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END ) AS missing_carrier_date,
    SUM(CASE WHEN order_status = 'cancelled' AND order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END) AS cancelled_order_status,
    SUM(CASE WHEN order_status = 'cancelled' AND order_delivered_carrier_date IS NOT NULL THEN 1 ELSE 0 END) AS cancelled_order_with_deliveryCarrierDate,
    SUM(CASE WHEN order_status = 'approved' AND order_delivered_customer_date IS NOT NULL THEN 1 ELSE 0 END) AS approved_with_deliveryDate
FROM raw.olist_orders_dataset



-- This view contains the cleaned Orders data while preserving the original raw date values.
-- It also adds analytical flags to identify data-quality issues and business conditions:
--   1. is_delivery_date_missing      - Flags orders with a missing delivery date.
--   2. is_carrier_before_approval    - Flags orders where the carrier date occurs before approval.
--   3. is_delivery_before_carrier    - Flags orders where delivery occurs before the carrier date.
--   4. is_late_delivery               - Business flag identifying orders delivered later than expected.
-- The first three flags assess data quality, while the final flag represents a business-related condition.
CREATE VIEW analysis.vw_orders_clean
AS
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    CASE WHEN order_status = 'delivered' AND order_delivered_customer_date IS NULL THEN 1 ELSE 0  END AS is_delivery_date_missing,
    CASE WHEN order_delivered_carrier_date IS NOT NULL AND order_approved_at IS NOT NULL AND order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END AS is_carrier_before_approval,
    CASE WHEN order_delivered_customer_date IS NOT NULL AND order_delivered_carrier_date IS NOT NULL AND order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END AS is_delivery_before_carrier,
    CASE WHEN order_estimated_delivery_date IS NOT NULL AND order_delivered_customer_date  IS NOT NULL AND order_estimated_delivery_date < order_delivered_customer_date THEN 1 ELSE 0 END AS is_late_delivery
FROM raw.olist_orders_dataset



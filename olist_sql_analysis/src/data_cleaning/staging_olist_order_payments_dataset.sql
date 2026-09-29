SELECT * FROM raw.olist_order_payments_dataset;

---check for data type for each col 
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'olist_order_payments_dataset'
ORDER BY ORDINAL_POSITION;

---Check for null-- count of all nulls per col
SELECT 
    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' OR LOWER(TRIM(order_id)) = 'null' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END ) AS missing_payment_sequential,
    SUM(CASE WHEN payment_type IS NULL OR TRIM(payment_type) = '' OR LOWER(TRIM(payment_type))= 'null' THEN 1 ELSE 0 END) AS missing_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS missing_payment_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END ) AS missing_payment_value
FROM raw.olist_order_payments_dataset;

---CHECK FOR DUPLICATES 
SELECT 
    order_id,
    payment_sequential,
    COUNT(*) AS total_count
FROM raw.olist_order_payments_dataset
GROUP BY 
    order_id,
    payment_sequential
HAVING COUNT(*) > 1;

----VALIDATING PAYMENT VALUES FOR NEGATIVE or impossible VALUES for set col
--2 values with 0 payment installments and 9 zero payment values 
SELECT 
    SUM(CASE WHEN payment_sequential < 1 THEN 1 ELSE 0 END) AS negative_payment_sequential,
    SUM(CASE WHEN payment_installments < 1 THEN 1 ELSE 0 END) AS negative_payment_intallments,
    SUM(CASE WHEN payment_value < 0 THEN 1 ELSE 0 END ) AS negative_payment_value,
    SUM(CASE WHEN payment_value = 0 THEN 1 ELSE 0 END) AS zero_payment_value
FROM raw.olist_order_payments_dataset;

--investigating the 2 payment installments (0)
SELECT 
    *
FROM raw.olist_order_payments_dataset
WHERE 
    payment_installments < 1;

--investigating the 9 zero payment values 
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM raw.olist_order_payments_dataset
WHERE payment_value = 0;

---payment types and their frequencies 
SELECT 
    payment_type,
    COUNT(*) total_count
FROM raw.olist_order_payments_dataset
GROUP BY 
    payment_type
ORDER BY 
    total_count DESC;

-----referential integrity
SELECT 
    COUNT(*) AS missing_order_reference
FROM raw.olist_order_payments_dataset p
LEFT JOIN analysis.vw_orders_clean o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;



-- This view contains the cleaned, analysis-ready Order Payments data.
-- It preserves the original payment identifiers and attributes while converting
-- payment_value to DECIMAL(18,2) for consistent numerical analysis.
-- It also adds three analytical flags:
--   1. is_invalid_installment   - flags payment records with installments below 1.
--   2. is_unknown_payment_type  - flags records with an unknown 'not_defined' payment type.
--   3. is_zero_payment          - flags records where the payment value is zero.
-- Zero-payment records are flagged for analysis but are not automatically treated as invalid.
-- The raw Order Payments table remains unchanged, and this view preserves its original row count.
CREATE VIEW analysis.vw_order_payments_clean
AS
SELECT 
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    TRY_CAST(payment_value AS DECIMAL(18,2)) AS payment_value,
    CASE WHEN payment_installments < 1 THEN 1 ELSE 0 END AS is_invalid_installment,
    CASE WHEN payment_type = 'not_defined' THEN 1 ELSE 0 END AS is_unknown_payment_type,
    CASE WHEN TRY_CAST(payment_value AS DECIMAL(18,2)) = 0 THEN 1 ELSE 0 END AS is_zero_payment
FROM raw.olist_order_payments_dataset;


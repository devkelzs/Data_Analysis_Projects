----------------------------------------------------PROFILLING FOR ORDER REVIEWS-------------------------------------------
SELECT * FROM raw.olist_order_reviews_dataset;

------CHECK FOR DATA TYPES 
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'raw'
AND TABLE_NAME = 'olist_order_reviews_dataset'
ORDER BY ORDINAL_POSITION;

SELECT 
    SUM(CASE WHEN review_id IS NULL OR TRIM(review_id) = '' OR LOWER(TRIM(review_id)) = 'null' THEN 1 ELSE 0 END) AS missing_review_ID,
    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' OR LOWER(TRIM(order_id)) = 'null' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN review_score IS NULL  THEN 1 ELSE 0 END) AS missing_review_score,
    SUM(CASE WHEN review_comment_title IS NULL OR TRIM(review_comment_title) = '' OR LOWER(TRIM(review_comment_title)) = 'null' THEN 1 ELSE 0 END) AS missing_review_comment_title,
    SUM(CASE WHEN review_comment_message IS NULL OR TRIM(review_comment_message) = '' OR LOWER(TRIM(review_comment_message)) = 'null' THEN 1 ELSE 0 END) AS missing_review_comment_message,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS missing_review_creation_date,
    SUM(CASE WHEN review_answer_timestamp IS NULL  THEN 1 ELSE 0 END) AS missing_review_answer_timestamp
FROM raw.olist_order_reviews_dataset;                 

----CHECK FOR DUPLICATE review id 
SELECT
    review_id,
    COUNT(*) AS total_count
FROM raw.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;

----Investigating duplicated review ids to see the relationship with order id , if the reviews are linked to different orders
SELECT 
    review_id,
    order_id
FROM raw.olist_order_reviews_dataset
WHERE review_id IN (
    SELECT 
        review_id
    FROM raw.olist_order_reviews_dataset
    GROUP BY review_id
    HAVING COUNT(DISTINCT order_id) > 1
)

SELECT TOP 20
    review_id,
   COUNT(DISTINCT order_id) AS ORDER_COUNT
FROM raw.olist_order_reviews_dataset
GROUP BY
    review_id
HAVING COUNT(DISTINCT order_id) > 1;

SELECT 
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM raw.olist_order_reviews_dataset
WHERE review_id = '02aa7f5f75e964e3c7efa59a1f515281';

---Previous query reveals  a review id can be asssociated with morethan one order_id there we use a composite business key to check for duplicate checks 
SELECT 
    review_id,
    order_id,
    COUNT(*) AS total_count
FROM raw.olist_order_reviews_dataset
GROUP BY
    review_id,
    order_id
HAVING COUNT(*) > 1;

----numeric validity check for review score col

SELECT 
    SUM (CASE 
        WHEN review_score NOT BETWEEN 1 AND 5 THEN 1 ELSE 0 
        END) AS invalid_review,

    SUM(CASE 
            WHEN review_score < 0 THEN 1 ELSE 0 
        END ) AS negative_score
FROM raw.olist_order_reviews_dataset;

-- referential check  between reviews and order purchase timestamp to see if there are any reviews created before order was purchased

SELECT 
    r.review_creation_date,
    o.order_purchase_timestamp
FROM raw.olist_order_reviews_dataset r  
INNER JOIN raw.olist_orders_dataset o  
ON r.order_id = o.order_id
WHERE r.review_creation_date < CAST(o.order_purchase_timestamp AS DATE)

----Are there any review records pointing to an order that does not exist in analysis.vw_orders_clean

SELECT 
    *
FROM raw.olist_order_reviews_dataset r  
LEFT JOIN raw.olist_orders_dataset o  
ON r.order_id = o.order_id
WHERE o.order_id IS NULL


-- This view contains the cleaned, analysis-ready Order Reviews data.
-- It preserves the original review fields and does not modify the raw Reviews table.
-- It adds a temporal data-quality flag identifying reviews whose creation date
-- occurs before the associated order's purchase date.
-- Missing review titles and messages are retained because they are not considered
-- invalid records, while the 64 identified temporal anomalies are flagged for analysis
-- rather than removed.
CREATE VIEW analysis.vw_order_reviews_clean
AS
SELECT 
    review_id,
    r.order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp,
    CASE 
        WHEN review_creation_date < CAST(order_purchase_timestamp AS DATE) THEN 1 ELSE 0 END AS is_pre_purchase_review
FROM raw.olist_order_reviews_dataset r  
INNER JOIN analysis.vw_orders_clean o  
ON r.order_id = o.order_id;

SELECT 
    (SELECT COUNT(*) FROM raw.olist_order_reviews_dataset) AS raw_count,
    (SELECT COUNT(*) FROM analysis.vw_order_reviews_clean ) AS clean_count,
    (SELECT COUNT(*) FROM analysis.vw_order_reviews_clean WHERE is_pre_purchase_review = 1) AS pre_purchase_review_count
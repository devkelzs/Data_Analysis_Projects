---How many delivered-order item records have a matching seller, and are there any delivered-order items without a seller?
SELECT 
    COUNT(ot.order_id) AS delivered_items_without_seller
FROM analysis.vw_orders_clean oc  
LEFT JOIN analysis.vw_order_items_clean ot   
ON oc.order_id = ot.order_id
WHERE oc.order_status = 'delivered'
    AND ot.seller_id IS NULL

---Are there any delivered-order items whose seller does not exist in
SELECT 
    COUNT(oc.order_id)
FROM analysis.vw_orders_clean oC 
INNER JOIN analysis.vw_order_items_clean ot  
ON oc.order_id = ot.order_id
LEFT JOIN analysis.vw_sellers_clean s  
ON ot.seller_id = s.seller_id
WHERE s.seller_id IS NULL
    AND oc.order_status = 'delivered'



WITH sellers_monthly_sales AS 
(
    SELECT 
        YEAR(oc.order_purchase_timestamp) AS sales_year,
        MONTH(oc.order_purchase_timestamp) AS sales_month,
        ot.seller_id,
        CAST(SUM(ot.price) AS DECIMAL(18,2)) AS revenue_per_month
    FROM analysis.vw_orders_clean oc  
    INNER JOIN analysis.vw_order_items_clean ot  
    ON oc.order_id = ot.order_id
    WHERE oc.order_status = 'delivered'
    GROUP BY 
        YEAR(oc.order_purchase_timestamp),
        MONTH(oc.order_purchase_timestamp),
        ot.seller_id
),
seller_activity AS 
(
    SELECT 
        seller_id,
        COUNT(*) AS active_months
    FROM sellers_monthly_sales
    GROUP BY 
        seller_id
)
SELECT 
    AVG(active_months * 1.0) AS avg_active_months_per_seller,
    MIN(active_months * 1.0) AS MIN_active_months_per_seller,
    MAX(active_months * 1.0) AS MAX_active_months_per_seller
FROM seller_activity;



/*SELECT 
    COUNT(DISTINCT seller_id) AS total_sellers,
    COUNT(*) AS total_seller_month_records ,
    MIN(DATEFROMPARTS(sales_year, sales_month, 1)) AS first_seller_month,
    MAX(DATEFROMPARTS(sales_year, sales_month, 1)) AS last_seller_month
FROM sellers_monthly_sales
*/


WITH sellers_monthly_sales AS 
(
    SELECT 
        YEAR(oc.order_purchase_timestamp) AS sales_year,
        MONTH(oc.order_purchase_timestamp) AS sales_month,
        ot.seller_id,
        CAST(SUM(ot.price) AS DECIMAL(18,2)) AS revenue_per_month
    FROM analysis.vw_orders_clean oc  
    INNER JOIN analysis.vw_order_items_clean ot  
    ON oc.order_id = ot.order_id
    WHERE oc.order_status = 'delivered'
    GROUP BY 
        YEAR(oc.order_purchase_timestamp),
        MONTH(oc.order_purchase_timestamp),
        ot.seller_id
)

SELECT 
    sales_year, sales_month,
    COUNT(Distinct seller_id) as total_sellers
FROM sellers_monthly_sales
GROUP BY sales_year, sales_month;


WITH calendar_months AS
(
    SELECT
        DATEADD(MONTH, n, DATEFROMPARTS(2016, 9, 1)) AS month_start
    FROM
    (
        SELECT TOP (24)
            ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
        FROM sys.all_objects
    ) x
),

seller_list AS
(
    SELECT DISTINCT
        oi.seller_id
    FROM analysis.vw_orders_clean o
    INNER JOIN analysis.vw_order_items_clean oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
),

seller_month_frame AS
(
    SELECT
        s.seller_id,
        c.month_start
    FROM seller_list s
    CROSS JOIN calendar_months c
),

sellers_monthly_sales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS month_start,
        oi.seller_id,
        CAST(SUM(oi.price) AS DECIMAL(18,2)) AS monthly_sales
    FROM analysis.vw_orders_clean o
    INNER JOIN analysis.vw_order_items_clean oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp),
        oi.seller_id
),

seller_monthly_ranked AS
(
    SELECT
        f.seller_id,
        f.month_start,
        COALESCE(s.monthly_sales, 0) AS monthly_sales,

        CASE
            WHEN COALESCE(s.monthly_sales, 0) > 0
            THEN RANK() OVER
            (
                PARTITION BY f.month_start
                ORDER BY COALESCE(s.monthly_sales, 0) DESC
            )
        END AS seller_rank

    FROM seller_month_frame f
    LEFT JOIN sellers_monthly_sales s
        ON f.seller_id = s.seller_id
        AND f.month_start = s.month_start
),

seller_rank_movement AS
(
    SELECT
        seller_id,
        month_start,
        monthly_sales,
        seller_rank,

        LAG(seller_rank) OVER
        (
            PARTITION BY seller_id
            ORDER BY month_start
        ) AS previous_rank

    FROM seller_monthly_ranked
)

SELECT
    rm.month_start,
    rm.seller_id,
    s.seller_city,
    s.seller_state,
    rm.monthly_sales,
    rm.seller_rank,
    rm.previous_rank,

    CASE
        WHEN rm.seller_rank = 1
             AND rm.previous_rank IS NULL
            THEN 'New Monthly Leader'

        WHEN rm.seller_rank IS NULL
             AND rm.previous_rank IS NOT NULL
            THEN 'Inactive'

        WHEN rm.seller_rank IS NOT NULL
             AND rm.previous_rank IS NULL
            THEN 'New/Reactivated'

        WHEN rm.seller_rank < rm.previous_rank
            THEN 'Improved'

        WHEN rm.seller_rank > rm.previous_rank
            THEN 'Declined'

        WHEN rm.seller_rank = rm.previous_rank
            THEN 'Unchanged'

        ELSE 'No Previous Rank'
    END AS rank_movement

FROM seller_rank_movement rm
LEFT JOIN analysis.vw_sellers_clean s
    ON rm.seller_id = s.seller_id

ORDER BY
    rm.month_start,
    rm.seller_rank,
    rm.seller_id;


WITH monthly_sales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ) AS month_start,

        oi.seller_id,

        CAST(SUM(oi.price) AS DECIMAL(18,2)) AS monthly_sales

    FROM analysis.vw_orders_clean o

    INNER JOIN analysis.vw_order_items_clean oi
        ON o.order_id = oi.order_id

    WHERE o.order_status = 'delivered'

    GROUP BY
        DATEFROMPARTS(
            YEAR(o.order_purchase_timestamp),
            MONTH(o.order_purchase_timestamp),
            1
        ),
        oi.seller_id
),

seller_ranking AS
(
    SELECT
        month_start,
        seller_id,
        monthly_sales,

        RANK() OVER
        (
            PARTITION BY month_start
            ORDER BY monthly_sales DESC
        ) AS seller_rank

    FROM monthly_sales
),

rank_changes AS
(
    SELECT
        month_start,
        seller_id,
        monthly_sales,
        seller_rank,

        LAG(seller_rank) OVER
        (
            PARTITION BY seller_id
            ORDER BY month_start
        ) AS previous_rank

    FROM seller_ranking
)

SELECT
    r.month_start,
    r.seller_id,
    s.seller_city,
    s.seller_state,
    r.monthly_sales,
    r.seller_rank,
    r.previous_rank,

    CASE
        WHEN r.previous_rank IS NULL THEN 'New'
        WHEN r.seller_rank < r.previous_rank THEN 'Improved'
        WHEN r.seller_rank > r.previous_rank THEN 'Declined'
        WHEN r.seller_rank = r.previous_rank THEN 'Unchanged'
    END AS rank_movement

FROM rank_changes r

LEFT JOIN analysis.vw_sellers_clean s
    ON r.seller_id = s.seller_id

ORDER BY
    r.month_start,
    r.seller_rank;
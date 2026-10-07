/*Which sellers have the strongest sales performance each month, 
and how does their ranking change over time?
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
),

rank_sellers AS 
(
    SELECT
        ss.*,
        sc.seller_city,
        sc.seller_state,
        RANK() OVER (PARTITION BY ss.sales_year, ss.sales_month ORDER BY ss.revenue_per_month DESC) AS seller_Rank
    FROM sellers_monthly_sales ss  
    INNER JOIN analysis.vw_sellers_clean sc  
    ON ss.seller_id = sc.seller_id
)
SELECT 
    seller_id,
    sales_year,
    seller_city,
    seller_state,
    DATENAME(MONTH, DATEFROMPARTS(sales_year, sales_month, 1)) AS month_name,
    revenue_per_month,
    seller_Rank
FROM rank_sellers
WHERE seller_Rank = 1
ORDER BY 
    sales_year,
    sales_month;



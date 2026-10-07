/* Which Brazilian state generate the most sales 
and how does their customer activities compare 
*/

WITH state_loyalty_metrics AS 
(
    SELECT 
    c.customer_state,
    COUNT(*) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS total_customers,
    CAST(COUNT(*) * 1.0 /COUNT(DISTINCT c.customer_unique_id) AS DECIMAL(18,2))  AS orders_per_customer,
    ---percentage calculation
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(18,2)) AS pct_of_order
    FROM analysis.vw_orders_clean o
    INNER JOIN analysis.vw_customers_clean c  
    ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
)
SELECT 
    *
FROM state_loyalty_metrics
ORDER BY total_orders DESC;
/* 
Calculates state-level order frequency and market share percentages to evaluate regional behavior.
*/
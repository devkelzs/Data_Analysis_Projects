/*How much revenue has MercadoNova generated,
and how does revenue vary by product category?
*/
WITH Revenue AS 
(
    SELECT 
        pt.product_category_name_english,
        CAST(SUM(o.price) AS DECIMAL(18,2)) AS total_revenue,
        CAST((CAST(SUM(o.price) AS DECIMAL(18,2)) * 100.00) / CAST(SUM(SUM(o.price)) OVER() AS DECIMAL(18,2)) AS DECIMAL(5,2)) AS revenue_percentage,
        CAST(SUM(SUM(o.price)) OVER() AS DECIMAL(18,2)) AS overall_grand_total
    FROM analysis.vw_order_items_clean o  
    LEFT JOIN analysis.vw_products_clean p  
    ON o.product_id = p.product_id
    LEFT JOIN analysis.vw_product_category_translation pt  
    ON p.product_category_name = pt.product_category_name
    GROUP BY    
        pt.product_category_name_english
)
SELECT 
*
FROM Revenue
ORDER BY total_revenue DESC;

-- Calculates total product revenue by product category
-- and each category's percentage contribution to overall revenue.
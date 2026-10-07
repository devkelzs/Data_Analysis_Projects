/*How does the average customer review score vary across product categories, 
and which categories receive the most reviews?
*/
WITH review_category_bridge AS 
(
    SELECT DISTINCT 
        r.review_id,
        r.order_id,
        r.review_score,
        p.product_category_name,
        pt.product_category_name_english
    FROM analysis.vw_order_reviews_clean AS r  
    INNER JOIN analysis.vw_order_items_clean AS ot  
    ON r.order_id = ot.order_id
    INNER JOIN analysis.vw_products_clean p  
    ON ot.product_id = p.product_id
    LEFT JOIN analysis.vw_product_category_translation pt  
    ON p.product_category_name = pt.product_category_name
    WHERE p.product_category_name IS NOT NULL
)

SELECT 
    COALESCE(
        product_category_name_english,
        product_category_name
    ) AS product_category,
    ROUND(AVG(CAST(review_score AS DECIMAL(10,2))), 2) AS average_review_score,
    COUNT(*) AS number_of_reviews
FROM review_category_bridge
GROUP BY 
    COALESCE(
        product_category_name_english,
        product_category_name
    )
ORDER BY 
    number_of_reviews DESC



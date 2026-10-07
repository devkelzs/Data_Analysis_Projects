/*
Which factors appear to be associated with late deliveries
 and lower customer satifaction
*/

---1) How does satisfaction change as delivery delay becomes more severe?
SELECT 
    CASE 
        WHEN o.delivery_delay_days <= 0 THEN 'On time / early'
        WHEN o.delivery_delay_days BETWEEN 1 AND 3 THEN 'Slightly late'
        WHEN o.delivery_delay_days BETWEEN 4 AND 7 THEN 'Moderately late'
        WHEN o.delivery_delay_days BETWEEN 8 AND 14 THEN 'Very late'
        WHEN o.delivery_delay_days > 14 THEN 'Severely late'
    END AS delay_category,

    COUNT(r.review_id) AS number_of_reviews,

    CAST(AVG(r.review_score) AS DECIMAL(18,2)) AS average_review_score

FROM (
    SELECT 
        *,
        DATEDIFF(
            DAY,
            order_estimated_delivery_date,
            order_delivered_customer_date
        ) AS delivery_delay_days

    FROM analysis.vw_orders_clean 
) AS o  

INNER JOIN analysis.vw_order_reviews_clean AS r  
    ON o.order_id = r.order_id

WHERE o.order_delivered_customer_date IS NOT NULL

GROUP BY
    CASE 
        WHEN o.delivery_delay_days <= 0 THEN 'On time / early'
        WHEN o.delivery_delay_days BETWEEN 1 AND 3 THEN 'Slightly late'
        WHEN o.delivery_delay_days BETWEEN 4 AND 7 THEN 'Moderately late'
        WHEN o.delivery_delay_days BETWEEN 8 AND 14 THEN 'Very late'
        WHEN o.delivery_delay_days > 14 THEN 'Severely late'
    END;


---2) Does the relationship between delivery performance and satisfaction vary by customer state?
WITH order_reviews AS 
(
    SELECT 
        order_id,
        AVG(review_score) AS average_review_score
    FROM analysis.vw_order_reviews_clean
    GROUP BY order_id
)

SELECT 
    c.customer_state,
    COUNT(oc.order_id) AS total_reviewed_orders,
    SUM(CASE WHEN oc.is_late_delivery = 0 THEN 1 ELSE 0 END) AS ontime_reviewed_orders,
    SUM(CASE WHEN oc.is_late_delivery = 1 THEN 1 ELSE 0 END) AS late_reviewed_orders,
    CAST(ROUND(SUM(CASE WHEN oc.is_late_delivery = 1 THEN 1.0 ELSE 0 END) * 100.0 / COUNT(oc.order_id), 2) AS DECIMAL(18,2)) AS late_delivery_rate,
    CAST(AVG(r.average_review_score) AS DECIMAL(18,2)) AS average_review_score,
    CAST(AVG(CASE WHEN oc.is_late_delivery = 0 THEN r.average_review_score END) AS DECIMAL(18,2)) AS average_on_time_score,
    CAST(AVG(CASE WHEN oc.is_late_delivery = 1 THEN r.average_review_score END) AS DECIMAL(18,2)) AS average_late_score

FROM analysis.vw_orders_clean AS oc

INNER JOIN order_reviews AS r
    ON oc.order_id = r.order_id

INNER JOIN analysis.vw_customers_clean AS c
    ON oc.customer_id = c.customer_id

WHERE oc.order_status = 'delivered'

GROUP BY 
    c.customer_state

ORDER BY 
    total_reviewed_orders DESC;


/*
Late vs on-time - satisfaction
Delay severity - satisfaction
Customer state - late-delivery rate + satisfaction
*/
------How do payment methods and recorded tipping patterns differ?--------------------------

CREATE OR ALTER VIEW analytics.vw_q4_payment_tip_analysis
AS
WITH payment_tip_patterns AS 
(
SELECT
    PaymentTypeName,
    COUNT(*) AS total_trips,
    COUNT(*) * 100.00 / (SELECT COUNT(*) 
                        FROM analytics.vw_yellow_tripdata_2025_clean
                        WHERE 
                            tpep_pickup_datetime >= '2025-01-01'
                        AND 
                            tpep_pickup_datetime < '2026-01-01') AS percentage_of_trips,
    ROUND(AVG(total_amount),3 ) AS avg_total_amount,
    ROUND(AVG(tip_amount), 3) AS avg_tip_amount,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tip_amount) AS median_tip_amount,
    SUM(CASE WHEN tip_amount > 0 THEN 1 ELSE 0 END ) AS positive_tips,
    COUNT(tip_amount) AS number_of_tips,
    SUM(CASE WHEN tip_amount IS NULL THEN 1 ELSE 0 END ) AS null_tip_amount
FROM analytics.vw_yellow_tripdata_2025_clean
WHERE 
    tpep_pickup_datetime >= '2025-01-01'
AND 
    tpep_pickup_datetime < '2026-01-01'
GROUP BY PaymentTypeName
)
SELECT 
    *,
     CAST(
        positive_tips * 100.0 / NULLIF(number_of_tips, 0)
        AS DECIMAL(10, 2)
    ) AS percentage_of_positive_tips
FROM payment_tip_patterns;


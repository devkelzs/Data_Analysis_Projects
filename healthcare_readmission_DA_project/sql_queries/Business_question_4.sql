/*
Business question
How does previous emergency department utilization relate to readmission?
*/
CREATE OR ALTER VIEW analytics.vw_emergency_readmission
AS
WITH Emergency_Utilization AS 
(
    SELECT
        readmitted,
        CASE 
            WHEN number_emergency = 0 THEN '0: No prior emergency visits'
            WHEN number_emergency = 1 THEN '1: Single (1 visit)'
            WHEN number_emergency BETWEEN 2 AND 3 THEN '2: Low (2-3 visits)'
            WHEN number_emergency BETWEEN 4 AND 6 THEN '3: Moderate (4-6 visits)'
            WHEN number_emergency >= 7 THEN '4: High (7+ visits)'
            ELSE '5: Unexpected / Other'
        END AS emergency_band
    FROM clean.diabetic_data
)
SELECT 
    emergency_band,
    COUNT(*) AS total_encounter,
    SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
    CAST(SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) * 100.00 / 
         NULLIF(COUNT(*), 0) AS DECIMAL(10,2)) AS percentage_readmission_rate_within_30,
    SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END) AS readmission_after_30days,
    CAST(SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END) * 100.00 / 
         NULLIF(COUNT(*), 0) AS DECIMAL(10,2)) AS percentage_readmission_rate_after_30,
    SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission,
    CAST(SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) * 100.00 / 
         NULLIF(COUNT(*), 0) AS DECIMAL(10,2)) AS percentage_no_readmission_rate
FROM Emergency_Utilization
GROUP BY 
    emergency_band;

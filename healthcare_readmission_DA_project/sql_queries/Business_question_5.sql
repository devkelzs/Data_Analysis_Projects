/*
Business question
How does length of hospital stay relate to readmission?
*/
CREATE OR ALTER VIEW analytics.vw_length_of_stay_readmission
AS
WITH length_of_stay AS 
(
    SELECT 
        readmitted,
        CASE 
            WHEN time_in_hospital BETWEEN 1 AND 2 THEN '1: Short Stay'
            WHEN time_in_hospital BETWEEN 3 AND 5 THEN '2: Moderate Stay'
            WHEN time_in_hospital BETWEEN 6 AND 9 THEN '3: Long Stay'
            WHEN time_in_hospital BETWEEN 10 AND 14 THEN '4: Very Long Stay'
            ELSE '5: Unexpected/other'
        END AS stay_band
    FROM clean.diabetic_data
)
SELECT 
    stay_band,
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
FROM length_of_stay
GROUP BY
    stay_band;
/*
Business question
What is the overall readmission burden in the hospital encounter dataset?
*/
CREATE OR ALTER VIEW analytics.vw_overall_readmission
AS
WITH overall_readmission AS (
    SELECT 
        COUNT(*) AS total_encounter,
        COUNT(DISTINCT patient_nbr) AS total_patients,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END ) AS readmitted_within_30_days,
        SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END ) AS readmitted_after_30_days,
        SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END )  AS no_readmission,
        SUM(CASE
                WHEN readmitted IN ('<30', '>30') THEN 1
                ELSE 0
            END) AS overall_readmission
    FROM clean.diabetic_data
)
SELECT 
    total_encounter,
    total_patients,

    readmitted_within_30_days,
    readmitted_after_30_days,
    no_readmission,
    overall_readmission,
    CAST (readmitted_within_30_days * 100.00 / 
                        total_encounter AS  DECIMAL(10,2)) AS readmission_rate_within_30days,
    CAST (readmitted_after_30_days * 100.00 /
                        total_encounter AS DECIMAL(10,2)) AS readmission_rate_after_30days,
    CAST (overall_readmission * 100.00 / 
                        total_encounter AS DECIMAL(10,2)) AS overall_readmission_rate
FROM overall_readmission;
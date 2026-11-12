/*
Business question
How does readmission vary across age groups?
*/
CREATE OR ALTER VIEW analytics.vw_age_readmission
AS
With readmission_rate_age_groups AS (
    SELECT 
        age,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM clean.diabetic_data
    GROUP BY 
        age
)
SELECT 
    age,
    total_encounter,
    readmission_within_30days,
    CAST (readmission_within_30days * 100.00 /
             NULLIF(total_encounter, 0) AS DECIMAL(10,2)) AS percentage_readmission_rate_within_30,
    readmission_after_30days,
    CAST (readmission_after_30days * 100.00 /
             NULLIF(total_encounter, 0) AS DECIMAL(10,2)) AS percentage_readmission_rate_after_30,
    no_readmission,
    CAST (no_readmission * 100.00 /
             NULLIF(total_encounter, 0) AS DECIMAL(10,2)) AS percentage_no_readmission_rate
FROM readmission_rate_age_groups;
/*
Business question:
How does discharge disposition relate to subsequent readmission?
*/
CREATE OR ALTER VIEW analytics.vw_discharge_readmission
AS
WITH Discharge_Disposition_And_Readmission AS 
(
    SELECT 
        d.discharge_disposition_id AS discharge_disposition_id,
        TRIM(a.description) AS description,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN d.readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN d.readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN d.readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM 
        clean.diabetic_data as d  
    LEFT JOIN 
        clean.disposition a 
    ON 
        d.discharge_disposition_id = a.discharge_disposition_id
    WHERE a.description IS NOT NULL 
    AND LOWER(TRIM(a.description)) != 'null'
    GROUP BY
        d.discharge_disposition_id,
        a.description
)
SELECT 
    discharge_disposition_id,
    description,
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
FROM Discharge_Disposition_And_Readmission;
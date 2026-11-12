/*
Business question:
Does the source of admission relate to readmission outcomes?
*/
CREATE OR ALTER VIEW analytics.vw_admission_source_readmission
AS
WITH Admission_Source_And_Readmission AS 
(
    SELECT 
        d.admission_source_id AS admission_source_id,
        TRIM(a.description) AS description,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN d.readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN d.readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN d.readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM 
        clean.diabetic_data as d  
    LEFT JOIN 
        clean.admission_source a 
    ON 
        d.admission_source_id = a.admission_source_id
    WHERE a.description IS NOT NULL 
    AND LOWER(TRIM(a.description)) != 'null'
    GROUP BY
        d.admission_source_id,
        a.description
)
SELECT 
    admission_source_id,
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
FROM Admission_Source_And_Readmission;

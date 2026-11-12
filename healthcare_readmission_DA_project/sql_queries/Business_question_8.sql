/*
Business question
Does the type of hospital admission relate to readmission outcomes?
*/
CREATE OR ALTER VIEW analytics.vw_admission_type_readmission
AS
WITH Admission_Type_And_Readmission AS 
(
    SELECT 
        d.admission_type_id AS admission_type_id,
        a.description AS description,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN d.readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN d.readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN d.readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM 
        clean.diabetic_data as d  
    LEFT JOIN 
        clean.IDS_mapping a 
    ON 
        d.admission_type_id = a.admission_type_id
    GROUP BY
        d.admission_type_id,
        a.description
)
SELECT 
    admission_type_id,
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
FROM Admission_Type_And_Readmission;

/*How does the number of laboratory procedures performed 
during an encounter relate to readmission?
*/
CREATE OR ALTER VIEW analytics.vw_lab_readmission
AS
WITH Laboratory_workload_and_readmission AS 
(
    SELECT 
        readmitted,
        CASE 
            WHEN num_lab_procedures BETWEEN 1 AND 20 THEN '1: Low laboratory workload'
            WHEN num_lab_procedures BETWEEN 21 AND 40 THEN '2: Moderate-low workload'
            WHEN num_lab_procedures BETWEEN 41 AND 60 THEN '3: Moderate-high workload'
            WHEN num_lab_procedures BETWEEN 61 AND 80 THEN '4: High workload'
            WHEN num_lab_procedures >=81 THEN '5: Very high workload'
            ELSE '6: Unexpected/other'
        END AS procedure_band
    FROM clean.diabetic_data
)
SELECT 
    procedure_band,
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
FROM Laboratory_workload_and_readmission
GROUP BY 
    procedure_band;

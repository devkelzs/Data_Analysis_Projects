/*
Business question
How does previous inpatient utilization relate to readmission?
*/
CREATE OR ALTER VIEW analytics.vw_inpatient_readmission
AS
WITH Prior_Inpatient_Utilization AS 
(
    SELECT
        readmitted,
        CASE 
            WHEN number_inpatient = 0 THEN '0: No prior inpatient visits'
            WHEN number_inpatient = 1 THEN '1: Single (1 visit)'
            WHEN number_inpatient BETWEEN 2 AND 3 THEN '2: Low (2-3 visits)'
            WHEN number_inpatient BETWEEN 4 AND 6 THEN '3: Moderate (4-6 visits)'
            WHEN number_inpatient >= 7 THEN '4: High (7-21 visits)'
            ELSE '5: Other / Missing'
        END AS inpatient_band
    FROM clean.diabetic_data
)
SELECT 
    inpatient_band,
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
FROM Prior_Inpatient_Utilization
GROUP BY 
    inpatient_band;

----------------------------
----How does previous outpatient utilization relate to readmission?
CREATE OR ALTER VIEW analytics.vw_outpatient_readmission
AS
WITH Prior_outpatient_Utilization AS 
(
    SELECT
        readmitted,
        CASE 
            WHEN number_outpatient = 0 THEN '0: No prior outpatient visits'
            WHEN number_outpatient = 1 THEN '1: Single (1 visit)'
            WHEN number_outpatient BETWEEN 2 AND 3 THEN '2: Low (2-3 visits)'
            WHEN number_outpatient BETWEEN 4 AND 6 THEN '3: Moderate (4-6 visits)'
            WHEN number_outpatient >= 7 THEN '4: High (7-21 visits)'
            ELSE '5: Other / Missing'
        END AS outpatient_band
    FROM clean.diabetic_data
)
SELECT 
    outpatient_band,
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
FROM Prior_outpatient_Utilization
GROUP BY 
   outpatient_band;
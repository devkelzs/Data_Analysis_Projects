/* Business question
How does readmission vary across racial groups?
*/
CREATE OR ALTER VIEW analytics.vw_race_readmission
AS
WITH Race_and_readmission AS 
(
    SELECT 
        race,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM clean.diabetic_data
    GROUP BY 
        race
)
SELECT 
    race,
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
FROM Race_and_readmission;

/* Business question
How does readmission vary across gender groups?
*/
CREATE OR ALTER VIEW analytics.vw_gender_readmission
AS
WITH Gender_and_readmission AS 
(
    SELECT 
        gender,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM clean.diabetic_data
    GROUP BY 
        gender
)
SELECT 
    gender,
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
FROM Gender_and_readmission;


/* Business question
How does readmission vary across A1C resul?
*/
CREATE OR ALTER VIEW analytics.vw_a1c_readmission
AS
WITH A1C_result_and_readmission AS 
(
    SELECT 
        A1Cresult,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM clean.diabetic_data
    GROUP BY 
        A1Cresult
)
SELECT 
    A1Cresult,
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
FROM A1C_result_and_readmission;

/* Business question
How does readmission vary with Diabetes medication?
*/
CREATE OR ALTER VIEW analytics.vw_diabetesmed_readmission
AS
WITH Diabetes_medication_and_readmission AS 
(
    SELECT 
        diabetesMed,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM clean.diabetic_data
    GROUP BY 
        diabetesMed
)
SELECT 
    diabetesMed,
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
FROM Diabetes_medication_and_readmission;

/* Business question
How does readmission vary with weight?
*/
WITH weight_and_readmission AS 
(
    SELECT 
        weight,
        COUNT(*) AS total_encounter,
        SUM(CASE WHEN readmitted = '<30' THEN 1 ELSE 0 END) AS readmission_within_30days,
        SUM(CASE WHEN readmitted = '>30' THEN 1 ELSE 0 END ) AS readmission_after_30days,
        SUM(CASE WHEN readmitted = 'NO' THEN 1 ELSE 0 END) AS no_readmission
    FROM clean.diabetic_data
    GROUP BY 
       weight
)
SELECT 
    weight,
    total_encounter,
     readmission_within_30days,
    CAST (readmission_within_30days * 100.00 /
             NULLIF(total_encounter, 0) AS DECIMAL(10,2)) AS readmission_rate_within_30,
    readmission_after_30days,
    CAST (readmission_after_30days * 100.00 /
             NULLIF(total_encounter, 0) AS DECIMAL(10,2)) AS readmission_rate_after_30,
    no_readmission,
    CAST (no_readmission * 100.00 /
             NULLIF(total_encounter, 0) AS DECIMAL(10,2)) AS no_readmission_rate
FROM weight_and_readmission;

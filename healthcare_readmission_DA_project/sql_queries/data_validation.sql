--------------------------------------------------------DATA VALIDATION-----------------------------------------------
SELECT COUNT(*) AS total_count FROM clean.diabetic_data;
SELECT COUNT(DISTINCT encounter_id) unique_encounter_id FROM clean.diabetic_data;
SELECT COUNT(DISTINCT patient_nbr) AS unique_patients FROM clean.diabetic_data;
SELECT 
    readmitted,
    COUNT(*) AS total_count,
    COUNT(DISTINCT patient_nbr) AS unique_patients
FROM clean.diabetic_data
GROUP BY 
    readmitted
ORDER BY 
    total_count DESC;

----------DATA TYPE AND COLUMN CHECK
SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_SCHEMA = 'clean'
AND 
    TABLE_NAME = 'diabetic_data' 
ORDER BY 
    ORDINAL_POSITION;

---------distribution of num_lab_procedures
SELECT 
    MIN(num_lab_procedures) AS lowest_num_lab_procedure,
    MAX(num_lab_procedures) AS highest_num_lab_procedure,
    AVG(num_lab_procedures) AS average_number_lab_procedure,
    APPROX_PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY num_lab_procedures) AS median_lab_procedure,
    COUNT(num_lab_procedures) AS total_count
FROM clean.diabetic_data;



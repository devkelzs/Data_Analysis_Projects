# Hospital Readmission & Healthcare Analytics

## 📊 Project Overview

Hospital readmissions are an important healthcare quality and operational concern. Understanding which patient characteristics, utilization patterns, and clinical factors are associated with readmission can help healthcare organizations identify populations that may require closer monitoring and better discharge planning.

This project analyzes the **UCI Diabetes 130-US Hospitals for Years 1999–2008** dataset to investigate hospital readmission patterns across more than 100,000 hospital encounters.

The project follows an end-to-end data analytics workflow:

**Raw Data → Excel Power Query → Exploratory Data Analysis → SQL Server → Analytical Views → Power BI Dashboard → Insights & Recommendations**

The analysis focuses primarily on:

- Overall readmission burden
- 30-day readmissions
- Patient demographics
- Previous healthcare utilization
- Length of hospital stay
- Laboratory workload
- A1C results
- Diabetes medication
- Admission pathways

> **Important:** This analysis identifies associations and patterns in the dataset. It does not establish that any factor directly causes readmission.

---

# 🎯 Business Problem

Healthcare organizations need to understand where readmission risk is concentrated so that they can investigate potential opportunities for improving patient management and discharge processes.

This project addresses the following questions:

1. How common are hospital readmissions?
2. What proportion of encounters result in readmission within 30 days?
3. How does readmission vary across age groups?
4. Does previous inpatient utilization correspond with higher readmission rates?
5. Does emergency or outpatient utilization relate to readmission?
6. Does length of stay show different readmission patterns?
7. Does laboratory workload vary across readmission outcomes?
8. How do A1C results and diabetes medication relate to readmission?
9. Are there meaningful differences in readmission rates across demographic groups?
10. Which patterns could help healthcare stakeholders identify areas for further investigation?

---

# 📁 Dataset

### Dataset

**Diabetes 130-US Hospitals for Years 1999–2008**

The dataset contains approximately:

- **101,766 hospital encounters**
- **71,518 unique patients**
- **60 variables**
- Data collected from **1999–2008**

### Unit of Analysis

One row represents a **hospital encounter**, not a unique patient.

This distinction is important because one patient can appear in multiple encounters.

The analysis therefore separates:

- Encounter-level metrics
- Patient-level metrics where appropriate

### Readmission Categories

The primary outcome variable is:

- `NO` — No readmission
- `<30` — Readmitted within 30 days
- `>30` — Readmitted after 30 days

---

# 🧹 Data Preparation & Quality

The raw dataset was imported into **Excel Power Query** for initial data preparation and quality assessment.

### Data quality checks included:

- Error detection
- Exact duplicate detection
- Missing encounter IDs
- Missing patient IDs
- Missing race values
- Invalid gender values
- Data type validation
- Category validation
- Age-category cleaning
- Validation of numeric utilization variables
- Validation of readmission categories

### Duplicate Check

The dataset contained **101,766 records before and after exact duplicate removal**, indicating that no exact duplicate rows were removed.

### Data Quality Flags

Quality flags were created for important issues, including:

- Missing encounter ID
- Missing patient number
- Missing race
- Invalid gender
- Overall quality issue indicator

The cleaned dataset was then loaded into **Microsoft SQL Server** for analytical processing.

---

# 🛠️ Tools & Technologies

| Tool | Purpose |
|---|---|
| **Microsoft Excel** | Initial data inspection and exploratory analysis |
| **Power Query** | Data cleaning and transformation |
| **SQL Server** | Data analysis and analytical views |
| **SSMS** | SQL development and validation |
| **Power BI** | Interactive dashboard development |
| **DAX** | Power BI calculations where required |
| **GitHub** | Project documentation and portfolio presentation |

---

# 🔄 Project Workflow

## 1. Data Understanding

The dataset structure, variables, data types, missing values, categories, and readmission definitions were reviewed before analysis.

## 2. Data Cleaning

Power Query was used to:

- Validate the dataset
- Check errors
- Remove exact duplicates
- Clean categorical values
- Create data-quality indicators
- Validate key analytical fields

## 3. Exploratory Data Analysis

Initial analysis was performed to understand:

- Patient and encounter volumes
- Readmission distribution
- Demographic patterns
- Utilization patterns
- Clinical variables
- Length of stay

## 4. SQL Analysis

The cleaned data was imported into SQL Server.

Analytical views were created around individual business questions rather than creating one oversized analytical table.

This approach made the analysis modular and easier to validate.

## 5. Power BI

The SQL analytical views were imported into Power BI and used to build an interactive three-page analytical report.

---

# 📊 Key Findings

## Overall Readmission Burden

Out of **101,766 encounters**:

- **54,864 (53.91%)** had no readmission
- **35,545 (34.93%)** were readmitted after 30 days
- **11,357 (11.16%)** were readmitted within 30 days
- **46,902 (46.09%)** involved some form of readmission

The overall readmission burden is therefore substantial, although the dataset represents historical encounters from 1999–2008 and should not be interpreted as a current hospital benchmark.

---

## Patient & Encounter Burden

The dataset contains:

- **101,766 encounters**
- **71,518 unique patients**
- Approximately **1.42 encounters per patient**

This demonstrates why patient-level and encounter-level analysis should not be treated as interchangeable.

---

## Age and Readmission

Readmission patterns varied across age groups.

Among the larger age groups, the **70–80 age group** had a particularly high rate of readmission after 30 days:

- `<30`: **11.77%**
- `>30`: **36.35%**

Older adult groups generally showed higher `>30` readmission rates than several younger groups.

However, age alone should not be interpreted as a causal risk factor.

---

## Prior Inpatient Utilization

Previous inpatient utilization showed one of the clearest associations with readmission.

The `>30-day` readmission rate was:

| Prior Inpatient Utilization | >30-Day Readmission |
|---|---:|
| No prior visits | 30.06% |
| Single | 41.84% |
| Low | 48.10% |
| Moderate | 49.90% |
| High | 43.65% |

Encounters involving previous inpatient utilization generally showed substantially higher readmission rates than encounters with no prior inpatient visits.

This suggests that **previous healthcare utilization may be an important population-segmentation signal for further investigation**.

---

## Emergency Utilization

Readmission also varied with previous emergency utilization.

The `>30-day` readmission rate increased from:

- **33.42%** for encounters with 0 prior emergency visits
- **44.94%** with 1 visit
- **49.55%** with 2–3 visits
- **53.64%** with 4–6 visits
- **58.78%** with 7+ visits

The higher observed readmission rates among frequent emergency users suggest that this population may warrant closer examination.

---

## Length of Stay

Readmission rates varied across length-of-stay categories.

The `>30-day` rate increased from approximately:

- **33.06%** for short stays
- **35.38%** for moderate stays
- **36.39%** for long stays
- **36.14%** for very long stays

The relationship is not perfectly linear, so length of stay should not be treated as a standalone predictor.

---

## Outpatient Utilization

Encounters with prior outpatient utilization generally showed higher `>30-day` readmission rates than encounters with no prior outpatient visits.

The observed rate ranged from approximately **32.98%** among encounters with no prior outpatient visits to above **52%** in the highest utilization category.

---

## Laboratory Workload

Readmission rates varied across laboratory workload bands.

The `>30-day` readmission rate generally increased from the lower laboratory-procedure groups toward higher workload groups, although the relationship was not perfectly monotonic.

This may reflect differences in patient complexity or clinical workload rather than a direct effect of laboratory testing itself.

---

## A1C Results

Readmission rates varied across recorded A1C categories.

However, a major analytical limitation is the large number of encounters where A1C was recorded as **`None`**.

`None` represents **no recorded A1C result**, not a normal A1C result.

Therefore, missingness itself should be considered when interpreting this analysis.

---

## Diabetes Medication

Encounters where diabetes medication was recorded as `Yes` had a higher observed readmission rate than encounters where it was recorded as `No`.

This may reflect differences in patient characteristics or disease complexity and should not be interpreted as evidence that medication causes readmission.

---

# 📈 Power BI Dashboard

The final Power BI report contains **three analytical pages**.

## Page 1 — Executive Overview

Provides a high-level view of:

- Total encounters
- Unique patients
- Overall readmission rate
- 30-day readmission rate
- Readmission outcome distribution
- Readmission by age
- Prior inpatient utilization
- Length of stay
- Key insights

### Purpose

Answer:

> **What is the overall scale and pattern of hospital readmission?**

---

## Page 2 — Patient & Demographic Analysis

Examines:

- Race
- Gender
- Outpatient utilization
- Demographic readmission patterns

### Purpose

Answer:

> **How does readmission vary across patient and demographic characteristics?**

---

## Page 3 — Utilization & Clinical Analysis

Examines:

- Emergency utilization
- Length of stay
- Outpatient utilization
- Laboratory workload
- A1C results
- Prior inpatient utilization

### Purpose

Answer:

> **Which healthcare utilization and clinical patterns are associated with readmission?**

---

# 💡 Recommendations

The recommendations below are based on the patterns observed in this historical dataset. They should be treated as **areas for investigation and operational improvement**, not as clinical directives.

## 1. Prioritize High-Utilization Patients for Further Review

Patients with previous inpatient or emergency utilization showed substantially higher observed readmission rates.

Healthcare organizations could consider developing **risk-stratification or case-management workflows** that identify patients with repeated prior utilization for additional review.

Potential actions could include:

- Enhanced discharge planning
- Medication reconciliation
- Follow-up appointment coordination
- Post-discharge outreach
- Care-management referral

---

## 2. Strengthen Post-Discharge Follow-Up

Because 30-day readmission represents an important quality outcome, organizations could strengthen follow-up processes for patients identified as potentially higher risk.

Examples include:

- Early post-discharge contact
- Follow-up appointment scheduling before discharge
- Medication reconciliation
- Patient education
- Clear discharge instructions

---

## 3. Pay Particular Attention to Older Patient Populations

Older adult groups showed relatively high readmission rates in the analysis.

Healthcare teams could investigate whether older patients require additional support related to:

- Follow-up care
- Medication management
- Chronic disease management
- Transition from hospital to home
- Coordination with outpatient services

---

## 4. Investigate Frequent Emergency-Use Populations

The strong relationship between previous emergency utilization and subsequent readmission suggests an opportunity to investigate frequent emergency users.

Organizations could examine:

- Underlying chronic conditions
- Access to primary care
- Previous discharge history
- Social and care-coordination factors
- Repeat emergency presentations

The goal should be to understand **why** utilization is high rather than simply labeling frequent users as high risk.

---

## 5. Improve Data Completeness for Clinical Indicators

The large number of encounters without recorded A1C results demonstrates the importance of understanding missing clinical data.

Healthcare analytics teams should distinguish between:

- A test not performed
- A test performed but not recorded
- Missing data
- A clinically normal result

Improving data completeness would make future clinical analyses more reliable.

---

## 6. Build a More Comprehensive Readmission Risk Model

This dashboard is primarily descriptive and exploratory.

A logical next step would be to develop a predictive model using variables such as:

- Prior inpatient utilization
- Emergency utilization
- Outpatient utilization
- Age
- Length of stay
- Laboratory workload
- A1C status
- Admission characteristics
- Other available clinical variables

A predictive model could help determine whether the observed relationships remain important **after controlling for other factors**.

---

# ⚠️ Limitations

Several limitations should be considered when interpreting this analysis.

### Historical Dataset

The data covers **1999–2008** and therefore does not represent current healthcare utilization or readmission patterns.

### Encounter-Level Dataset

A row represents an encounter rather than a unique patient.

Repeated encounters from the same patient can influence aggregate results.

### Association ≠ Causation

The analysis identifies patterns and associations. It does not demonstrate that a variable directly causes readmission.

### Missing Clinical Data

Several clinical variables contain substantial missing or unrecorded values.


---

# 🧠 Analytical Principles

This project follows several important analytical principles:

- Always distinguish **patients from encounters**
- Use **rates when comparing groups of different sizes**
- Use **counts when describing population volume**
- Treat missing clinical values separately from valid clinical categories
- Avoid interpreting association as causation
- Be cautious with small sample sizes
- Define denominators before calculating percentages
- Validate results across tools
- Document assumptions and limitations

---

# 📌 Portfolio Skills Demonstrated

### Data Analysis

- Exploratory Data Analysis
- Data profiling
- Data quality assessment
- Missing-data analysis
- Descriptive statistics
- Healthcare analytics
- Readmission analysis
- Business-question-driven analysis

### Excel & Power Query

- Data import
- Data transformation
- Data validation
- Duplicate detection
- Data quality flags
- Exploratory analysis

### SQL Server

- Data aggregation
- CTE-based analysis
- Grouping and segmentation
- Conditional logic
- Readmission-rate calculations
- Patient-level analysis
- Analytical views
- Data validation

### Power BI

- Data modeling
- KPI development
- Interactive dashboards
- Analytical visualizations
- Percentage/rate analysis
- Dashboard storytelling
- Healthcare KPI reporting

### Analytical Thinking

- Business question definition
- Metric selection
- Denominator awareness
- Patient vs encounter analysis
- Association analysis
- Insight generation
- Recommendation development

---

# Repository Structure

```text
hospital-readmission-healthcare-analytics/
│
├── data/
│   ├── raw/
│   ├── cleaned/
│   └── mapping/
│
├── excel/
│   └── exploratory_analysis/
│
├── sql/
│   ├── data_quality/
│   ├── analysis/
│   └── views/
│
├── powerbi/
│   └── hospital_readmission_dashboard.pbix
│
├── documentation/
│   ├── data_dictionary.md
│   ├── methodology.md
│   └── assumptions_and_limitations.md
│
├── images/
│   └── dashboard_screenshots/
│
└── README.md
```

---

# 🚀 Future Improvements

Future versions of this project could include:

- Predictive readmission modeling
- Patient-level risk scoring
- Time-based analysis if appropriate temporal fields are available
- More advanced Power BI drill-through pages
- Statistical significance testing
- Logistic regression
- Machine learning classification
- Model evaluation and explainability
- Additional clinical risk factors
- Automated data refresh
- More advanced healthcare quality metrics

---

# 📚 Data Source

**UCI Machine Learning Repository — Diabetes 130-US Hospitals for Years 1999–2008**

Dataset: Diabetes 130-US Hospitals for Years 1999–2008

The dataset contains hospital encounter records used for educational and analytical purposes.

---

# 👤 Author

**Kelly Ankiambom**

Medical Laboratory Scientist | Data Analyst | Healthcare Analytics

This project demonstrates the application of data cleaning, SQL analysis, exploratory data analysis, and Power BI visualization to a real-world healthcare analytics problem.

---

## ⭐ Project Summary

This project demonstrates an end-to-end approach to healthcare analytics:

**Clean the data → Validate the data → Define business questions → Analyze with SQL → Build Power BI dashboards → Identify patterns → Develop actionable recommendations.**

The central finding is that **readmission is not evenly distributed across encounters**. Prior healthcare utilization, age, length of stay, outpatient and emergency utilization, and selected clinical indicators show meaningful differences in observed readmission rates.

The analysis provides a foundation for deeper patient-level risk analysis and predictive modeling while maintaining appropriate caution around causality, missing data, historical context, and sample size.
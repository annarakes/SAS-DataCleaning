# SAS Data Cleaning Project
## Authors: Anna Rakes and Lexi Waller

This project was developed by Anna Rakes and Lexi Waller for the Statistical Computing for Data Management course at Elon University. This project analyzes pain severity and treatment effectiveness in a clinical study. The dataset consists of baseline and follow-up visit data for patients receiving different treatments. The study examines pain trends over time, baseline pain severity across demographics, and treatment effectiveness.

### Skills:
**Data Import & Cleaning:** Importing patient records, handling missing values, and creating new variables.

**Exploratory Data Analysis:** Computing descriptive statistics, deriving key health metrics (BMI, Pain Severity, etc.), and categorizing data.

**Data Visualization:** Creating box plots and line plots to examine trends in pain severity by race, gender, and treatment group.

**Feature Engineering:** Creating variables for pain severity, pain interference, and treatment effects.

**Final Data Preparation:** Generating clean datasets for further analysis and visualization

### Technologies Used
✅ SAS: Data import, cleaning, transformation, and statistical analysis.

✅ SAS PROC MEANS & PROC FORMAT: Computing summary statistics and formatting categorical variables.

✅ SAS PROC SGPLOT: Data visualization (box plots and line charts).

## Data Processing
- Import baseline and follow-up patient data.
- Handle missing values and derive new features (e.g., BMI, pain severity scores).
- Categorize race, gender, and opioid usage.

## Key Analyses
- **Baseline Pain Severity by Demographics:** Box plots comparing pain levels across race and gender.
- **Pain Trends Over Time:** Line plots tracking pain severity across different treatments over 365 days.
- **Treatment Effectiveness:** Evaluating the impact of various treatment groups on pain reduction.


## How to Run
1. Download BetterStudyData.xlsx from repository.
2. Upload data to SAS.
3. File paths on lines 6 and 14 of code in Project1.sas must be replaced with new file path of BetterStudyData.
4. Update line 194 in Project1.sas with file path location of where permanent data set will be stored.
5. Run Project1.sas
6. Update line 4 in Project2.sas with file path of permanent data set created from Project1.sas
7. Run Project2.sas


-- =============================================================
-- HR Attrition & Workforce Report | 02 - Load and validate data
-- Run from the project root folder:
--   mysql --local-infile=1 -u root -p < sql/02_load_and_validate.sql
-- =============================================================

USE hr_db;

TRUNCATE TABLE employees;

LOAD DATA LOCAL INFILE 'data/hr_employee_attrition.csv'
INTO TABLE employees
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(age, attrition, business_travel, daily_rate, department, distance_from_home, education,
 education_field, employee_count, employee_number, environment_satisfaction, gender,
 hourly_rate, job_involvement, job_level, job_role, job_satisfaction, marital_status,
 monthly_income, monthly_rate, num_companies_worked, over18, over_time, percent_salary_hike,
 performance_rating, relationship_satisfaction, standard_hours, stock_option_level,
 total_working_years, training_times_last_year, work_life_balance, years_at_company,
 years_in_current_role, years_since_last_promotion, years_with_curr_manager);

-- 1. Row count and unique employees -> expected 1470 and 1470
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT employee_number) AS unique_employees
FROM employees;

-- 2. Missing values in the columns used for reporting -> expected all 0
SELECT
    SUM(attrition IS NULL)       AS missing_attrition,
    SUM(department IS NULL)      AS missing_department,
    SUM(job_role IS NULL)        AS missing_job_role,
    SUM(monthly_income IS NULL)  AS missing_income,
    SUM(years_at_company IS NULL) AS missing_tenure
FROM employees;

-- 3. Category values look clean (no typos or stray spaces)
SELECT 'attrition' AS column_name, attrition AS value, COUNT(*) AS employees FROM employees GROUP BY attrition
UNION ALL
SELECT 'department', department, COUNT(*) FROM employees GROUP BY department
UNION ALL
SELECT 'over_time', over_time, COUNT(*) FROM employees GROUP BY over_time
UNION ALL
SELECT 'business_travel', business_travel, COUNT(*) FROM employees GROUP BY business_travel;

-- 4. Range checks -> expected 0 rows
SELECT employee_number, age, years_at_company, total_working_years
FROM employees
WHERE age < 18
   OR years_at_company > total_working_years
   OR years_in_current_role > years_at_company
   OR job_satisfaction NOT BETWEEN 1 AND 4;

-- 5. Constant columns carry no information -> each returns 1, so they are excluded from analysis
SELECT COUNT(DISTINCT employee_count) AS employee_count_values,
       COUNT(DISTINCT over18)         AS over18_values,
       COUNT(DISTINCT standard_hours) AS standard_hours_values
FROM employees;

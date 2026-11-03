-- =============================================================
-- HR Attrition & Workforce Report | 03 - Attrition analysis
-- Attrition rate = employees who left / total employees in the group
-- =============================================================

USE hr_db;

-- Q1. Company-wide headcount, leavers and attrition rate
SELECT COUNT(*)                                            AS headcount,
       SUM(attrition = 'Yes')                              AS leavers,
       ROUND(AVG(attrition = 'Yes') * 100, 1)              AS attrition_rate_pct,
       ROUND(AVG(monthly_income), 0)                       AS avg_monthly_income,
       ROUND(AVG(years_at_company), 1)                     AS avg_years_at_company
FROM employees;

-- Q2. Attrition by department, with each department's share of all leavers (window SUM)
SELECT department,
       COUNT(*)                                            AS headcount,
       SUM(attrition = 'Yes')                              AS leavers,
       ROUND(AVG(attrition = 'Yes') * 100, 1)              AS attrition_rate_pct,
       ROUND(SUM(attrition = 'Yes') * 100.0
             / SUM(SUM(attrition = 'Yes')) OVER (), 1)     AS share_of_all_leavers_pct
FROM employees
GROUP BY department
ORDER BY attrition_rate_pct DESC;

-- Q3. Job roles ranked by attrition rate within each department (RANK window)
SELECT department,
       job_role,
       COUNT(*)                                            AS headcount,
       SUM(attrition = 'Yes')                              AS leavers,
       ROUND(AVG(attrition = 'Yes') * 100, 1)              AS attrition_rate_pct,
       RANK() OVER (PARTITION BY department
                    ORDER BY AVG(attrition = 'Yes') DESC)  AS rank_in_department
FROM employees
GROUP BY department, job_role
ORDER BY department, rank_in_department;

-- Q4. Overtime vs attrition
SELECT over_time,
       COUNT(*)                                            AS headcount,
       SUM(attrition = 'Yes')                              AS leavers,
       ROUND(AVG(attrition = 'Yes') * 100, 1)              AS attrition_rate_pct
FROM employees
GROUP BY over_time;

-- Q5. Attrition by tenure band (CTE + CASE)
WITH banded AS (
    SELECT attrition,
           CASE WHEN years_at_company <= 2  THEN '1) 0-2 years'
                WHEN years_at_company <= 5  THEN '2) 3-5 years'
                WHEN years_at_company <= 10 THEN '3) 6-10 years'
                ELSE                             '4) 10+ years' END AS tenure_band
    FROM employees
)
SELECT tenure_band,
       COUNT(*)                                            AS headcount,
       SUM(attrition = 'Yes')                              AS leavers,
       ROUND(AVG(attrition = 'Yes') * 100, 1)              AS attrition_rate_pct
FROM banded
GROUP BY tenure_band
ORDER BY tenure_band;

-- Q6. Job level: attrition and pay gap between leavers and stayers
SELECT job_level,
       COUNT(*)                                                         AS headcount,
       ROUND(AVG(attrition = 'Yes') * 100, 1)                           AS attrition_rate_pct,
       ROUND(AVG(CASE WHEN attrition = 'Yes' THEN monthly_income END), 0) AS avg_income_leavers,
       ROUND(AVG(CASE WHEN attrition = 'No'  THEN monthly_income END), 0) AS avg_income_stayers
FROM employees
GROUP BY job_level
ORDER BY job_level;

-- Q7. Satisfaction scores with readable labels (JOIN to lookup table)
SELECT 'Job satisfaction' AS measure, r.rating_value, r.rating_label,
       COUNT(*) AS headcount, ROUND(AVG(e.attrition = 'Yes') * 100, 1) AS attrition_rate_pct
FROM employees e JOIN rating_lookup r ON r.rating_value = e.job_satisfaction
GROUP BY r.rating_value, r.rating_label
UNION ALL
SELECT 'Environment satisfaction', r.rating_value, r.rating_label,
       COUNT(*), ROUND(AVG(e.attrition = 'Yes') * 100, 1)
FROM employees e JOIN rating_lookup r ON r.rating_value = e.environment_satisfaction
GROUP BY r.rating_value, r.rating_label
UNION ALL
SELECT 'Work-life balance', r.rating_value, r.rating_label,
       COUNT(*), ROUND(AVG(e.attrition = 'Yes') * 100, 1)
FROM employees e JOIN rating_lookup r ON r.rating_value = e.work_life_balance
GROUP BY r.rating_value, r.rating_label
ORDER BY measure, rating_value;

-- Q8. Pay versus department average (AVG window): do leavers earn below their peers?
WITH pay AS (
    SELECT employee_number, department, job_level, attrition, monthly_income,
           AVG(monthly_income) OVER (PARTITION BY department, job_level) AS peer_avg_income
    FROM employees
)
SELECT attrition,
       COUNT(*)                                                     AS employees,
       ROUND(AVG(monthly_income), 0)                                AS avg_income,
       ROUND(AVG(monthly_income - peer_avg_income), 0)              AS avg_gap_vs_peers,
       ROUND(AVG(monthly_income < peer_avg_income) * 100, 1)        AS pct_paid_below_peers
FROM pay
GROUP BY attrition;

-- Q9. Marital status and business travel
SELECT 'Marital status' AS factor, marital_status AS value_label,
       COUNT(*) AS headcount, ROUND(AVG(attrition = 'Yes') * 100, 1) AS attrition_rate_pct
FROM employees GROUP BY marital_status
UNION ALL
SELECT 'Business travel', business_travel,
       COUNT(*), ROUND(AVG(attrition = 'Yes') * 100, 1)
FROM employees GROUP BY business_travel
ORDER BY factor, attrition_rate_pct DESC;

-- Q10. Highest-risk segment: early-career overtime workers (CTE)
WITH flagged AS (
    SELECT *,
           (over_time = 'Yes' AND job_level = 1 AND years_at_company <= 2) AS high_risk
    FROM employees
)
SELECT CASE WHEN high_risk THEN 'Level 1, <=2 years, overtime' ELSE 'Everyone else' END AS segment,
       COUNT(*)                                            AS headcount,
       SUM(attrition = 'Yes')                              AS leavers,
       ROUND(AVG(attrition = 'Yes') * 100, 1)              AS attrition_rate_pct
FROM flagged
GROUP BY high_risk
ORDER BY high_risk DESC;

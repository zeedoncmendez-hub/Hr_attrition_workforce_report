-- =============================================================
-- HR Attrition & Workforce Report | 01 - Create database and tables
-- Author : Ashik Dev A S
-- Target : MySQL 8.0+ (also tested on MariaDB 10.11)
-- =============================================================

CREATE DATABASE IF NOT EXISTS hr_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hr_db;

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS rating_lookup;
DROP TABLE IF EXISTS education_lookup;

-- One row per employee (IBM HR Analytics sample, 1,470 employees)
CREATE TABLE employees (
    age                         TINYINT,
    attrition                   VARCHAR(3),      -- 'Yes' = left the company
    business_travel             VARCHAR(20),
    daily_rate                  INT,
    department                  VARCHAR(30),
    distance_from_home          TINYINT,
    education                   TINYINT,         -- 1-5, see education_lookup
    education_field             VARCHAR(30),
    employee_count              TINYINT,         -- constant (1), not used
    employee_number             INT PRIMARY KEY,
    environment_satisfaction    TINYINT,         -- 1-4, see rating_lookup
    gender                      VARCHAR(10),
    hourly_rate                 INT,
    job_involvement             TINYINT,
    job_level                   TINYINT,         -- 1 (entry) to 5 (senior)
    job_role                    VARCHAR(40),
    job_satisfaction            TINYINT,         -- 1-4, see rating_lookup
    marital_status              VARCHAR(10),
    monthly_income              INT,
    monthly_rate                INT,
    num_companies_worked        TINYINT,
    over18                      CHAR(1),         -- constant ('Y'), not used
    over_time                   VARCHAR(3),
    percent_salary_hike         TINYINT,
    performance_rating          TINYINT,
    relationship_satisfaction   TINYINT,
    standard_hours              TINYINT,         -- constant (80), not used
    stock_option_level          TINYINT,
    total_working_years         TINYINT,
    training_times_last_year    TINYINT,
    work_life_balance           TINYINT,         -- 1-4, see rating_lookup
    years_at_company            TINYINT,
    years_in_current_role       TINYINT,
    years_since_last_promotion  TINYINT,
    years_with_curr_manager     TINYINT
);

-- Lookup tables: labels from the dataset's documentation
CREATE TABLE rating_lookup (
    rating_value  TINYINT PRIMARY KEY,
    rating_label  VARCHAR(12) NOT NULL
);
INSERT INTO rating_lookup VALUES (1, 'Low'), (2, 'Medium'), (3, 'High'), (4, 'Very High');

CREATE TABLE education_lookup (
    education_value  TINYINT PRIMARY KEY,
    education_label  VARCHAR(15) NOT NULL
);
INSERT INTO education_lookup VALUES
    (1, 'Below College'), (2, 'College'), (3, 'Bachelor'), (4, 'Master'), (5, 'Doctor');

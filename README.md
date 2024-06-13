
# SQL Analytical Queries Repository

This repository contains a collection of SQL queries that perform various analytical tasks using window functions and other SQL operations. The queries are designed to solve common problems in data analysis.

## Table of Contents

1. [Student Performance Analysis](#student-performance-analysis)
    - [Find Students with Above Average Marks](#find-students-with-above-average-marks)
    - [Find Branch Topper](#find-branch-topper)
2. [Customer Order Analysis](#customer-order-analysis)
    - [Top 2 Most Paying Customers of Each Month](#top-2-most-paying-customers-of-each-month)
    - [Month-over-Month Sales Growth](#month-over-month-sales-growth)
3. [Insurance Data Analysis](#insurance-data-analysis)
    - [Top 5 Patients by Insurance Claim](#top-5-patients-by-insurance-claim)
    - [Average Insurance Claim by Number of Children](#average-insurance-claim-by-number-of-children)
    - [Highest and Lowest Claimed Amount by Region](#highest-and-lowest-claimed-amount-by-region)
    - [Percentage of Smokers in Each Age Group](#percentage-of-smokers-in-each-age-group)
    - [Difference Between Claimed Amount and First Claimed Amount](#difference-between-claimed-amount-and-first-claimed-amount)
    - [Patient with Highest BMI in Each Region](#patient-with-highest-bmi-in-each-region)
    - [Difference in Claim Amount by BMI and Smoker Status](#difference-in-claim-amount-by-bmi-and-smoker-status)
    - [Rolling Average of Claims](#rolling-average-of-claims)
    - [First Claimed Insurance Value for Non-Diabetic Patients](#first-claimed-insurance-value-for-non-diabetic-patients)

## Student Performance Analysis

### Find Students with Above Average Marks

```sql
SELECT * FROM (
    SELECT *, AVG(marks) OVER (PARTITION BY branch) AS avv
    FROM marks
) t
WHERE t.avv < t.marks;
```

### Find Branch Topper

```sql
SELECT * FROM (
    SELECT *,
           FIRST_VALUE(name) OVER (PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS nm,
           FIRST_VALUE(marks) OVER (PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS mrk
    FROM marks
) t
WHERE t.marks = t.mrk
  AND t.name = t.nm;
```

## Customer Order Analysis

### Top 2 Most Paying Customers of Each Month

```sql
SELECT * FROM (
    SELECT MONTHNAME(date) AS mn, user_id, SUM(amount) AS sm,
           RANK() OVER (PARTITION BY MONTHNAME(date) ORDER BY SUM(amount)) AS mn_rnk
    FROM orders
    GROUP BY mn, user_id
    ORDER BY mn
) t
WHERE t.mn_rnk < 3
ORDER BY mn DESC, mn_rnk;
```

### Month-over-Month Sales Growth

```sql
SELECT MONTHNAME(datee), SUM(amount),
       ((SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY MONTH(datee))) / LAG(SUM(amount)) OVER (ORDER BY MONTH(datee))) * 100 AS MOM
FROM orders
GROUP BY MONTH(datee), MONTHNAME(datee)
ORDER BY MONTH(datee);
```

## Insurance Data Analysis

### Top 5 Patients by Insurance Claim

```sql
SELECT PatientID, claim AS ss
FROM insurance_data
ORDER BY ss DESC
LIMIT 5;
```

### Average Insurance Claim by Number of Children

```sql
SELECT children, AVG(claim)
FROM insurance_data
GROUP BY children;
```

### Highest and Lowest Claimed Amount by Region

```sql
SELECT region, MAX(claim), MIN(claim)
FROM insurance_data
GROUP BY region;
```

### Percentage of Smokers in Each Age Group

```sql
SELECT age, (cnt / cnt_1) * 100 FROM (
    SELECT age,
           SUM(CASE WHEN smoker = 'Yes' THEN 1 ELSE 0 END) AS cnt,
           SUM(CASE WHEN smoker = 'No' THEN 1 ELSE 0 END) AS cnt_1,
           SUM(CASE WHEN smoker = 'Yes' THEN 1 ELSE 0 END) + SUM(CASE WHEN smoker = 'No' THEN 1 ELSE 0 END) AS total
    FROM insurance_data
    GROUP BY age
) t;
```

### Difference Between Claimed Amount and First Claimed Amount

```sql
SELECT *, claim - FIRST_VALUE(claim) OVER () AS diff
FROM insurance_data;
```

### Patient with Highest BMI in Each Region

```sql
SELECT * FROM (
    SELECT *,
           RANK() OVER (PARTITION BY region ORDER BY bmi DESC) AS group_rank,
           RANK() OVER (ORDER BY bmi) AS overall_rank
    FROM insurance_data
) t
WHERE t.group_rank = 1;
```

### Difference in Claim Amount by BMI and Smoker Status

```sql
SELECT *, (claim - MAX(claim) OVER (PARTITION BY region, smoker)) AS diff
FROM insurance_data
ORDER BY diff DESC;
```

### Rolling Average of Claims

```sql
SELECT *,
       AVG(claim) OVER (ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) AS rolling_avg
FROM insurance_data;
```

### First Claimed Insurance Value for Non-Diabetic Patients

```sql
SELECT * FROM (
    SELECT *,
           FIRST_VALUE(claim) OVER (PARTITION BY region, gender ORDER BY age),
           ROW_NUMBER() OVER (PARTITION BY region, gender ORDER BY age) AS rn
    FROM insurance_data
    WHERE diabetic = 'No'
      AND bmi BETWEEN 25 AND 30
) t
WHERE t.rn = 1;
```















<!-- 
# Data Science Jobs Analysis SQL Case Study

## Scenario Summaries

1. **Compensation Analyst**: Identify countries offering fully remote work for managers with salaries exceeding $90,000 USD.

2. **HR Tech Startup**: Identify the top 5 countries with the highest count of large tech firms for fresher client placements.

3. **Workforce Management**: Calculate the percentage of employees enjoying fully remote roles with salaries exceeding $100,000 USD.

4. **Global Recruitment**: Identify locations with entry-level average salaries exceeding the market average, guiding candidates to lucrative opportunities.

5. **HR Consultancy**: Find countries paying the maximum average salary for each job title, aiding candidate placements.

6. **Business Consultant**: Analyze salary trends across company locations, pinpointing locations with consistent salary growth.

7. **Workforce Strategist**: Determine the percentage of fully remote work for each experience level in 2021 and compare it with 2024.

8. **Fortune 500**: Analyze salary trends to calculate the average salary increase percentage for each experience level and job title between 2023 and 2024.

9. **Database Security**: Implement role-based access control for a company's employee database, ensuring data confidentiality.

10. **Career Transition Consulting**: Guide clients in transitioning to different domains within the data industry based on their experience, employment type, company location, and size, focusing on average salary trends. -->

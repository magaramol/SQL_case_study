-- Find all the students whose average marks are greater than the branch average
SELECT * 
FROM (
    SELECT *, AVG(marks) OVER (PARTITION BY branch) AS avv
    FROM marks
) t
WHERE t.avv < t.marks;

-- Find the top 2 most paying customers of each month
SELECT * 
FROM (
    SELECT MONTHNAME(date) AS mn, user_id, SUM(amount) AS sm,
           RANK() OVER (PARTITION BY MONTHNAME(date) ORDER BY SUM(amount)) AS mn_rnk
    FROM orders
    GROUP BY mn, user_id
    ORDER BY mn
) t
WHERE t.mn_rnk < 3
ORDER BY mn DESC, mn_rnk;

-- Find the branch topper
SELECT * 
FROM (
    SELECT *,
           FIRST_VALUE(name) OVER (PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS nm,
           FIRST_VALUE(marks) OVER (PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS mrk
    FROM marks
) t
WHERE t.marks = t.mrk
  AND t.name = t.nm;

-- Create roll number from branch and marks
SELECT *, LAST_VALUE(name) OVER (
    PARTITION BY branch
    ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
) AS ac
FROM marks;

-- Calculate lag and lead of marks within each branch
SELECT *, 
       LAG(marks) OVER (PARTITION BY branch ORDER BY student_id) AS prev_marks,
       LEAD(marks) OVER (PARTITION BY branch ORDER BY student_id) AS next_marks
FROM marks;

-- Month-over-month sales growth
SELECT MONTHNAME(datee), SUM(amount),
       ((SUM(amount) - LAG(SUM(amount)) OVER (ORDER BY MONTH(datee))) / LAG(SUM(amount)) OVER (ORDER BY MONTH(datee))) * 100 AS MOM
FROM orders
GROUP BY MONTH(datee), MONTHNAME(datee)
ORDER BY MONTH(datee);

-- Find the top 5 patients who claimed the highest insurance amounts
SELECT PatientID, claim AS ss
FROM insurance_data
ORDER BY ss DESC
LIMIT 5;

-- Find the average insurance claimed by patients based on the number of children they have
SELECT children, AVG(claim)
FROM insurance_data
GROUP BY children;

-- Find the highest and lowest claimed amount by patients in each region
SELECT region, MAX(claim), MIN(claim)
FROM insurance_data
GROUP BY region;

-- Calculate the percentage of smokers in each age group
SELECT age, (cnt / cnt_1) * 100 AS smoker_percentage
FROM (
    SELECT age,
           SUM(CASE WHEN smoker = 'Yes' THEN 1 ELSE 0 END) AS cnt,
           SUM(CASE WHEN smoker = 'No' THEN 1 ELSE 0 END) AS cnt_1,
           SUM(CASE WHEN smoker = 'Yes' THEN 1 ELSE 0 END) + SUM(CASE WHEN smoker = 'No' THEN 1 ELSE 0 END) AS total
    FROM insurance_data
    GROUP BY age
) t;

-- Calculate the difference between the claimed amount of each patient and the first claimed amount of that patient
SELECT *, claim - FIRST_VALUE(claim) OVER () AS diff
FROM insurance_data;

-- Calculate the difference between the claimed amount of each patient and the average claimed amount of patients with the same number of children
SELECT *, AVG(claim) OVER (PARTITION BY children) AS avv,
       AVG(claim) OVER (PARTITION BY children) - claim AS diff
FROM insurance_data;

-- Show the patient with the highest BMI in each region and their respective rank
SELECT * 
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY region ORDER BY bmi DESC) AS group_rank,
           RANK() OVER (ORDER BY bmi) AS overall_rank
    FROM insurance_data
) t
WHERE t.group_rank = 1;

-- Calculate the difference between the claimed amount of each patient and the claimed amount of the patient who has the highest BMI in their region
SELECT *, claim - FIRST_VALUE(claim) OVER (PARTITION BY region ORDER BY bmi DESC) AS diff
FROM insurance_data;

-- Calculate the difference in claim amount between the patient and the patient with the highest claim amount among patients with the same BMI and smoker status, within the same region
SELECT *, (claim - MAX(claim) OVER (PARTITION BY region, smoker)) AS diff
FROM insurance_data
ORDER BY diff DESC;

-- Find the maximum BMI value among the next three records for each patient, ordered by age
SELECT *, MAX(bmi) OVER (ORDER BY age ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING) AS max_bmi_next_3
FROM insurance_data;

-- Find the rolling average of the last 2 claims for each patient
SELECT *, AVG(claim) OVER (ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) AS rolling_avg
FROM insurance_data;

-- Find the first claimed insurance value for male and female patients within each region, ordered by age in ascending order, and only include non-diabetic patients with a BMI between 25 and 30
SELECT * 
FROM (
    SELECT *, FIRST_VALUE(claim) OVER (PARTITION BY region, gender ORDER BY age) AS first_claim,
           ROW_NUMBER() OVER (PARTITION BY region, gender ORDER BY age) AS rn
    FROM insurance_data
    WHERE diabetic = 'No'
      AND bmi BETWEEN 25 AND 30
) t
WHERE t.rn = 1;
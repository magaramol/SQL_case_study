-- find all the students whose avg is greater than branch avg

select * from (select * , avg(marks) over (partition by branch)  as avv
from marks) t
where t.avv<t.marks
-- find top 2 most paying cx of each month

select * from (select monthname(date) as mn,user_id,sum(amount) as sm,
rank() over (partition by monthname(date) order by sum(amount)) as mn_rnk
from orders
group by mn,user_id
order by mn) t
where t.mn_rnk<3
order by mn desc, mn_rnk



-------------------------


select * ,last_value(name) over (
partition by branch
order by marks desc rows between unbounded preceding and unbounded following) as ac
 from marks



 ------------------

-- find the branch topper

select * from 
(select * ,
first_value(name) over (partition by branch order by marks
--  desc rows between unbounded preceding and unbounded following
) as nm,
first_value(marks) over (partition by branch order by marks 
-- desc rows between unbounded preceding and unbounded following 
) as mrk
from marks) t
where t.marks=t.mrk
and t.name=t.nm



--------------------------------------------

SELECT *
FROM (
    SELECT *,
           FIRST_VALUE(name) OVER (PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS nm,
           FIRST_VALUE(marks) OVER (PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS mrk
    FROM marks
) t
WHERE t.marks = t.mrk
  AND t.name = t.nm;


-- crreate roll number from branch and marks








--------------------------------------------------------

select *, 
lag(marks) over(partition by branch order by student_id),
lead(marks) over(partition by branch order by student_id)  
from marks;





-----------------------


------------ MOM

select monthname(datee) , sum(amount),
(
(sum(amount)- lag(sum(amount)) over(order by month(datee)))/lag(sum(amount)) over(order by month(datee)))*100 as MOM
from orders
group by  MONTH(datee), MONTHNAME(datee)
order by month(datee) 


----------------


-- Problem 1: What are the top 5 patients who claimed the highest insurance amounts?

select  PatientID, sum(claim) as ss
from insurance_data
group by PatientID
order by ss desc
limit 5;
----------------------------------------------
-- Problem 2: What is the average insurance claimed by patients based on the number of children they have?

select children, avg(claim)
  from insurance_data
  group by children;

-- using window function

SELECT distinct 
    children, 
    AVG(claim) OVER(PARTITION BY children) AS average_claim
FROM 
    insurance_data
ORDER BY 
    children;


-- Problem 3: What is the highest and lowest claimed amount by patients in each region?

select region,max(claim),min(claim)
 from insurance_data
 group by region


 ---using window function
select distinct region,max(claim) over (partition by region) as mx,
min(claim) over (partition by region) as mn
from insurance_data;
select * from insurance_data

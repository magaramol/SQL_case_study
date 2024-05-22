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




-- crreate roll number from branch and marks







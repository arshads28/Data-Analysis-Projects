SELECT *
FROM orders



---change  date

select order_date ,date, CONVERT(datetime,date)
from orders;

update orders
set order_date = TRY_CONVERT(date, order_date);



alter table orders
add date date

update orders
set date = CONVERT(datetime,date);




------top 10 revinue generated product
select top 10 sub_category, SUM(sale_price) sale
from orders
group by sub_category
order by 2 desc



-------top 5 heighest selling product in each region
with cte as
(
select region,product_id, SUM(sale_price)as sale
from orders
group by region,product_id
--order by 1,3 desc
)
select * from(
select *, ROW_NUMBER() over(partition by region order by  sale desc) as rn
from cte) A
where rn <=5



--------find month over month compression of 2022 and 2023 sale


--	select  date, FORMAT(date,'yyyy-MM')
--	from orders
with cte as
(
select year(date) year, month(date) month , SUM(sale_price) sale
from orders
group by year(date), month(date)
--order by 2,1
)
select month,
		SUM( case when year = 2022 then sale else 0 end ) as sale_2022
		,SUM( case when year = 2023 then sale else 0 end ) as sale_2023
from cte 
group by month
order by 1



---------------for each cetogery which month has heighest sales

with cte as(

select category ,FORMAT(date, 'yyyy-MM') as year_month ,SUM(sale_price) sales
from orders
group by category,FORMAT(date, 'yyyy-MM') 
--order by  category,SUM(sale_price)  desc
)
select * from(
select * ,
ROW_NUMBER() over(partition by category order by sales desc) rn
from cte) A
where rn <=1



-----or

with cte as(

select category ,FORMAT(date, 'yyyy-MM') as year_month ,SUM(sale_price) sales,
ROW_NUMBER() over(partition by category order by SUM(sale_price)desc) rn

from orders
group by category,FORMAT(date, 'yyyy-MM') 
--order by  category,SUM(sale_price)  desc
)
select * 
from cte
where rn <=1



--------------------which sub_category has the heighest growth  by profit forom 2022 to 2023
with cte as
(
select sub_category, YEAR(date) as year ,SUM(sale_price) sale
from orders
group by sub_category, YEAR(date)
--order by 3 desc
)
, cte2 as(
select sub_category,
		SUM( case when year =2022 then sale else 0 end ) as sale_2022,
		sum	(case when year =2023 then sale else 0 end ) as sale_2023
		
from cte
group by sub_category
)
select *, (sale_2023-sale_2022)*100/sale_2022 as percentage
from cte2
order by 4 desc
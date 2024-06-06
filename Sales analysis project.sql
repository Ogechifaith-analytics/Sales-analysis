-- vechile sales exploratory analysis: answering quuestions as relate to products,sales,customers and relationships among them.
use classicmodels;

------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------- Feature enginnering -------------------------------------------------------------
-- add month to order table
select*from orders;
select substring(orderDate,6,2) as MONTH
FROM orders;

alter table orders add column Month  int;
update orders
set Month = substring(orderDate,6,2);

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------- Generic questiion ----------------------------------------------------------
-- how many countries,cities are represented in the data
select * 
from customers;

select
 distinct country from customers;
select
 distinct country,city from customers
 order by country;
 
 select *  
 from offices;
 select
 distinct country from offices;

select
 distinct country,city from offices
 order by country; 
 -- ---------------------------------------------------------------------------------------------------------------------------------------------------
 -- ----------------------------------------------------------- product ------------------------------------------------------------------------
 -- How many unique productlines are in the data
 SELECT 
 DISTINCT productline
FROM productlines;

-- What are the Most selling productlines?
select * from products;

select productline,  
count(productline) as products_rank
from products
group by productline
order by products_rank desc;

-- what productline had largest revenue
select 
pr.productline,sum(od.quantityordered*od.priceEach) as total_revenue
from products as pr
join orderdetails as od
on pr.productCode=od.productCode
group by productline
order by total_revenue desc;

-- month with highest orders
select p.productline,o.month,sum(od.quantityordered) as total_QtyOrdered
from products as p
join orderdetails as od
on p.productCode=od.productCode
join orders as o
on od.orderNumber=o.orderNumber
group by p.productline,o.month
order by total_QtyOrdered desc;

-- product above average quantityordered
select p.productline,sum(od.quantityordered) as quantity
from products as p
join orderdetails as od
on p.productCode= od.productCode
group by productLine
having sum(od.quantityordered) > 
(select avg(quantityordered) from orderdetails)
order by quantity desc;

-- ---------- Add a column to products showing 'good'or'bad'.Good if its greater than average quantityordered
-- 1st,calculate the average quantity ordered
select avg(quantityordered) as avgQuantityOrdered
from orderdetails;
-- 2ndly, add new column
alter table products add column Quality varchar(12);

-- 3rdly,update new column based on the condition

update products  p
join(
select productcode,avg(quantityOrdered) as avgQuantityOrdered
from orderdetails
group by productCode)
AS od ON p.productcode = od.productCode
SET p.Quality= CASE
when od.avgQuantityOrdered > (select avg(QuantityOrdered) from orderdetails) 
then 'Good'
else 'Bad'
end;

select * from products
order by productName;

-- --------------------------------------------------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------sales --------------------------------------------------------------------------------
-- Monthly sales
with Month_sales AS
(select o.month,sum(od.quantityordered) as total_qtyordered,
sum(od.quantityordered*od.priceeach) as sales
from orders as o
join orderdetails as od
on o.orderNumber=od.orderNumber
group by o.month
order by sales desc)
select * from Month_sales;

-- sales by country,city per month
with City_sales AS
(select c.country,c.city,o.month,
sum(od.quantityordered*od.priceeach) as total_revenue
from customers as c
join orders as o
on c.customerNumber=o.customerNumber
join orderdetails as od
on o.orderNumber=od.orderNumber
group by c.country,c.city,o.month
order by total_revenue desc)
select * from City_sales;

-- determine revenue
select productName,productline,  p.quantityInStock,p.buyPrice,sum(p.quantityInStock*p.buyPrice) as Cost,
od.priceeach as selling_price,sum(p.quantityInStock*od.priceeach) as Revenue
from products as p
join orderdetails as od
on p.productCode = od.productCode
group by productName,productLine,quantityInStock,buyPrice,quantityordered,priceeach
order by productLine;

-- ---------------------------------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------------------- customers------------------------------------------------------------------------------
-- total number of customers 
select distinct customerName
from customers;
select distinct count(*)customerName
from customers;

-- customers purchase ranking
with customers_purchase AS
(select c.customerName,c.country,c.city,o.month,
sum(od.quantityordered*od.priceeach) as total_sales
from customers as c
join orders as o
on c.customerNumber=o.customerNumber
join orderdetails as od
on o.orderNumber=od.orderNumber
group by c.customerName,c.country,c.city,o.month
order by total_sales desc),
 customers_purchase_rank as
(select * ,dense_rank() over(partition by customerName order by total_sales desc) as Ranking
from customers_purchase ) 
select *
 from customers_purchase_rank
order by Ranking;




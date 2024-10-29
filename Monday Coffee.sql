-- Moday Coffee Data Analysis

select * from city;
select * from products;
select * from customers;
select * from sales;


-- Reports and Data Analysis

-- 1. Coffee consumers count
-- How many people in each city are estimated to consume coffee, given that 25% of the population does?

select * from city;

select 
	*, 
    round((population * 0.25)/1000000, 2) as coffee_consumers_in_mills
from 
	city
order by 
	population desc;
-- Note; Delhi, Mumbai, Kolkata, Bangalore and Chennai are the top 5 in coffee consumers


-- 2. Total Revenue From Coffee Sales
-- What is the total revenue generated from coffee sales accross all cities in the last quarter of 2023?

select * from sales;

select 
	sum(total) as last_quarter_total_revenue
from 
	sales
where 
		quarter(sale_date) = 4 and year(sale_date) = 2023
;
-- 1963300

-- To find the total revenue for each city
select 
	city.city_name,
	sum(s.total) as last_quarter_total_revenue
from 
	sales s
join 
	customers c
on 
	s.customer_id = c.customer_id
join 
	city 
on 
	city.city_id = c.city_id
where 
		quarter(s.sale_date) = 4 and year(s.sale_date) = 2023
group by
	city.city_name
order by
	2 desc
;
-- Note, Pune, Chennai, Bangalore, Japur and Delhi are the top 5



-- 3. Sales Count for Each Product
-- How many units of each coffee product have been sold?
select * from products;
select * from sales;

select 
	p.product_id,
	p.product_name,
    count(product_name) as units_sold
from 
	products p
left join
	sales s
on
	p.product_id = s.product_id
group by
	p.product_name
order by 3 desc;
-- Note: 'Cold Brew Coffee Pack (6 Bottles)', 'Ground Espresso Coffee (250g)', 'Instant Coffee Powder (100g)',
-- 'Coffee Beans (500g)', and 'Tote Bag with Coffee Design' are the highest selling products. reccomend these to the clients.


-- 4. Average Sales Amount per City
-- What is the average sales amount per customer in each city?

select * from city;
select * from sales;
select * from customers;

select 
	city.city_name,
	sum(s.total) as total_revenue,
	count(distinct s.customer_id) as total_customer,
	round(sum(s.total)/count(distinct s.customer_id), 2) as avg_sales_per_customer
from 
	sales s
join 
	customers c
on 
	s.customer_id = c.customer_id
join 
	city 
on 
	city.city_id = c.city_id
group by
	city.city_name
order by
	4 desc;
-- Note: Pune, Chennai, Bangalore, Jalpur and Delhi are the top 5 highest Average sales per customer, this helps in picking the 
-- top 3 cities to start the business in.




-- 5. City Population and Coffee Consumers
-- Provide a list of cities along with their populations and estimated coffee consumers.

select * from city;

with city_table as(
select 
	city_name, 
    population,
    round((population * 0.25)/1000000, 2) as coffee_consumers_in_mills
from 
	city
), 
customers_table as
(
	select 
		c1.city_name,
		count(distinct c.customer_id) as unique_customers
	from 
	sales s
	join 
		customers c
	on
		s.customer_id = c.customer_id
	join 
		city c1
	on
		c1.city_id = c.city_id
	group by 
		1
)

select 
	ct.city_name,
    ct.coffee_consumers_in_mills,
    cu.unique_customers
from 
	city_table ct
join 
	customers_table cu
on
	ct.city_name = cu.city_name
order by 2 desc
;
-- Delhi, Mumbai, Kolkata, Bangalore and Chennai are the top 5 cities with the most coffee consumers in millions



-- 6. Top Selling Products by City
-- What are the top 3 selling products in each city based on sales volume?
-- calculate hightest sales by city


select * from city;
select * from products;
select * from customers;
select * from sales;


select * from
(
	select 
		ci.city_name,
		s.product_id,
		p.product_name,
		count(s.sale_id) as total_sales,
		row_number() over(partition by ci.city_name order by count(s.sale_id)desc) as ranking
	from
		sales s
	join
		products p
	on
		p.product_id = s.product_id
	join
		customers cu
	on
		cu.customer_id = s.customer_id
	join
		city ci
	on 
		cu.city_id = ci.city_id
	group by 1, 2, 3
) a
where ranking in (1, 2, 3)
;


-- 7. Customer Segmentation by City
-- How many unique customers are there in each city who have purchased coffee products?

select * from city;
select * from products;
select * from customers;
select * from sales;

select 
	ci.city_id,
    ci.city_name,
    count(distinct cu.customer_id) as unique_customers
from 
	customers cu
join
	city ci
on
	cu.city_id = ci.city_id
join
	sales s
on
	cu.customer_id = s.customer_id
join
	products p
on
	s.product_id = p.product_id
where 
	s.product_id in (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
group by 
	ci.city_id, ci.city_name
order by 3 desc
;


-- 8. Average Sale vs Rent
-- Find each city and their average sale per customer and avg rent per customer

select * from city;
select * from products;
select * from customers;
select * from sales;

with city_table as(
	select 
		city.city_name,
		sum(s.total) as total_revenue,
		count(distinct s.customer_id) as total_customer,
		round(sum(s.total)/count(distinct s.customer_id), 2) as avg_sales_per_customer
	from 
		sales s
	join 
		customers c
	on 
		s.customer_id = c.customer_id
	join 
		city 
	on 
		city.city_id = c.city_id
	group by
		city.city_name
	order by
		4 desc
),
city_rent as (
	select 
		city_name, 
		estimated_rent
	from
		city
)

select 
	cr.city_name, 
	cr.estimated_rent,
    ct.total_customer,
    ct.avg_sales_per_customer,
    round((cr.estimated_rent/ct.total_customer), 2) as avg_rent_per_customer
from 
	city_rent cr
join
	city_table ct
on
	cr.city_name = ct.city_name
order by 4 desc
;



-- 9. Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).

select * from city;
select * from products;
select * from customers;
select * from sales;



with monthly_sales as(
	select 
		ci.city_name,
		month(s.sale_date) as month,
		year(s.sale_date) as year,
		sum(s.total) as total_sale
	from 
		sales s
	join 
		customers cu
	on 
		s.customer_id = cu.customer_id
	join 
		city ci
	on 
		ci.city_id = cu.city_id
	group by
		1, 2, 3
	order by
		1,3 , 2
),

last_monthly_sale as(
	select
		city_name,
		month,
		year,
		total_sale as cr_month_sale,
		lag(total_sale, 1) over(partition by city_name) as last_month_sale
	from
		monthly_sales
)

select
	city_name,
    month,
    year,
    cr_month_sale,
    last_month_sale,
    round(((cr_month_sale-last_month_sale)/last_month_sale) * 100, 2) as growth_ratio
from
	last_monthly_sale
where last_month_sale is not null
;

-- 10. Market Potential Analysis
-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated coffee consumer


with city_table as(
	select 
		city.city_name,
		sum(s.total) as total_revenue,
		count(distinct s.customer_id) as total_customer,
		round(sum(s.total)/count(distinct s.customer_id), 2) as avg_sales_per_customer
	from 
		sales s
	join 
		customers c
	on 
		s.customer_id = c.customer_id
	join 
		city 
	on 
		city.city_id = c.city_id
	group by
		city.city_name
	order by
		4 desc
),
city_rent as (
	select 
		city_name, 
		estimated_rent,
        round(population * 0.25/1000000, 2)  as estimated_coffee_consumer_in_mills
	from
		city
)

select 
	cr.city_name, 
    total_revenue,
	cr.estimated_rent,
    ct.total_customer,
    ct.avg_sales_per_customer,
    estimated_coffee_consumer_in_mills,
    round((cr.estimated_rent/ct.total_customer), 2) as avg_rent_per_customer
from 
	city_rent cr
join
	city_table ct
on
	cr.city_name = ct.city_name
order by 2 desc
;

-- Recomendation
-- city 1: Pune
-- Average rent per customer is very low (290.23)
-- Highest total revenue(1,258,290)
-- High average sales per customer(24,197.88)

-- city 2: Delhi
-- Highest amount of coffee consumed (7.7 million)
-- second highest number of customers (68)
-- average rent per customer is moderately bellow 500 (330.88)

-- city 3: Jaipur
-- Highest total customers(68)
-- Lowest average rent per customer(156.52)
-- Average sales per customer is high (11.6k) despit 1M being consumed

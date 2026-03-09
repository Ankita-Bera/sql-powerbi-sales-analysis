CREATE DATABASE  pizzahut;
use pizzahut;

create table customers(
custid int not null,
first_name varchar(20) not null,
last_name varchar(20) not null,	
email varchar(25) not null,	
phone bigint not null,	
address	varchar(25) not null,
city varchar(10) not null,	
state varchar(10) not null,	
postal_code int not null,
primary key(custid)
);

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
custid int not null,
status varchar(10) not null,
primary key(order_id),
foreign key (custid) references customers(custid) 
);

create table pizza_type(
pizza_type_id varchar(50) not null,	
name varchar(100) not null,	
category varchar(50) not null,	
ingredients text not null,
primary key(pizza_type_id)
);
 
 create table pizzas(
 pizza_id varchar(15) not null,	
 pizza_type_id varchar(15) not null,	
 size varchar(5) not null,	
 price numeric(10,2) not null,
 primary key(pizza_id),
 foreign key(pizza_type_id) references pizza_type(pizza_type_id)
 );

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id varchar(15) not null,
quantity int not null,
primary key(order_details_id),
foreign key(pizza_id) references pizzas(pizza_id),
foreign key(order_id) references orders(order_id)
);

show tables;

DESCRIBE orders;
DESCRIBE order_details;
DESCRIBE pizza_type;
DESCRIBE pizzas;
DESCRIBE customers;

-- check null values
SELECT *
FROM orders
WHERE order_date IS NULL
   OR order_time IS NULL;

-- check duplicate value
select count(*) from customers;

select min(custid)
from customers
group by email;

-- check incorrect value
SELECT *
FROM order_details
WHERE quantity <= 0;

-- check inconsistent format
SELECT order_date
FROM orders
where order_date is null;

SELECT *
FROM orders
WHERE STR_TO_DATE(order_date,'%Y-%m-%d') IS NULL;

SELECT *
FROM customers
WHERE email NOT LIKE '%@%.%';

-- retrieve total no of order placed
select * from orders;

select count(order_id) as total_order_placed
from orders;
 
--  calculate the total revenue generated from pizza sales
select * from pizzas;
select * from order_details;

SELECT sum(pizzas.price*order_details.quantity) as total_revenue
FROM pizzas
JOIN order_details
ON pizzas.pizza_id = order_details.pizza_id;

-- total number of pizza sold
select * from order_details;

select sum(quantity) as total_pizza
from order_details;

-- identify the highest priced pizza name
select * from pizzas;
select * from pizza_type;

select pizza_type.name,pizzas.price
from pizza_type
join pizzas
on pizza_type.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;

-- most common pizza size ordered
select * from pizzas;
select * from order_details;

select pizzas.size,count(order_details.order_details_id) as total_pizza
from pizzas
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size
order by total_pizza desc limit 1;

-- list the most ordered pizza types along with their quantities
select * from pizzas;
select * from order_details;
select * from pizza_type;

select pizza_type.category,sum(order_details.quantity) as quantity
from pizzas
join pizza_type
on pizzas.pizza_type_id = pizza_type.pizza_type_id 
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_type.category
order by quantity desc;

-- list the top 5 most ordered pizza names along with their quantities

select pizza_type.name,sum(order_details.quantity) as quantity
from pizzas
join pizza_type
on pizzas.pizza_type_id = pizza_type.pizza_type_id 
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_type.name
order by quantity desc limit 5;

-- determine the distribution of orders by hour of the day
select hour(order_time), count(order_id) as order_count
from orders
group by hour(order_time);

-- find category-wise distribution of pizzas
select category, count(name) 
from pizza_type
group by category;

-- group the orders by date and calculate the average number of pizzas ordered per day
select * from order_details;
select * from orders;

select round(avg(quantity),2) as avg_pizza_ordered_per_day
from
(select orders.order_date, sum(order_details.quantity) as quantity
from orders
join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity;

-- determine the top 3 most ordered pizza types based on revenue
select pizza_type.name, sum(order_details.quantity*pizzas.price) as revenue
from pizza_type
join pizzas
on pizza_type.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_type.name
order by revenue desc limit 3;

-- calculate the percentage contribution of each pizza type to total revenue
select pizza_type.category, sum(order_details.quantity*pizzas.price) as revenue,
round((sum(order_details.quantity*pizzas.price)/
(select sum(order_details.quantity*pizzas.price)
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id)*100),2) as percentage_contribution
from pizza_type
join pizzas
on pizza_type.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_type.category
order by revenue desc;

-- analyze the cumulative revenue generated over time
select order_date, sum(revenue) over (order by order_date) as cum_revenue 
from
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue
from orders 
join order_details
on orders.order_id = order_details.order_id
join pizzas
on order_details.pizza_id = pizzas.pizza_id
group by order_date) as sales;

-- find top 3 most ordered pizza types based on revenue for each pizza category
select category, name, revenue
from
(select category, name, revenue, rank() over(partition by category order by revenue desc) as ranking
from
(select pizza_type.category,pizza_type.name,sum(pizzas.price*order_details.quantity) as revenue
from pizza_type
join pizzas
on pizza_type.pizza_type_id = pizzas.pizza_type_id
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizza_type.category,pizza_type.name)  as a) as b
where ranking <=3;

-- average amount spent per order
select * from order_details;
select * from pizzas;

select round(sum(pizzas.price*order_details.quantity)/count(distinct orders.order_id),2) as avg_order
from order_details
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on order_details.order_id = orders.order_id;

-- average pizza sold per order
select * from order_details;

select round(sum(quantity)/count(distinct order_id),2) as avg_pizza_per_order
from order_details;

-- last 5 saled pizza by revenue
select * from pizza_type;

select pizza_type.name,sum(order_details.quantity*pizzas.price) as revenue
from order_details 
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join pizza_type
on pizzas.pizza_type_id = pizza_type.pizza_type_id
group by pizza_type.name
order by revenue asc limit 5;

-- top 5 best sellers by revenue
select customers.custid,sum(order_details.quantity*pizzas.price) as revenue
from order_details 
join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on order_details.order_id = orders.order_id
join customers
on orders.custid = customers.custid
group by customers.custid
order by revenue desc limit 5;

-- daily trend for total orders
select order_date, count(order_id) as total_orders
from orders
group by order_date
order by order_date; 

-- monthly trend for total orders
select month(order_date) as month, count(order_id) as total_orders
from orders
group by month(order_date)
order by month; 

-- order by day of week
select dayname(order_date) as day, count(order_id) as orders
from orders
group by day;

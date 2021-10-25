/*
GOAL: solve questions of "Explore the tables" section
DESCRIPTION: 
	Provide a simple solution for the questions on the section "Explore the tables"
    https://platform.wbscodingschool.com/courses/data-science/8738/
*/
USE magist;

-- How many orders are there in the dataset?
SELECT COUNT(*) AS orders_count
FROM orders;

-- How many different products are in the products table?
SELECT COUNT( DISTINCT product_id) AS products_count
FROM products;

-- How many different products were actually sold in the orders contained in this database?
-- Waiting for Guillem refactoring question.
select count( distinct product_id)
from order_items;

select * 
from products as pr, order_items as oi;

-- What are the most popular categories?
-- Question has to be changed to: Which is the category with more products?
SELECT product_category_name, COUNT(DISTINCT product_id) 
FROM products
GROUP BY product_category_name
ORDER BY COUNT(product_id) DESC;

-- What’s the price for the most expensive and cheapest products?
-- Check the option for MIN() and MAX()
(
	SELECT product_id, AVG(price) AS avg_price
	FROM order_items
	GROUP BY product_id
	ORDER BY AVG(price)
	LIMIT 1
) UNION (
	SELECT product_id, AVG(price) AS avg_price
	FROM order_items
	GROUP BY product_id
	ORDER BY AVG(price) DESC
	LIMIT 1
    );

-- What are the highest and lowest payment values?
-- SELECT * FROM order_payments
(
	SELECT order_id, AVG(payment_value) AS min_payment_value
	FROM order_payments
	GROUP BY order_id
	ORDER BY AVG(payment_value) DESC
	LIMIT 1
) UNION (
	SELECT order_id, AVG(payment_value) AS min_payment_value
	FROM order_payments
	GROUP BY order_id
	ORDER BY AVG(payment_value)
	LIMIT 1
    );
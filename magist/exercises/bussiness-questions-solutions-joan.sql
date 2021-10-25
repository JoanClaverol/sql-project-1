/*
GOAL: Solve questions of teh section "Answer Business Questions"
DESCRIPTION: 
	Provide a solution to the main business questions: 
    https://platform.wbscodingschool.com/courses/data-science/8744/
    Remember to always keep on mind the Eniac's strategy: 
		* Is Magist is a good fit for high-end tech products?
		* Are orders delivered on time?
*/
USE magist; 
-- Create a temporary table to store names of tech categoies

-- In relation to the products:

-- -- What categories of tech products does Magist have?
-- -- Note: to create a temporary table to store the tech products as a list would be a nice solution. 
CREATE TABLE IF NOT EXISTS tech_categories(
	SELECT product_category_name_english, product_category_name
	FROM product_category_name_translation
	WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
);
SELECT * 
FROM tech_categories; 

-- -- How many products of these tech categories have been sold within the time window of the database snapshot? What percentage does that represent of the total products sold?
SELECT COUNT(DISTINCT(oi.product_id)) AS tech_products_sold
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IN (SELECT product_category_name FROM tech_categories); 

-- -- What’s the average price of the products being sold?
SELECT product_id, AVG(price) AS avg_price
FROM order_items
GROUP BY product_id;

-- -- Are expensive tech products popular?
-- -- NOTE: 
-- -- 	1. what does it mean popular? For me it would be that there are more transactions with tech products than without in the time window of the database snapshot. 
-- -- 	2. which are the expensive tech products? 
-- -- Quick count of overall number of transactions for errors check: 
SET @transactions_count = (
	SELECT COUNT(DISTINCT(order_id)) 
	FROM order_items
    );
-- -- Count of tech transactions: 
SET @tech_transactions = (
	SELECT COUNT(DISTINCT(oi.order_id)) AS orders_count
	FROM order_items oi
	LEFT JOIN products p ON oi.product_id = p.product_id
	WHERE p.product_category_name IN (SELECT product_category_name FROM tech_categories)
    ); 
-- -- Count of NOT tech transactions: 
SET @not_tech_transactions = (
	SELECT COUNT(DISTINCT(oi.order_id)) AS orders_count
	FROM order_items oi
	LEFT JOIN products p ON oi.product_id = p.product_id
	WHERE p.product_category_name NOT IN (SELECT product_category_name FROM tech_categories)
    ); 
-- -- Results table
SELECT @not_tech_transactions, @tech_transactions, @transactions_count;

-- -- What’s the average monthly revenue of Magist’s sellers?
SELECT rym.seller_id, AVG(rym.revenue_ym) AS avg_revenue
FROM (
	SELECT YEAR(shipping_limit_date), MONTH(shipping_limit_date), seller_id, SUM(price) AS revenue_ym  
	FROM order_items
	GROUP BY YEAR(shipping_limit_date), MONTH(shipping_limit_date), seller_id
    ) rym
GROUP BY rym.seller_id
ORDER BY AVG(rym.revenue_ym) DESC;

-- In relation to the sellers:

-- -- How many sellers are there?
SELECT COUNT(DISTINCT(seller_id)) AS sellers_count
FROM sellers;

-- -- What’s the average revenue of the sellers?
-- -- Notes: see ticket on notion

-- -- What’s the average revenue of sellers that sell tech products?
SELECT rym.seller_id, AVG(rym.revenue_ym) AS avg_revenue
FROM (
	SELECT YEAR(oi.shipping_limit_date), MONTH(oi.shipping_limit_date), oi.seller_id, SUM(oi.price) AS revenue_ym  
	FROM order_items oi
    LEFT JOIN products p ON oi.product_id = p.product_id
	WHERE p.product_category_name IN (SELECT product_category_name FROM tech_categories)
    GROUP BY YEAR(oi.shipping_limit_date), MONTH(oi.shipping_limit_date), oi.seller_id
    ) rym
GROUP BY rym.seller_id
ORDER BY AVG(rym.revenue_ym) DESC;

-- In relation to the delivery time:

-- -- What’s the average time between the order being placed and the product being delivered?
-- -- NOTES: how to get the average time in time format that makes sense to human perspective?
SELECT ROUND(AVG(odt.days_diff)) AS day_deliver_avg, AVG(odt.time_diff) AS time_deliver_svg
FROM (
	SELECT 
		order_delivered_customer_date, order_approved_at, 
		TIMEDIFF(order_delivered_customer_date, order_approved_at) AS time_diff, 
		ROUND(HOUR(TIMEDIFF(order_delivered_customer_date, order_approved_at))/24) AS days_diff
	FROM orders
    ) odt;

-- -- How many orders are delivered on time vs orders delivered with a delay?
SELECT 
	CASE 
		WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date) THEN 'On date'
		ELSE 'Delay'
    END AS deliver_status, 
    COUNT(order_id) AS orders_count
FROM orders
WHERE order_status = 'delivered'
GROUP BY deliver_status;

-- -- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT *, 
	CASE 
		WHEN DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date) THEN 'On date'
		ELSE 'Delay'
    END AS deliver_status, 
    TIMEDIFF(order_delivered_customer_date, order_approved_at) AS time_diff, 
    ROUND(HOUR(TIMEDIFF(order_delivered_customer_date, order_approved_at))/24) AS days_diff
FROM orders
WHERE order_status = 'delivered' AND NOT DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date); 
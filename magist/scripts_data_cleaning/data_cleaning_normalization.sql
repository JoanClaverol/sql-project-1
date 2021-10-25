use magist;

/*
Setting primary keys
*/

-- product_category_name_translation
ALTER TABLE product_category_name_translation
MODIFY product_category_name VARCHAR(255) NOT NULL;

ALTER TABLE product_category_name_translation
ADD PRIMARY KEY (product_category_name);

-- products
ALTER TABLE products
MODIFY product_id VARCHAR(255) NOT NULL;

ALTER TABLE products
ADD PRIMARY KEY (product_id);

-- orders
ALTER TABLE orders
MODIFY order_id VARCHAR(255) NOT NULL;

ALTER TABLE orders
ADD PRIMARY KEY (order_id);

-- order_reviews
-- There are 1627 duplicate reviews. For now they will all be dropped
SELECT * FROM order_reviews WHERE review_id in(
SELECT t1.review_id FROM
(SELECT 
    review_id, 
    COUNT(review_id)
FROM
    order_reviews
GROUP BY review_id
HAVING COUNT(review_id) > 1) t1)
ORDER BY review_id;

DELETE from order_reviews where review_id IN(
SELECT distinct(review_id) FROM
(SELECT 
    review_id, 
    COUNT(review_id)
FROM
    order_reviews
GROUP BY review_id
HAVING COUNT(review_id) > 1) t1);

ALTER TABLE order_reviews
MODIFY review_id VARCHAR(255) NOT NULL;

ALTER TABLE order_reviews
ADD PRIMARY KEY (review_id);

-- sellers
ALTER TABLE sellers
MODIFY seller_id VARCHAR(255) NOT NULL;

ALTER TABLE sellers
ADD PRIMARY KEY (seller_id);


-- customers
ALTER TABLE customers
MODIFY customer_id VARCHAR(255) NOT NULL;

ALTER TABLE customers
ADD PRIMARY KEY (customer_id);


/* Foreign keys */

-- orders.customer_id -> customers.customer_id
ALTER TABLE orders
MODIFY customer_id VARCHAR(255) NOT NULL;

ALTER TABLE orders
ADD FOREIGN KEY (customer_id) REFERENCES customers(customer_id); 

-- order_items.order_id -> orders.order_id
ALTER TABLE order_items
MODIFY order_id VARCHAR(255) NOT NULL;

ALTER TABLE order_items
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id); 

-- order_items.product_id -> products.product_id
ALTER TABLE order_items
MODIFY product_id VARCHAR(255) NOT NULL;

ALTER TABLE order_items
ADD FOREIGN KEY (product_id) REFERENCES products(product_id); 

-- order_items.seller_id --> sellers.seller_id
ALTER TABLE order_items
MODIFY seller_id VARCHAR(255) NOT NULL;

ALTER TABLE order_items
ADD FOREIGN KEY (seller_id) REFERENCES sellers(seller_id); 

/* 
replacing nulls in products.product_category_name with "outros"
and adding a row to product_category_name_translation with "outros" - "others" 
*/
update products set product_category_name = "outros" where product_category_name is null;
insert into product_category_name_translation
values ("outros", "others");

/*
adding to product_category_name_translation categories that exist in products
*/
SELECT DISTINCT(product_category_name) FROM
products WHERE product_category_name NOT IN (
SELECT product_category_name FROM
product_category_name_translation);

insert into product_category_name_translation values 
("pc_gamer", "pc_gamer"),
("portateis_cozinha_e_preparadores_de_alimentos", "portable_kitchen_food_processors");

-- then products.product_category_name ->  product_category_name_translation.product_category_name
ALTER TABLE products
MODIFY product_category_name VARCHAR(255) NOT NULL;

ALTER TABLE products
ADD FOREIGN KEY (product_category_name) REFERENCES product_category_name_translation(product_category_name); 

-- Removing leading & trailing whitespaces / tabs / newlines from product_category_name_english
UPDATE product_category_name_translation
SET product_category_name_english = REGEXP_REPLACE(product_category_name_english, '(^[[:space:]]+|[[:space:]]+$)', '');

-- order_payments.order_id -> orders.order_id
ALTER TABLE order_payments
MODIFY order_id VARCHAR(255) NOT NULL;

ALTER TABLE order_payments
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id); 

-- order_reviews.order_id -> orders.order_id
ALTER TABLE order_reviews
MODIFY order_id VARCHAR(255) NOT NULL;

ALTER TABLE order_reviews
ADD FOREIGN KEY (order_id) REFERENCES orders(order_id); 

-- sellers.seller_zip_code_prefix -> zip_geolocation.zip_code_prefix
ALTER TABLE sellers
MODIFY seller_zip_code_prefix INT NOT NULL;

ALTER TABLE sellers
ADD FOREIGN KEY (seller_zip_code_prefix) REFERENCES geo(zip_code_prefix); 


-- zip codes in customers, not in zip_geolocation
SELECT DISTINCT
    (c.customer_zip_code_prefix)
FROM
    customers c
WHERE
    c.customer_zip_code_prefix NOT IN (SELECT 
            g.zip_code_prefix
        FROM
            zip_geolocation g);


SELECT COUNT(*) FROM zip_geolocation_full;
SELECT COUNT(distinct(zip_code_prefix)) FROM zip_geolocation_full;


SELECT DISTINCT
    (c.customer_zip_code_prefix)
FROM
    customers c
WHERE
    c.customer_zip_code_prefix NOT IN (SELECT 
            f.zip_code_prefix
        FROM
            zip_geolocation_full f);

SELECT DISTINCT
    (f.zip_code_prefix)
FROM
    zip_geolocation_full f
WHERE
    f.zip_code_prefix NOT IN (SELECT 
            g.zip_code_prefix
        FROM
            zip_geolocation g);



-- zip codes in customers, not in zip_geolocation
SELECT DISTINCT(customer_zip_code_prefix) FROM
customers WHERE customer_zip_code_prefix NOT IN (
SELECT zip_code_prefix FROM
zip_geolocation_full);


select count(distinct(zip_code_prefix)) from zip_geolocation;
select count(zip_code_prefix) from zip_geolocation_full;

-- customers.customer_zip_code_prefix -> zip_geolocation.zip_code_prefix
ALTER TABLE customers
MODIFY customer_zip_code_prefix INT NOT NULL;

ALTER TABLE customers
ADD FOREIGN KEY (customer_zip_code_prefix) REFERENCES geo(zip_code_prefix); 

/* Droping city & state from customers & sellers tables
As well as customer_unique_id
*/
ALTER TABLE customers
DROP COLUMN customer_unique_id,
DROP COLUMN customer_city,
DROP COLUMN customer_state;

ALTER TABLE sellers
DROP COLUMN seller_city,
DROP COLUMN seller_state;
DROP TABLE zip_geolocation_full;

/* Can't drop zip_geolocation without removing the foreign key from sellers */
SHOW CREATE TABLE sellers; -- shows the name of the Constraint (not the same as the foreign key)
ALTER TABLE sellers
DROP FOREIGN KEY sellers_ibfk_1;

DROP TABLE zip_geolocation;
DROP TABLE closed_deals;
DROP TABLE marketing_qualified_leads;

COMMIT;


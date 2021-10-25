/*
SQL JOIN
------------------------------------------------------------------------------------------------
HOW TO GET THE SCHEMA OF A DATABASE: 
* Windows/Linux: Ctrl + r
* MacOS: Cmd + r
*/
USE publications; 

-- AS 
# Change the column name qty to Quantity into the sales table
# https://www.w3schools.com/sql/sql_alias.asp
SELECT *, qty as 'Quantity'
FROM sales;
# Assign a new name into the table sales, and call the column order number using the table alias


-- JOINS
# https://www.w3schools.com/sql/sql_join.asp
-- LEFT JOIN
SELECT * 
FROM stores s 
LEFT JOIN discounts d ON d.stor_id = s.stor_id;
-- RIGHT JOIN
SELECT * 
FROM stores s 
RIGHT JOIN discounts d ON d.stor_id = s.stor_id;
-- INNER JOIN
SELECT * 
FROM stores s 
INNER JOIN discounts d ON d.stor_id = s.stor_id;

-- CHALLENGES: 
# In which cities has "Is Anger the Enemy?" been sold?
# HINT: you can add WHERE function after the joins

# Select all the books (and show their title) where the employee
# Howard Snyder had work.

# Select all the authors that have work (directly or indirectly)
# with the employee Howard Snyder

# Select the book title with higher number of sales (qty)

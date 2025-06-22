--1.	Find the total quantity sold for each product category across all stores.
--CTAS
CREATE TABLE global_sales
AS 
SELECT
	s.*,
	st.store_name,
	st.city,
	st.country,
	p.product_name,
	p.category,
	p.subcategory,
	ROUND(((s.qty * s.unit_price)-(s.qty *s.unit_price *s.discount_percentage)):: NUMERIC,3) AS net_sale
FROM stores st 
INNER JOIN 
sales s 
ON s.store_id = st.store_id
INNER JOIN 
products p 
ON p.product_id = s.product_id

--1.	Find the total quantity sold for each product category across all stores.
SELECT
	store_name,
	category,
	SUM(qty) AS quantity_sold
FROM
global_sales
GROUP BY 1,2
ORDER BY 1

--2.	List each store's total sales revenue, including both discounted and non-discounted prices.
SELECT
	store_name,
	net_sale AS discounted_sale,
	SUM(qty * unit_price) AS non_discounted_price
FROM
global_sales
GROUP BY 1,2

--3.	Identify the top three products with the highest sales quantity in each country.

WITH product_sale
AS
(SELECT
	country,
	product_id,
	product_name,
	SUM(qty) as total_sale
FROM
global_sales
GROUP BY 1,2,3)
SELECT
	p1.country,
	p1.product_name,
	p1.total_sale
FROM
	product_sale as p1
WHERE
	(SELECT COUNT(*)
	  FROM product_sale as p2
	  WHERE p2.country = p1.country
	  AND p2.total_sale > p1.total_sale
	 )<3
ORDER BY 1,3



--4.Calculate the average discount given per product category across all stores.
SELECT
	store_name,
	category,
	ROUND((AVG(discount_percentage *100))::NUMERIC,3) AS avg_discount_value
FROM 
global_sales
GROUP BY 1,2
ORDER BY 1,2

--5.	Find the number of unique products sold in each store within the "Furniture" category.
SELECT
	product_id,
	product_name,
	store_name,
	SUM(qty) AS product_sold
FROM 
global_sales
WHERE 
category ='Furniture'
GROUP BY 1,2,3
ORDER BY 3, 4 DESC




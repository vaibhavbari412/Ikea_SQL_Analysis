--1.	Identify products that have never been sold in any store.
--approach 1 using subquery
SELECT 
	product_id,
	product_name
FROM 
products
WHERE
	product_id NOT IN (SELECT DISTINCT product_id from sales)

--approach 2 using join
SELECT 
	p.product_id,
	p.product_name
FROM
products p
LEFT JOIN 
sales s
ON s.product_id = p.product_id
WHERE s.product_id IS NULL

--2.Find stores where the total sales revenue is higher than the average revenue across all stores.
SELECT
	store_id,
	store_name,
	SUM(net_sale) AS total_revenue
FROM
	global_sales
GROUP BY 1,2
HAVING SUM(net_sale) > (SELECT 
								SUM(net_sale)/(SELECT COUNT(DISTINCT store_id) FROM global_sales) 
								FROM global_sales)
								
--3.Display products whose average unit price in sales transactions is lower than their listed price in the products table.
--approach 1 
SELECT
	product_id,
	product_name,
	unit_pice
FROM
	products AS p
WHERE unit_pice > (SELECT 
						AVG(s.unit_price)
					FROM 
						sales AS s
					WHERE s.product_id=p.product_id
					)

--approach 2
SELECT
	p.product_id,
	p.product_name,
	AVG(s.unit_price) AS avg_unit_price
FROM
	sales s
INNER JOIN
	products p
ON
	p.product_id=s.product_id
GROUP BY 1,2
HAVING 
	AVG(s.unit_price)<p.unit_pice


--4.Use a correlated subquery to find products whose sales exceeded the average sales of their category. 
--(Find Best Selling Products of Each Category)
WITH total_sales
AS
(SELECT
	category,
	product_id,
	product_name,
	SUM(net_sale) AS total_sale
FROM
	global_sales
GROUP BY 1,2,3
ORDER BY 1,2,3)
SELECT 
	t1.category,
	t1.product_id,
	t1.product_name
FROM total_sales AS t1
WHERE total_sale > (SELECT AVG(total_sale)
						FROM total_sales
						WHERE category =t1.category)
ORDER BY 1

--5.List cities with total sales greater than the average sales for their country.
WITH city_sale
AS
(SELECT
	country,
	city,
	SUM(net_sale) AS total_sales
FROM 
	global_sales
GROUP BY 1,2)
SELECT
	country,
	city
FROM city_sale AS c
WHERE total_sales >(SELECT AVG(total_sales) FROM city_sale 
					WHERE country=c.country)






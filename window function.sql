--1.	List the top five products by sales quantity within each store.
--
WITH product_sales
AS
(SELECT
	product_id,
	product_name,
	store_name,
	store_id,
	SUM(qty) AS quantity_sold
FROM
	global_sales
GROUP BY 1,2,3,4)
, product_sales_rank
AS
(SELECT
	*,
	DENSE_RANK() OVER(PARTITION BY store_id ORDER BY quantity_sold DESC) AS d_rank
FROM
	product_sales)
SELECT
	store_name,
	product_name,
	quantity_sold,
	d_rank
FROM
	product_sales_rank
WHERE
	d_rank <=5

--2.	Rank each product by quantity sold in each store

WITH product_sales
AS
(SELECT
	product_id,
	product_name,
	store_name,
	store_id,
	SUM(qty) AS quantity_sold
FROM
	global_sales
GROUP BY 1,2,3,4)
SELECT 
	store_name,
	product_name,
	quantity_sold,
	RANK() OVER(PARTITION BY store_id ORDER BY quantity_sold DESC) AS p_rank
FROM 
product_sales

--3.	Retrieve the top-selling product in each category.
WITH product_sales
AS
(SELECT
	product_id,
	product_name,
	category,
	SUM(net_sale) as total_sales
FROM
	global_sales
GROUP BY 1,2,3)
,product_sales_rank
AS
(
	SELECT
		*,
		DENSE_RANK() OVER (PARTITION BY category ORDER BY total_sales) AS d_rank
	FROM
		product_sales
)
SELECT
	category,
	product_name,
	d_rank
FROM
	product_sales_rank
WHERE 
	d_rank =1

--4.	Get RANK for each store based on total revenue.
WITH product_sales
AS
(SELECT
	store_id,
	store_name,
	SUM(net_sale) as total_sales
FROM
	global_sales
GROUP BY 1,2)
SELECT
		*,
		RANK() OVER ( ORDER BY total_sales) AS d_rank
	FROM
		product_sales

--5.	Use ROW_NUMBER to find the first sale of each product in each store.
WITH product_sale
as
(
SELECT
	store_name,
	product_name,
	order_date,
	ROW_NUMBER() OVER(PARTITION BY store_id,product_id ORDER BY order_date) as order_rk
FROM
	global_sales
)
SELECT
	*
FROM 
	product_sale
WHERE 
	order_rk =1

--6.	Rank products within each category based on total sales revenue.
WITH product_sales
AS
(
SELECT
	product_id,
	product_name,
	category,
	SUM(net_sale) AS total_sales
FROM
	global_sales
GROUP BY 1,2,3
)
SELECT
	*,
	RANK() OVER (PARTITION BY category order by total_sales DESC)
FROM
	product_sales

--7.	Assign a unique ranking to each product based on its sales quantity, grouped by country.
WITH product_sale
AS
(
SELECT
	product_id,
	product_name,
	country,
	SUM(qty) as total_sales_qty
FROM
global_sales
GROUP BY 1,2,3
)
SELECT
	*,
	ROW_NUMBER() OVER (PARTITION BY COUNTRY ORDER BY total_sales_qty desc)
FROM
product_sale

--8.	For each store, show the order history of products sorted by the order date and assign a sequential number to each 
SELECT
	store_name,
	product_name,
	order_date,
	ROW_NUMBER() OVER(PARTITION BY store_id ORDER BY order_date DESC) AS row_num	
FROM
global_sales
ORDER BY 1,3


--9.	Find the top three stores with the highest sales revenue in each country using the DENSE_RANK function.
WITH product_sale
AS
(SELECT
	store_id,
	store_name,
	country,
	SUM(net_sale) as total_revenue
FROM
global_sales
GROUP BY 1,2,3)
,product_sale_rank
AS
(SELECT
	*,
	DENSE_RANK() OVER(PARTITION BY country ORDER BY total_revenue) as d_rank
FROM
product_sale)
SELECT
	*
FROM
	product_sale_rank
WHERE 
	d_rank <4
ORDER BY 3

--10.	Identify the store with the highest revenue in each country.
WITH product_sale
AS
(SELECT
	store_id,
	store_name,
	country,
	SUM(net_sale) as total_revenue
FROM
	global_sales
GROUP BY 1,2,3)
,product_sale_rank
AS
(
SELECT
	*,
	DENSE_RANK() OVER (PARTITION BY country ORDER BY total_revenue DESC) AS d_rank
FROM
	product_sale
)
SELECT
	*
FROM
	product_sale_rank
WHERE
	d_rank=1

--11.	Retrieve the total revenue and discount given on each product category per store.
SELECT
	store_id,
	store_name,
	category,
	SUM(net_sale) as total_revenue,
	SUM(discount_percentage) as total_discount
FROM
	global_sales
GROUP BY 1,2,3













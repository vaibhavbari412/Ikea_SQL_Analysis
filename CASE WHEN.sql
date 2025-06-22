--1.	Categorize stores based on sales performance as "High," "Medium," or "Low" using the total sales revenue.
SELECT 
	store_name,
	store_id,
	SUM(qty)AS total_sales,
	CASE
		WHEN SUM(qty)>2000 THEN 'High'
		WHEN SUM(qty) BETWEEN 500 AND 2000 THEN 'Medium'
		ELSE 'Low'
	END AS store_performance
FROM
global_sales
GROUP BY 1,2
--ORDER BY 3 DESC

--2.	Create a column indicating if the product price is above or below the average price for its category.
WITH t1
AS
(
SELECT
	category,
	AVG(unit_price) as avg_price
FROM
global_sales
GROUP BY 1
)
SELECT 
	product_id,
	product_name,
	gs.unit_price,
	t1.avg_price,
	CASE 
		WHEN gs.unit_price > t1.avg_price THEN 'High'
		ELSE 'Low'
	END AS product_performance
FROM
global_sales gs
INNER JOIN
t1
ON t1.category = gs.category

--3.Display the reorder status for each product in inventory as "Low Stock" if current stock is below the reorder level,
--otherwise "Sufficient Stock."
SELECT
	inventory_id,
	product_id,
	current_stock,
	reorder_level,
	CASE
		WHEN current_stock > reorder_level THEN 'Sufficient Stock'
		ELSE 'Low Stock'
	END AS reorder_status
FROM
inventory

--4.Identify each store’s top-selling product and categorize it as “Top Performer” or “Underperformer” 
--based on a specified sales quantity threshold.
SELECT
	product_id,
	product_name,
	SUM(qty) AS total_sale_qty,
	CASE
		WHEN SUM(qty) > 700 THEN 'Top Performer'
		ELSE 'Underperformer'
	END AS product_performance
FROM
global_sales
GROUP BY 1,2

--5.For each product, indicate if it has a "High Discount," "Moderate Discount," or "Low Discount" based on the discount percentage.
SELECT
	product_id,
	product_name,
	CASE
		WHEN (discount_percentage *100)>40 THEN 'High Discount'
		WHEN (discount_percentage *100)<40 AND (discount_percentage*100)>20 THEN 'Moderate Discount'
		ELSE 'Low Discount'
	END as product_performance
FROM
global_sales

--6.Mark stores as "Overstocked" or "Understocked" if current stock is above or below reorder level.
SELECT
	*,
	CASE
		WHEN current_stock > reorder_level THEN 'Overstocked'
		ELSE 'Understocked'
	END AS stock_chk
FROM
inventory






-- IKEA Project SCHEMA

DROP TABLE IF EXISTS inventory, sales, products, stores;

-- Product Table
CREATE TABLE products
(
	product_id VARCHAR(10) PRIMARY KEY,	
	product_name VARCHAR(35) ,
	category	VARCHAR(20),
	subcategory	VARCHAR(20),
	unit_pice FLOAT
);

-- Stores Table

CREATE TABLE stores
(
	store_id	VARCHAR(10) PRIMARY KEY,
	store_name	VARCHAR(25),
	city	VARCHAR(25),
	country VARCHAR(25)
);

-- Sales Table

CREATE TABLE sales
(
	order_id 	VARCHAR(10) PRIMARY KEY,
	order_date	DATE,
	product_id	VARCHAR(10) REFERENCES products(product_id), --FK
	qty	INT,
	discount_percentage	FLOAT,
	unit_price FLOAT,	
	store_id VARCHAR(10) REFERENCES stores(store_id) --FK
);


-- Inventory Table
CREATE TABLE inventory
(
	inventory_id SERIAL PRIMARY KEY,
	product_id	VARCHAR(10) REFERENCES products(product_id), --FK
	current_stock 	INT,
	reorder_level INT
);

SELECT 'All table created!';



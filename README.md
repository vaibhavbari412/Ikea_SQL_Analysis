
# IKEA Retail Sales SQL Project

![Project Banner Placeholder](https://github.com/vaibhavbari412/Ikea_SQL_Analysis/blob/main/Ikea-logo.png)

Welcome to the **IKEA Retail Sales SQL Project**! This project leverages a detailed dataset of millions of sales records, product inventory, and store information across IKEA's global operations. The analysis focuses on uncovering sales trends, product performance, and inventory management insights to assist in data-driven decision-making.

---

## Table of Contents
- [Introduction](#introduction)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Business Problems](#business-problems)
- [SQL Queries & Analysis](#sql-queries--analysis)
- [Getting Started](#getting-started)
- [Questions & Feedback](#questions--feedback)
- [Contact Me](#contact-me)
- [ERD (Entity-Relationship Diagram)](#erd-entity-relationship-diagram)

---

## Introduction

The IKEA Retail Sales SQL Project demonstrates the use of SQL to analyze retail data, including **sales records**, **store performance**, **product trends**, and **inventory status**. Using a robust schema, this project answers critical business questions and provides actionable insights to optimize IKEA's operational efficiency and profitability.

---

## Project Structure

1. **SQL Scripts**: Contains SQL queries to create the database schema, populate tables, and perform analyses.
2. **Dataset**: Includes sales data, product information, store details, and inventory records.
3. **Analysis**: SQL queries solve key business problems, leveraging advanced SQL techniques like joins, aggregations, and subqueries.

---

## Database Schema

### 1. **Products Table**
- **product_id**: Unique identifier for each product (Primary Key).
- **product_name**: Name of the product.
- **category**: Category to which the product belongs.
- **subcategory**: Subcategory of the product.
- **unit_price**: Price per unit of the product.

### 2. **Stores Table**
- **store_id**: Unique identifier for each store (Primary Key).
- **store_name**: Name of the store.
- **city**: City where the store is located.
- **country**: Country where the store operates.

### 3. **Sales Table**
- **order_id**: Unique identifier for each sales order (Primary Key).
- **order_date**: Date when the order was placed.
- **product_id**: Foreign key referencing the `products` table.
- **qty**: Quantity of the product sold.
- **discount_percentage**: Discount applied to the order.
- **unit_price**: Price per unit of the product at the time of sale.
- **store_id**: Foreign key referencing the `stores` table.

### 4. **Inventory Table**
- **inventory_id**: Unique identifier for each inventory record (Primary Key).
- **product_id**: Foreign key referencing the `products` table.
- **current_stock**: Current stock level of the product.
- **reorder_level**: Minimum stock level to trigger a reorder.

---

## Business Problems

This project tackles the following business problems:

---

## 🟢 Easy Level:

### 1. List Customers and Products Purchased
**Skill Used:** INNER JOIN, ORDER BY

```sql
SELECT c.customer_id, c.customer_name, p.product_name
FROM customers c
INNER JOIN sales s ON s.customer_id = c.customer_id
INNER JOIN products p ON p.product_id = s.product_id
ORDER BY c.customer_id;
```

---

### 2. Find Orders without Shipping Records
**Skill Used:** LEFT JOIN, NULL handling

```sql
SELECT s.order_id, s.product_id, sp.shipping_id, sp.delivery_status
FROM sales s
LEFT JOIN shippings sp ON sp.order_id = s.order_id
ORDER BY 3;
```

---

### 3. Categorize Store Performance Based on Sales
**Skill Used:** GROUP BY, CASE WHEN, Aggregation

```sql
SELECT store_name, store_id, SUM(qty) AS total_sales,
  CASE
    WHEN SUM(qty) > 2000 THEN 'High'
    WHEN SUM(qty) BETWEEN 500 AND 2000 THEN 'Medium'
    ELSE 'Low'
  END AS store_performance
FROM global_sales
GROUP BY 1,2;
```

---

## 🟡 Medium Level:

### 1. Average Payment Value for Customers with >3 Orders
**Skill Used:** JOIN, GROUP BY, HAVING, Aggregation

```sql
SELECT c.customer_name, COUNT(s.order_id) AS total_order,
       AVG(s.quantity * s.price_per_unit) AS avg_payment_value
FROM customers c
INNER JOIN sales s ON s.customer_id = c.customer_id
INNER JOIN payments pm ON pm.order_id = s.order_id
GROUP BY c.customer_name
HAVING COUNT(s.order_id) > 3;
```

---

### 2. Rank Products Within Each Store by Sales Quantity
**Skill Used:** CTE, DENSE_RANK, Window Functions

```sql
WITH product_sales AS (
  SELECT product_id, product_name, store_name, store_id, SUM(qty) AS quantity_sold
  FROM global_sales
  GROUP BY 1,2,3,4
)
SELECT store_name, product_name, quantity_sold,
       DENSE_RANK() OVER(PARTITION BY store_id ORDER BY quantity_sold DESC) AS d_rank
FROM product_sales;
```

---

### 3. Categorize Product Price Above/Below Category Average
**Skill Used:** CTE, JOIN, CASE WHEN, Aggregation

```sql
WITH t1 AS (
  SELECT category, AVG(unit_price) AS avg_price
  FROM global_sales
  GROUP BY 1
)
SELECT product_id, product_name, gs.unit_price, t1.avg_price,
  CASE WHEN gs.unit_price > t1.avg_price THEN 'High' ELSE 'Low' END AS product_performance
FROM global_sales gs
INNER JOIN t1 ON t1.category = gs.category;
```

---

### 4. Get First Sale of Each Product in Each Store
**Skill Used:** ROW_NUMBER, Window Functions

```sql
WITH product_sale AS (
  SELECT store_name, product_name, order_date,
         ROW_NUMBER() OVER(PARTITION BY store_id, product_id ORDER BY order_date) AS order_rk
  FROM global_sales
)
SELECT * FROM product_sale WHERE order_rk = 1;
```

---

### 5. Rank Stores by Total Revenue
**Skill Used:** RANK, Window Functions

```sql
WITH product_sales AS (
  SELECT store_id, store_name, SUM(net_sale) AS total_sales
  FROM global_sales
  GROUP BY 1,2
)
SELECT *, RANK() OVER (ORDER BY total_sales) AS d_rank
FROM product_sales;
```

---

## 🔴 Hard Level:

### 1. Find the Store with Highest Revenue in Each Country
**Skill Used:** CTE, DENSE_RANK, Partitioning

```sql
WITH product_sale AS (
  SELECT store_id, store_name, country, SUM(net_sale) AS total_revenue
  FROM global_sales
  GROUP BY 1,2,3
),
product_sale_rank AS (
  SELECT *, DENSE_RANK() OVER(PARTITION BY country ORDER BY total_revenue DESC) AS d_rank
  FROM product_sale
)
SELECT * FROM product_sale_rank WHERE d_rank = 1;
```

---

### 2. Identify Top 3 Stores by Revenue per Country
**Skill Used:** CTE, DENSE_RANK, Filtering

```sql
WITH product_sale AS (
  SELECT store_id, store_name, country, SUM(net_sale) AS total_revenue
  FROM global_sales
  GROUP BY 1,2,3
),
product_sale_rank AS (
  SELECT *, DENSE_RANK() OVER(PARTITION BY country ORDER BY total_revenue DESC) AS d_rank
  FROM product_sale
)
SELECT * FROM product_sale_rank WHERE d_rank <= 3
ORDER BY country;
```

---


## SQL Queries & Analysis

All SQL queries developed for this project are available in the above files. The queries demonstrate advanced SQL skills, including:

- Aggregations with `GROUP BY`.
- Filtering data using `WHERE` and `HAVING`.
- Joining multiple tables to uncover insights.
- Using subqueries and window functions for complex analyses.

---

## Getting Started

### Prerequisites
- PostgreSQL (or any SQL-compatible database).
- Basic knowledge of SQL.

### Steps to Run
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/ikea-sales-sql-project.git
   ```
2. **Set Up the Database**:
   - Run `schema.sql` to create the database schema.

3. **Execute Queries**:
   - Open files above and execute the queries for analysis.

---

## Questions & Feedback

Feel free to reach out with questions or suggestions. Here's an example query for reference:

### Example Query
**Question**: Retrieve the total sales revenue for each store in a specific country.
```sql
SELECT 
    s.store_name, 
    SUM(sales.qty * sales.unit_price) AS total_revenue
FROM 
    sales
JOIN 
    stores s ON sales.store_id = s.store_id
WHERE 
    s.country = 'USA'
GROUP BY 
    s.store_name
ORDER BY 
    total_revenue DESC;
```

---

## Contact Me

📧 **[Email](mailto:vaibhavbari412@gmail.com)**  
💼 **[LinkedIn](https://linkedin.com/in/yourprofile)**  

---

## ERD (Entity-Relationship Diagram)

Here’s the ERD for the IKEA Retail Sales SQL Project:

![ERD Placeholder](https://github.com/vaibhavbari412/Ikea_SQL_Analysis/blob/main/Ikea%20ERD.png)

---

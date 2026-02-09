-- ==========================================
-- PROJECT: Olist Supply Chain Risk & Recovery Diagnostic
-- AUTHOR: Muhammad Sami Ullah (Data Analyst)
-- OBJECTIVE: Identifying Revenue at Risk & Regional Logistics Bottlenecks
-- ==========================================

CREATE DATABASE IF NOT EXISTS Olist_db;
USE Olist_db;

-- 1. CLEAN SLATE
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS order_items, order_payments, products, sellers, customers, orders;

-- 2. SCHEMA DEFINITION
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);

CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(20),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value DECIMAL(12, 2)
);

CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_weight_g FLOAT
);

CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2)
);

-- 3. DATA INGESTION (BULLETPROOF VERSION)
-- Handling Error 1292 (Incorrect datetime value: '')

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_orders_dataset.csv'
INTO TABLE orders 
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS 
(order_id, customer_id, order_status, @v_purchase, @v_approved, @v_carrier, @v_customer, @v_estimated)
SET 
    order_purchase_timestamp = NULLIF(@v_purchase, ''),
    order_approved_at = NULLIF(@v_approved, ''),
    order_delivered_carrier_date = NULLIF(@v_carrier, ''),
    order_delivered_customer_date = NULLIF(@v_customer, ''),
    order_estimated_delivery_date = NULLIF(@v_estimated, '');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_customers_dataset.csv'
INTO TABLE customers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_payments_dataset.csv'
INTO TABLE order_payments FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_products_dataset.csv'
INTO TABLE products FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS 
(product_id, product_category_name, @dummy, @dummy, @dummy, @v_weight, @dummy, @dummy, @dummy)
SET product_weight_g = NULLIF(@v_weight, '');

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/olist_order_items_dataset.csv'
INTO TABLE order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;

-- 4. PERFORMANCE LAYER (Indexing for Nordic Speed)
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_delivery_date ON orders(order_delivered_customer_date);
CREATE INDEX idx_payments_order ON order_payments(order_id);

SET FOREIGN_KEY_CHECKS = 1;

-- 5. THE REVENUE AT RISK QUERY (Your Main Portfolio Weapon)
SELECT 
    c.customer_city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN p.payment_value ELSE 0 END), 2) AS revenue_at_risk,
    ROUND(SUM(o.order_delivered_customer_date > o.order_estimated_delivery_date) / COUNT(*) * 100, 2) AS late_delivery_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city
HAVING total_orders > 50
ORDER BY revenue_at_risk DESC
LIMIT 10;

-- 6. TREND ANALYSIS QUERY (The Surprise Page Logic)
-- Using the exact same business logic as the main dashboard for consistency.

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue,
    ROUND(SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN p.payment_value ELSE 0 END), 2) AS monthly_revenue_at_risk,
    ROUND(SUM(o.order_delivered_customer_date > o.order_estimated_delivery_date) / COUNT(*) * 100, 2) AS monthly_late_pct
FROM orders o
JOIN order_payments p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;
-- To verify my tables
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM payments;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM reviews;
SELECT COUNT(*) FROM sellers;

-- Handling missing values in customer table
SELECT *
FROM customers
WHERE customer_id IS NULL;

SELECT *
FROM customers
WHERE email IS NULL;

UPDATE customers
SET email = 'Unknown'
WHERE email IS NULL;

SELECT *
FROM customers
WHERE city IS NULL;

-- Handling missing values in order_items table

SELECT
COUNT(*) FILTER (WHERE item_id IS NULL) AS item_id_nulls,
COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
COUNT(*) FILTER (WHERE quantity IS NULL) AS quantity_nulls,
COUNT(*) FILTER (WHERE unit_price IS NULL) AS unit_price_nulls,
COUNT(*) FILTER (WHERE line_total IS NULL) AS line_total_nulls
FROM order_items;

SELECT *
FROM order_items
LIMIT 10;

UPDATE order_items
SET line_total = quantity * unit_price
WHERE line_total IS NULL;

UPDATE order_items
SET unit_price = line_total / quantity
WHERE unit_price IS NULL;

SELECT *
FROM order_items
WHERE unit_price IS NULL
AND line_total IS NULL;

DELETE FROM order_items
WHERE unit_price IS NULL
AND line_total IS NULL;

-- Handling missing values in orders table
SELECT
COUNT(*) FILTER (WHERE order_id IS NULL) AS orde_id_nulls,
COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id_nulls,
COUNT(*) FILTER (WHERE order_date IS NULL) AS order_date_nulls,
COUNT(*) FILTER (WHERE delivery_date IS NULL) AS delivery_date_nulls,
COUNT(*) FILTER (WHERE order_status IS NULL) AS order_status_nulls,
COUNT(*) FILTER (WHERE total_amount IS NULL) AS total_amount_nulls
FROM orders;

SELECT *
FROM orders
LIMIT 10;

UPDATE orders
SET total_amount = (
    SELECT SUM(line_total)
    FROM order_items
    WHERE order_items.order_id = orders.order_id
)
WHERE total_amount IS NULL;


SELECT COUNT(*)
FROM orders
WHERE total_amount IS NULL;

SELECT order_id, total_amount
FROM orders
WHERE total_amount IS NULL;

UPDATE orders o
SET total_amount = COALESCE((
    SELECT SUM(COALESCE(oi.line_total, 0))
    FROM order_items oi
    WHERE oi.order_id = o.order_id
), 0)
WHERE o.total_amount IS NULL;

SELECT *
FROM orders
WHERE total_amount IS NULL;
-- Missing values [null] in delivery_date was left as [null]

--Handling missing values [null]s in payments table
SELECT
COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
COUNT(*) FILTER (WHERE payment_id IS NULL) AS payment_id_nulls,
COUNT(*) FILTER (WHERE payment_method IS NULL) AS payment_method_nulls,
COUNT(*) FILTER (WHERE amount IS NULL) AS amount_nulls,
COUNT(*) FILTER (WHERE payment_date IS NULL) AS payment_date_nulls
FROM payments;

SELECT *
FROM payments
LIMIT 10;

UPDATE payments
SET amount = orders.total_amount
FROM orders
WHERE payments.order_id = orders.order_id
AND payments.amount IS NULL;

SELECT COUNT(*)
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.amount IS NULL
AND o.total_amount IS NULL;

SELECT p.order_id, p.amount, o.total_amount
FROM payments p
JOIN orders o ON p.order_id = o.order_id
WHERE p.amount IS NULL;

UPDATE orders o
SET total_amount = sub.total
FROM (
    SELECT order_id, SUM(line_total) AS total
    FROM order_items
    GROUP BY order_id
) sub
WHERE o.order_id = sub.order_id
AND o.total_amount IS NULL;

UPDATE payments
SET amount = orders.total_amount
FROM orders
WHERE payments.order_id = orders.order_id
AND payments.amount IS NULL;

SELECT COUNT(*) 
FROM payments
WHERE amount IS NULL;

UPDATE payments
SET amount = 0
WHERE amount IS NULL;

-- Handling missing values in the products table
SELECT
COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
COUNT(*) FILTER (WHERE product_name IS NULL) AS product_name_nulls,
COUNT(*) FILTER (WHERE category IS NULL) AS category_nulls,
COUNT(*) FILTER (WHERE unit_price IS NULL) AS unit_price_nulls,
COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id_nulls
FROM products;

SELECT product_id, COUNT(DISTINCT unit_price) AS price_variations
FROM order_items
GROUP BY product_id
HAVING COUNT(DISTINCT unit_price) > 1;

UPDATE products p
SET unit_price = oi.unit_price
FROM order_items oi
WHERE p.product_id = oi.product_id
AND p.unit_price IS NULL;

SELECT p.product_id
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE p.unit_price IS NULL
AND oi.product_id IS NULL;

UPDATE products p
SET unit_price = sub.avg_price
FROM (
    SELECT product_id, AVG(unit_price) AS avg_price
    FROM order_items
    GROUP BY product_id
) sub
WHERE p.product_id = sub.product_id
AND p.unit_price IS NULL;

UPDATE products
SET unit_price = 0
WHERE unit_price IS NULL;

SELECT *
FROM products
WHERE unit_price IS NULL;

--Handling missing values in reviews table
SELECT
COUNT(*) FILTER (WHERE review_id IS NULL) AS review_id_nulls,
COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulls,
COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulls,
COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulls,
COUNT(*) FILTER (WHERE review_date IS NULL) AS review_date_nulls,
COUNT(*) FILTER (WHERE rating IS NULL) AS rating_nulls
FROM reviews;

--Handling missing values in sellers table
SELECT
COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id_nulls,
COUNT(*) FILTER (WHERE seller_name IS NULL) AS seller_name_nulls,
COUNT(*) FILTER (WHERE onboarding_date IS NULL) AS onboarding_date_nulls,
COUNT(*) FILTER (WHERE product_category IS NULL) AS onboarding_date_nulls,
COUNT(*) FILTER (WHERE city IS NULL) AS city_nulls,
COUNT(*) FILTER (WHERE state IS NULL) AS state_nulls,
COUNT(*) FILTER (WHERE account_status IS NULL) AS account_status_nulls
FROM sellers;

--Checking for Duplicates in the customers table

SELECT email, COUNT(*)
FROM customers
GROUP BY email
HAVING COUNT(*) > 1;

SELECT *
FROM customers
WHERE email IN (
	SELECT email
	FROM customers
	GROUP BY email
	HAVING COUNT(*) > 1
)
ORDER BY email;

-- Removing Duplicates by using first_name and last_name
WITH ranked AS (
    SELECT customer_id,
           LOWER(first_name || '.' || last_name) AS base_email,
           ROW_NUMBER() OVER (
               PARTITION BY LOWER(first_name || '.' || last_name)
               ORDER BY customer_id
           ) AS rn
    FROM customers
)
UPDATE customers c
SET email = CASE
    WHEN r.rn = 1 THEN r.base_email || '@gmail.com'
    ELSE r.base_email || r.rn || '@gmail.com'
END
FROM ranked r
WHERE c.customer_id = r.customer_id
AND c.email IN (
    SELECT email
    FROM customers
    GROUP BY email
    HAVING COUNT(*) > 1
);

ALTER TABLE customers
ADD CONSTRAINT unique_email UNIQUE (email);

--Checking duplicates in the orders table
SELECT *
FROM orders
WHERE order_id IN (
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(*) > 1
)
ORDER BY order_id;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;
--No duplicates found using order_id

--Checking duplicates in the sellers table
SELECT seller_id, COUNT(*)
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

SELECT seller_name, COUNT(*)
FROM sellers
GROUP BY seller_name
HAVING COUNT(*) > 1;
--No duplicates found

--Checking date formatting
SELECT DISTINCT order_date
FROM orders
ORDER BY order_date;

--Checking date column type
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'orders';
--Date is in a consistent format and type

--Data Validation
SELECT 
    o.order_id,
    o.total_amount AS stored_total,
    COALESCE(SUM(oi.line_total), 0) AS calculated_total
FROM orders o
LEFT JOIN order_items oi 
    ON oi.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount IS DISTINCT FROM COALESCE(SUM(oi.line_total), 0);

SELECT 
    o.order_id,
    o.total_amount,
    COALESCE(SUM(oi.line_total), 0) AS calculated_total,
    (o.total_amount - COALESCE(SUM(oi.line_total), 0)) AS difference
FROM orders o
LEFT JOIN order_items oi 
    ON oi.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount IS DISTINCT FROM COALESCE(SUM(oi.line_total), 0)
ORDER BY ABS(o.total_amount - COALESCE(SUM(oi.line_total), 0)) DESC;

UPDATE orders o
SET total_amount = sub.total
FROM (
    SELECT order_id, SUM(line_total) AS total
    FROM order_items
    GROUP BY order_id
) sub
WHERE o.order_id = sub.order_id;
--2996 rows were updated

SELECT 
    o.order_id,
    o.total_amount,
    SUM(oi.line_total) AS calculated_total,
    (o.total_amount - SUM(oi.line_total)) AS difference,
    CASE 
        WHEN ABS(o.total_amount - SUM(oi.line_total)) > 1 THEN 'Mismatch'
        ELSE 'OK'
    END AS status
FROM orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.total_amount;
--Kept both but flagged issues. 3015 rows affected



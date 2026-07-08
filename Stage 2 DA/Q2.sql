-- Question 2: Product Performance

SELECT 
    p.product_id,
    p.product_name,
    p.category,
    
    SUM(oi.line_total) AS total_revenue,
    
    COUNT(DISTINCT oi.order_id) AS total_orders

FROM order_items oi
JOIN orders o 
    ON oi.order_id = o.order_id
JOIN products p 
    ON oi.product_id = p.product_id

WHERE o.order_date >= '2024-01-01'
  AND o.order_date < '2025-01-01'

GROUP BY 
    p.product_id, 
    p.product_name, 
    p.category

ORDER BY total_revenue DESC
LIMIT 10;

-- HP Pavilion 15 Laptop Intel i5-v2 generates the most revenue
-- Anker PowerBank 20000mAh USB-C generates the lowest revenue
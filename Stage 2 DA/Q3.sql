-- Question 3
-- Seller Fulfillment Efficiency

SELECT 
    s.seller_id,
    COUNT(DISTINCT o.order_id) AS total_completed_orders,

    AVG((o.delivery_date - o.order_date) * 24) AS avg_fulfilment_hours,

    AVG(r.rating) AS avg_customer_rating

FROM orders o

JOIN order_items oi 
ON o.order_id = oi.order_id

JOIN products p 
ON oi.product_id = p.product_id

JOIN sellers s 
ON p.seller_id = s.seller_id

LEFT JOIN reviews r 
ON o.order_id = r.order_id

WHERE o.delivery_date IS NOT NULL

GROUP BY s.seller_id

HAVING COUNT(DISTINCT o.order_id) >= 20

ORDER BY avg_fulfilment_hours ASC

LIMIT 20;

-- An avg_fulfilment_hours of 110.57 hours and total_completed_orders of 28 has an avg_customer_rating of 3.38
-- While avg_fulfilment_hours of 93.81 hours has avg_customer rating of 2.92 with 22 total_completed_orders.
-- Also, avg_fulfilment_hours of 102.32 hours has 4.17 customer rating with 37 total_completed_orders.
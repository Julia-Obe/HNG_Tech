-- Question 8
-- Top Seller Bonus Qualification

WITH seller_base AS (
    SELECT
        o.seller_id,
        COUNT(DISTINCT o.order_id) AS total_orders,
        AVG(r.rating) AS avg_rating,
        SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    LEFT JOIN reviews r
        ON o.order_id = r.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY o.seller_id
),

filtered AS (
    SELECT *
    FROM seller_base
    WHERE total_orders >= 10
      AND avg_rating >= 4.0
)

SELECT
    f.seller_id,
    s.seller_name,
    f.total_orders,
    f.avg_rating,
    f.total_revenue
FROM filtered f
JOIN sellers s
    ON f.seller_id = s.seller_id
ORDER BY f.total_revenue DESC
LIMIT 10;

-- StyleKraft NG has the highest total_order (40) with 4.2 avg_rating
-- HomeNest NG has the highest avg_rating (4.73) with 30 total_orders
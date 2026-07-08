-- Question 7
-- Review Ratings and Sales Performance

WITH product_ratings AS (
    SELECT
        p.product_id,
        p.product_name,
        AVG(r.rating) AS avg_rating
    FROM products p
    JOIN reviews r
        ON p.product_id = r.product_id
    GROUP BY p.product_id, p.product_name
),

product_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        AVG(oi.unit_price) AS avg_unit_price
    FROM order_items oi
    GROUP BY oi.product_id
),

combined AS (
    SELECT
        pr.product_id,
        pr.avg_rating,
        COALESCE(ps.revenue, 0) AS revenue,
        COALESCE(ps.avg_unit_price, 0) AS avg_unit_price
    FROM product_ratings pr
    LEFT JOIN product_sales ps
        ON pr.product_id = ps.product_id
)

SELECT
    CASE
        WHEN avg_rating >= 4.0 THEN 'High Rated'
        WHEN avg_rating >= 3.0 THEN 'Mid Rated'
        ELSE 'Low Rated'
    END AS rating_category,

    COUNT(product_id) AS product_count,
    SUM(revenue) AS total_revenue,
    AVG(avg_unit_price) AS avg_unit_price

FROM combined
GROUP BY rating_category
ORDER BY total_revenue DESC;

-- 118 products has Mid Rated reviews and highest total revenue
-- 114 products has High Rated reviews
-- 33 products has low Rated reviews with the lowest total_revenue
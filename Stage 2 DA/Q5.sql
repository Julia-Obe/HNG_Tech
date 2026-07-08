-- Question 5
-- Customer Spend Segmentation

WITH customer_spend AS (
    SELECT 
        customer_id,
        SUM(total_amount) AS total_spend
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2024
    GROUP BY customer_id
)

SELECT
    CASE
        WHEN total_spend >= 100000 THEN 'High Spenders'
        WHEN total_spend BETWEEN 50000 AND 99999 THEN 'Medium Spenders'
        ELSE 'Low Spenders'
    END AS spend_segment,

    COUNT(customer_id) AS customer_count,

    AVG(total_spend) AS avg_spend_per_customer,

    SUM(total_spend) AS total_revenue

FROM customer_spend

GROUP BY spend_segment

ORDER BY total_revenue DESC;

-- 603 high spenders with avg_spend_per_customer= 1,439,893.33
-- 25 medium spenders with avg_spend_per_customer= 68,535.99
--49 low spenders with avg_spend_per_customer= 23,433.13
-- Question 1: Customer Acquisition & 30-Day Conversion

WITH new_customers_2024 AS (
    SELECT 
        customer_id,
        state,
        signup_date
    FROM customers
    WHERE signup_date >= '2024-01-01'
      AND signup_date < '2025-01-01'
),

customer_purchases AS (
    SELECT 
        nc.customer_id,
        nc.state,
        nc.signup_date,
        MIN(o.order_date) AS first_order_date
    FROM new_customers_2024 nc
    LEFT JOIN orders o 
        ON nc.customer_id = o.customer_id
    GROUP BY nc.customer_id, nc.state, nc.signup_date
),

conversion_flag AS (
    SELECT 
        state,
        customer_id,
        CASE 
            WHEN first_order_date IS NOT NULL
             AND first_order_date <= signup_date + INTERVAL '30 days'
            THEN 1
            ELSE 0
        END AS converted_30d
    FROM customer_purchases
)

SELECT 
    state,
    COUNT(*) AS total_signups,
    SUM(converted_30d) AS converted_within_30_days,
    ROUND(
        (SUM(converted_30d)::decimal / COUNT(*)) * 100, 
        2
    ) AS conversion_rate_percentage
FROM conversion_flag
GROUP BY state
ORDER BY total_signups DESC
LIMIT 5;

-- Lagos has the highest conversion rate of 49.32%
-- Kano has the lowest customer conversion rate of 31.03%
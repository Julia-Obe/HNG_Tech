-- Question 6
-- Payment Method preferences by State

WITH payment_summary AS (
    SELECT
        c.state AS state,
        py.payment_method AS payment_method,
        COUNT(*) AS transaction_count,
        SUM(py.amount) AS total_amount
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    JOIN payments py
        ON o.order_id = py.order_id
    GROUP BY c.state, py.payment_method
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY state
            ORDER BY transaction_count DESC
        ) AS rn
    FROM payment_summary
)

SELECT
    state,
    payment_method,
    transaction_count,
    total_amount,
    CASE
        WHEN rn = 1 THEN 'Most Popular'
        ELSE NULL
    END AS most_popular_method
FROM ranked
ORDER BY state, transaction_count DESC;

-- Payment method with the highest ranking by state
WITH payment_summary AS (
    SELECT
        c.state,
        py.payment_method,
        COUNT(*) AS transaction_count,
        SUM(py.amount) AS total_amount
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    JOIN payments py ON o.order_id = py.order_id
    GROUP BY c.state, py.payment_method
),

ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY state
               ORDER BY transaction_count DESC
           ) AS rn
    FROM payment_summary
)

SELECT
    state,
    payment_method AS most_popular_payment_method,
    transaction_count,
    total_amount
FROM ranked
WHERE rn = 1
ORDER BY state;

-- Lagos has highest payment method to be card
-- FCT has highest payment method to be card
-- Kano has highest payment method to be cash on delivery
-- Oyo has highest payment method to be cash on delivery
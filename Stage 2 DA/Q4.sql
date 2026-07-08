-- Question 4
-- Quaterly Revenue Trends

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,

    SUM(total_amount) AS total_revenue,

    AVG(total_amount) AS avg_order_value,

    COUNT(order_id) AS total_orders

FROM orders

WHERE EXTRACT(YEAR FROM order_date) IN (2023, 2024)

GROUP BY year, quarter

ORDER BY year, quarter;

--Quater with the highest growth

WITH quarterly_revenue AS (

SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(QUARTER FROM order_date) AS quarter,
    SUM(total_amount) AS revenue

FROM orders

WHERE EXTRACT(YEAR FROM order_date) IN (2023, 2024)

GROUP BY year, quarter
)

SELECT
    q24.quarter,

    q23.revenue AS revenue_2023,
    q24.revenue AS revenue_2024,

    (q24.revenue - q23.revenue) AS revenue_growth

FROM quarterly_revenue q23

JOIN quarterly_revenue q24
ON q23.quarter = q24.quarter
AND q23.year = 2023
AND q24.year = 2024

ORDER BY revenue_growth DESC

LIMIT 1;

-- Quater 4 has the strongest revenue growth
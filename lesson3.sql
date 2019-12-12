-- Quiz: DATE FUNCTIONS
-- 1. Find the sales in terms of total dollars for all orders in each year, ordered from greatest to least. Do you notice any trends in the yearly sales totals?
SELECT DATE_PART ('year', occurred_at), SUM(total_amt_usd) total_usd
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Which month did Parch & Posey have the greatest sales in terms of total dollars? Are all months evenly represented by the dataset?
SELECT DATE_PART ('month', occurred_at) ord_month, SUM(total_amt_usd) total_usd
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Which year did Parch & Posey have the greatest sales in terms of total number of orders? Are all years evenly represented by the dataset?
SELECT DATE_PART ('year', occurred_at) ord_year, COUNT(id) total_ord
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Which month did Parch & Posey have the greatest sales in terms of total number of orders? Are all months evenly represented by the dataset?
SELECT DATE_PART ('month', occurred_at) ord_month, COUNT(*) total_ord
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

-- 5. In which month of which year did Walmart spend the most on gloss paper in terms of dollars?
SELECT DATE_TRUNC ('month', o.occurred_at) ord_month, SUM(o.gloss_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Quiz: CASE
-- 1. Write a query to display for each order, the account ID, total amount of the order, and the level of the order - ‘Large’ or ’Small’ - depending on if the order is $3000 or more, or smaller than $3000.
SELECT account_id, total_amt_usd,
CASE WHEN total_amt_usd >3000
THEN 'Large'
ELSE 'Small'
END
AS ord_level
FROM orders;

-- 2. Write a query to display the number of orders in each of three categories, based on the total number of items in each order. The three categories are: 'At Least 2000', 'Between 1000 and 2000' and 'Less than 1000'.
SELECT CASE WHEN total > 2000
THEN 'At Least 2000'
WHEN total BETWEEN 1000 AND 2000
THEN 'Between 1000 and 2000'
WHEN total < 1000
THEN 'Less than 1000'
END
AS ord_category,
COUNT (*) AS ord_count
FROM orders
GROUP BY 1;

-- 3. We would like to understand 3 different levels of customers based on the amount associated with their purchases. The top level includes anyone with a Lifetime Value (total sales of all orders) greater than 200,000 usd. The second level is between 200,000 and 100,000 usd. The lowest level is anyone under 100,000 usd. Provide a table that includes the level associated with each account. You should provide the account name, the total sales of all orders for the customer, and the level. Order with the top spending customers listed first.
SELECT a.name, SUM(o.total_amt_usd) total_spent, CASE WHEN SUM(o.total_amt_usd) > 200000
THEN 'top'
WHEN SUM(o.total_amt_usd) BETWEEN 200000 AND 100000
THEN 'mid'
ELSE 'low'
END
AS account_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
ORDER BY 2 DESC;

-- 4. We would now like to perform a similar calculation to the first, but we want to obtain the total amount spent by customers only in 2016 and 2017. Keep the same levels as in the previous question. Order with the top spending customers listed first.
SELECT a.name, SUM(o.total_amt_usd) total_spent, CASE WHEN 2 > 200000
THEN 'top'
WHEN 2 BETWEEN 200000 AND 100000
THEN 'mid'
ELSE 'low'
END
AS account_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE DATE_PART ('year', occurred_at) IN (2016, 2017)
GROUP BY 1
ORDER BY 2 DESC;

-- 5. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders. Create a table with the sales rep name, the total number of orders, and a column with top or not depending on if they have more than 200 orders. Place the top sales people first in your final table.
SELECT s.name, COUNT (*) num_order, CASE WHEN COUNT (*) > 200
THEN 'top'
ELSE 'not'
END
AS account_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 2 DESC;

-- 6. The previous didn't account for the middle, nor the dollar amount associated with the sales. Management decides they want to see these characteristics represented as well. We would like to identify top performing sales reps, which are sales reps associated with more than 200 orders or more than 750000 in total sales. The middle group has any rep with more than 150 orders or 500000 in sales. Create a table with the sales rep name, the total number of orders, total sales across all orders, and a column with top, middle, or low depending on this criteria. Place the top sales people based on dollar amount of sales first in your final table. You might see a few upset sales people by this criteria!
SELECT s.name, COUNT (*) num_order, SUM (o.total_amt_usd) total_spent, CASE WHEN COUNT (*) > 200 OR SUM (o.total_amt_usd) >750000
THEN 'top'
WHEN COUNT (*) > 150 OR SUM (o.total_amt_usd) > 500000
THEN 'middle'
ELSE 'low'
END
AS account_level
FROM orders o
JOIN accounts a
ON a.id = o.account_id
JOIN sales_reps s
ON a.sales_rep_id = s.id
GROUP BY 1
ORDER BY 2 DESC;
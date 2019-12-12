-- DATE FUNCTIONS QUIZ

SELECT DATE_PART ('year', occurred_at), SUM(total_amt_usd) total_usd
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

SELECT DATE_PART ('month', occurred_at) ord_month, SUM(total_amt_usd) total_usd
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

SELECT DATE_PART ('year', occurred_at) ord_year, COUNT(id) total_ord
FROM orders
GROUP BY 1
ORDER BY 2 DESC;

SELECT DATE_PART ('month', occurred_at) ord_month, COUNT(*) total_ord
FROM orders
WHERE occurred_at BETWEEN '2014-01-01' AND '2017-01-01'
GROUP BY 1
ORDER BY 2 DESC;

SELECT DATE_TRUNC ('month', o.occurred_at) ord_month, SUM(o.gloss_amt_usd) total_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
WHERE a.name = 'Walmart'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- CASE STATEMENTS QUIZ
SELECT account_id, total_amt_usd,
CASE WHEN total_amt_usd >3000
THEN 'Large'
ELSE 'Small'
END
AS ord_level
FROM orders;

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

-- LESSON 4 - SQL SUBQUERIES QUIZ
SELECT COUNT (*), DATE_TRUNC ('day', occurred_at) occur_day, channel
FROM web_events
GROUP BY 2, 3
ORDER BY 1 DESC;

SELECT AVG (events) as avg_event, channel
FROM (SELECT COUNT (*) as events, DATE_TRUNC ('day', occurred_at) occur_day, channel
FROM web_events 
GROUP BY 2, 3) sub
GROUP BY channel
ORDER BY 1 DESC;

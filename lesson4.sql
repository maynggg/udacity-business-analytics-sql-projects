-- QUIZ MORE ON SUBQUERIES
SELECT AVG (standard_qty) avg_standard, AVG (gloss_qty) avg_gloss, AVG (poster_qty) avg_poster
FROM orders
WHERE DATE_TRUNC ('month', occurred_at) =
(SELECT DATE_TRUNC ('month', MIN (occurred_at))
FROM orders);

SELECT SUM (total_amt_usd)
FROM orders
WHERE DATE_TRUNC ('month', occurred_at) =
(SELECT DATE_TRUNC ('month', MIN (occurred_at))
FROM orders);

-- QUIZ SUBQUERY MANIA
-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
SELECT sub3.sales_reps_name, sub2.region_name, sub2.max_amt
FROM
    (SELECT region_name, MAX (total_amt) max_amt
    FROM
        (SELECT s.name sales_reps_name, r.name region_name, SUM (o.total_amt_usd) total_amt
        FROM region r
        JOIN sales_reps s
        ON r.id = s.region_id
        JOIN accounts a
        ON s.id = a.sales_rep_id
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1,2
        ORDER BY 3 DESC) sub1
    GROUP BY 1) sub2

JOIN

(SELECT s.name sales_reps_name, r.name region_name, SUM (o.total_amt_usd) total_amt
    FROM region r
    JOIN sales_reps s
    ON r.id = s.region_id
    JOIN accounts a
    ON s.id = a.sales_rep_id
    JOIN orders o
    ON a.id = o.account_id
    GROUP BY 1,2
    ORDER BY 3 DESC) sub3

ON sub2.max_amt = sub3.total_amt AND sub2.region_name = sub3.region_name;

-- 2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
SELECT r.name region_name, COUNT (o.id) total_orders
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
HAVING SUM (o.total_amt_usd) =
    (SELECT MAX (total_amt) max_amt
    FROM
        (SELECT r.name region_name, SUM (o.total_amt_usd) total_amt
        FROM region r
        JOIN sales_reps s
        ON r.id = s.region_id
        JOIN accounts a
        ON s.id = a.sales_rep_id
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1) sub);

-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
SELECT COUNT(*)
FROM 
    (SELECT a.name
    FROM orders o  
    JOIN accounts a 
    ON a.id = o.account_id
    GROUP BY 1
    HAVING SUM (o.total) >
    (SELECT total 
    FROM
        (SELECT a.name, SUM (o.standard_qty) sum_standard_qty, SUM (o.total) total
        FROM accounts a 
        JOIN orders o 
        ON a.id = o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1) sub)) sub2;

-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
SELECT a.name, w.channel, COUNT (w.id)
FROM web_events w 
JOIN accounts a
ON w.account_id = a.id 
GROUP BY 1,2
HAVING a.name = 
(SELECT customer_name
FROM
    (SELECT a.name customer_name, SUM (o.total_amt_usd) total_amt_usd
    FROM accounts a 
    JOIN orders o 
    ON a.id = o.account_id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 1) sub);

-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
SELECT AVG (total_spent)
FROM 
    (SELECT a.name, SUM (o.total_amt_usd) total_spent
    FROM accounts a 
    JOIN orders o 
    ON a.id = o.account_id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10) sub 

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
SELECT AVG(avg_spent)
FROM 
    (SELECT a.name, AVG (o.total_amt_usd) avg_spent
    FROM accounts a 
    JOIN orders o 
    ON a.id = o.account_id
    GROUP BY 1
    HAVING AVG (o.total_amt_usd) > 
        (SELECT AVG(total_amt_usd) avg_all
        FROM orders)) sub; 

-- QUIZ WITH 
-- 1. Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
WITH sub1 AS (SELECT s.name sales_reps_name, r.name region_name, SUM (o.total_amt_usd) total_amt
        FROM region r
        JOIN sales_reps s
        ON r.id = s.region_id
        JOIN accounts a
        ON s.id = a.sales_rep_id
        JOIN orders o
        ON a.id = o.account_id
        GROUP BY 1,2
        ORDER BY 3 DESC),
    
    sub2 AS (SELECT region_name, MAX (total_amt) max_amt
            FROM sub1
            GROUP BY 1)
    
SELECT sub1.sales_reps_name, sub2.region_name, sub2.max_amt
FROM sub1
JOIN sub2
ON sub2.max_amt = sub1.total_amt AND sub1.region_name = sub2.region_name;

-- 2. For the region with the largest (sum) of sales total_amt_usd, how many total (count) orders were placed?
WITH sub1 AS (SELECT r.name region_name, SUM (o.total_amt_usd) total_amt
            FROM region r
            JOIN sales_reps s
            ON r.id = s.region_id
            JOIN accounts a
            ON s.id = a.sales_rep_id
            JOIN orders o
            ON a.id = o.account_id
            GROUP BY 1),
    sub2 AS (SELECT MAX (total_amt) max_amt
            FROM sub1)

SELECT r.name region_name, COUNT (o.id) total_orders
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id = a.sales_rep_id
JOIN orders o
ON a.id = o.account_id
GROUP BY 1
HAVING SUM (o.total_amt_usd) = (SELECT * FROM sub2);

-- 3. How many accounts had more total purchases than the account name which has bought the most standard_qty paper throughout their lifetime as a customer?
WITH sub1 AS (SELECT a.name, SUM (o.standard_qty) sum_standard_qty, SUM (o.total) total
        FROM accounts a 
        JOIN orders o 
        ON a.id = o.account_id
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1),
    
    sub2 AS (SELECT a.name
            FROM orders o  
            JOIN accounts a 
            ON a.id = o.account_id
            GROUP BY 1
            HAVING SUM (o.total) > (SELECT total FROM sub1))

SELECT COUNT(*)
FROM sub2

-- 4. For the customer that spent the most (in total over their lifetime as a customer) total_amt_usd, how many web_events did they have for each channel?
WITH sub1 AS (SELECT a.name customer_name, SUM (o.total_amt_usd) total_amt_usd
            FROM accounts a 
            JOIN orders o 
            ON a.id = o.account_id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 1),

SELECT a.name, w.channel, COUNT (w.id)
FROM web_events w 
JOIN accounts a
ON w.account_id = a.id 
GROUP BY 1,2
HAVING a.name = (SELECT customer_name FROM sub1);

-- 5. What is the lifetime average amount spent in terms of total_amt_usd for the top 10 total spending accounts?
WITH sub1 AS (SELECT a.name, SUM (o.total_amt_usd) total_spent
    FROM accounts a 
    JOIN orders o 
    ON a.id = o.account_id
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 10)

SELECT AVG (total_spent)
FROM sub1;

-- 6. What is the lifetime average amount spent in terms of total_amt_usd, including only the companies that spent more per order, on average, than the average of all orders.
WITH sub1 AS (SELECT AVG(total_amt_usd) avg_all
              FROM orders),

    sub2 AS (SELECT a.name, AVG (o.total_amt_usd) avg_spent
    FROM accounts a 
    JOIN orders o 
    ON a.id = o.account_id
    GROUP BY 1
    HAVING AVG (o.total_amt_usd) > (SELECT * FROM sub1))

SELECT AVG(avg_spent)
FROM sub2;
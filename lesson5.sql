-- QUIZ: LEFT & RIGHT 
-- 1. In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table.
SELECT RIGHT (website, 3) AS domain, COUNT (*) AS count_domain
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 2. There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).
SELECT LEFT (UPPER(name), 1) AS first_letter, COUNT (*) AS count_comp
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter?
SELECT SUM(nums) * 100.0 / (SUM(nums) + SUM(letters)) AS percent_numbers, SUM(letters) * 100.0 / (SUM(nums) + SUM(letters)) AS percent_letters
FROM 
    (SELECT name, CASE WHEN LEFT (UPPER(name), 1) IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
    THEN 1
    ELSE 0
    END AS nums,
    CASE WHEN LEFT (UPPER(name), 1) NOT IN ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9')
    THEN 1
    ELSE 0
    END AS letters
    FROM accounts) sub1

-- 4. Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?
SELECT SUM(vowels) * 100.0 / (SUM(vowels) + SUM(not_vowels)) AS percent_vowels, SUM(not_vowels) * 100.0 / (SUM(vowels) + SUM(not_vowels)) AS percent_not_vowels
FROM 
    (SELECT name, CASE WHEN LEFT (UPPER(name), 1) IN ('A', 'E', 'I', 'O', 'U')
    THEN 1
    ELSE 0
    END AS vowels,
    CASE WHEN LEFT (UPPER(name), 1) NOT IN ('A', 'E', 'I', 'O', 'U')
    THEN 1
    ELSE 0
    END AS not_vowels
    FROM accounts) sub1;

-- Quiz: POSITION, STRPOS, & SUBSTR
-- 1. Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.
SELECT primary_poc, LEFT (primary_poc, POSITION(' ' IN primary_poc)-1) AS first_name, RIGHT (primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name
FROM accounts;

-- 2. Now see if you can do the same thing for every rep name in the sales_reps table. Again provide first and last name columns.
SELECT name, LEFT (name, STRPOS (name, ' ') -1) AS first_name, RIGHT (name, LENGTH(name) - STRPOS (name, ' ')) AS last_name
FROM sales_reps;

-- Quiz: CONCAT
-- 1. Each company in the accounts table wants to create an email address for each primary_poc. The email address should be the first name of the primary_poc . last name primary_poc @ company name .com.
WITH sub1 AS (SELECT name, primary_poc, LEFT (primary_poc, POSITION(' ' IN primary_poc)-1) AS first_name, RIGHT (primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name
             FROM accounts)
SELECT  primary_poc, 
        first_name,
        last_name,
        CONCAT (first_name, '.', last_name, '@', name, '.com') AS poc_email
FROM sub1;

-- 2. You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your solution should be just as in question 1. 
WITH sub1 AS (SELECT name, primary_poc, LEFT (primary_poc, POSITION(' ' IN primary_poc)-1) AS first_name, RIGHT (primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name
             FROM accounts)
SELECT  primary_poc, 
        first_name,
        last_name,
        CONCAT (first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com') AS poc_email
FROM sub1;

-- 3. We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.
WITH sub1 AS (SELECT name, primary_poc, LEFT (primary_poc, POSITION(' ' IN primary_poc) -1) AS first_name, RIGHT (primary_poc, LENGTH(primary_poc) - POSITION(' ' IN primary_poc)) AS last_name
             FROM accounts)
SELECT first_name, last_name, CONCAT (LEFT (LOWER(first_name), 1), RIGHT (LOWER(first_name), 1), LEFT (LOWER(last_name), 1), RIGHT (LOWER(last_name), 1), LENGTH(first_name), LENGTH(last_name), REPLACE (UPPER(name), ' ', '')) AS passwords
FROM sub1;

-- Quiz: CAST
-- What is the correct format of dates in SQL?
-- yyyy-mm-dd

-- Write a query to change the date into the correct SQL date format
WITH sub1 AS    (SELECT  date, 
                SUBSTR(date, 1, 2) AS extract_month, 
                SUBSTR(date, 4, 2) AS extract_day, 
                SUBSTR(date, 7, 4) AS extract_year,
                SUBSTR(date, 7, 4) || '-' || SUBSTR(date, 1, 2) || '-' || SUBSTR(date, 4, 2) AS correct_date_format
                FROM sf_crime_data)

SELECT  date, correct_date_format, 
        CAST (correct_date_format AS date) AS convert_data_type,
        correct_date_format :: date AS convert_data_type_alt
FROM sub1;

-- Quiz: COALESCE
-- 2. Fill in the accounts.id column with the account.id for the NULL value
SELECT COALESCE(a.id) fill_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, o.*
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- 3. Fill in the orders.account_id column with the account.id for the NULL value
SELECT COALESCE(a.id) fill_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- 4. Fill in each of the qty and usd columns with 0
SELECT COALESCE(a.id) fill_id, a.name, a.website, a.lat, a.long, a.primary_poc, a.sales_rep_id, COALESCE(o.account_id, a.id) account_id, o.occurred_at, COALESCE(o.standard_qty, 0) standard_qty, COALESCE(o.gloss_qty, 0) gloss_qty, COALESCE(o.poster_qty, 0) poster_qty, COALESCE(o.total, 0) total, COALESCE(o.standard_amt_usd,0) standard_amt_usd, COALESCE(o.gloss_amt_usd,0) gloss_amt_usd, COALESCE(o.poster_amt_usd,0) poster_amt_usd, COALESCE(o.total_amt_usd,0) total_amt_usd
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id
WHERE o.total IS NULL;

-- 5. COUNT the number of ids
SELECT COUNT(*)
FROM accounts a
LEFT JOIN orders o
ON a.id = o.account_id;
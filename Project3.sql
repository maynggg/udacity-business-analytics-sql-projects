-- QUESTION SET 2

SELECT c.Email, c.FirstName, c.LastName, g.Name
FROM Customer c
JOIN Invoice i
ON c.CustomerId = i.CustomerId
JOIN InvoiceLine il
ON i.InvoiceId = il.InvoiceId
JOIN Track t
ON il.TrackId = t.TrackId
JOIN Genre g
ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY 1, 2, 3
ORDER BY 1;

SELECT a.ArtistId, a.Name, COUNT (t.TrackId) AS songs
FROM Artist a
JOIN Album al
ON a.ArtistId = al.ArtistId
JOIN track t
ON al.AlbumId = t.AlbumId
JOIN Genre g
ON t.GenreId = g.GenreId
WHERE g.Name = 'Rock'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10; 

SELECT a.ArtistId, a.Name, SUM(il.UnitPrice*il.Quantity) AS Amount
FROM Artist a
JOIN Album al
ON a.ArtistId = al.ArtistId
JOIN track t
ON al.AlbumId = t.AlbumId
JOIN InvoiceLine il
ON t.TrackId = il.TrackId
GROUP BY 1, 2
ORDER BY 3 DESC; 

SELECT a.ArtistId, a.Name, c.CustomerId, c.FirstName, c.LastName, SUM(il.UnitPrice*il.Quantity) AS amount_spent
FROM Artist a
JOIN Album al
ON a.ArtistId = al.ArtistId
JOIN track t
ON al.AlbumId = t.AlbumId
JOIN InvoiceLine il
ON t.TrackId = il.TrackId
JOIN Invoice i
ON il.InvoiceId = i.InvoiceId
JOIN Customer c
ON i.CustomerId = c.CustomerId
WHERE a.ArtistId = 90
GROUP BY 1, 2, 3, 4, 5
ORDER BY 6 DESC; 

-- QUESTION SET 3
-- QUESTION 1 

SELECT sub2.GenreId, sub2.Name, sub2.BillingCountry, sub2.Purchases
FROM
(
    SELECT sub.GenreId, sub.Name, sub.BillingCountry, MAX (sub.Purchases) Purchases
    FROM 
    (
        SELECT g.GenreId, g.Name, i.BillingCountry, SUM (il.Quantity) Purchases
            FROM Genre g
            JOIN track t
            ON g.GenreId = t.GenreId
            JOIN InvoiceLine il
            ON t.TrackId = il.TrackId
            JOIN Invoice i
            ON il.InvoiceId = i.InvoiceId
            GROUP BY 1, 2, 3) sub
GROUP BY sub.BillingCountry) max_purchase

JOIN 
(
	SELECT g.GenreId, g.Name, i.BillingCountry, SUM (il.Quantity) Purchases
	FROM Genre g
    JOIN track t
    ON g.GenreId = t.GenreId
    JOIN InvoiceLine il
    ON t.TrackId = il.TrackId
    JOIN Invoice i
    ON il.InvoiceId = i.InvoiceId
    GROUP BY 1, 2, 3) sub2
ON sub2.BillingCountry = max_purchase.BillingCountry AND sub2.Purchases = max_purchase.Purchases;

-- QUESTION SET 3
-- QUESTION 2
SELECT Name, Milliseconds
FROM Track
WHERE Milliseconds > 
	(SELECT AVG (Milliseconds)
	FROM Track)
ORDER BY Milliseconds DESC; 

-- QUESTION SET 3
-- QUESTION 3
SELECT sub2.Country, sub2.total_spent, sub2.FirstName, sub2.LastName, sub2.CustomerId
FROM
(
SELECT sub.Country, MAX(sub.total_spent) total_spent, sub.FirstName, sub.LastName, sub.CustomerId
FROM 
(
	SELECT c.Country, SUM(i.total) total_spent, c.FirstName, c.LastName, c.CustomerId
	FROM Customer c
	JOIN Invoice i 
	ON c.CustomerId = i.CustomerId	
	GROUP BY 1,3,4,5) sub
GROUP BY 1
) max_total_spent

JOIN (
	SELECT c.Country, SUM(i.total) total_spent, c.FirstName, c.LastName, c.CustomerId
	FROM Customer c
	JOIN Invoice i 
	ON c.CustomerId = i.CustomerId	
	GROUP BY 1,3,4,5) sub2
ON sub2.Country = max_total_spent.Country AND sub2.total_spent = max_total_spent.total_spent;


-- PROJECT PRESENTATION
-- QUESTION 1: Which countries have the highest amount of purchases of MPEG audio file? 

SELECT i.BillingCountry, m.Name, SUM (il.Quantity) Purchases
FROM Invoice i
JOIN InvoiceLine il
ON i.InvoiceId = il.InvoiceId
JOIN Track t
ON il.TrackId = t.TrackId
JOIN MediaType m 
ON t.MediaTypeId = m.MediaTypeId
WHERE m.Name = "MPEG audio file"
GROUP BY 1,2
ORDER BY 3 DESC;

-- PROJECT PRESENTATION
-- QUESTION 2: Which employees support the most customers?

SELECT e.EmployeeId, e.FirstName || ' ' || e.LastName EmployeeName, COUNT (c.CustomerId) SupportingTotal
FROM Employee e
JOIN Customer c
ON e.EmployeeId = c.SupportRepId
GROUP BY 1
ORDER BY 2 DESC;

-- PROJECT PRESENTATION
-- QUESTION 3: Which artists have the most number of Pop songs? 
SELECT a.Name, COUNT (t.TrackId) No_Of_Songs
FROM Artist a
JOIN Album al
ON a.ArtistId = al.ArtistId
JOIN Track t
ON al.AlbumId = t.AlbumId
JOIN Genre g
ON t.GenreId = g.GenreId 
WHERE g.Name = "Pop"
GROUP BY 1
ORDER BY 2 DESC;

-- PROJECT PRESENTATION
-- QUESTION 4: How many artists are there per each income level (with the income from the music store higher than the average artist income considered as "High", equal to the average as "Average" and lower than average as "Low")

SELECT sub2.Income_Level, COUNT (*) AS Number_Of_Artists
FROM
(
    SELECT a.ArtistId, a.Name, il.UnitPrice * il.Quantity AS Income,  CASE 
    WHEN il.UnitPrice * il.Quantity > (
            SELECT AVG(il.UnitPrice * il.Quantity)
            FROM InvoiceLine il
    )
    THEN "High"
    WHEN il.UnitPrice * il.Quantity = (
            SELECT AVG(il.UnitPrice * il.Quantity)
            FROM InvoiceLine il
    )
    THEN "Average"
    ELSE "Low"
    END
    AS Income_Level
    FROM Artist a
    JOIN Album al
    ON a.ArtistId = al.ArtistId
    JOIN Track t
    ON al.AlbumId = t.AlbumId
    JOIN Genre g
    ON t.GenreId = g.GenreId 
    JOIN InvoiceLine il
    ON t.TrackId = il.TrackId 
    GROUP BY 1,2) sub2
GROUP BY sub2.Income_Level;
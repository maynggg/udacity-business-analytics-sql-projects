-- QUESTION SET 2
-- Use your query to return the email, first name, last name, and Genre of all Rock Music listeners. Return your list ordered alphabetically by email address starting with A.
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

-- 2. Write a query that returns the Artist name and total track count of the top 10 rock bands.
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

-- 3. Find which artist has earned the most according to the InvoiceLines? 
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

-- 4. Find which customer spent the most on this artist.
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
-- 1. find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres.
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

-- 2. Return all the track names that have a song length longer than the average song length
SELECT Name, Milliseconds
FROM Track
WHERE Milliseconds > 
	(SELECT AVG (Milliseconds)
	FROM Track)
ORDER BY Milliseconds DESC; 

-- 3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.
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
-- 1. Which countries have the highest amount of purchases of MPEG audio file? 
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

-- 2. Which employees support the most customers?

SELECT e.EmployeeId, e.FirstName || ' ' || e.LastName EmployeeName, COUNT (c.CustomerId) SupportingTotal
FROM Employee e
JOIN Customer c
ON e.EmployeeId = c.SupportRepId
GROUP BY 1
ORDER BY 2 DESC;

-- 3. Which artists have the most number of Pop songs? 
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

-- 4. How many artists are there per each income level (with the income from the music store higher than the average artist income considered as "High", equal to the average as "Average" and lower than average as "Low")
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
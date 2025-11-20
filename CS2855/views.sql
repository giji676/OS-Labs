CREATE VIEW query1 AS
SELECT name, price 
FROM item 
WHERE seller = 'jemma123' 
ORDER BY price DESC;

CREATE VIEW query2 AS
SELECT DISTINCT i.name
FROM item i
JOIN rating r ON i.id = r.item_id
WHERE r.stars >= 3
ORDER BY i.name ASC;

CREATE VIEW query3 AS
SELECT
    i.name AS item_name,
    MAX(r.date_time) AS most_recent_rating,
    ROUND(AVG(r.stars)::numeric, 2) AS average_stars
FROM item i
JOIN rating r ON i.id = r.item_id
GROUP BY i.id, i.name
ORDER BY average_stars ASC;

CREATE VIEW query4 AS
SELECT
    c.name AS customer_name,
    i.name AS item_name,
    MAX(r.stars) AS highest_star,
    MIN(r.stars) AS lowest_star
FROM rating r
JOIN item i ON r.item_id = i.id
JOIN customer c ON r.customer_id = c.id
GROUP BY c.id, c.name, i.id, i.name
HAVING COUNT(r.id) > 1
ORDER BY customer_name ASC;

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

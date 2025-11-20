SELECT
    i.name AS item_name,
    MAX(r.date_time) AS most_recent_rating,
    ROUND(AVG(r.stars)::numeric, 2) AS average_stars
FROM item i
JOIN rating r ON i.id = r.item_id
GROUP BY i.id, i.name
ORDER BY average_stars ASC;

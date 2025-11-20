SELECT DISTINCT i.name
FROM item i
JOIN rating r ON i.id = r.item_id
WHERE r.stars >= 3
ORDER BY i.name ASC;

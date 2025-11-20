INSERT INTO item (name, seller, price) VALUES
    ('apple', 'jemma123', 0.85),
    ('grape', 'alice', 1.05),
    ('banana', 'jemma123', 1.00),
    ('carrot', 'bob', 0.40),
    ('pear', 'john', 0.99);

INSERT INTO customer (name, postcode) VALUES
    ('Alice Ali', 'AL1 2AA'),
    ('Charlie Cha', 'CH2 3AB'),
    ('David Dav', 'DA3 4BB'),
    ('Ethan Eth', 'E4 5BC'),
    ('Ross Ro', 'R55 6CC');

INSERT INTO rating (item_id, customer_id, date_time, stars) VALUES
    (1, 1, '2025-11-01 10:00:00', 5),
    (1, 2, '2025-11-02 12:30:00', 4),
    (2, 3, '2025-11-03 15:45:00', 3),
    (3, 4, '2025-11-04 09:20:00', 2),
    (4, 5, '2025-11-05 18:10:00', 1),
    (2, 1, '2025-11-06 11:00:00', 2),
    (2, 1, '2025-11-07 13:05:00', 5),
    (1, 3, '2025-11-07 14:00:00', 3);

INSERT INTO invoice (item_id, customer_id, quantity, cost) VALUES
    (1, 1, 2, 1.70),
    (2, 2, 1, 1.05),
    (3, 3, 3, 3.00),
    (4, 4, 1, 0.40),
    (5, 5, 2, 0.98);

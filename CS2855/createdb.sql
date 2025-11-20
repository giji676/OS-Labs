CREATE TABLE item (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    seller TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE customer (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    postcode TEXT NOT NULL
);

CREATE TABLE rating (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    date_time TIMESTAMP NOT NULL,
    stars NUMERIC(2,1) NOT NULL CHECK (stars >= 0 AND stars <= 5),
    CONSTRAINT fk_item FOREIGN KEY (item_id) REFERENCES item(id),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customer(id)
);

CREATE TABLE invoice (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL,
    customer_id INTEGER NOT NULL,
    quantity NUMERIC(3,0) NOT NULL CHECK (quantity >= 1 AND quantity <= 100),
    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
    CONSTRAINT fk_item FOREIGN KEY (item_id) REFERENCES item(id),
    CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES customer(id)
);

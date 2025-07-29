-- Create customers table
CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE,
  phone VARCHAR(20)
);

-- Create orders table
CREATE TABLE orders (
  order_id SERIAL PRIMARY KEY,
  customer_id INT NOT NULL,
  product VARCHAR(100),
  amount NUMERIC(10,2),
  order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Insert sample customers
INSERT INTO customers (name, email, phone) VALUES
('Alice Johnson', 'alice@example.com', '555-1234'),
('Bob Smith', 'bob@example.com', '555-5678'),
('Charlie Brown', 'charlie@example.com', '555-9012');

-- Insert sample orders
INSERT INTO orders (customer_id, product, amount) VALUES
(1, 'Wireless Mouse', 25.50),
(1, 'Mechanical Keyboard', 70.00),
(2, 'USB Headset', 40.00),
(3, 'Webcam', 55.75),
(3, 'Gaming Mouse Pad', 15.25);

-- Create index on customer_id in orders table for performance
CREATE INDEX idx_customer_id ON orders(customer_id);

-- Create a view to show customer orders
CREATE VIEW customer_orders AS
SELECT c.customer_id, c.name, o.order_id, o.product, o.amount, o.order_date
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;
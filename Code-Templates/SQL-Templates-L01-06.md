# Code-Templates für Lektionen 1-6

## Template 1: Datenbank Setup

```sql
-- ==================================================
-- Template: Basic Database Setup
-- ==================================================

-- Datenbank erstellen und auswählen
DROP DATABASE IF EXISTS my_database;
CREATE DATABASE my_database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE my_database;

-- Beispiel-Tabelle
CREATE TABLE example_table (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Testdaten einfügen
INSERT INTO example_table (name) VALUES ('Test 1'), ('Test 2');

-- Abfrage testen
SELECT * FROM example_table;
```

## Template 2: Tabelle mit Foreign Key

```sql
-- ==================================================
-- Template: Related Tables with Foreign Keys
-- ==================================================

-- Parent Table
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB;

-- Child Table with Foreign Key
CREATE TABLE products (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    category_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CHECK (price > 0)
) ENGINE=InnoDB;

-- Test Data
INSERT INTO categories (name, description) VALUES
    ('Electronics', 'Electronic devices'),
    ('Books', 'Printed books');

INSERT INTO products (name, price, category_id) VALUES
    ('Laptop', 999.99, 1),
    ('Database Book', 49.90, 2);
```

## Template 3: N:M Relationship

```sql
-- ==================================================
-- Template: Many-to-Many Relationship
-- ==================================================

-- Table 1
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
) ENGINE=InnoDB;

-- Table 2
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    credits INT
) ENGINE=InnoDB;

-- Junction Table
CREATE TABLE enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade DECIMAL(3,1),
    
    FOREIGN KEY (student_id) REFERENCES students(id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(id)
        ON DELETE CASCADE,
    
    UNIQUE KEY unique_enrollment (student_id, course_id)
) ENGINE=InnoDB;

-- Test Data
INSERT INTO students (name, email) VALUES
    ('Anna Müller', 'anna@hftm.ch'),
    ('Peter Schmidt', 'peter@hftm.ch');

INSERT INTO courses (name, credits) VALUES
    ('Databases', 4),
    ('Web Development', 3);

INSERT INTO enrollments (student_id, course_id, grade) VALUES
    (1, 1, 5.5),
    (1, 2, 6.0),
    (2, 1, 5.0);
```

## Template 4: CRUD Operations Template

```sql
-- ==================================================
-- Template: Complete CRUD Operations
-- ==================================================

-- CREATE (INSERT)
INSERT INTO products (name, price, category_id) VALUES
    ('New Product', 29.99, 1);

-- READ (SELECT)
-- All records
SELECT * FROM products;

-- With filter
SELECT * FROM products WHERE price > 20;

-- With JOIN
SELECT 
    p.name,
    p.price,
    c.name AS category
FROM products p
INNER JOIN categories c ON p.category_id = c.id;

-- UPDATE
UPDATE products 
SET price = price * 1.10
WHERE category_id = 1;

-- DELETE
DELETE FROM products 
WHERE price < 10;
```

## Template 5: Subqueries Template

```sql
-- ==================================================
-- Template: Subqueries
-- ==================================================

-- Subquery in WHERE
SELECT * FROM products
WHERE category_id IN (
    SELECT id FROM categories WHERE name = 'Electronics'
);

-- Subquery in FROM
SELECT 
    avg_price.category,
    avg_price.average
FROM (
    SELECT 
        c.name AS category,
        AVG(p.price) AS average
    FROM products p
    INNER JOIN categories c ON p.category_id = c.id
    GROUP BY c.id, c.name
) AS avg_price
WHERE avg_price.average > 50;

-- Correlated Subquery
SELECT p.name, p.price
FROM products p
WHERE p.price > (
    SELECT AVG(price)
    FROM products
    WHERE category_id = p.category_id
);
```

## Template 6: Aggregations Template

```sql
-- ==================================================
-- Template: Aggregations and GROUP BY
-- ==================================================

-- Basic aggregations
SELECT 
    COUNT(*) AS total_products,
    AVG(price) AS avg_price,
    MAX(price) AS max_price,
    MIN(price) AS min_price,
    SUM(price) AS total_value
FROM products;

-- GROUP BY
SELECT 
    c.name AS category,
    COUNT(p.id) AS product_count,
    AVG(p.price) AS avg_price
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY product_count DESC;

-- HAVING (filter after GROUP BY)
SELECT 
    category_id,
    COUNT(*) AS count
FROM products
GROUP BY category_id
HAVING COUNT(*) > 5;
```

## Template 7: Transactions Template

```sql
-- ==================================================
-- Template: Transactions
-- ==================================================

START TRANSACTION;

-- Multiple related operations
INSERT INTO orders (customer_id, total) VALUES (1, 0);
SET @order_id = LAST_INSERT_ID();

INSERT INTO order_items (order_id, product_id, quantity, price)
VALUES (@order_id, 10, 2, 29.99);

UPDATE products SET stock = stock - 2 WHERE id = 10;

UPDATE orders 
SET total = (SELECT SUM(quantity * price) FROM order_items WHERE order_id = @order_id)
WHERE id = @order_id;

-- If everything OK:
COMMIT;

-- If error occurred:
-- ROLLBACK;
```

## Template 8: User Permissions Template

```sql
-- ==================================================
-- Template: User Management and Permissions
-- ==================================================

-- Create user
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'secure_password';

-- Grant specific permissions
GRANT SELECT, INSERT, UPDATE ON my_database.* TO 'app_user'@'localhost';

-- Grant all permissions
GRANT ALL PRIVILEGES ON my_database.* TO 'admin_user'@'localhost';

-- Show grants
SHOW GRANTS FOR 'app_user'@'localhost';

-- Revoke permissions
REVOKE INSERT ON my_database.* FROM 'app_user'@'localhost';

-- Remove user
DROP USER 'app_user'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;
```

## Template 9: Indexes Template

```sql
-- ==================================================
-- Template: Creating Indexes
-- ==================================================

-- Simple index
CREATE INDEX idx_name ON products(name);

-- Composite index
CREATE INDEX idx_category_price ON products(category_id, price);

-- Unique index
CREATE UNIQUE INDEX idx_email ON customers(email);

-- Full-text index (for text search)
CREATE FULLTEXT INDEX idx_description ON products(description);

-- Show indexes
SHOW INDEX FROM products;

-- Drop index
DROP INDEX idx_name ON products;
```

## Template 10: Joins Overview

```sql
-- ==================================================
-- Template: All Types of JOINs
-- ==================================================

-- INNER JOIN - only matching records
SELECT p.name, c.name AS category
FROM products p
INNER JOIN categories c ON p.category_id = c.id;

-- LEFT JOIN - all from left, matching from right
SELECT c.name, COUNT(p.id) AS product_count
FROM categories c
LEFT JOIN products p ON c.id = p.category_id
GROUP BY c.id, c.name;

-- RIGHT JOIN - all from right, matching from left
SELECT p.name, c.name AS category
FROM products p
RIGHT JOIN categories c ON p.category_id = c.id;

-- CROSS JOIN - cartesian product
SELECT s.name AS student, c.name AS course
FROM students s
CROSS JOIN courses c;

-- SELF JOIN - join table with itself
SELECT 
    e1.name AS employee,
    e2.name AS manager
FROM employees e1
LEFT JOIN employees e2 ON e1.manager_id = e2.id;
```

---

## Verwendung der Templates

1. **Kopiere** das gewünschte Template
2. **Passe** die Namen und Datentypen an deine Bedürfnisse an
3. **Teste** das Template in einer Test-Datenbank
4. **Erweitere** nach Bedarf mit zusätzlichen Features

## Best Practices

✅ **Immer verwenden:**
- Prepared Statements (?) für User-Input
- Foreign Key Constraints für Beziehungen
- NOT NULL wo sinnvoll
- Sinnvolle Datentypen (DECIMAL für Geld!)
- Indexes auf häufig gesuchten Spalten

❌ **Vermeiden:**
- SELECT * in Production
- VARCHAR ohne Limit
- Fehlende PRIMARY KEYs
- Keine Backups
- SQL Injection Risiken

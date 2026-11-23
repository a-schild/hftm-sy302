-- ================================================
-- HFTM Library Database - Complete Setup
-- Version: 1.0
-- Date: 2024-12-15
-- ================================================

-- Drop database if exists and create fresh
DROP DATABASE IF EXISTS hftm_library;
CREATE DATABASE hftm_library CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hftm_library;

-- ================================================
-- Table: places
-- ================================================
CREATE TABLE places (
    id INT PRIMARY KEY AUTO_INCREMENT,
    zip VARCHAR(10) NOT NULL,
    city VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_zip_city (zip, city)
) ENGINE=InnoDB;

-- ================================================
-- Table: authors
-- ================================================
CREATE TABLE authors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    birth_date DATE,
    email VARCHAR(100),
    address VARCHAR(255),
    location_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES places(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_lastname (lastname),
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- ================================================
-- Table: publishers
-- ================================================
CREATE TABLE publishers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    address VARCHAR(255),
    email VARCHAR(100),
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_name (name)
) ENGINE=InnoDB;

-- ================================================
-- Table: genres
-- ================================================
CREATE TABLE genres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    genre VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ================================================
-- Table: books
-- ================================================
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    author_id INT,
    publisher_id INT,
    genre_id INT,
    published_date DATE,
    price DECIMAL(10,2),
    amount_in_stock INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES publishers(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_title (title),
    INDEX idx_isbn (isbn),
    INDEX idx_author (author_id),
    INDEX idx_publisher (publisher_id),
    CHECK (price >= 0),
    CHECK (amount_in_stock >= 0)
) ENGINE=InnoDB;

-- ================================================
-- Table: customers
-- ================================================
CREATE TABLE customers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    firstname VARCHAR(50) NOT NULL,
    lastname VARCHAR(50) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    address VARCHAR(255),
    location_id INT,
    registration_date DATE DEFAULT (CURRENT_DATE),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (location_id) REFERENCES places(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_lastname (lastname),
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- ================================================
-- Table: lends
-- ================================================
CREATE TABLE lends (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    book_id INT NOT NULL,
    date_from DATE NOT NULL,
    date_to DATE NOT NULL,
    returned BOOLEAN DEFAULT FALSE,
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_customer (customer_id),
    INDEX idx_book (book_id),
    INDEX idx_dates (date_from, date_to),
    CHECK (date_to > date_from),
    CHECK (price >= 0)
) ENGINE=InnoDB;

-- ================================================
-- Table: authors_publishers (N:M)
-- ================================================
CREATE TABLE authors_publishers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    author_id INT NOT NULL,
    publisher_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (publisher_id) REFERENCES publishers(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE KEY unique_author_publisher (author_id, publisher_id)
) ENGINE=InnoDB;

-- ================================================
-- Table: authors_genres (N:M)
-- ================================================
CREATE TABLE authors_genres (
    id INT PRIMARY KEY AUTO_INCREMENT,
    author_id INT NOT NULL,
    genre_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE KEY unique_author_genre (author_id, genre_id)
) ENGINE=InnoDB;

-- ================================================
-- INSERT TEST DATA
-- ================================================

-- Places
INSERT INTO places (zip, city) VALUES
('3000', 'Bern'),
('8000', 'Zürich'),
('1200', 'Genève'),
('4000', 'Basel'),
('6900', 'Lugano'),
('OX1', 'Oxford'),
('WC2', 'London'),
('10001', 'New York');

-- Publishers
INSERT INTO publishers (name, address, email, phone) VALUES
('Penguin Random House', '1745 Broadway, New York', 'info@penguinrandomhouse.com', '+1-212-782-9000'),
('HarperCollins', '195 Broadway, New York', 'info@harpercollins.com', '+1-212-207-7000'),
('Simon & Schuster', '1230 Avenue of the Americas', 'info@simonandschuster.com', '+1-212-698-7000'),
('Macmillan Publishers', '120 Broadway, New York', 'info@macmillan.com', '+1-646-307-5151'),
('Hachette Book Group', '1290 Avenue of the Americas', 'info@hachettebookgroup.com', '+1-212-364-1100'),
('Diogenes Verlag', 'Sprecherstrasse 8, Zürich', 'info@diogenes.ch', '+41-44-254-8511'),
('Suhrkamp Verlag', 'Pappelallee 78-79, Berlin', 'info@suhrkamp.de', '+49-30-74076-0');

-- Genres
INSERT INTO genres (genre, description) VALUES
('Fiction', 'Literary fiction and novels'),
('Science Fiction', 'Speculative fiction about future and technology'),
('Fantasy', 'Stories with magic and imaginary worlds'),
('Mystery', 'Detective and crime fiction'),
('Thriller', 'Suspenseful and exciting stories'),
('Romance', 'Love stories'),
('Historical Fiction', 'Stories set in the past'),
('Biography', 'Life stories of real people'),
('Self-Help', 'Personal development books'),
('Science', 'Scientific non-fiction');

-- Authors
INSERT INTO authors (firstname, lastname, birth_date, email, location_id) VALUES
('George', 'Orwell', '1903-06-25', 'orwell@classic.lit', 7),
('J.K.', 'Rowling', '1965-07-31', 'jk.rowling@hogwarts.com', 7),
('Stephen', 'King', '1947-09-21', 'stephen.king@horror.com', 8),
('Agatha', 'Christie', '1890-09-15', 'agatha@mystery.co.uk', 6),
('Isaac', 'Asimov', '1920-01-02', 'asimov@scifi.com', 8),
('J.R.R.', 'Tolkien', '1892-01-03', 'tolkien@middleearth.com', 6),
('Dan', 'Brown', '1964-06-22', 'dan.brown@thriller.com', 8),
('Paulo', 'Coelho', '1947-08-24', 'paulo@alchemist.com', NULL),
('Friedrich', 'Dürrenmatt', '1921-01-05', 'duerrenmatt@swiss.lit', 1),
('Max', 'Frisch', '1911-05-15', 'max.frisch@swiss.lit', 2);

-- Books
INSERT INTO books (title, isbn, author_id, publisher_id, genre_id, published_date, price, amount_in_stock) VALUES
('1984', '978-0-452-28423-4', 1, 1, 1, '1949-06-08', 18.90, 25),
('Animal Farm', '978-0-452-28424-1', 1, 1, 1, '1945-08-17', 16.50, 30),
('Harry Potter and the Philosophers Stone', '978-0-7475-3269-9', 2, 2, 3, '1997-06-26', 24.90, 50),
('Harry Potter and the Chamber of Secrets', '978-0-7475-3849-3', 2, 2, 3, '1998-07-02', 24.90, 45),
('Harry Potter and the Prisoner of Azkaban', '978-0-7475-4215-5', 2, 2, 3, '1999-07-08', 26.90, 40),
('The Shining', '978-0-385-12167-5', 3, 3, 5, '1977-01-28', 22.50, 15),
('It', '978-0-670-81302-8', 3, 3, 5, '1986-09-15', 28.90, 20),
('Murder on the Orient Express', '978-0-00-711931-9', 4, 2, 4, '1934-01-01', 19.90, 12),
('And Then There Were None', '978-0-00-711932-6', 4, 2, 4, '1939-11-06', 18.90, 18),
('Foundation', '978-0-553-29335-0', 5, 4, 2, '1951-06-01', 21.90, 25),
('I Robot', '978-0-553-38256-5', 5, 4, 2, '1950-12-02', 20.50, 22),
('The Hobbit', '978-0-345-33968-3', 6, 1, 3, '1937-09-21', 24.90, 35),
('The Lord of the Rings', '978-0-345-33970-6', 6, 1, 3, '1954-07-29', 45.00, 30),
('The Da Vinci Code', '978-0-385-50420-1', 7, 3, 5, '2003-03-18', 26.90, 40),
('Angels and Demons', '978-0-671-02735-3', 7, 3, 5, '2000-05-01', 24.90, 35),
('The Alchemist', '978-0-06-112241-5', 8, 2, 1, '1988-01-01', 19.90, 45),
('Der Richter und sein Henker', '978-3-257-23047-7', 9, 6, 4, '1950-12-15', 16.90, 20),
('Die Physiker', '978-3-257-23050-7', 9, 6, 1, '1962-02-21', 14.90, 25),
('Homo Faber', '978-3-518-36854-7', 10, 7, 1, '1957-09-01', 18.50, 18),
('Stiller', '978-3-518-36840-0', 10, 7, 1, '1954-11-01', 19.90, 15);

-- Customers
INSERT INTO customers (firstname, lastname, email, phone, address, location_id, registration_date) VALUES
('Anna', 'Müller', 'anna.mueller@email.ch', '079 123 45 67', 'Bahnhofstrasse 10', 1, '2023-01-15'),
('Peter', 'Schmidt', 'peter.schmidt@email.ch', '078 234 56 78', 'Hauptstrasse 25', 2, '2023-02-20'),
('Maria', 'Garcia', 'maria.garcia@email.ch', '076 345 67 89', 'Seestrasse 42', 3, '2023-03-10'),
('Hans', 'Weber', 'hans.weber@email.ch', '077 456 78 90', 'Dorfstrasse 8', 4, '2023-04-05'),
('Sophie', 'Meyer', 'sophie.meyer@email.ch', '079 567 89 01', 'Bergweg 15', 1, '2023-05-12'),
('Luca', 'Bernasconi', 'luca.bernasconi@email.ch', '078 678 90 12', 'Via Nassa 33', 5, '2023-06-18'),
('Emma', 'Fischer', 'emma.fischer@email.ch', '076 789 01 23', 'Alte Landstrasse 7', 2, '2023-07-22'),
('Noah', 'Keller', 'noah.keller@email.ch', '077 890 12 34', 'Wiesenweg 19', 1, '2023-08-30');

-- Lends (some current, some past, some overdue)
INSERT INTO lends (customer_id, book_id, date_from, date_to, returned, price) VALUES
(1, 3, '2024-11-01', '2024-11-15', TRUE, 5.00),
(1, 12, '2024-11-20', '2024-12-04', FALSE, 5.00),
(2, 1, '2024-11-15', '2024-11-29', TRUE, 5.00),
(2, 14, '2024-12-01', '2024-12-15', FALSE, 5.00),
(3, 6, '2024-10-20', '2024-11-03', FALSE, 5.00),
(4, 16, '2024-12-05', '2024-12-19', FALSE, 5.00),
(5, 7, '2024-11-10', '2024-11-24', TRUE, 5.00),
(6, 13, '2024-12-01', '2024-12-15', FALSE, 5.00),
(7, 9, '2024-11-25', '2024-12-09', FALSE, 5.00),
(8, 4, '2024-12-10', '2024-12-24', FALSE, 5.00);

-- Authors-Publishers relationships
INSERT INTO authors_publishers (author_id, publisher_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 2),
(5, 4),
(6, 1),
(7, 3),
(8, 2),
(9, 6),
(10, 7);

-- Authors-Genres relationships
INSERT INTO authors_genres (author_id, genre_id) VALUES
(1, 1),
(1, 2),
(2, 3),
(3, 5),
(4, 4),
(5, 2),
(6, 3),
(7, 5),
(8, 1),
(9, 1),
(9, 4),
(10, 1);

-- ================================================
-- Useful Queries for Testing
-- ================================================

-- Show all tables
-- SHOW TABLES;

-- Show table structures
-- DESCRIBE books;
-- DESCRIBE authors;
-- DESCRIBE customers;

-- Test queries
-- SELECT * FROM books LIMIT 5;
-- SELECT * FROM authors WHERE location_id IS NOT NULL;
-- SELECT b.title, a.lastname FROM books b INNER JOIN authors a ON b.author_id = a.id;

-- ================================================
-- END OF SETUP
-- ================================================

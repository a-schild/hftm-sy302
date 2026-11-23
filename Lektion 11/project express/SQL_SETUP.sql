-- Datenbank erstellen
CREATE DATABASE IF NOT EXISTS library_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE library_db;

-- Tabellen werden automatisch von Sequelize erstellt!
-- Diese SQL-Datei ist nur zur Referenz

-- Authors Tabelle
CREATE TABLE IF NOT EXISTS authors (
    author_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(100),
    birth_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Books Tabelle
CREATE TABLE IF NOT EXISTS books (
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    isbn VARCHAR(20) UNIQUE,
    publication_year INT,
    pages INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Categories Tabelle
CREATE TABLE IF NOT EXISTS categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Book_Categories Verknüpfungstabelle (N:M)
CREATE TABLE IF NOT EXISTS book_categories (
    book_id INT,
    category_id INT,
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
);

-- Beispieldaten einfügen
INSERT INTO authors (name, country, birth_year) VALUES
('J.R.R. Tolkien', 'England', 1892),
('George Orwell', 'England', 1903),
('Jane Austen', 'England', 1775),
('Hermann Hesse', 'Deutschland', 1877);

INSERT INTO categories (name, description) VALUES
('Fantasy', 'Fantasy- und Fantastikliteratur'),
('Klassiker', 'Literarische Klassiker'),
('Science Fiction', 'Science-Fiction Literatur'),
('Roman', 'Romane verschiedener Genres'),
('Dystopie', 'Dystopische Literatur');

INSERT INTO books (title, author_id, isbn, publication_year, pages) VALUES
('Der Hobbit', 1, '978-3-423-21212-0', 1937, 336),
('Der Herr der Ringe', 1, '978-3-608-93830-2', 1954, 1216),
('1984', 2, '978-3-548-23440-9', 1949, 336),
('Farm der Tiere', 2, '978-3-257-20057-7', 1945, 144),
('Stolz und Vorurteil', 3, '978-3-15-010926-0', 1813, 432),
('Der Steppenwolf', 4, '978-3-518-36675-9', 1927, 288);

-- Bücher mit Kategorien verknüpfen
INSERT INTO book_categories (book_id, category_id) VALUES
(1, 1), -- Der Hobbit → Fantasy
(1, 2), -- Der Hobbit → Klassiker
(2, 1), -- Der Herr der Ringe → Fantasy
(2, 2), -- Der Herr der Ringe → Klassiker
(3, 3), -- 1984 → Science Fiction
(3, 5), -- 1984 → Dystopie
(3, 2), -- 1984 → Klassiker
(4, 5), -- Farm der Tiere → Dystopie
(4, 2), -- Farm der Tiere → Klassiker
(5, 2), -- Stolz und Vorurteil → Klassiker
(5, 4), -- Stolz und Vorurteil → Roman
(6, 2), -- Der Steppenwolf → Klassiker
(6, 4); -- Der Steppenwolf → Roman

-- Nützliche Queries

-- Alle Bücher mit Autor und Kategorien
SELECT
    b.book_id,
    b.title,
    a.name as author_name,
    GROUP_CONCAT(c.name) as categories
FROM books b
LEFT JOIN authors a ON b.author_id = a.author_id
LEFT JOIN book_categories bc ON b.book_id = bc.book_id
LEFT JOIN categories c ON bc.category_id = c.category_id
GROUP BY b.book_id;

-- Bücher pro Autor
SELECT
    a.name,
    COUNT(b.book_id) as book_count
FROM authors a
LEFT JOIN books b ON a.author_id = b.author_id
GROUP BY a.author_id;

-- Bücher pro Kategorie
SELECT
    c.name,
    COUNT(bc.book_id) as book_count
FROM categories c
LEFT JOIN book_categories bc ON c.category_id = bc.category_id
GROUP BY c.category_id;

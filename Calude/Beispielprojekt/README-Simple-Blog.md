# Beispielprojekt: Simple Blog System

## Projekt-Übersicht

**Name:** Simple Blog System
**Beschreibung:** Einfaches Blog-System mit Posts, Kommentaren und Kategorien
**Technologien:** MariaDB, Node.js, Express.js, HTML/CSS/JavaScript
**Niveau:** Grundlegend (geeignet für Lektionen 1-6)

---

## Datenbankdesign

### ER-Diagramm (Textformat)

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   users     │         │    posts    │         │ categories  │
│─────────────│         │─────────────│         │─────────────│
│ id (PK)     │ 1     N │ id (PK)     │ N     1 │ id (PK)     │
│ username    │─────────│ title       │─────────│ name        │
│ email       │ author  │ content     │ in      │ description │
│ password    │         │ author_id(FK│         └─────────────┘
│ created_at  │         │ category_id │
└─────────────┘         │ created_at  │
                        └─────────────┘
                              │
                              │ 1
                              │
                              │ N
                              │
                        ┌─────────────┐
                        │  comments   │
                        │─────────────│
                        │ id (PK)     │
                        │ content     │
                        │ post_id (FK)│
                        │ author_id(FK│
                        │ created_at  │
                        └─────────────┘
```

### Entitäten

**users** - Blog-Benutzer (Autoren)
**posts** - Blog-Posts
**categories** - Kategorien für Posts
**comments** - Kommentare zu Posts

### Beziehungen

- Ein User kann viele Posts schreiben (1:N)
- Ein Post gehört zu einer Kategorie (N:1)
- Ein Post kann viele Kommentare haben (1:N)
- Ein User kann viele Kommentare schreiben (1:N)

---

## SQL DDL Script

```sql
-- ================================================
-- Simple Blog System Database
-- ================================================

DROP DATABASE IF EXISTS simple_blog;
CREATE DATABASE simple_blog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE simple_blog;

-- Table: users
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email)
) ENGINE=InnoDB;

-- Table: categories
CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- Table: posts
CREATE TABLE posts (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    content TEXT NOT NULL,
    excerpt VARCHAR(500),
    author_id INT NOT NULL,
    category_id INT,
    published BOOLEAN DEFAULT FALSE,
    views INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    INDEX idx_title (title),
    INDEX idx_slug (slug),
    INDEX idx_author (author_id),
    INDEX idx_category (category_id),
    INDEX idx_published (published)
) ENGINE=InnoDB;

-- Table: comments
CREATE TABLE comments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    content TEXT NOT NULL,
    post_id INT NOT NULL,
    author_id INT NOT NULL,
    approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    INDEX idx_post (post_id),
    INDEX idx_author (author_id),
    INDEX idx_approved (approved)
) ENGINE=InnoDB;

-- ================================================
-- Test Data
-- ================================================

-- Users (passwords are just examples - in real app use bcrypt!)
INSERT INTO users (username, email, password_hash, bio) VALUES
('admin', 'admin@blog.com', '$2a$10$hash1', 'Blog Administrator'),
('john_doe', 'john@example.com', '$2a$10$hash2', 'Tech enthusiast and blogger'),
('jane_smith', 'jane@example.com', '$2a$10$hash3', 'Writer and developer');

-- Categories
INSERT INTO categories (name, description) VALUES
('Technology', 'Posts about technology and programming'),
('Lifestyle', 'Lifestyle and personal development'),
('Travel', 'Travel experiences and tips'),
('Food', 'Recipes and food reviews');

-- Posts
INSERT INTO posts (title, slug, content, excerpt, author_id, category_id, published, views) VALUES
(
    'Getting Started with MySQL',
    'getting-started-mysql',
    'MySQL is a powerful relational database management system. In this post, we will explore the basics...',
    'Learn the fundamentals of MySQL database',
    2,
    1,
    TRUE,
    150
),
(
    'Top 10 Travel Destinations 2024',
    'top-10-travel-destinations-2024',
    'Here are my top 10 travel destinations for 2024. Each place offers unique experiences...',
    'Discover amazing places to visit this year',
    3,
    3,
    TRUE,
    320
),
(
    'Healthy Breakfast Ideas',
    'healthy-breakfast-ideas',
    'Start your day right with these healthy breakfast ideas. Easy to make and delicious...',
    'Quick and nutritious breakfast recipes',
    3,
    4,
    TRUE,
    89
),
(
    'Introduction to Node.js',
    'introduction-nodejs',
    'Node.js is a JavaScript runtime built on Chromes V8 engine. Lets explore how to get started...',
    'Learn Node.js from scratch',
    2,
    1,
    FALSE,
    45
);

-- Comments
INSERT INTO comments (content, post_id, author_id, approved) VALUES
('Great article! Very helpful.', 1, 3, TRUE),
('Thanks for sharing this information.', 1, 1, TRUE),
('I visited 3 of these places last year. Highly recommend!', 2, 2, TRUE),
('Could you add more vegetarian options?', 3, 2, TRUE),
('Looking forward to the full article!', 4, 3, TRUE);

-- ================================================
-- Useful Queries
-- ================================================

-- Get all published posts with author and category
SELECT 
    p.title,
    p.excerpt,
    u.username AS author,
    c.name AS category,
    p.views,
    p.created_at
FROM posts p
INNER JOIN users u ON p.author_id = u.id
LEFT JOIN categories c ON p.category_id = c.id
WHERE p.published = TRUE
ORDER BY p.created_at DESC;

-- Get post with all comments
SELECT 
    p.title,
    cm.content AS comment,
    u.username AS commenter,
    cm.created_at AS comment_date
FROM posts p
LEFT JOIN comments cm ON p.id = cm.post_id
LEFT JOIN users u ON cm.author_id = u.id
WHERE p.id = 1 AND cm.approved = TRUE
ORDER BY cm.created_at;

-- Most viewed posts
SELECT 
    title,
    views,
    username AS author
FROM posts p
INNER JOIN users u ON p.author_id = u.id
WHERE p.published = TRUE
ORDER BY views DESC
LIMIT 5;

-- Posts per category
SELECT 
    c.name AS category,
    COUNT(p.id) AS post_count
FROM categories c
LEFT JOIN posts p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY post_count DESC;
```

---

## Projektstruktur (Dateibaum)

```
simple-blog/
├── database/
│   ├── schema.sql              # DDL Script (CREATE TABLE)
│   ├── data.sql                # Test data (INSERT)
│   └── simple_blog_dump.sql    # Complete dump
├── docs/
│   ├── README.md               # Projekt-Dokumentation
│   ├── API.md                  # API Dokumentation
│   └── er-diagram.png          # ER-Diagramm (Bild)
├── .gitignore
└── README.md
```

---

## Wichtige Queries für Credits

### Für Credit 2 (DDL)

```sql
-- Zeige alle Tabellen
SHOW TABLES;

-- Zeige Struktur einer Tabelle
DESCRIBE posts;

-- Zeige alle Indexes
SHOW INDEX FROM posts;

-- Zeige alle Foreign Keys
SELECT 
    CONSTRAINT_NAME,
    TABLE_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'simple_blog'
    AND REFERENCED_TABLE_NAME IS NOT NULL;
```

### Für Credit 3 (DML)

```sql
-- INSERT: Neuer Post
INSERT INTO posts (title, slug, content, author_id, category_id, published)
VALUES (
    'My New Post',
    'my-new-post',
    'This is the content of my new post...',
    1,
    1,
    TRUE
);

-- SELECT: Alle publizierten Posts
SELECT * FROM posts WHERE published = TRUE;

-- UPDATE: Post-Views erhöhen
UPDATE posts SET views = views + 1 WHERE id = 1;

-- DELETE: Unpublizierte Posts löschen
DELETE FROM posts WHERE published = FALSE AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### Für Credit 4 (JOINs)

```sql
-- INNER JOIN: Posts mit Autoren
SELECT 
    p.title,
    u.username,
    p.created_at
FROM posts p
INNER JOIN users u ON p.author_id = u.id;

-- LEFT JOIN: Kategorien mit Anzahl Posts
SELECT 
    c.name,
    COUNT(p.id) AS post_count
FROM categories c
LEFT JOIN posts p ON c.id = p.category_id
GROUP BY c.id, c.name;

-- Mehrfache JOINs: Posts mit allem
SELECT 
    p.title,
    u.username AS author,
    c.name AS category,
    COUNT(cm.id) AS comment_count
FROM posts p
INNER JOIN users u ON p.author_id = u.id
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN comments cm ON p.id = cm.post_id
GROUP BY p.id, p.title, u.username, c.name;
```

---

## Bewertungskriterien

### Datenbankdesign (25%)
- ✅ ER-Diagramm mit 4 Entitäten
- ✅ Mindestens 2× 1:N Beziehungen
- ✅ Alle Attribute sinnvoll
- ✅ Normalisation korrekt

### SQL Implementation (25%)
- ✅ CREATE TABLE für alle Entitäten
- ✅ Alle Constraints (PK, FK, NOT NULL)
- ✅ Sinnvolle Datentypen
- ✅ Test-Daten vorhanden

### Queries (30%)
- ✅ Mindestens 5 verschiedene SELECT-Queries
- ✅ Mindestens 2 JOINs
- ✅ Mindestens 1 Aggregation
- ✅ Alle CRUD-Operationen demonstriert

### Dokumentation (20%)
- ✅ README mit Beschreibung
- ✅ ER-Diagramm (Bild oder Text)
- ✅ SQL-Script kommentiert
- ✅ Installation Instructions

---

## Erweiterungsideen

Für fortgeschrittene Studierende:

1. **Tags für Posts** (N:M Beziehung)
2. **Like-System** für Posts
3. **User-Rollen** (Admin, Author, Reader)
4. **Post-Drafts** und Versionierung
5. **Email-Notifications** (Tabelle für Queue)
6. **Media/Images** Tabelle für Uploads

---

## Häufige Fehler vermeiden

❌ Keine PRIMARY KEYs definiert
❌ FOREIGN KEYs vergessen
❌ Keine Indexes auf häufig gesuchten Feldern
❌ VARCHAR ohne Längenangabe
❌ Keine Test-Daten
❌ Kein ER-Diagramm

✅ Alle Tabellen haben PRIMARY KEY
✅ Alle Beziehungen mit FOREIGN KEY
✅ Indexes auf username, email, slug
✅ VARCHAR mit sinnvoller Länge
✅ Min. 3 Testdaten pro Tabelle
✅ ER-Diagramm vorhanden

---

**Dieses Beispielprojekt erfüllt alle Anforderungen für Credits 2-4!**

# Projet exemple: Système de Blog Simple

## Vue d'ensemble du projet

**Nom:** Système de Blog Simple
**Description:** Système de blog simple avec posts, commentaires et catégories
**Technologies:** MariaDB, Node.js, Express.js, HTML/CSS/JavaScript
**Niveau:** Débutant (adapté pour leçons 1-6)

---

## Conception de la base de données

### Diagramme ER (format texte)

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   users     │         │    posts    │         │ categories  │
│─────────────│         │─────────────│         │─────────────│
│ id (PK)     │ 1     N │ id (PK)     │ N     1 │ id (PK)     │
│ username    │─────────│ title       │─────────│ name        │
│ email       │ auteur  │ content     │ dans    │ description │
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

### Entités

**users** - Utilisateurs du blog (auteurs)
**posts** - Articles de blog
**categories** - Catégories pour les articles
**comments** - Commentaires sur les articles

### Relations

- Un utilisateur peut écrire plusieurs posts (1:N)
- Un post appartient à une catégorie (N:1)
- Un post peut avoir plusieurs commentaires (1:N)
- Un utilisateur peut écrire plusieurs commentaires (1:N)

---

## Script SQL DDL

```sql
-- ================================================
-- Base de données Système de Blog Simple
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
-- Données de test
-- ================================================

-- Users (les mots de passe sont des exemples - en production utiliser bcrypt!)
INSERT INTO users (username, email, password_hash, bio) VALUES
('admin', 'admin@blog.com', '$2a$10$hash1', 'Administrateur du blog'),
('jean_dupont', 'jean@example.com', '$2a$10$hash2', 'Passionné de technologie et blogueur'),
('marie_martin', 'marie@example.com', '$2a$10$hash3', 'Écrivaine et développeuse');

-- Categories
INSERT INTO categories (name, description) VALUES
('Technologie', 'Articles sur la technologie et la programmation'),
('Style de vie', 'Style de vie et développement personnel'),
('Voyage', 'Expériences et conseils de voyage'),
('Cuisine', 'Recettes et critiques culinaires');

-- Posts
INSERT INTO posts (title, slug, content, excerpt, author_id, category_id, published, views) VALUES
(
    'Débuter avec MySQL',
    'debuter-avec-mysql',
    'MySQL est un système de gestion de base de données relationnelle puissant. Dans cet article, nous explorerons les bases...',
    'Apprenez les fondamentaux de MySQL',
    2,
    1,
    TRUE,
    150
),
(
    'Top 10 des destinations voyage 2024',
    'top-10-destinations-voyage-2024',
    'Voici mes 10 meilleures destinations de voyage pour 2024. Chaque endroit offre des expériences uniques...',
    'Découvrez des endroits incroyables à visiter cette année',
    3,
    3,
    TRUE,
    320
),
(
    'Idées de petits déjeuners sains',
    'idees-petits-dejeuners-sains',
    'Commencez bien votre journée avec ces idées de petits déjeuners sains. Faciles à préparer et délicieuses...',
    'Recettes de petits déjeuners rapides et nutritifs',
    3,
    4,
    TRUE,
    89
),
(
    'Introduction à Node.js',
    'introduction-nodejs',
    'Node.js est un environnement d exécution JavaScript construit sur le moteur V8 de Chrome. Explorons comment débuter...',
    'Apprenez Node.js depuis zéro',
    2,
    1,
    FALSE,
    45
);

-- Comments
INSERT INTO comments (content, post_id, author_id, approved) VALUES
('Excellent article! Très utile.', 1, 3, TRUE),
('Merci de partager ces informations.', 1, 1, TRUE),
('J ai visité 3 de ces endroits l année dernière. Je recommande vivement!', 2, 2, TRUE),
('Pourriez-vous ajouter plus d options végétariennes?', 3, 2, TRUE),
('J attends avec impatience l article complet!', 4, 3, TRUE);

-- ================================================
-- Requêtes utiles
-- ================================================

-- Obtenir tous les posts publiés avec auteur et catégorie
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

-- Obtenir un post avec tous ses commentaires
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

-- Posts les plus consultés
SELECT 
    title,
    views,
    username AS author
FROM posts p
INNER JOIN users u ON p.author_id = u.id
WHERE p.published = TRUE
ORDER BY views DESC
LIMIT 5;

-- Posts par catégorie
SELECT 
    c.name AS category,
    COUNT(p.id) AS post_count
FROM categories c
LEFT JOIN posts p ON c.id = p.category_id
GROUP BY c.id, c.name
ORDER BY post_count DESC;
```

---

## Structure du projet (arborescence)

```
simple-blog/
├── database/
│   ├── schema.sql              # Script DDL (CREATE TABLE)
│   ├── data.sql                # Données de test (INSERT)
│   └── simple_blog_dump.sql    # Dump complet
├── docs/
│   ├── README.md               # Documentation du projet
│   ├── API.md                  # Documentation API
│   └── er-diagram.png          # Diagramme ER (image)
├── .gitignore
└── README.md
```

---

## Requêtes importantes pour les Credits

### Pour Credit 2 (DDL)

```sql
-- Afficher toutes les tables
SHOW TABLES;

-- Afficher la structure d'une table
DESCRIBE posts;

-- Afficher tous les index
SHOW INDEX FROM posts;

-- Afficher toutes les Foreign Keys
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

### Pour Credit 3 (DML)

```sql
-- INSERT: Nouveau post
INSERT INTO posts (title, slug, content, author_id, category_id, published)
VALUES (
    'Mon nouveau post',
    'mon-nouveau-post',
    'Ceci est le contenu de mon nouveau post...',
    1,
    1,
    TRUE
);

-- SELECT: Tous les posts publiés
SELECT * FROM posts WHERE published = TRUE;

-- UPDATE: Augmenter les vues d'un post
UPDATE posts SET views = views + 1 WHERE id = 1;

-- DELETE: Supprimer les posts non publiés
DELETE FROM posts WHERE published = FALSE AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### Pour Credit 4 (JOINs)

```sql
-- INNER JOIN: Posts avec auteurs
SELECT 
    p.title,
    u.username,
    p.created_at
FROM posts p
INNER JOIN users u ON p.author_id = u.id;

-- LEFT JOIN: Catégories avec nombre de posts
SELECT 
    c.name,
    COUNT(p.id) AS post_count
FROM categories c
LEFT JOIN posts p ON c.id = p.category_id
GROUP BY c.id, c.name;

-- JOINs multiples: Posts avec tout
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

## Critères d'évaluation

### Conception de base de données (25%)
- ✅ Diagramme ER avec 4 entités
- ✅ Au moins 2× relations 1:N
- ✅ Tous les attributs pertinents
- ✅ Normalisation correcte

### Implémentation SQL (25%)
- ✅ CREATE TABLE pour toutes les entités
- ✅ Toutes les contraintes (PK, FK, NOT NULL)
- ✅ Types de données appropriés
- ✅ Données de test présentes

### Requêtes (30%)
- ✅ Au moins 5 requêtes SELECT différentes
- ✅ Au moins 2 JOINs
- ✅ Au moins 1 agrégation
- ✅ Toutes les opérations CRUD démontrées

### Documentation (20%)
- ✅ README avec description
- ✅ Diagramme ER (image ou texte)
- ✅ Script SQL commenté
- ✅ Instructions d'installation

---

## Idées d'extension

Pour les étudiants avancés:

1. **Tags pour les posts** (relation N:M)
2. **Système de likes** pour les posts
3. **Rôles utilisateur** (Admin, Auteur, Lecteur)
4. **Brouillons** et versioning des posts
5. **Notifications par email** (table pour la queue)
6. **Table Media/Images** pour les uploads

---

## Éviter les erreurs courantes

❌ Pas de PRIMARY KEYs définies
❌ FOREIGN KEYs oubliées
❌ Pas d'index sur les champs fréquemment recherchés
❌ VARCHAR sans spécification de longueur
❌ Pas de données de test
❌ Pas de diagramme ER

✅ Toutes les tables ont une PRIMARY KEY
✅ Toutes les relations avec FOREIGN KEY
✅ Index sur username, email, slug
✅ VARCHAR avec longueur appropriée
✅ Min. 3 données de test par table
✅ Diagramme ER présent

---

**Ce projet exemple remplit toutes les exigences pour les Credits 2-4!**

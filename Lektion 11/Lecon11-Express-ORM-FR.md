# Leçon 11: Frameworks Express & ORM

## Objectifs d'apprentissage

L'étudiant(e) est capable de...

- évaluer un framework adapté pour l'accès à la base de données
- évaluer un framework adapté pour la mise en œuvre d'une API REST
- appliquer le pattern MVC dans Express.js
- comprendre les ORM (Object-Relational Mapping) et les utiliser avec Sequelize
- créer et exécuter des migrations et des seeders de base de données
- comparer SQL brut et ORM et les utiliser de manière ciblée
- structurer le code selon les bonnes pratiques

## Qu'est-ce qu'un framework?

Un **framework** est un ensemble d'outils, de bibliothèques et de bonnes pratiques qui structurent et accélèrent le développement.

### Framework vs bibliothèque

| Bibliothèque | Framework |
|--------------|-----------|
| Le code appelle la bibliothèque | Le framework appelle le code |
| Exemple: lodash, axios | Exemple: Express, NestJS |
| Fonctions individuelles | Architecture complète |
| Plus de flexibilité | Plus de structure |

## Pattern MVC (Model-View-Controller)

**MVC** sépare le code en trois domaines de responsabilité:

```text
┌─────────────┐
│    View     │  ← Présentation (frontend, templates)
│  (Frontend) │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│ Controller  │  ← Logique métier, traitement des requêtes
│  (Routes)   │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│    Model    │  ← Modèle de données, accès à la BD
│  (Database) │
└─────────────┘
```

### Avantages du MVC

- **Separation of Concerns**: chaque couche a une tâche claire
- **Maintenabilité**: les modifications ne concernent qu'une seule couche
- **Testabilité**: chaque couche peut être testée de manière isolée
- **Réutilisabilité**: les modèles peuvent être utilisés dans plusieurs contrôleurs

## Structure de projet Express.js avec MVC

Les exemples utilisent la HFTM Library DB (MariaDB/MySQL) avec les tables `authors`, `books`, `categories` et `book_categories`. Le projet de démonstration complet se trouve dans `Lektion 11/project express/` (Sequelize) et `Lektion 11/prisma/` (Prisma).

### Structure des dossiers

```text
project/
├── src/
│   ├── models/
│   │   ├── Book.js
│   │   ├── Author.js
│   │   ├── Category.js
│   │   └── index.js
│   ├── controllers/
│   │   ├── bookController.js
│   │   ├── authorController.js
│   │   └── categoryController.js
│   ├── services/
│   │   ├── bookService.js
│   │   ├── authorService.js
│   │   └── categoryService.js
│   ├── routes/
│   │   ├── books.js
│   │   ├── authors.js
│   │   ├── categories.js
│   │   └── index.js
│   ├── middleware/
│   │   ├── errorHandler.js
│   │   └── validator.js
│   └── config/
│       └── database.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

### Couche Model

Sans ORM, le modèle encapsule les requêtes SQL (pool mysql2 de la leçon 10).

**models/Book.js**

```javascript
const db = require('../config/database');  // pool mysql2/promise

class Book {
    static async findAll() {
        const [rows] = await db.query('SELECT * FROM books');
        return rows;
    }

    static async findById(id) {
        const [rows] = await db.query(
            'SELECT * FROM books WHERE book_id = ?',
            [id]
        );
        return rows[0];
    }

    static async create(bookData) {
        const { title, author_id, isbn, publication_year, pages } = bookData;
        const [result] = await db.query(
            'INSERT INTO books (title, author_id, isbn, publication_year, pages) VALUES (?, ?, ?, ?, ?)',
            [title, author_id, isbn, publication_year, pages]
        );
        return result.insertId;
    }

    static async update(id, bookData) {
        const { title, author_id, isbn, publication_year, pages } = bookData;
        const [result] = await db.query(
            'UPDATE books SET title = ?, author_id = ?, isbn = ?, publication_year = ?, pages = ? WHERE book_id = ?',
            [title, author_id, isbn, publication_year, pages, id]
        );
        return result.affectedRows;
    }

    static async delete(id) {
        const [result] = await db.query(
            'DELETE FROM books WHERE book_id = ?',
            [id]
        );
        return result.affectedRows;
    }

    static async findByAuthor(authorName) {
        const [rows] = await db.query(
            `SELECT b.* FROM books b
             INNER JOIN authors a ON b.author_id = a.author_id
             WHERE a.name LIKE ?`,
            [`%${authorName}%`]
        );
        return rows;
    }
}

module.exports = Book;
```

### Couche Controller

**controllers/bookController.js**

```javascript
const Book = require('../models/Book');

exports.getAllBooks = async (req, res, next) => {
    try {
        const books = await Book.findAll();
        res.json(books);
    } catch (error) {
        next(error);
    }
};

exports.getBookById = async (req, res, next) => {
    try {
        const book = await Book.findById(req.params.id);

        if (!book) {
            return res.status(404).json({ error: 'Livre introuvable' });
        }

        res.json(book);
    } catch (error) {
        next(error);
    }
};

exports.createBook = async (req, res, next) => {
    try {
        const bookId = await Book.create(req.body);
        res.status(201).json({
            message: 'Livre créé avec succès',
            bookId
        });
    } catch (error) {
        next(error);
    }
};

exports.updateBook = async (req, res, next) => {
    try {
        const affected = await Book.update(req.params.id, req.body);

        if (affected === 0) {
            return res.status(404).json({ error: 'Livre introuvable' });
        }

        res.json({ message: 'Livre mis à jour avec succès' });
    } catch (error) {
        next(error);
    }
};

exports.deleteBook = async (req, res, next) => {
    try {
        const affected = await Book.delete(req.params.id);

        if (affected === 0) {
            return res.status(404).json({ error: 'Livre introuvable' });
        }

        res.status(204).send();
    } catch (error) {
        next(error);
    }
};
```

### Couche Route

**routes/books.js**

```javascript
const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');
const { validateBook } = require('../middleware/validator');

router.get('/', bookController.getAllBooks);
router.get('/:id', bookController.getBookById);
router.post('/', validateBook, bookController.createBook);
router.put('/:id', validateBook, bookController.updateBook);
router.delete('/:id', bookController.deleteBook);

module.exports = router;
```

## ORM - Object-Relational Mapping

Un **ORM** fait correspondre les tables de la base de données à des objets et traduit entre objets (code) et tables (base de données). Les requêtes SQL sont ainsi abstraites.

### Avantages des ORM

- ✅ **Code plus court et plus lisible**
- ✅ **Abstraction de la base de données** (compatibilité multi-SGBD)
- ✅ **Protection contre l'injection SQL** (paramètres automatiques)
- ✅ **Validation intégrée**
- ✅ **Migrations gérées**
- ✅ **Sécurité des types** (avec TypeScript)

### Inconvénients des ORM

- ❌ **Courbe d'apprentissage**
- ❌ **Overhead de performance**
- ❌ **Requêtes complexes difficiles**
- ❌ **Moins de contrôle** sur le SQL généré
- ❌ **La « magie » peut causer des problèmes**

## Sequelize - ORM pour Node.js

**Sequelize** est l'ORM le plus répandu pour Node.js et prend en charge MySQL, MariaDB, PostgreSQL, SQLite et MSSQL.

### Installation

```bash
npm install sequelize mysql2 dotenv   # mysql2 fonctionne aussi avec MariaDB
npm install --save-dev sequelize-cli
```

### Configuration

**config/database.js**

```javascript
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
    process.env.DB_NAME,
    process.env.DB_USER,
    process.env.DB_PASSWORD,
    {
        host: process.env.DB_HOST,
        port: process.env.DB_PORT || 3306,
        dialect: 'mysql',
        // Journaliser les requêtes SQL uniquement en développement
        logging: process.env.NODE_ENV === 'development' ? console.log : false,
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000
        },
        define: {
            timestamps: true,   // created_at / updated_at
            underscored: true   // noms de colonnes en snake_case
        }
    }
);

// Tester la connexion
const testConnection = async () => {
    try {
        await sequelize.authenticate();
        console.log('Base de données connectée');
    } catch (error) {
        console.error('Erreur de connexion:', error.message);
        process.exit(1);
    }
};

module.exports = { sequelize, testConnection };
```

### Définition de modèles avec Sequelize

**models/Book.js**

```javascript
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');

const Book = sequelize.define('Book', {
    book_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    title: {
        type: DataTypes.STRING(255),
        allowNull: false,
        validate: {
            notEmpty: true,
            len: [1, 255]
        }
    },
    author_id: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    isbn: {
        type: DataTypes.STRING(20),
        unique: true,
        validate: {
            is: /^[\d-]+$/   // uniquement chiffres et tirets
        }
    },
    publication_year: {
        type: DataTypes.INTEGER,
        validate: {
            min: 1000,
            max: new Date().getFullYear() + 1
        }
    },
    pages: {
        type: DataTypes.INTEGER,
        validate: {
            min: 1
        }
    }
}, {
    tableName: 'books',
    timestamps: true,   // created_at / updated_at
    underscored: true
});

module.exports = Book;
```

### CRUD avec Sequelize

Les exemples suivants s'exécutent à l'intérieur d'une fonction `async` (p. ex. dans un contrôleur ou un service).

```javascript
const { Book, Author } = require('./models');

// CREATE
const newBook = await Book.create({
    title: 'Der Hobbit',
    author_id: 1,
    isbn: '978-3-423-21212-0',
    publication_year: 1937,
    pages: 336
});

// READ - tous
const allBooks = await Book.findAll();

// READ - avec filtre
const tolkienBooks = await Book.findAll({
    where: { author_id: 1 }
});

// READ - un seul enregistrement
const book = await Book.findByPk(1);   // clé primaire
const hobbit = await Book.findOne({
    where: { isbn: '978-3-423-21212-0' }
});

// UPDATE - avec condition WHERE
await Book.update(
    { publication_year: 1938 },
    { where: { book_id: 1 } }
);

// UPDATE - mettre à jour une instance
book.publication_year = 1938;
await book.save();
// ou: await book.update({ publication_year: 1938 });

// DELETE - avec condition WHERE
await Book.destroy({
    where: { book_id: 1 }
});
// ou supprimer une instance: await hobbit.destroy();
```

### Requêtes avancées avec Sequelize

```javascript
const { Op } = require('sequelize');

// WHERE avec opérateurs
const modernBooks = await Book.findAll({
    where: {
        publication_year: {
            [Op.gte]: 2000,   // >= 2000
            [Op.lte]: 2024    // <= 2024
        }
    }
});

// AND
const longModernBooks = await Book.findAll({
    where: {
        [Op.and]: [
            { publication_year: { [Op.gte]: 1900 } },
            { pages: { [Op.gt]: 300 } }
        ]
    }
});

// OR
const selectedBooks = await Book.findAll({
    where: {
        [Op.or]: [
            { author_id: 1 },
            { pages: { [Op.lt]: 150 } }
        ]
    }
});

// LIKE
const hobbitBooks = await Book.findAll({
    where: {
        title: { [Op.like]: '%Hobbit%' }
    }
});

// IN
const booksOfAuthors = await Book.findAll({
    where: {
        author_id: { [Op.in]: [1, 2, 3] }
    }
});

// ORDER BY
const sortedBooks = await Book.findAll({
    order: [
        ['publication_year', 'DESC'],
        ['title', 'ASC']
    ]
});

// LIMIT et OFFSET (pagination: page 3 avec 10 entrées chacune)
const pageThree = await Book.findAll({
    limit: 10,
    offset: 20
});

// SELECT de champs spécifiques
const titles = await Book.findAll({
    attributes: ['title', 'isbn']
});
```

### Agrégations

```javascript
const { sequelize } = require('./config/database');

// COUNT
const totalBooks = await Book.count();
const tolkienCount = await Book.count({
    where: { author_id: 1 }
});

// SUM, MAX, MIN
const totalPages = await Book.sum('pages');
const maxPages = await Book.max('pages');
const oldestYear = await Book.min('publication_year');

// AVG (pas de raccourci dédié, donc aggregate)
const avgPages = await Book.aggregate('pages', 'AVG');

// GROUP BY
const booksPerAuthor = await Book.findAll({
    attributes: [
        'author_id',
        [sequelize.fn('COUNT', sequelize.col('book_id')), 'book_count']
    ],
    group: ['author_id'],
    raw: true
});
```

### Associations (relations) dans Sequelize

Les relations sont définies de manière centralisée dans **models/index.js** (comme dans le projet de démonstration).

**Relation 1:N** (un auteur a plusieurs livres) et **relation N:M** (livres et catégories via `book_categories`):

```javascript
// models/index.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Book = require('./Book');
const Author = require('./Author');
const Category = require('./Category');

// 1:N - un auteur a plusieurs livres
Author.hasMany(Book, {
    foreignKey: 'author_id',
    as: 'books'
});

Book.belongsTo(Author, {
    foreignKey: 'author_id',
    as: 'author'
});

// N:M - table de liaison
const BookCategory = sequelize.define('BookCategory', {
    book_id: { type: DataTypes.INTEGER, primaryKey: true },
    category_id: { type: DataTypes.INTEGER, primaryKey: true }
}, {
    tableName: 'book_categories',
    timestamps: false
});

Book.belongsToMany(Category, {
    through: BookCategory,
    foreignKey: 'book_id',
    otherKey: 'category_id',
    as: 'categories'
});

Category.belongsToMany(Book, {
    through: BookCategory,
    foreignKey: 'category_id',
    otherKey: 'book_id',
    as: 'books'
});

module.exports = { sequelize, Book, Author, Category, BookCategory };
```

**Utiliser les relations:**

```javascript
// Auteurs avec leurs livres
const authors = await Author.findAll({
    include: [{ model: Book, as: 'books' }]
});

// Livres avec auteur et catégories
const books = await Book.findAll({
    include: [
        { model: Author, as: 'author', attributes: ['name', 'country'] },
        { model: Category, as: 'categories', through: { attributes: [] } }
    ]
});

// Filtre sur la table liée (INNER JOIN)
const englishBooks = await Book.findAll({
    include: [{
        model: Author,
        as: 'author',
        where: { country: 'England' }
    }]
});

// Catégorie avec tous ses livres
const category = await Category.findByPk(1, {
    include: [{ model: Book, as: 'books' }]
});

// Méthodes générées par la relation N:M
const book = await Book.findByPk(1);
await book.setCategories([1, 2]);   // attribuer les catégories 1 et 2
```

### Transactions

Plusieurs opérations sont exécutées ensemble ou annulées ensemble.

```javascript
const t = await sequelize.transaction();

try {
    const book = await Book.create({
        title: 'Farm der Tiere',
        author_id: 2,
        isbn: '978-3-257-20057-7',
        publication_year: 1945,
        pages: 144
    }, { transaction: t });

    // Attribuer les catégories dans la même transaction
    await book.addCategories([2, 5], { transaction: t });

    await t.commit();

} catch (err) {
    await t.rollback();   // annuler toutes les modifications
    throw err;
}
```

## Migrations avec Sequelize

Les migrations permettent des modifications versionnées de la base de données.

### Initialiser Sequelize CLI

```bash
# Initialiser Sequelize CLI (sequelize-cli est déjà installé)
npx sequelize-cli init
```

Structure créée:

```text
project/
├── config/
│   └── config.json
├── migrations/
├── models/
└── seeders/
```

### Créer une migration

```bash
npx sequelize-cli migration:generate --name create-books-table
```

### Fichier de migration

La migration pour `authors` doit être exécutée avant celle pour `books`, car `books.author_id` y fait référence.

```javascript
// migrations/20241010120000-create-books-table.js
module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.createTable('books', {
            book_id: {
                type: Sequelize.INTEGER,
                primaryKey: true,
                autoIncrement: true
            },
            title: {
                type: Sequelize.STRING(255),
                allowNull: false
            },
            author_id: {
                type: Sequelize.INTEGER,
                allowNull: true,
                references: {
                    model: 'authors',
                    key: 'author_id'
                },
                onUpdate: 'CASCADE',
                onDelete: 'SET NULL'
            },
            isbn: {
                type: Sequelize.STRING(20),
                unique: true
            },
            publication_year: {
                type: Sequelize.INTEGER
            },
            pages: {
                type: Sequelize.INTEGER
            },
            created_at: {
                type: Sequelize.DATE,
                allowNull: false,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            },
            updated_at: {
                type: Sequelize.DATE,
                allowNull: false,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            }
        });

        // Index pour une colonne fréquemment recherchée
        await queryInterface.addIndex('books', ['title']);
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('books');
    }
};
```

### Exécuter les migrations

```bash
# Exécuter toutes les migrations
npx sequelize-cli db:migrate

# Annuler la dernière migration
npx sequelize-cli db:migrate:undo

# Annuler toutes les migrations
npx sequelize-cli db:migrate:undo:all
```

## Seeders

Les seeders remplissent la base de données avec des données d'exemple ou de test.

### Créer un seeder

```bash
npx sequelize-cli seed:generate --name demo-books
```

### Fichier seeder

```javascript
// seeders/20241010130000-demo-books.js
module.exports = {
    up: async (queryInterface, Sequelize) => {
        await queryInterface.bulkInsert('books', [
            {
                title: 'Der Hobbit',
                author_id: 1,
                isbn: '978-3-423-21212-0',
                publication_year: 1937,
                pages: 336,
                created_at: new Date(),
                updated_at: new Date()
            },
            {
                title: '1984',
                author_id: 2,
                isbn: '978-3-548-23440-9',
                publication_year: 1949,
                pages: 336,
                created_at: new Date(),
                updated_at: new Date()
            }
        ]);
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.bulkDelete('books', null, {});
    }
};
```

### Exécuter les seeders

```bash
# Exécuter tous les seeders
npx sequelize-cli db:seed:all

# Annuler tous les seeders
npx sequelize-cli db:seed:undo:all
```

## Prisma - ORM moderne

**Prisma** est un ORM plus récent avec une approche TypeScript-first. Le schéma est défini dans un fichier dédié, à partir duquel un client typé est généré.

### Installation

```bash
npm install @prisma/client
npm install -D prisma
npx prisma init
npx prisma generate   # générer le client à partir du schéma
```

### Définir le schéma

**prisma/schema.prisma**

```prisma
// Schéma complet avec catégories: Lektion 11/prisma/prisma/schema.prisma
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Author {
  id        Int      @id @default(autoincrement()) @map("author_id")
  name      String   @db.VarChar(255)
  country   String?  @db.VarChar(100)
  books     Book[]

  @@map("authors")
}

model Book {
  id              Int      @id @default(autoincrement()) @map("book_id")
  title           String   @db.VarChar(255)
  authorId        Int?     @map("author_id")
  isbn            String?  @unique @db.VarChar(20)
  publicationYear Int?     @map("publication_year")
  pages           Int?
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")
  author          Author?  @relation(fields: [authorId], references: [id], onDelete: SetNull)

  @@map("books")
}
```

### Utiliser Prisma Client

```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// CREATE (avec liaison à un auteur existant)
const newBook = await prisma.book.create({
    data: {
        title: 'Der Herr der Ringe',
        isbn: '978-3-608-93830-2',
        publicationYear: 1954,
        pages: 1216,
        author: { connect: { id: 1 } }
    }
});

// READ
const books = await prisma.book.findMany();
const book = await prisma.book.findUnique({
    where: { id: 1 }
});

// UPDATE
const updated = await prisma.book.update({
    where: { id: 1 },
    data: { publicationYear: 1938 }
});

// DELETE
await prisma.book.delete({
    where: { id: 1 }
});

// Avec relations
const author = await prisma.author.findUnique({
    where: { id: 1 },
    include: { books: true }
});
```

## Comparaison des ORM

| Fonctionnalité | Sequelize | Prisma | TypeORM |
|----------------|-----------|--------|---------|
| **TypeScript** | Pris en charge | Natif | Natif |
| **Migrations** | Oui | Oui | Oui |
| **Relations** | Bon | Excellent | Bon |
| **Performance** | Bonne | Très bonne | Bonne |
| **Courbe d'apprentissage** | Moyenne | Faible | Élevée |
| **Communauté** | Grande | En croissance | Grande |
| **Idéal pour** | JavaScript | TypeScript | TypeScript Enterprise |

## Comparaison: SQL brut vs ORM

### SQL brut

Avantages:

- ✅ Contrôle total
- ✅ Performance optimale
- ✅ Requêtes complexes faciles

Inconvénients:

- ❌ Risque d'injection SQL (si aucune requête préparée n'est utilisée)
- ❌ Plus de code
- ❌ Changement de base de données difficile

```javascript
const [books] = await pool.query(`
    SELECT b.*, a.name AS author_name
    FROM books b
    INNER JOIN authors a ON b.author_id = a.author_id
    WHERE b.pages > ?
    ORDER BY b.title
`, [300]);
```

### ORM (Sequelize)

Avantages:

- ✅ Code plus propre
- ✅ Protection contre l'injection SQL
- ✅ Migrations gérées
- ✅ Abstraction de la base de données

Inconvénients:

- ❌ Overhead de performance
- ❌ Courbe d'apprentissage
- ❌ Moins de contrôle

```javascript
const books = await Book.findAll({
    where: {
        pages: { [Op.gt]: 300 }
    },
    include: [{
        model: Author,
        as: 'author',
        attributes: ['name'],
        required: true   // INNER JOIN
    }],
    order: [['title', 'ASC']]
});
```

### Quand utiliser quoi?

**Utiliser SQL brut:**

- Requêtes très complexes
- Performance critique
- Équipe expérimentée en SQL

**Utiliser un ORM:**

- Projets de taille moyenne à grande
- Développement rapide
- Équipe mixte (juniors/seniors)

**Approche hybride:**

```javascript
const { QueryTypes } = require('sequelize');

// ORM pour le CRUD simple
const book = await Book.findByPk(1);

// SQL brut pour les analyses complexes
const stats = await sequelize.query(`
    SELECT
        c.name,
        COUNT(b.book_id) AS book_count,
        AVG(b.pages) AS avg_pages
    FROM categories c
    LEFT JOIN book_categories bc ON c.category_id = bc.category_id
    LEFT JOIN books b ON bc.book_id = b.book_id
    GROUP BY c.category_id, c.name
    HAVING book_count > :minBooks
`, {
    replacements: { minBooks: 1 },
    type: QueryTypes.SELECT
});
```

## Pattern Service Layer

Pour une logique métier complexe: une couche service entre le contrôleur et le modèle.

```text
Controller → Service → Model → Database
```

**services/bookService.js**

```javascript
const { Op } = require('sequelize');
const { Book, Author } = require('../models');

class BookService {
    async getAllBooks(filters = {}) {
        const { author, year, limit = 50 } = filters;

        const where = {};
        if (year) where.publication_year = year;

        const authorInclude = { model: Author, as: 'author', attributes: ['author_id', 'name'] };
        if (author) authorInclude.where = { name: { [Op.like]: `%${author}%` } };

        return Book.findAll({ where, include: [authorInclude], limit: Number(limit) });
    }

    async getBookWithAuthor(bookId) {
        return Book.findByPk(bookId, {
            include: [{ model: Author, as: 'author' }]
        });
    }

    async createBookWithValidation(bookData) {
        // Validation
        if (!bookData.title) {
            throw new Error('Le titre est obligatoire');
        }

        // Vérifier si l'ISBN existe déjà
        if (bookData.isbn) {
            const existing = await Book.findOne({
                where: { isbn: bookData.isbn }
            });

            if (existing) {
                throw new Error('ISBN déjà existant');
            }
        }

        // Vérifier si l'auteur existe
        if (bookData.author_id) {
            const author = await Author.findByPk(bookData.author_id);

            if (!author) {
                throw new Error('Auteur introuvable');
            }
        }

        // Créer le livre
        return Book.create(bookData);
    }
}

module.exports = new BookService();
```

**Le contrôleur utilise le service:**

```javascript
const bookService = require('../services/bookService');

exports.getAllBooks = async (req, res, next) => {
    try {
        const books = await bookService.getAllBooks(req.query);
        res.json(books);
    } catch (error) {
        next(error);
    }
};
```

## Exercices pratiques

### Exercice 1: Refactoring MVC

Restructurer le projet d'API REST existant selon le pattern MVC:

1. Créer le dossier `models/` avec les classes de modèle
2. Déplacer la logique BD des contrôleurs vers les modèles
3. Créer le dossier `services/` pour la logique métier
4. Documenter la nouvelle structure

### Exercice 2: Setup Sequelize

1. Installer Sequelize et sequelize-cli
2. Configurer la connexion
3. Définir trois modèles (Book, Author, Category)
4. Mettre en place les associations (1:N et N:M)

### Exercice 3: API avec Sequelize

Convertir l'API existante pour utiliser Sequelize:

1. Remplacer les requêtes SQL brutes par des appels Sequelize
2. Réécrire les opérations CRUD
3. Utiliser les associations (`include`)
4. Comparer les performances (avec/sans ORM)

### Exercice 4: Migrations et seeders

1. Configurer Sequelize CLI
2. Créer une migration pour chaque table
3. Exécuter les migrations et tester up/down
4. Créer et exécuter des seeders avec des données de test

## Bonnes pratiques

### 1. Configuration par environnement

```javascript
// config/config.js
module.exports = {
    development: {
        username: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME,
        host: process.env.DB_HOST,
        dialect: 'mysql'
    },
    production: {
        use_env_variable: 'DATABASE_URL',
        dialect: 'mysql',
        dialectOptions: {
            ssl: {
                require: true,
                rejectUnauthorized: true
            }
        }
    }
};
```

Pour que sequelize-cli utilise `config/config.js` au lieu de `config/config.json`, le chemin doit être indiqué dans un fichier `.sequelizerc`.

### 2. Gestion des erreurs

```javascript
// middleware/errorHandler.js
const { ValidationError, UniqueConstraintError } = require('sequelize');

module.exports = (err, req, res, next) => {
    console.error(err.stack);

    // Vérifier d'abord: UniqueConstraintError hérite de ValidationError
    if (err instanceof UniqueConstraintError) {
        return res.status(409).json({
            error: 'Enregistrement déjà existant'
        });
    }

    if (err instanceof ValidationError) {
        return res.status(400).json({
            error: 'Erreur de validation',
            details: err.errors.map(e => e.message)
        });
    }

    res.status(500).json({ error: 'Erreur interne du serveur' });
};
```

### 3. Injection de dépendances

```javascript
// controllers/BookController.js - améliorer la testabilité
class BookController {
    constructor(bookService) {
        this.bookService = bookService;
    }

    // Arrow function: "this" reste lié même comme handler de route
    getAllBooks = async (req, res, next) => {
        try {
            const books = await this.bookService.getAllBooks(req.query);
            res.json(books);
        } catch (error) {
            next(error);
        }
    };
}

module.exports = BookController;

// Production: injecter le vrai service
// const controller = new BookController(require('../services/bookService'));
// router.get('/', controller.getAllBooks);

// Test: injecter un service fictif (mock)
// const controller = new BookController({ getAllBooks: async () => [] });
```

### 4. Validation dans le modèle

```javascript
// ✅ Bon - validation au niveau du modèle
const Book = sequelize.define('Book', {
    title: {
        type: DataTypes.STRING(255),
        allowNull: false,
        validate: {
            notEmpty: true,
            len: [1, 255]
        }
    }
});

// ❌ Éviter - pas de validation
const Book = sequelize.define('Book', {
    title: DataTypes.STRING
});
```

### 5. Charger uniquement les champs nécessaires

```javascript
// ✅ Bon - charger uniquement les champs nécessaires
const books = await Book.findAll({
    attributes: ['book_id', 'title', 'pages'],
    include: [{
        model: Author,
        as: 'author',
        attributes: ['name']
    }]
});

// ❌ Éviter - toutes les colonnes de toutes les tables (SELECT *)
const books = await Book.findAll({
    include: [{ model: Author, as: 'author' }]
});
```

### 6. Index

```javascript
// ✅ Définir les index des colonnes fréquemment recherchées dans les options du modèle
const Book = sequelize.define('Book', {
    title: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    isbn: {
        type: DataTypes.STRING(20),
        unique: true   // unique crée automatiquement un index
    }
}, {
    tableName: 'books',
    indexes: [
        { fields: ['title'] }
    ]
});
```

## Résumé

### ORM vs SQL brut

| Aspect | ORM | SQL brut |
|--------|-----|----------|
| Lisibilité | ✅ Meilleure | ⚠️ Moyenne |
| Performance | ⚠️ Overhead | ✅ Optimale |
| Sécurité | ✅ Intégrée | ⚠️ Manuelle |
| Courbe d'apprentissage | ⚠️ Raide | ✅ Familière |
| Flexibilité | ⚠️ Limitée | ✅ Totale |

### Quand utiliser Sequelize

- ✅ **Projets moyens à grands**
- ✅ **Équipes mixtes**
- ✅ **Développement rapide**
- ✅ **Modifications fréquentes du schéma (migrations)**

## Devoirs

1. **Convertir votre propre API** pour utiliser Sequelize
2. **Créer des migrations** pour toutes les tables
3. **Ajouter des seeders** avec des données de test
4. **Comparer les performances**: SQL brut vs ORM

## Checklist pour le crédit 10

- [ ] Projet structuré selon le pattern MVC
- [ ] Couche Model implémentée
- [ ] Couche Controller implémentée
- [ ] Couche Routes implémentée
- [ ] ORM (Sequelize ou Prisma) intégré
- [ ] Au moins 2 modèles avec relation
- [ ] Migrations et seeders créés
- [ ] Couche Service pour la logique complexe
- [ ] Documentation de l'architecture

## Ressources supplémentaires

- [Documentation Sequelize](https://sequelize.org/)
- [Sequelize CLI](https://github.com/sequelize/cli)
- [Documentation Prisma](https://www.prisma.io/docs)
- [TypeORM](https://typeorm.io/) (alternative)
- [MVC Pattern Explained](https://www.codecademy.com/article/mvc)
- [Express Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)

## Prochaines étapes

Dans la leçon 12, nous abordons l'intégration MQTT et les thèmes de sécurité dans le projet web:

- MQTT pour l'IoT
- Authentification JWT
- Sécurité des API
- Protection contre les attaques

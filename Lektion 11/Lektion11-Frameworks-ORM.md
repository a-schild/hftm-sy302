# Lektion 11: Express Frameworks & ORM

## Lernziele

Die Studierenden können...

- ein geeignetes Framework für den DB-Zugriff evaluieren
- ein geeignetes Framework zur Umsetzung eines REST API evaluieren
- das MVC-Pattern in Express.js anwenden
- ORM (Object-Relational Mapping) verstehen und mit Sequelize einsetzen
- Datenbank-Migrationen und Seeders erstellen und ausführen
- Raw SQL und ORM vergleichen und gezielt einsetzen
- Code nach Best Practices strukturieren

## Was ist ein Framework?

Ein **Framework** ist eine Sammlung von Tools, Libraries und Best Practices, die die Entwicklung strukturieren und beschleunigen.

### Framework vs. Library

| Library | Framework |
|---------|-----------|
| Eigener Code ruft die Library auf | Framework ruft den eigenen Code auf |
| Beispiel: lodash, axios | Beispiel: Express, NestJS |
| Einzelne Funktionen | Gesamte Architektur |
| Mehr Flexibilität | Mehr Struktur |

## MVC-Pattern (Model-View-Controller)

**MVC** trennt Code in drei Verantwortungsbereiche:

```text
┌─────────────┐
│    View     │  ← Präsentation (Frontend, Templates)
│  (Frontend) │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│ Controller  │  ← Business-Logik, Request Handling
│  (Routes)   │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│    Model    │  ← Datenmodell, DB-Zugriff
│  (Database) │
└─────────────┘
```

### Vorteile von MVC

- **Separation of Concerns**: Jede Schicht hat eine klare Aufgabe
- **Wartbarkeit**: Änderungen betreffen nur eine Schicht
- **Testbarkeit**: Jede Schicht kann isoliert getestet werden
- **Wiederverwendbarkeit**: Models können in mehreren Controllern genutzt werden

## Express.js Projektstruktur mit MVC

Die Beispiele verwenden die HFTM Library DB (MariaDB/MySQL) mit den Tabellen `authors`, `books`, `categories` und `book_categories`. Das vollständige Demo-Projekt liegt in `Lektion 11/project express/` (Sequelize) bzw. `Lektion 11/prisma/` (Prisma).

### Ordnerstruktur

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

### Model Layer

Ohne ORM kapselt das Model die SQL-Queries (mysql2-Pool aus Lektion 10).

**models/Book.js**

```javascript
const db = require('../config/database');  // mysql2/promise Pool

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

### Controller Layer

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
            return res.status(404).json({ error: 'Buch nicht gefunden' });
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
            message: 'Buch erfolgreich erstellt',
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
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.json({ message: 'Buch erfolgreich aktualisiert' });
    } catch (error) {
        next(error);
    }
};

exports.deleteBook = async (req, res, next) => {
    try {
        const affected = await Book.delete(req.params.id);

        if (affected === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.status(204).send();
    } catch (error) {
        next(error);
    }
};
```

### Route Layer

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

Ein **ORM** bildet Datenbank-Tabellen auf Objekte ab und übersetzt zwischen Objekten (Code) und Tabellen (Datenbank). SQL-Queries werden dabei abstrahiert.

### Vorteile von ORMs

- ✅ **Weniger und besser lesbarer Code**
- ✅ **Abstraktion der Datenbank** (Cross-Database-Kompatibilität)
- ✅ **Schutz vor SQL Injection** (automatische Parameter)
- ✅ **Integrierte Validierung**
- ✅ **Migration-Management**
- ✅ **Typsicherheit** (bei TypeScript)

### Nachteile von ORMs

- ❌ **Lernkurve**
- ❌ **Performance-Overhead**
- ❌ **Komplexe Queries schwierig**
- ❌ **Weniger Kontrolle** über das erzeugte SQL
- ❌ **"Magic" kann zu Problemen führen**

## Sequelize - ORM für Node.js

**Sequelize** ist das verbreitetste ORM für Node.js und unterstützt MySQL, MariaDB, PostgreSQL, SQLite und MSSQL.

### Installation

```bash
npm install sequelize mysql2 dotenv   # mysql2 funktioniert auch mit MariaDB
npm install --save-dev sequelize-cli
```

### Konfiguration

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
        // SQL-Queries nur in der Entwicklung loggen
        logging: process.env.NODE_ENV === 'development' ? console.log : false,
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000
        },
        define: {
            timestamps: true,   // created_at / updated_at
            underscored: true   // Spaltennamen in snake_case
        }
    }
);

// Verbindung testen
const testConnection = async () => {
    try {
        await sequelize.authenticate();
        console.log('Datenbank verbunden');
    } catch (error) {
        console.error('Verbindungsfehler:', error.message);
        process.exit(1);
    }
};

module.exports = { sequelize, testConnection };
```

### Model-Definition mit Sequelize

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
            is: /^[\d-]+$/   // nur Ziffern und Bindestriche
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

### CRUD mit Sequelize

Die folgenden Beispiele laufen innerhalb einer `async`-Funktion (z. B. in einem Controller oder Service).

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

// READ - alle
const allBooks = await Book.findAll();

// READ - mit Filter
const tolkienBooks = await Book.findAll({
    where: { author_id: 1 }
});

// READ - ein Datensatz
const book = await Book.findByPk(1);   // Primary Key
const hobbit = await Book.findOne({
    where: { isbn: '978-3-423-21212-0' }
});

// UPDATE - mit WHERE-Bedingung
await Book.update(
    { publication_year: 1938 },
    { where: { book_id: 1 } }
);

// UPDATE - Instanz aktualisieren
book.publication_year = 1938;
await book.save();
// oder: await book.update({ publication_year: 1938 });

// DELETE - mit WHERE-Bedingung
await Book.destroy({
    where: { book_id: 1 }
});
// oder Instanz löschen: await hobbit.destroy();
```

### Erweiterte Queries mit Sequelize

```javascript
const { Op } = require('sequelize');

// WHERE mit Operatoren
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

// LIMIT und OFFSET (Pagination: Seite 3 mit je 10 Einträgen)
const pageThree = await Book.findAll({
    limit: 10,
    offset: 20
});

// SELECT bestimmte Felder
const titles = await Book.findAll({
    attributes: ['title', 'isbn']
});
```

### Aggregationen

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

// AVG (kein eigener Shortcut, daher aggregate)
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

### Beziehungen (Associations) in Sequelize

Die Beziehungen werden zentral in **models/index.js** definiert (wie im Demo-Projekt).

**1:N-Beziehung** (ein Autor hat mehrere Bücher) und **N:M-Beziehung** (Bücher und Kategorien über `book_categories`):

```javascript
// models/index.js
const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/database');
const Book = require('./Book');
const Author = require('./Author');
const Category = require('./Category');

// 1:N - ein Autor hat mehrere Bücher
Author.hasMany(Book, {
    foreignKey: 'author_id',
    as: 'books'
});

Book.belongsTo(Author, {
    foreignKey: 'author_id',
    as: 'author'
});

// N:M - Verknüpfungstabelle
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

**Beziehungen verwenden:**

```javascript
// Autoren mit ihren Büchern
const authors = await Author.findAll({
    include: [{ model: Book, as: 'books' }]
});

// Bücher mit Autor und Kategorien
const books = await Book.findAll({
    include: [
        { model: Author, as: 'author', attributes: ['name', 'country'] },
        { model: Category, as: 'categories', through: { attributes: [] } }
    ]
});

// Filter auf die verknüpfte Tabelle (INNER JOIN)
const englishBooks = await Book.findAll({
    include: [{
        model: Author,
        as: 'author',
        where: { country: 'England' }
    }]
});

// Kategorie mit allen Büchern
const category = await Category.findByPk(1, {
    include: [{ model: Book, as: 'books' }]
});

// Generierte Methoden der N:M-Beziehung
const book = await Book.findByPk(1);
await book.setCategories([1, 2]);   // Kategorien 1 und 2 zuweisen
```

### Transaktionen

Mehrere Operationen werden gemeinsam ausgeführt oder gemeinsam rückgängig gemacht.

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

    // Kategorien in derselben Transaktion zuweisen
    await book.addCategories([2, 5], { transaction: t });

    await t.commit();

} catch (err) {
    await t.rollback();   // alle Änderungen rückgängig machen
    throw err;
}
```

## Migrations mit Sequelize

Migrations ermöglichen versionierte Datenbankänderungen.

### Sequelize CLI initialisieren

```bash
# Sequelize CLI initialisieren (sequelize-cli ist bereits installiert)
npx sequelize-cli init
```

Erstellte Struktur:

```text
project/
├── config/
│   └── config.json
├── migrations/
├── models/
└── seeders/
```

### Migration erstellen

```bash
npx sequelize-cli migration:generate --name create-books-table
```

### Migration-Datei

Die Migration für `authors` muss vor jener für `books` laufen, da `books.author_id` darauf verweist.

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

        // Index für häufig gesuchte Spalte
        await queryInterface.addIndex('books', ['title']);
    },

    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('books');
    }
};
```

### Migrations ausführen

```bash
# Alle Migrations ausführen
npx sequelize-cli db:migrate

# Letzte Migration rückgängig machen
npx sequelize-cli db:migrate:undo

# Alle Migrations rückgängig machen
npx sequelize-cli db:migrate:undo:all
```

## Seeders

Seeders füllen die Datenbank mit Beispiel- oder Testdaten.

### Seeder erstellen

```bash
npx sequelize-cli seed:generate --name demo-books
```

### Seeder-Datei

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

### Seeders ausführen

```bash
# Alle Seeders ausführen
npx sequelize-cli db:seed:all

# Alle Seeders rückgängig machen
npx sequelize-cli db:seed:undo:all
```

## Prisma - Modernes ORM

**Prisma** ist ein neueres ORM mit TypeScript-First-Ansatz. Das Schema wird in einer eigenen Datei definiert, daraus wird ein typsicherer Client generiert.

### Installation

```bash
npm install @prisma/client
npm install -D prisma
npx prisma init
npx prisma generate   # Client aus dem Schema generieren
```

### Schema definieren

**prisma/schema.prisma**

```prisma
// Vollständiges Schema mit Kategorien: Lektion 11/prisma/prisma/schema.prisma
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

### Prisma Client verwenden

```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// CREATE (mit Verknüpfung zu einem bestehenden Autor)
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

// Mit Beziehungen
const author = await prisma.author.findUnique({
    where: { id: 1 },
    include: { books: true }
});
```

## ORM-Vergleich

| Feature | Sequelize | Prisma | TypeORM |
|---------|-----------|--------|---------|
| **TypeScript** | Unterstützt | Nativ | Nativ |
| **Migrations** | Ja | Ja | Ja |
| **Beziehungen** | Gut | Exzellent | Gut |
| **Performance** | Gut | Sehr gut | Gut |
| **Lernkurve** | Mittel | Niedrig | Hoch |
| **Community** | Gross | Wachsend | Gross |
| **Am besten für** | JavaScript | TypeScript | TypeScript Enterprise |

## Vergleich: Raw SQL vs. ORM

### Raw SQL

Vorteile:

- ✅ Volle Kontrolle
- ✅ Optimale Performance
- ✅ Komplexe Queries einfach umsetzbar

Nachteile:

- ❌ Risiko von SQL Injection (wenn keine Prepared Statements verwendet werden)
- ❌ Mehr Code
- ❌ Wechsel der Datenbank schwierig

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

Vorteile:

- ✅ Saubererer Code
- ✅ Schutz vor SQL Injection
- ✅ Verwaltete Migrations
- ✅ Abstraktion der Datenbank

Nachteile:

- ❌ Performance-Overhead
- ❌ Lernkurve
- ❌ Weniger Kontrolle

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

### Wann was verwenden?

**Raw SQL verwenden:**

- Sehr komplexe Queries
- Performance-kritische Stellen
- Team mit viel SQL-Erfahrung

**ORM verwenden:**

- Mittlere bis grosse Projekte
- Schnelle Entwicklung
- Gemischtes Team (Junior/Senior)

**Hybrider Ansatz:**

```javascript
const { QueryTypes } = require('sequelize');

// ORM für einfaches CRUD
const book = await Book.findByPk(1);

// Raw SQL für komplexe Auswertungen
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

## Service Layer Pattern

Für komplexe Business-Logik: Service Layer zwischen Controller und Model.

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
        // Validierung
        if (!bookData.title) {
            throw new Error('Titel ist erforderlich');
        }

        // Prüfen, ob die ISBN schon existiert
        if (bookData.isbn) {
            const existing = await Book.findOne({
                where: { isbn: bookData.isbn }
            });

            if (existing) {
                throw new Error('ISBN existiert bereits');
            }
        }

        // Prüfen, ob der Autor existiert
        if (bookData.author_id) {
            const author = await Author.findByPk(bookData.author_id);

            if (!author) {
                throw new Error('Autor nicht gefunden');
            }
        }

        // Buch erstellen
        return Book.create(bookData);
    }
}

module.exports = new BookService();
```

**Controller verwendet Service:**

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

## Praktische Übungen

### Übung 1: MVC Refactoring

Das bestehende REST-API-Projekt nach MVC-Pattern refactoren:

1. Ordner `models/` mit Model-Klassen erstellen
2. DB-Logik aus den Controllern in die Models verschieben
3. Ordner `services/` für die Business-Logik erstellen
4. Die neue Struktur dokumentieren

### Übung 2: Sequelize Setup

1. Sequelize und sequelize-cli installieren
2. Die Verbindung konfigurieren
3. Drei Models definieren (Book, Author, Category)
4. Die Beziehungen (1:N und N:M) einrichten

### Übung 3: API mit Sequelize

Das bestehende API auf Sequelize umstellen:

1. Raw-SQL-Queries durch Sequelize-Aufrufe ersetzen
2. CRUD-Operationen umschreiben
3. Beziehungen (`include`) verwenden
4. Performance vergleichen (mit/ohne ORM)

### Übung 4: Migrations und Seeders

1. Sequelize CLI einrichten
2. Für jede Tabelle eine Migration erstellen
3. Migrations ausführen und Up/Down testen
4. Seeders mit Testdaten erstellen und ausführen

## Best Practices

### 1. Environment-based Configuration

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

Damit sequelize-cli `config/config.js` statt `config/config.json` verwendet, muss der Pfad in einer `.sequelizerc`-Datei angegeben werden.

### 2. Error Handling

```javascript
// middleware/errorHandler.js
const { ValidationError, UniqueConstraintError } = require('sequelize');

module.exports = (err, req, res, next) => {
    console.error(err.stack);

    // Zuerst prüfen: UniqueConstraintError erbt von ValidationError
    if (err instanceof UniqueConstraintError) {
        return res.status(409).json({
            error: 'Datensatz existiert bereits'
        });
    }

    if (err instanceof ValidationError) {
        return res.status(400).json({
            error: 'Validierungsfehler',
            details: err.errors.map(e => e.message)
        });
    }

    res.status(500).json({ error: 'Interner Serverfehler' });
};
```

### 3. Dependency Injection

```javascript
// controllers/BookController.js - Testbarkeit verbessern
class BookController {
    constructor(bookService) {
        this.bookService = bookService;
    }

    // Arrow Function: "this" bleibt auch als Route-Handler gebunden
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

// Produktion: echten Service injizieren
// const controller = new BookController(require('../services/bookService'));
// router.get('/', controller.getAllBooks);

// Test: Mock-Service injizieren
// const controller = new BookController({ getAllBooks: async () => [] });
```

### 4. Validierung im Model

```javascript
// ✅ Gut - Validierung auf Model-Ebene
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

// ❌ Vermeiden - keine Validierung
const Book = sequelize.define('Book', {
    title: DataTypes.STRING
});
```

### 5. Nur benötigte Felder laden

```javascript
// ✅ Gut - nur benötigte Felder laden
const books = await Book.findAll({
    attributes: ['book_id', 'title', 'pages'],
    include: [{
        model: Author,
        as: 'author',
        attributes: ['name']
    }]
});

// ❌ Vermeiden - alle Spalten aller Tabellen (SELECT *)
const books = await Book.findAll({
    include: [{ model: Author, as: 'author' }]
});
```

### 6. Indexes

```javascript
// ✅ Indexes für häufig gesuchte Spalten in den Model-Optionen definieren
const Book = sequelize.define('Book', {
    title: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    isbn: {
        type: DataTypes.STRING(20),
        unique: true   // unique erzeugt automatisch einen Index
    }
}, {
    tableName: 'books',
    indexes: [
        { fields: ['title'] }
    ]
});
```

## Zusammenfassung

### ORM vs. Raw SQL

| Aspekt | ORM | Raw SQL |
|--------|-----|---------|
| Lesbarkeit | ✅ Besser | ⚠️ Mittel |
| Performance | ⚠️ Overhead | ✅ Optimal |
| Sicherheit | ✅ Eingebaut | ⚠️ Manuell |
| Lernkurve | ⚠️ Steil | ✅ Vertraut |
| Flexibilität | ⚠️ Eingeschränkt | ✅ Voll |

### Wann Sequelize verwenden

- ✅ **Mittlere bis grosse Projekte**
- ✅ **Gemischte Teams**
- ✅ **Schnelle Entwicklung**
- ✅ **Häufige Schemaänderungen (Migrations)**

## Hausaufgaben

1. **Das eigene API** auf Sequelize umstellen
2. **Migrations** für alle Tabellen erstellen
3. **Seeders** mit Testdaten hinzufügen
4. **Performance vergleichen**: Raw SQL vs. ORM

## Checkliste für Credit 10

- [ ] Projekt nach MVC-Pattern strukturiert
- [ ] Model Layer implementiert
- [ ] Controller Layer implementiert
- [ ] Routes Layer implementiert
- [ ] ORM (Sequelize oder Prisma) integriert
- [ ] Mindestens 2 Models mit Beziehung
- [ ] Migrations und Seeders erstellt
- [ ] Service Layer für komplexe Logik
- [ ] Dokumentation der Architektur

## Zusätzliche Ressourcen

- [Sequelize Dokumentation](https://sequelize.org/)
- [Sequelize CLI](https://github.com/sequelize/cli)
- [Prisma Dokumentation](https://www.prisma.io/docs)
- [TypeORM](https://typeorm.io/) (Alternative)
- [MVC Pattern Explained](https://www.codecademy.com/article/mvc)
- [Express Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)

## Nächste Schritte

In Lektion 12 geht es um MQTT-Integration und Security-Themen im Webprojekt:

- MQTT für IoT
- Authentifizierung mit JWT
- Sicherheit von APIs
- Schutz vor Angriffen

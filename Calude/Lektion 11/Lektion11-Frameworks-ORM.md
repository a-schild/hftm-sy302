# Lektion 11: Express Frameworks & ORM

## Lernziele

- Ein geeignetes Framework für den DB-Zugriff zu evaluieren
- Ein geeignetes Framework zur Umsetzung eines REST API zu evaluieren
- MVC-Pattern in Express.js anwenden
- ORM (Object-Relational Mapping) verstehen und einsetzen
- Code nach Best Practices strukturieren

## Was ist ein Framework?

Ein **Framework** ist eine Sammlung von Tools, Libraries und Best Practices, die die Entwicklung strukturieren und beschleunigen.

### Framework vs. Library

| Library | Framework |
|---------|-----------|
| Du rufst die Library auf | Framework ruft deinen Code auf |
| Beispiel: lodash, axios | Beispiel: Express, NestJS |
| Einzelne Funktionen | Gesamte Architektur |
| Mehr Flexibilität | Mehr Struktur |

## MVC-Pattern (Model-View-Controller)

**MVC** trennt Code in drei Verantwortungsbereiche:

```
┌─────────────┐
│    View     │  ← Präsentation (Frontend, Templates)
│  (Frontend) │
└──────┬──────┘
       │
       ↓
┌─────────────┐
│ Controller  │  ← Business Logic, Request Handling
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

### Ordnerstruktur

```
project/
├── src/
│   ├── models/
│   │   ├── Book.js
│   │   ├── Author.js
│   │   └── User.js
│   ├── controllers/
│   │   ├── bookController.js
│   │   ├── authorController.js
│   │   └── userController.js
│   ├── routes/
│   │   ├── books.js
│   │   ├── authors.js
│   │   └── users.js
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── errorHandler.js
│   │   └── validator.js
│   ├── config/
│   │   └── database.js
│   └── utils/
│       └── helpers.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

### Model Layer

**models/Book.js**
```javascript
const db = require('../config/database');

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
        const { title, author, isbn, publicationYear } = bookData;
        const [result] = await db.query(
            'INSERT INTO books (title, author, isbn, publication_year) VALUES (?, ?, ?, ?)',
            [title, author, isbn, publicationYear]
        );
        return result.insertId;
    }
    
    static async update(id, bookData) {
        const { title, author, isbn, publicationYear } = bookData;
        const [result] = await db.query(
            'UPDATE books SET title = ?, author = ?, isbn = ?, publication_year = ? WHERE book_id = ?',
            [title, author, isbn, publicationYear, id]
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
    
    static async findByAuthor(author) {
        const [rows] = await db.query(
            'SELECT * FROM books WHERE author LIKE ?',
            [`%${author}%`]
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

Ein **ORM** bildet Datenbank-Tabellen auf Objekte ab und abstrahiert SQL-Queries.

### Vorteile von ORMs

✅ **Weniger SQL-Code**
✅ **Typsicherheit** (bei TypeScript)
✅ **Automatische Validierung**
✅ **Migration-Management**
✅ **Cross-Database Kompatibilität**

### Nachteile von ORMs

❌ **Performance-Overhead**
❌ **Komplexe Queries schwierig**
❌ **Lernkurve**
❌ **"Magic" kann zu Problemen führen**

## Sequelize - ORM für Node.js

**Sequelize** ist das beliebteste ORM für Node.js und unterstützt MySQL, PostgreSQL, SQLite und MSSQL.

### Installation

```bash
npm install sequelize
npm install mysql2  # Für MariaDB/MySQL
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
        dialect: 'mysql',
        logging: false, // SQL-Queries nicht loggen
        pool: {
            max: 5,
            min: 0,
            acquire: 30000,
            idle: 10000
        }
    }
);

// Verbindung testen
sequelize.authenticate()
    .then(() => console.log('Datenbank verbunden'))
    .catch(err => console.error('Verbindungsfehler:', err));

module.exports = sequelize;
```

### Model Definition mit Sequelize

**models/Book.js**
```javascript
const { DataTypes } = require('sequelize');
const sequelize = require('../config/database');

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
            notEmpty: true
        }
    },
    author: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    isbn: {
        type: DataTypes.STRING(20),
        unique: true,
        validate: {
            is: /^[\d-]+$/i  // Nur Zahlen und Bindestriche
        }
    },
    publication_year: {
        type: DataTypes.INTEGER,
        validate: {
            min: 1000,
            max: new Date().getFullYear()
        }
    }
}, {
    tableName: 'books',
    timestamps: false  // Keine created_at/updated_at
});

module.exports = Book;
```

### CRUD mit Sequelize

```javascript
const Book = require('./models/Book');

// CREATE
const newBook = await Book.create({
    title: 'The Hobbit',
    author: 'J.R.R. Tolkien',
    isbn: '978-0547928227',
    publication_year: 1937
});

// READ - Alle
const allBooks = await Book.findAll();

// READ - Mit Filter
const tolkienBooks = await Book.findAll({
    where: {
        author: 'J.R.R. Tolkien'
    }
});

// READ - Ein Buch
const book = await Book.findByPk(1);  // Primary Key
const book2 = await Book.findOne({
    where: { isbn: '978-0547928227' }
});

// UPDATE
await Book.update(
    { publication_year: 1938 },
    { where: { book_id: 1 } }
);

// Oder: Instanz aktualisieren
const book = await Book.findByPk(1);
book.publication_year = 1938;
await book.save();

// DELETE
await Book.destroy({
    where: { book_id: 1 }
});
```

### Erweiterte Queries mit Sequelize

```javascript
const { Op } = require('sequelize');

// WHERE mit Operatoren
const books = await Book.findAll({
    where: {
        publication_year: {
            [Op.gte]: 2000,  // >= 2000
            [Op.lte]: 2024   // <= 2024
        }
    }
});

// LIKE
const books = await Book.findAll({
    where: {
        title: {
            [Op.like]: '%Hobbit%'
        }
    }
});

// OR
const books = await Book.findAll({
    where: {
        [Op.or]: [
            { author: 'Tolkien' },
            { author: 'Lewis' }
        ]
    }
});

// ORDER BY
const books = await Book.findAll({
    order: [
        ['publication_year', 'DESC'],
        ['title', 'ASC']
    ]
});

// LIMIT und OFFSET (Pagination)
const books = await Book.findAll({
    limit: 10,
    offset: 20
});

// SELECT bestimmte Felder
const books = await Book.findAll({
    attributes: ['title', 'author']
});

// COUNT
const count = await Book.count({
    where: { author: 'Tolkien' }
});
```

### Beziehungen (Associations) in Sequelize

**1:N Beziehung**

```javascript
// models/Author.js
const Author = sequelize.define('Author', {
    author_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    name: DataTypes.STRING,
    country: DataTypes.STRING
});

// models/Book.js
const Book = sequelize.define('Book', {
    book_id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    title: DataTypes.STRING,
    author_id: DataTypes.INTEGER
});

// Beziehung definieren
Author.hasMany(Book, {
    foreignKey: 'author_id',
    as: 'books'
});

Book.belongsTo(Author, {
    foreignKey: 'author_id',
    as: 'author'
});

// Verwenden
const authors = await Author.findAll({
    include: [{
        model: Book,
        as: 'books'
    }]
});

const books = await Book.findAll({
    include: [{
        model: Author,
        as: 'author'
    }]
});
```

**N:M Beziehung**

```javascript
// models/Book.js
const Book = sequelize.define('Book', {
    book_id: { type: DataTypes.INTEGER, primaryKey: true }
});

// models/Category.js
const Category = sequelize.define('Category', {
    category_id: { type: DataTypes.INTEGER, primaryKey: true }
});

// Verknüpfungstabelle
const BookCategory = sequelize.define('BookCategory', {
    book_id: DataTypes.INTEGER,
    category_id: DataTypes.INTEGER
}, {
    tableName: 'book_categories',
    timestamps: false
});

// Beziehungen definieren
Book.belongsToMany(Category, {
    through: BookCategory,
    foreignKey: 'book_id'
});

Category.belongsToMany(Book, {
    through: BookCategory,
    foreignKey: 'category_id'
});

// Verwenden
const book = await Book.findByPk(1, {
    include: [Category]
});

const category = await Category.findByPk(1, {
    include: [Book]
});
```

## Prisma - Modernes ORM

**Prisma** ist ein neueres ORM mit TypeScript-First Ansatz.

### Installation

```bash
npm install @prisma/client
npm install -D prisma
npx prisma init
```

### Schema definieren

**prisma/schema.prisma**
```prisma
datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model Book {
  id              Int      @id @default(autoincrement())
  title           String
  author          String
  isbn            String   @unique
  publicationYear Int?     @map("publication_year")
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")
  
  @@map("books")
}

model Author {
  id      Int    @id @default(autoincrement())
  name    String
  country String?
  books   Book[]
  
  @@map("authors")
}
```

### Prisma Client verwenden

```javascript
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// CREATE
const book = await prisma.book.create({
    data: {
        title: 'The Hobbit',
        author: 'J.R.R. Tolkien',
        isbn: '978-0547928227',
        publicationYear: 1937
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

## ORM Vergleich

| Feature | Sequelize | Prisma | TypeORM |
|---------|-----------|--------|---------|
| **TypeScript** | Unterstützt | Native | Native |
| **Migrations** | Ja | Ja | Ja |
| **Beziehungen** | Gut | Exzellent | Gut |
| **Performance** | Gut | Sehr gut | Gut |
| **Lernkurve** | Mittel | Niedrig | Hoch |
| **Community** | Groß | Wachsend | Groß |
| **Best für** | JavaScript | TypeScript | TypeScript Enterprise |

## Migrations mit Sequelize

Migrations ermöglichen versionierte Datenbankänderungen.

### Sequelize CLI installieren

```bash
npm install -D sequelize-cli
npx sequelize-cli init
```

### Migration erstellen

```bash
npx sequelize-cli migration:generate --name create-books-table
```

**migrations/20241010-create-books-table.js**
```javascript
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
            author: {
                type: Sequelize.STRING(255),
                allowNull: false
            },
            isbn: {
                type: Sequelize.STRING(20),
                unique: true
            },
            publication_year: {
                type: Sequelize.INTEGER
            },
            created_at: {
                type: Sequelize.DATE,
                defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
            }
        });
    },
    
    down: async (queryInterface, Sequelize) => {
        await queryInterface.dropTable('books');
    }
};
```

### Migration ausführen

```bash
# Migration ausführen
npx sequelize-cli db:migrate

# Letzte Migration rückgängig machen
npx sequelize-cli db:migrate:undo

# Alle Migrations rückgängig machen
npx sequelize-cli db:migrate:undo:all
```

## Service Layer Pattern

Für komplexe Business-Logik: Service Layer zwischen Controller und Model.

```
Controller → Service → Model → Database
```

**services/bookService.js**
```javascript
const Book = require('../models/Book');
const Author = require('../models/Author');

class BookService {
    async getAllBooks(filters = {}) {
        const { author, year, limit = 50 } = filters;
        
        const where = {};
        if (author) where.author = { [Op.like]: `%${author}%` };
        if (year) where.publication_year = year;
        
        return await Book.findAll({ where, limit });
    }
    
    async getBookWithAuthor(bookId) {
        return await Book.findByPk(bookId, {
            include: [{ model: Author, as: 'author' }]
        });
    }
    
    async createBookWithValidation(bookData) {
        // Validierung
        if (!bookData.title || !bookData.author) {
            throw new Error('Titel und Autor sind erforderlich');
        }
        
        // Prüfen ob ISBN schon existiert
        const existing = await Book.findOne({
            where: { isbn: bookData.isbn }
        });
        
        if (existing) {
            throw new Error('ISBN existiert bereits');
        }
        
        // Buch erstellen
        return await Book.create(bookData);
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

Nimm dein bestehendes REST API Projekt und refactore es nach MVC-Pattern:

1. Erstelle `models/` Ordner mit Model-Klassen
2. Verschiebe DB-Logik aus Controllern in Models
3. Erstelle `services/` für Business-Logik
4. Dokumentiere die neue Struktur

### Übung 2: Sequelize Integration

Implementiere dein Projekt mit Sequelize:

1. Sequelize installieren und konfigurieren
2. Models mit Sequelize definieren
3. Beziehungen einrichten
4. CRUD-Operationen umschreiben
5. Performance vergleichen (mit/ohne ORM)

### Übung 3: Migrations erstellen

Erstelle Migrations für deine Datenbank:

1. Sequelize CLI Setup
2. Migration für jede Tabelle
3. Migration mit Beispieldaten (Seeder)
4. Up/Down Migrations testen

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
                rejectUnauthorized: false
            }
        }
    }
};
```

### 2. Error Handling

```javascript
// middleware/errorHandler.js
module.exports = (err, req, res, next) => {
    console.error(err.stack);
    
    if (err.name === 'SequelizeValidationError') {
        return res.status(400).json({
            error: 'Validierungsfehler',
            details: err.errors.map(e => e.message)
        });
    }
    
    if (err.name === 'SequelizeUniqueConstraintError') {
        return res.status(409).json({
            error: 'Datensatz existiert bereits'
        });
    }
    
    res.status(500).json({ error: 'Interner Serverfehler' });
};
```

### 3. Dependency Injection

```javascript
// Testbarkeit verbessern
class BookController {
    constructor(bookService) {
        this.bookService = bookService;
    }
    
    async getAllBooks(req, res, next) {
        const books = await this.bookService.findAll();
        res.json(books);
    }
}

module.exports = new BookController(bookService);
```

## Checkliste für Credit 10

- [ ] Projekt nach MVC-Pattern strukturiert
- [ ] Model Layer implementiert
- [ ] Controller Layer implementiert
- [ ] Routes Layer implementiert
- [ ] ORM (Sequelize oder Prisma) integriert
- [ ] Mindestens 2 Models mit Beziehung
- [ ] Service Layer für komplexe Logik
- [ ] Dokumentation der Architektur

## Zusätzliche Ressourcen

- [Sequelize Dokumentation](https://sequelize.org/)
- [Prisma Dokumentation](https://www.prisma.io/docs)
- [MVC Pattern Explained](https://www.codecademy.com/article/mvc)
- [Express Best Practices](https://expressjs.com/en/advanced/best-practice-performance.html)

## Nächste Schritte

In Lektion 12 schauen wir uns MQTT-Integration und Security-Themen im Webprojekt an.

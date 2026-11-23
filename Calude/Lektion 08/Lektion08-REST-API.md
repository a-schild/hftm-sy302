# Lektion 8: REST API mit Express.js

## Lernziele

- Die Grundidee von REST zu erklären
- Ein einfaches REST API zu entwerfen und mittels JavaScript umzusetzen
- HTTP-Methoden (GET, POST, PUT, DELETE) korrekt anzuwenden
- JSON als Datenformat für APIs zu verwenden

## Was ist REST?

**REST** (Representational State Transfer) ist ein Architekturstil für verteilte Systeme, insbesondere für Web-Services.

### REST Prinzipien

1. **Client-Server-Architektur**: Trennung von Frontend und Backend
2. **Stateless**: Jede Anfrage enthält alle notwendigen Informationen
3. **Cacheable**: Antworten können gecacht werden
4. **Uniform Interface**: Einheitliche Schnittstelle
5. **Layered System**: Mehrschichtige Architektur möglich

### HTTP-Methoden (Verben)

| Methode | Bedeutung | Verwendung | Idempotent |
|---------|-----------|------------|------------|
| GET | Lesen | Daten abrufen | Ja |
| POST | Erstellen | Neue Ressource anlegen | Nein |
| PUT | Aktualisieren | Ressource vollständig ersetzen | Ja |
| PATCH | Teilupdate | Ressource teilweise ändern | Nein |
| DELETE | Löschen | Ressource entfernen | Ja |

**Idempotent** bedeutet: Mehrfaches Ausführen hat denselben Effekt wie einmaliges Ausführen.

### HTTP-Statuscodes

| Code | Bedeutung | Beispiel |
|------|-----------|----------|
| 200 | OK | Erfolgreiche GET/PUT-Anfrage |
| 201 | Created | Ressource wurde erstellt (POST) |
| 204 | No Content | Erfolgreiche DELETE-Anfrage |
| 400 | Bad Request | Ungültige Eingabedaten |
| 401 | Unauthorized | Authentifizierung erforderlich |
| 403 | Forbidden | Keine Berechtigung |
| 404 | Not Found | Ressource existiert nicht |
| 500 | Internal Server Error | Serverfehler |

## Express.js Setup

### Installation

```bash
npm install express
npm install cors  # Für Cross-Origin Requests
```

### Grundstruktur eines Express Servers

Erstelle `server.js`:

```javascript
require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json()); // JSON Body Parser

// Test Route
app.get('/', (req, res) => {
    res.json({ message: 'HFTM Library API v1.0' });
});

// Server starten
app.listen(PORT, () => {
    console.log(`Server läuft auf http://localhost:${PORT}`);
});
```

Server starten:
```bash
node server.js
```

## REST API Design

### URL-Struktur (Best Practices)

```
GET    /api/books              - Alle Bücher
GET    /api/books/:id          - Ein spezifisches Buch
POST   /api/books              - Neues Buch erstellen
PUT    /api/books/:id          - Buch aktualisieren
DELETE /api/books/:id          - Buch löschen

GET    /api/books/:id/loans    - Ausleihen eines Buchs
POST   /api/loans              - Neue Ausleihe
```

**Regeln:**
- Plural verwenden: `/books` statt `/book`
- Keine Verben in URLs: `/books` statt `/getBooks`
- Hierarchien darstellen: `/books/:id/loans`
- Versionierung: `/api/v1/books`

## CRUD Endpoints implementieren

### Books Controller erstellen

Erstelle `controllers/booksController.js`:

```javascript
const db = require('../db');

// GET /api/books - Alle Bücher
exports.getAllBooks = async (req, res) => {
    try {
        const [books] = await db.query('SELECT * FROM books');
        res.json(books);
    } catch (error) {
        console.error('Fehler beim Abrufen der Bücher:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};

// GET /api/books/:id - Ein Buch
exports.getBookById = async (req, res) => {
    try {
        const bookId = req.params.id;
        const [books] = await db.query(
            'SELECT * FROM books WHERE book_id = ?',
            [bookId]
        );
        
        if (books.length === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }
        
        res.json(books[0]);
    } catch (error) {
        console.error('Fehler:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};

// POST /api/books - Neues Buch erstellen
exports.createBook = async (req, res) => {
    try {
        const { title, author, isbn, publication_year } = req.body;
        
        // Validierung
        if (!title || !author || !isbn) {
            return res.status(400).json({ 
                error: 'Titel, Autor und ISBN sind erforderlich' 
            });
        }
        
        const [result] = await db.query(
            'INSERT INTO books (title, author, isbn, publication_year) VALUES (?, ?, ?, ?)',
            [title, author, isbn, publication_year]
        );
        
        res.status(201).json({
            message: 'Buch erfolgreich erstellt',
            bookId: result.insertId
        });
    } catch (error) {
        console.error('Fehler beim Erstellen:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};

// PUT /api/books/:id - Buch aktualisieren
exports.updateBook = async (req, res) => {
    try {
        const bookId = req.params.id;
        const { title, author, isbn, publication_year } = req.body;
        
        const [result] = await db.query(
            'UPDATE books SET title = ?, author = ?, isbn = ?, publication_year = ? WHERE book_id = ?',
            [title, author, isbn, publication_year, bookId]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }
        
        res.json({ message: 'Buch erfolgreich aktualisiert' });
    } catch (error) {
        console.error('Fehler beim Aktualisieren:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};

// DELETE /api/books/:id - Buch löschen
exports.deleteBook = async (req, res) => {
    try {
        const bookId = req.params.id;
        
        const [result] = await db.query(
            'DELETE FROM books WHERE book_id = ?',
            [bookId]
        );
        
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }
        
        res.status(204).send(); // No Content
    } catch (error) {
        console.error('Fehler beim Löschen:', error);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};
```

### Routes definieren

Erstelle `routes/books.js`:

```javascript
const express = require('express');
const router = express.Router();
const booksController = require('../controllers/booksController');

router.get('/', booksController.getAllBooks);
router.get('/:id', booksController.getBookById);
router.post('/', booksController.createBook);
router.put('/:id', booksController.updateBook);
router.delete('/:id', booksController.deleteBook);

module.exports = router;
```

### Routes in server.js einbinden

```javascript
const booksRoutes = require('./routes/books');

// Routes
app.use('/api/books', booksRoutes);
```

## Erweiterte Features

### Query Parameters für Filterung

```javascript
// GET /api/books?author=Tolkien&year=1954
exports.getAllBooks = async (req, res) => {
    try {
        let query = 'SELECT * FROM books WHERE 1=1';
        const params = [];
        
        if (req.query.author) {
            query += ' AND author LIKE ?';
            params.push(`%${req.query.author}%`);
        }
        
        if (req.query.year) {
            query += ' AND publication_year = ?';
            params.push(req.query.year);
        }
        
        const [books] = await db.query(query, params);
        res.json(books);
    } catch (error) {
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};
```

### Pagination (Seitenweise Daten)

```javascript
// GET /api/books?page=2&limit=10
exports.getAllBooks = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const offset = (page - 1) * limit;
        
        const [books] = await db.query(
            'SELECT * FROM books LIMIT ? OFFSET ?',
            [limit, offset]
        );
        
        const [countResult] = await db.query(
            'SELECT COUNT(*) as total FROM books'
        );
        
        res.json({
            data: books,
            pagination: {
                page,
                limit,
                total: countResult[0].total,
                totalPages: Math.ceil(countResult[0].total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};
```

### JOIN Endpoints

```javascript
// GET /api/books/:id/details - Buch mit Autor und Kategorie
exports.getBookDetails = async (req, res) => {
    try {
        const query = `
            SELECT 
                b.book_id,
                b.title,
                b.isbn,
                a.author_name,
                a.country,
                c.category_name
            FROM books b
            LEFT JOIN authors a ON b.author_id = a.author_id
            LEFT JOIN categories c ON b.category_id = c.category_id
            WHERE b.book_id = ?
        `;
        
        const [books] = await db.query(query, [req.params.id]);
        
        if (books.length === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }
        
        res.json(books[0]);
    } catch (error) {
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
};
```

## Input Validierung

### Manuelle Validierung

```javascript
exports.createBook = async (req, res) => {
    const { title, author, isbn, publication_year } = req.body;
    
    // Validierung
    const errors = [];
    
    if (!title || title.trim().length === 0) {
        errors.push('Titel ist erforderlich');
    }
    
    if (!isbn || !/^\d{3}-\d{10}$/.test(isbn)) {
        errors.push('ISBN muss im Format XXX-XXXXXXXXXX sein');
    }
    
    if (publication_year && (publication_year < 1000 || publication_year > new Date().getFullYear())) {
        errors.push('Ungültiges Erscheinungsjahr');
    }
    
    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }
    
    // ... Rest der Logik
};
```

### Mit express-validator

```bash
npm install express-validator
```

```javascript
const { body, validationResult } = require('express-validator');

const validateBook = [
    body('title').notEmpty().withMessage('Titel ist erforderlich'),
    body('author').notEmpty().withMessage('Autor ist erforderlich'),
    body('isbn').matches(/^\d{3}-\d{10}$/).withMessage('Ungültiges ISBN Format'),
    body('publication_year').optional().isInt({ min: 1000, max: new Date().getFullYear() })
];

router.post('/', validateBook, (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }
    // ... Controller Logik
});
```

## API Testen mit Postman / Thunder Client

### Test Cases

**1. GET alle Bücher**
```
GET http://localhost:3000/api/books
```

**2. GET ein Buch**
```
GET http://localhost:3000/api/books/1
```

**3. POST neues Buch**
```
POST http://localhost:3000/api/books
Content-Type: application/json

{
    "title": "The Hobbit",
    "author": "J.R.R. Tolkien",
    "isbn": "978-0547928227",
    "publication_year": 1937
}
```

**4. PUT Buch aktualisieren**
```
PUT http://localhost:3000/api/books/1
Content-Type: application/json

{
    "title": "The Hobbit - Updated",
    "author": "J.R.R. Tolkien",
    "isbn": "978-0547928227",
    "publication_year": 1937
}
```

**5. DELETE Buch**
```
DELETE http://localhost:3000/api/books/1
```

## Projektstruktur Best Practice

```
project/
├── node_modules/
├── controllers/
│   ├── booksController.js
│   ├── authorsController.js
│   └── loansController.js
├── routes/
│   ├── books.js
│   ├── authors.js
│   └── loans.js
├── middleware/
│   └── errorHandler.js
├── config/
│   └── db.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

## Error Handling Middleware

Erstelle `middleware/errorHandler.js`:

```javascript
exports.errorHandler = (err, req, res, next) => {
    console.error(err.stack);
    
    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'Datensatz existiert bereits' });
    }
    
    res.status(500).json({ 
        error: 'Ein unerwarteter Fehler ist aufgetreten',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
};
```

In `server.js` am Ende einfügen:
```javascript
const { errorHandler } = require('./middleware/errorHandler');

// ... alle Routes ...

app.use(errorHandler);
```

## Praktische Übung

### Aufgabe 1: REST API für HFTM Library

Erstelle ein vollständiges REST API für die HFTM Library mit:

1. Books CRUD (alle 5 Operationen)
2. Authors CRUD
3. GET /api/books/:id/loans - Ausleihen eines Buchs
4. POST /api/loans - Neue Ausleihe erstellen
5. PUT /api/loans/:id/return - Buch zurückgeben

### Aufgabe 2: Ärztezentrum API

Implementiere folgende Endpoints für das Ärztezentrum:

1. `/api/patients` - CRUD für Patienten
2. `/api/doctors` - CRUD für Ärzte
3. `/api/appointments` - CRUD für Termine
4. GET `/api/doctors/:id/appointments` - Termine eines Arztes
5. GET `/api/patients/:id/appointments` - Termine eines Patienten

### Aufgabe 3: API Dokumentation

Dokumentiere dein API mit:
- Alle Endpoints (URL, Methode)
- Request Body Beispiele
- Response Beispiele
- Fehlercodes

**Abgabe für Credit 7:** Lauffähiges REST API + Dokumentation

## Testing mit curl

```bash
# GET Request
curl http://localhost:3000/api/books

# POST Request
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Book","author":"Test Author","isbn":"123-4567890123"}'

# PUT Request
curl -X PUT http://localhost:3000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{"title":"Updated Title","author":"Test Author","isbn":"123-4567890123"}'

# DELETE Request
curl -X DELETE http://localhost:3000/api/books/1
```

## Zusätzliche Ressourcen

- [Express.js Dokumentation](https://expressjs.com/)
- [REST API Best Practices](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)
- [HTTP Status Codes](https://httpstatuses.com/)
- [Postman Learning Center](https://learning.postman.com/)

## Nächste Schritte

In der nächsten Lektion schauen wir uns an, wie KI/AI-Tools bei der Datenbankentwicklung helfen können und arbeiten am Projekt weiter.

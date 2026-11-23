# Lektion 8: REST API mit Express.js

## Lernziele

Die/der Studierende ist in der Lage...

- Die Grundidee von REST zu erklären
- Ein REST API zu entwerfen und mit Express.js umzusetzen
- Die HTTP-Methoden (GET, POST, PUT, DELETE) und HTTP-Statuscodes korrekt anzuwenden
- JSON als Datenformat für APIs zu verwenden
- Ein API professionell zu strukturieren (Routes, Controllers, Middleware)
- Eingaben zu validieren und Fehler zentral zu behandeln
- Das API mit Postman, Thunder Client oder curl zu testen und zu dokumentieren

## Vorbereitung

- Das Projekt aus Lektion 7 mit funktionierender Datenbankverbindung (`db.js` und `.env`)
- MariaDB-Server läuft, die HFTM Library Datenbank (`hftm_library`) ist importiert
- Postman oder die VS-Code-Erweiterung Thunder Client ist installiert

## Was ist REST?

**REST** (**RE**presentational **S**tate **T**ransfer) ist ein Architekturstil für verteilte Systeme, insbesondere für Web-Services. Ein REST API macht Daten (z.B. aus einer Datenbank) über HTTP zugänglich.

### REST-Prinzipien

1. **Client-Server-Architektur**: Trennung von Frontend und Backend
2. **Stateless**: Jede Anfrage ist unabhängig und enthält alle notwendigen Informationen
3. **Cacheable**: Antworten können gecacht werden
4. **Uniform Interface**: Einheitliche Schnittstelle, die HTTP-Methoden werden korrekt eingesetzt
5. **Ressourcen**: Alles ist eine Ressource (books, authors, lends usw.) und hat eine eigene URI
6. **Layered System**: Mehrschichtige Architektur möglich (z.B. Proxy, Load Balancer)

### Ressourcen und URIs

```text
GET    /api/books              - Alle Bücher
GET    /api/books/5            - Buch mit ID 5
POST   /api/books              - Neues Buch erstellen
PUT    /api/books/5            - Buch 5 aktualisieren
DELETE /api/books/5            - Buch 5 löschen

GET    /api/books/5/lends      - Ausleihen von Buch 5
POST   /api/lends              - Neue Ausleihe erfassen
```

**Regeln:**

- Plural verwenden: `/books` statt `/book`
- Kleinbuchstaben verwenden: `/books` statt `/Books`
- Keine Verben in URLs: `/books` statt `/getBooks`
- Hierarchien darstellen: `/books/:id/lends`
- Versionierung: `/api/v1/books`

## HTTP-Methoden und Statuscodes

### HTTP-Methoden (Verben)

| Methode | Bedeutung | CRUD-Operation | Verwendung | Idempotent |
|---------|-----------|----------------|------------|------------|
| GET | Lesen | Read | Daten abrufen | Ja |
| POST | Erstellen | Create | Neue Ressource anlegen | Nein |
| PUT | Aktualisieren (vollständig) | Update | Ressource vollständig ersetzen | Ja |
| PATCH | Aktualisieren (teilweise) | Update | Ressource teilweise ändern | Nein |
| DELETE | Löschen | Delete | Ressource entfernen | Ja |

**Idempotent** bedeutet: Mehrfaches Ausführen hat denselben Effekt wie einmaliges Ausführen.

### HTTP-Statuscodes

Die Statuscodes sind in Klassen eingeteilt: **2xx** = Erfolg, **4xx** = Fehler des Clients, **5xx** = Fehler des Servers.

| Code | Bedeutung | Beispiel |
|------|-----------|----------|
| 200 | OK | Erfolgreiche GET/PUT-Anfrage |
| 201 | Created | Ressource wurde erstellt (POST) |
| 204 | No Content | Erfolgreiche DELETE-Anfrage, keine Daten in der Antwort |
| 400 | Bad Request | Ungültige Eingabedaten |
| 401 | Unauthorized | Authentifizierung erforderlich |
| 403 | Forbidden | Keine Berechtigung |
| 404 | Not Found | Ressource existiert nicht |
| 409 | Conflict | Datensatz existiert bereits oder wird noch referenziert |
| 500 | Internal Server Error | Serverfehler |

## Express.js Setup

**Express** ist das bekannteste Web-Framework für Node.js. Es kümmert sich um Routing, Middleware und das Senden von Antworten.

### Installation

```bash
# Im Projekt aus Lektion 7 (mysql2 und dotenv sind bereits installiert)
npm install express
npm install cors  # Für Cross-Origin Requests
```

### Grundstruktur eines Express-Servers

Erstelle `server.js`:

```javascript
// server.js
require('dotenv').config();
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware: JSON-Body der Anfragen parsen
app.use(express.json());

// Test-Route
app.get('/', (req, res) => {
    res.json({ message: 'HFTM Library API v1.0' });
});

// Server starten
app.listen(PORT, () => {
    console.log(`Server läuft auf http://localhost:${PORT}`);
});
```

### Server starten

```bash
node server.js
```

Danach im Browser `http://localhost:3000` öffnen. Die Antwort ist ein JSON-Objekt.

## CRUD-Endpunkte für Books

Die Beispiele verwenden die Tabelle `books` der HFTM Library (`ID`, `Titel`, `ISBN`, `Published_Date`, `AmountInStock`, `AuthorsID`, `PublishersID`, `GenresID`) und das Modul `db.js` aus Lektion 7, abgelegt unter `config/db.js`. Die Endpunkte werden zuerst direkt in `server.js` geschrieben und im nächsten Kapitel in Controller und Routes aufgeteilt.

### GET - Alle Bücher lesen

```javascript
const db = require('./config/db');

// GET /api/books - alle Bücher
app.get('/api/books', async (req, res) => {
    try {
        // Die Tabelle enthält mehrere tausend Bücher, darum begrenzen
        const [books] = await db.query('SELECT * FROM books LIMIT 100');
        res.json(books);
    } catch (err) {
        console.error('Fehler beim Abrufen der Bücher:', err);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});
```

### GET - Ein Buch per ID lesen

```javascript
// GET /api/books/:id - ein Buch
app.get('/api/books/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const [books] = await db.query(
            'SELECT * FROM books WHERE ID = ?',
            [id]
        );

        if (books.length === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.json(books[0]);
    } catch (err) {
        console.error('Fehler:', err);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});
```

### POST - Neues Buch erstellen

```javascript
// POST /api/books - neues Buch erstellen
app.post('/api/books', async (req, res) => {
    try {
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;

        // Einfache Validierung (Details im Kapitel Input-Validierung)
        if (!Titel || !AuthorsID || !PublishersID) {
            return res.status(400).json({
                error: 'Titel, AuthorsID und PublishersID sind erforderlich'
            });
        }

        const stock = AmountInStock ?? 0;

        const [result] = await db.query(
            `INSERT INTO books (Titel, ISBN, AmountInStock, AuthorsID, PublishersID)
             VALUES (?, ?, ?, ?, ?)`,
            [Titel, ISBN, stock, AuthorsID, PublishersID]
        );

        res.status(201).json({
            ID: result.insertId,
            Titel,
            ISBN,
            AmountInStock: stock,
            AuthorsID,
            PublishersID
        });
    } catch (err) {
        console.error('Fehler beim Erstellen:', err);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});
```

### PUT - Buch aktualisieren

```javascript
// PUT /api/books/:id - Buch aktualisieren
app.put('/api/books/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;

        const [result] = await db.query(
            `UPDATE books
             SET Titel = ?, ISBN = ?, AmountInStock = ?, AuthorsID = ?, PublishersID = ?
             WHERE ID = ?`,
            [Titel, ISBN, AmountInStock, AuthorsID, PublishersID, id]
        );

        // affectedRows = 0: es gibt kein Buch mit dieser ID
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.json({ ID: Number(id), Titel, ISBN, AmountInStock, AuthorsID, PublishersID });
    } catch (err) {
        console.error('Fehler beim Aktualisieren:', err);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});
```

### DELETE - Buch löschen

```javascript
// DELETE /api/books/:id - Buch löschen
app.delete('/api/books/:id', async (req, res) => {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE ID = ?',
            [req.params.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.status(204).send(); // No Content
    } catch (err) {
        console.error('Fehler beim Löschen:', err);
        res.status(500).json({ error: 'Interner Serverfehler' });
    }
});
```

**Hinweis:** Ein Buch, das in `lends` referenziert wird, kann wegen des Fremdschlüssels nicht gelöscht werden (Fehlercode `ER_ROW_IS_REFERENCED_2`). Dieser Fall wird im Kapitel Error-Handling-Middleware mit Status 409 beantwortet.

## Projektstruktur (MVC)

Wenn alle Endpunkte in `server.js` stehen, wird die Datei schnell unübersichtlich. Deshalb wird der Code nach dem MVC-Prinzip aufgeteilt: **Routes** definieren die URLs, **Controllers** enthalten die Logik. Models (Datenmodelle mit einem ORM) folgen in Lektion 11.

### Ordnerstruktur

```text
library-api/
├── config/
│   └── db.js                # Datenbankverbindung (aus Lektion 7)
├── controllers/
│   ├── bookController.js    # Logik für Bücher
│   ├── authorController.js  # Logik für Autoren
│   └── lendController.js    # Logik für Ausleihen
├── routes/
│   ├── bookRoutes.js        # Routes für Bücher
│   ├── authorRoutes.js      # Routes für Autoren
│   └── lendRoutes.js        # Routes für Ausleihen
├── middleware/
│   ├── errorHandler.js      # Zentrale Fehlerbehandlung
│   └── validation.js        # Validierung der Eingaben
├── .env
├── .gitignore
├── package.json
└── server.js                # Einstiegspunkt
```

### Datenbankverbindung (config/db.js)

Das Modul aus Lektion 7 wird unverändert übernommen:

```javascript
// config/db.js
require('dotenv').config();
const mysql = require('mysql2');

// Connection Pool erstellen
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Promise-Wrapper für async/await
module.exports = pool.promise();
```

### Controller (controllers/bookController.js)

Im Controller werden Fehler nicht mehr selbst beantwortet, sondern mit `next(err)` an die zentrale Error-Handling-Middleware weitergegeben (siehe weiter unten).

```javascript
// controllers/bookController.js
const db = require('../config/db');

// GET /api/books - alle Bücher
exports.getAllBooks = async (req, res, next) => {
    try {
        const [books] = await db.query('SELECT * FROM books LIMIT 100');
        res.json(books);
    } catch (err) {
        next(err); // an die Error-Handling-Middleware weitergeben
    }
};

// GET /api/books/:id - ein Buch
exports.getBookById = async (req, res, next) => {
    try {
        const [books] = await db.query(
            'SELECT * FROM books WHERE ID = ?',
            [req.params.id]
        );

        if (books.length === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.json(books[0]);
    } catch (err) {
        next(err);
    }
};

// POST /api/books - neues Buch erstellen
exports.createBook = async (req, res, next) => {
    try {
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
        const stock = AmountInStock ?? 0;

        const [result] = await db.query(
            `INSERT INTO books (Titel, ISBN, AmountInStock, AuthorsID, PublishersID)
             VALUES (?, ?, ?, ?, ?)`,
            [Titel, ISBN, stock, AuthorsID, PublishersID]
        );

        res.status(201).json({
            ID: result.insertId,
            Titel,
            ISBN,
            AmountInStock: stock,
            AuthorsID,
            PublishersID
        });
    } catch (err) {
        next(err);
    }
};

// PUT /api/books/:id - Buch aktualisieren
exports.updateBook = async (req, res, next) => {
    try {
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
        const { id } = req.params;

        const [result] = await db.query(
            `UPDATE books
             SET Titel = ?, ISBN = ?, AmountInStock = ?, AuthorsID = ?, PublishersID = ?
             WHERE ID = ?`,
            [Titel, ISBN, AmountInStock, AuthorsID, PublishersID, id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.json({ ID: Number(id), Titel, ISBN, AmountInStock, AuthorsID, PublishersID });
    } catch (err) {
        next(err);
    }
};

// DELETE /api/books/:id - Buch löschen
exports.deleteBook = async (req, res, next) => {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE ID = ?',
            [req.params.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.status(204).send();
    } catch (err) {
        next(err);
    }
};
```

### Routes (routes/bookRoutes.js)

```javascript
// routes/bookRoutes.js
const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');

router.get('/', bookController.getAllBooks);
router.get('/:id', bookController.getBookById);
router.post('/', bookController.createBook);
router.put('/:id', bookController.updateBook);
router.delete('/:id', bookController.deleteBook);

module.exports = router;
```

### Einstiegspunkt (server.js)

```javascript
// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());                                  // Cross-Origin Requests erlauben
app.use(express.json());                          // JSON-Body parsen
app.use(express.urlencoded({ extended: true }));  // Formulardaten parsen

// Routes
const bookRoutes = require('./routes/bookRoutes');
const authorRoutes = require('./routes/authorRoutes');

app.use('/api/books', bookRoutes);
app.use('/api/authors', authorRoutes);

// Root-Route mit Übersicht
app.get('/', (req, res) => {
    res.json({
        message: 'HFTM Library API v1.0',
        endpoints: {
            books: '/api/books',
            authors: '/api/authors'
        }
    });
});

// Unbekannte Endpunkte: 404
app.use((req, res) => {
    res.status(404).json({ error: 'Endpunkt nicht gefunden' });
});

// Fehlerbehandlung: muss nach allen Routes stehen
app.use(errorHandler);

// Server starten
app.listen(PORT, () => {
    console.log(`Server läuft auf http://localhost:${PORT}`);
});
```

## Query Parameters

Query Parameters werden an die URL angehängt (`?key=value&key2=value2`) und in Express über `req.query` gelesen. Sie eignen sich für Filter, Sortierung und Pagination. Die folgenden Funktionen ersetzen jeweils `getAllBooks` im Controller.

### Filtern und Suchen

```javascript
// GET /api/books?search=harry&authorId=1&year=1997
exports.getAllBooks = async (req, res, next) => {
    try {
        const { search, authorId, year } = req.query;

        let sql = 'SELECT * FROM books WHERE 1=1';
        const params = [];

        if (search) {
            sql += ' AND Titel LIKE ?';
            params.push(`%${search}%`);
        }

        if (authorId) {
            sql += ' AND AuthorsID = ?';
            params.push(authorId);
        }

        if (year) {
            sql += ' AND YEAR(Published_Date) = ?';
            params.push(year);
        }

        sql += ' LIMIT 100';

        const [books] = await db.query(sql, params);
        res.json(books);
    } catch (err) {
        next(err);
    }
};
```

### Sortieren

Spaltennamen und Sortierrichtung können nicht mit Platzhaltern (`?`) übergeben werden. Deshalb werden sie gegen eine Whitelist geprüft, damit keine SQL-Injection möglich ist.

```javascript
// GET /api/books?sortBy=Titel&order=asc
exports.getAllBooks = async (req, res, next) => {
    try {
        const { sortBy, order } = req.query;

        let sql = 'SELECT * FROM books';

        const validColumns = ['ID', 'Titel', 'Published_Date', 'AmountInStock'];
        const validOrder = ['asc', 'desc'];

        if (sortBy && validColumns.includes(sortBy)) {
            sql += ` ORDER BY ${sortBy}`;

            if (order && validOrder.includes(order.toLowerCase())) {
                sql += ` ${order.toUpperCase()}`;
            }
        }

        sql += ' LIMIT 100';

        const [books] = await db.query(sql);
        res.json(books);
    } catch (err) {
        next(err);
    }
};
```

### Pagination

Bei grossen Tabellen werden die Daten seitenweise ausgeliefert:

```javascript
// GET /api/books?page=2&limit=10
exports.getAllBooks = async (req, res, next) => {
    try {
        const page = Math.max(parseInt(req.query.page) || 1, 1);
        const limit = Math.min(parseInt(req.query.limit) || 10, 100); // max. 100
        const offset = (page - 1) * limit;

        const [books] = await db.query(
            'SELECT * FROM books ORDER BY ID LIMIT ? OFFSET ?',
            [limit, offset]
        );

        const [countResult] = await db.query(
            'SELECT COUNT(*) AS total FROM books'
        );
        const total = countResult[0].total;

        res.json({
            data: books,
            pagination: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit)
            }
        });
    } catch (err) {
        next(err);
    }
};
```

## JOIN-Endpunkte

Mit JOINs liefert das API zusammengehörige Daten aus mehreren Tabellen in einer Antwort.

### Bücher mit Autoren

```javascript
// GET /api/books/with-authors
exports.getBooksWithAuthors = async (req, res, next) => {
    try {
        const sql = `
            SELECT
                b.ID,
                b.Titel,
                b.ISBN,
                b.Published_Date,
                a.ID AS AuthorID,
                a.Firstname,
                a.Lastname
            FROM books b
            INNER JOIN authors a ON b.AuthorsID = a.ID
            ORDER BY b.Titel
            LIMIT 100
        `;

        const [books] = await db.query(sql);
        res.json(books);
    } catch (err) {
        next(err);
    }
};
```

### Buch mit allen Details

```javascript
// GET /api/books/:id/details - Buch mit Autor, Genre und Verlag
exports.getBookDetails = async (req, res, next) => {
    try {
        const sql = `
            SELECT
                b.ID,
                b.Titel,
                b.ISBN,
                b.Published_Date,
                b.AmountInStock,
                a.ID AS AuthorID,
                CONCAT(a.Firstname, ' ', a.Lastname) AS Author,
                g.Genre,
                p.Name AS Publisher
            FROM books b
            LEFT JOIN authors a ON b.AuthorsID = a.ID
            LEFT JOIN genres g ON b.GenresID = g.ID
            LEFT JOIN publishers p ON b.PublishersID = p.ID
            WHERE b.ID = ?
        `;

        const [books] = await db.query(sql, [req.params.id]);

        if (books.length === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.json(books[0]);
    } catch (err) {
        next(err);
    }
};
```

### Ausleihen eines Buchs

```javascript
// GET /api/books/:id/lends - alle Ausleihen eines Buchs mit Kunde
exports.getBookLends = async (req, res, next) => {
    try {
        const sql = `
            SELECT
                l.ID,
                l.Date_From,
                l.Date_To,
                l.Price,
                c.ID AS CustomerID,
                c.Firstname,
                c.Lastname
            FROM lends l
            INNER JOIN customers c ON l.CustomerID = c.ID
            WHERE l.BookID = ?
            ORDER BY l.Date_From DESC
        `;

        const [lends] = await db.query(sql, [req.params.id]);
        res.json(lends);
    } catch (err) {
        next(err);
    }
};
```

Die neuen Endpunkte werden in `routes/bookRoutes.js` ergänzt. **Wichtig:** Feste Pfade wie `/with-authors` müssen **vor** `/:id` stehen, sonst wird `with-authors` als ID interpretiert.

```javascript
// routes/bookRoutes.js
router.get('/with-authors', bookController.getBooksWithAuthors); // vor '/:id'!
router.get('/:id', bookController.getBookById);
router.get('/:id/details', bookController.getBookDetails);
router.get('/:id/lends', bookController.getBookLends);
```

## Input-Validierung

Eingaben des Clients dürfen nie ungeprüft in die Datenbank geschrieben werden. Die Validierung wird als Middleware vor dem Controller ausgeführt.

### Manuelle Validierung als Middleware

```javascript
// middleware/validation.js
exports.validateBook = (req, res, next) => {
    const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
    const errors = [];

    if (!Titel || Titel.trim().length === 0) {
        errors.push('Titel ist erforderlich');
    } else if (Titel.length > 50) {
        errors.push('Titel darf höchstens 50 Zeichen lang sein');
    }

    // ISBN in der HFTM Library: z.B. 586-25-07337-83-2
    if (ISBN && !/^\d{3}-\d{2}-\d{5}-\d{2}-\d$/.test(ISBN)) {
        errors.push('ISBN muss im Format XXX-XX-XXXXX-XX-X sein');
    }

    if (AmountInStock !== undefined && (!Number.isInteger(AmountInStock) || AmountInStock < 0)) {
        errors.push('AmountInStock muss eine ganze Zahl >= 0 sein');
    }

    if (!Number.isInteger(AuthorsID) || AuthorsID < 1) {
        errors.push('Gültige AuthorsID ist erforderlich');
    }

    if (!Number.isInteger(PublishersID) || PublishersID < 1) {
        errors.push('Gültige PublishersID ist erforderlich');
    }

    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    next(); // Daten sind gültig: weiter zum Controller
};
```

**Verwendung in den Routes:**

```javascript
// routes/bookRoutes.js
const { validateBook } = require('../middleware/validation');

router.post('/', validateBook, bookController.createBook);
router.put('/:id', validateBook, bookController.updateBook);
```

### Mit express-validator

Das Package `express-validator` bietet fertige Prüfregeln:

```bash
npm install express-validator
```

```javascript
// middleware/validation.js (Variante mit express-validator)
const { body, validationResult } = require('express-validator');

exports.validateBook = [
    body('Titel').trim().notEmpty().withMessage('Titel ist erforderlich')
        .isLength({ max: 50 }).withMessage('Titel darf höchstens 50 Zeichen lang sein'),
    body('ISBN').optional().matches(/^\d{3}-\d{2}-\d{5}-\d{2}-\d$/)
        .withMessage('Ungültiges ISBN-Format'),
    body('AmountInStock').optional().isInt({ min: 0 })
        .withMessage('AmountInStock muss eine ganze Zahl >= 0 sein'),
    body('AuthorsID').isInt({ min: 1 }).withMessage('Gültige AuthorsID ist erforderlich'),
    body('PublishersID').isInt({ min: 1 }).withMessage('Gültige PublishersID ist erforderlich'),

    // Resultat der Prüfungen auswerten
    (req, res, next) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        next();
    }
];
```

Die Verwendung in den Routes bleibt gleich wie bei der manuellen Validierung.

## Error-Handling-Middleware

Eine Error-Handling-Middleware hat **vier** Parameter `(err, req, res, next)`. Sie fängt alle Fehler ab, die mit `next(err)` weitergegeben werden, und übersetzt typische Datenbankfehler in passende HTTP-Statuscodes.

Erstelle `middleware/errorHandler.js`:

```javascript
// middleware/errorHandler.js
exports.errorHandler = (err, req, res, next) => {
    console.error(err.stack);

    // Validierungsfehler
    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: err.message });
    }

    // Datensatz existiert bereits (z.B. UNIQUE-Constraint)
    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'Datensatz existiert bereits' });
    }

    // Fremdschlüssel zeigt auf einen nicht existierenden Datensatz
    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
        return res.status(400).json({ error: 'Referenzierter Datensatz existiert nicht' });
    }

    // Datensatz wird noch referenziert (z.B. Buch mit Ausleihen löschen)
    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
        return res.status(409).json({ error: 'Datensatz wird noch verwendet' });
    }

    // Standard: 500, Details nur in der Entwicklung anzeigen
    res.status(500).json({
        error: 'Ein unerwarteter Fehler ist aufgetreten',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
};
```

**Verwendung in server.js:**

```javascript
const { errorHandler } = require('./middleware/errorHandler');

// ... alle Routes ...

// Muss nach allen Routes stehen
app.use(errorHandler);
```

**Hinweis:** In Express 4 werden Fehler in `async`-Funktionen nicht automatisch an die Error-Handling-Middleware weitergegeben. Deshalb braucht jeder Controller `try/catch` mit `next(err)`. Ab Express 5 werden abgelehnte Promises automatisch weitergeleitet.

## CORS

**CORS** (Cross-Origin Resource Sharing) legt fest, ob ein Browser von einer anderen Origin (z.B. ein Frontend auf `http://localhost:5173`) auf das API zugreifen darf. Ohne CORS-Header blockiert der Browser solche Anfragen.

### Installation

```bash
npm install cors
```

### Konfiguration

```javascript
const cors = require('cors');

// Alle Origins erlauben (Entwicklung)
app.use(cors());

// Nur bestimmte Origins erlauben (Produktion)
app.use(cors({
    origin: 'https://myapp.com',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));
```

### Alternative ohne Package

Die CORS-Header können auch mit einer eigenen Middleware gesetzt werden:

```javascript
// CORS-Header manuell setzen
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next();
});
```

## API testen

### Postman / Thunder Client

- **Postman**: Download unter [postman.com](https://www.postman.com/downloads/)
- **Thunder Client**: Erweiterung direkt in VS Code (Extensions, nach "Thunder Client" suchen)

Vorgehen in Postman:

1. **New Collection** erstellen, z.B. "HFTM Library API"
2. Für jeden Endpunkt eine Request hinzufügen
3. Bei POST und PUT unter **Body** die Option **raw** und **JSON** wählen
4. Collection exportieren (für die Abgabe)

### Testfälle

**1. GET alle Bücher**

```http
GET http://localhost:3000/api/books
```

**2. GET ein Buch**

```http
GET http://localhost:3000/api/books/1
```

**3. POST neues Buch**

```http
POST http://localhost:3000/api/books
Content-Type: application/json

{
    "Titel": "The Hobbit",
    "ISBN": "978-05-47928-22-7",
    "AmountInStock": 3,
    "AuthorsID": 1,
    "PublishersID": 1
}
```

**4. PUT Buch aktualisieren**

```http
PUT http://localhost:3000/api/books/1
Content-Type: application/json

{
    "Titel": "The Hobbit - Updated",
    "ISBN": "978-05-47928-22-7",
    "AmountInStock": 5,
    "AuthorsID": 1,
    "PublishersID": 1
}
```

**5. DELETE Buch**

```http
DELETE http://localhost:3000/api/books/1
```

**6. GET Buch mit Details (JOIN)**

```http
GET http://localhost:3000/api/books/2/details
```

**7. Fehlerfälle prüfen**

```http
# Buch existiert nicht: 404 erwartet
GET http://localhost:3000/api/books/999999

# Titel fehlt: 400 erwartet
POST http://localhost:3000/api/books
Content-Type: application/json

{
    "AuthorsID": 1,
    "PublishersID": 1
}
```

### Testing mit curl

```bash
# GET Request
curl http://localhost:3000/api/books

# POST Request
curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{"Titel":"Test Book","ISBN":"123-45-67890-12-3","AuthorsID":1,"PublishersID":1}'

# PUT Request
curl -X PUT http://localhost:3000/api/books/1 \
  -H "Content-Type: application/json" \
  -d '{"Titel":"Updated Title","ISBN":"123-45-67890-12-3","AmountInStock":2,"AuthorsID":1,"PublishersID":1}'

# DELETE Request (-i zeigt den Statuscode 204)
curl -i -X DELETE http://localhost:3000/api/books/1
```

**Hinweis für Windows:** Die Beispiele in Git Bash ausführen. In PowerShell `curl.exe` statt `curl` verwenden, da `curl` dort ein Alias für `Invoke-WebRequest` sein kann.

## Praktische Übungen

### Übung 1: REST API für die HFTM Library

Erstelle ein vollständiges REST API für die HFTM Library mit:

1. Books CRUD (alle 5 Operationen)
2. Authors CRUD: `GET /api/authors`, `GET /api/authors/:id`, `POST /api/authors`, `PUT /api/authors/:id`, `DELETE /api/authors/:id`
3. `GET /api/books/:id/lends` - Ausleihen eines Buchs
4. `POST /api/lends` - Neue Ausleihe erfassen (Transaktion aus Lektion 7 verwenden)
5. `PUT /api/lends/:id/return` - Buch zurückgeben (`Date_To` auf das aktuelle Datum setzen, `AmountInStock` erhöhen)

### Übung 2: Erweiterte Suche

Implementiere:

- Suche nach Titel: `GET /api/books?search=harry`
- Filter nach Autor: `GET /api/books?authorId=1`
- Pagination: `GET /api/books?page=2&limit=10`
- Sortierung: `GET /api/books?sortBy=Titel&order=asc`

### Übung 3: Relationen

Implementiere:

- Bücher eines Autors: `GET /api/authors/:id/books`
- Autoren eines Genres: `GET /api/genres/:id/authors` (über die Tabelle `authors_genres`)
- Statistik: `GET /api/stats/books-by-genre` (Anzahl Bücher pro Genre)

### Übung 4: Ärztezentrum API

Implementiere folgende Endpunkte für das Ärztezentrum:

1. `/api/patients` - CRUD für Patienten
2. `/api/doctors` - CRUD für Ärzte
3. `/api/appointments` - CRUD für Termine
4. `GET /api/doctors/:id/appointments` - Termine eines Arztes
5. `GET /api/patients/:id/appointments` - Termine eines Patienten

### Übung 5: API-Dokumentation

Dokumentiere dein API (Vorlage siehe Kapitel API-Dokumentation) mit:

- Allen Endpunkten (URL, Methode)
- Request-Body-Beispielen
- Response-Beispielen
- Fehlercodes

## Best Practices

### Namenskonventionen

**Gut (Plural, Kleinbuchstaben):**

```text
GET /api/books
GET /api/authors
GET /api/books/5/lends
```

**Zu vermeiden:**

```text
GET /api/getBooks
GET /api/Book
GET /api/books/getAllBooks
```

### Passende Statuscodes

```javascript
// 200 - OK (GET, PUT erfolgreich)
res.status(200).json(data);

// 201 - Created (POST erfolgreich)
res.status(201).json(newResource);

// 204 - No Content (DELETE erfolgreich)
res.status(204).send();

// 400 - Bad Request (ungültige Daten)
res.status(400).json({ error: 'Ungültige Daten' });

// 404 - Not Found (Ressource existiert nicht)
res.status(404).json({ error: 'Ressource nicht gefunden' });

// 500 - Internal Server Error
res.status(500).json({ error: 'Interner Serverfehler' });
```

### Validierung

```javascript
// Eingehende Daten immer validieren
if (!Titel || Titel.trim() === '') {
    return res.status(400).json({ error: 'Titel ist erforderlich' });
}

if (ISBN && !/^\d{3}-\d{2}-\d{5}-\d{2}-\d$/.test(ISBN)) {
    return res.status(400).json({ error: 'Ungültiges ISBN-Format' });
}
```

### Sicherheit

```javascript
// GUT: Prepared Statements (immer!)
const [books] = await db.query(
    'SELECT * FROM books WHERE Titel = ?',
    [searchTerm]
);

// SCHLECHT: SQL-Injection möglich!
const [unsafeBooks] = await db.query(
    `SELECT * FROM books WHERE Titel = '${searchTerm}'`
);
```

Weitere Punkte:

- Spaltennamen für `ORDER BY` nur aus einer Whitelist übernehmen
- Zugangsdaten nur in der `.env`-Datei, nie im Code
- Fehlermeldungen mit technischen Details nur in der Entwicklung ausgeben

## API-Dokumentation

Ein API ist nur so gut wie seine Dokumentation. Eine einfache Variante ist eine `README.md` im Projekt.

### README.md

````markdown
# HFTM Library API

## Base URL

`http://localhost:3000/api`

## Endpoints

### Books

#### GET /books

Liefert alle Bücher.

**Query Parameters:**

- `search` (optional): Suche im Titel
- `page` (optional): Seite für die Pagination (Standard: 1)
- `limit` (optional): Anzahl Resultate pro Seite (Standard: 10)

**Response:** 200 OK

```json
[
    {
        "ID": 2,
        "Titel": "Paradise Lost",
        "ISBN": "586-25-07337-83-2",
        "AmountInStock": 5,
        "AuthorsID": 1252,
        "PublishersID": 15
    }
]
```

#### POST /books

Erstellt ein neues Buch.

**Body:**

```json
{
    "Titel": "New Book",
    "ISBN": "978-12-34567-89-0",
    "AmountInStock": 1,
    "AuthorsID": 1,
    "PublishersID": 1
}
```

**Response:** 201 Created

**Fehler:** 400 Bad Request (ungültige Daten)
````

## Zusammenfassung

### Grundgerüst eines REST-Endpunkts

```javascript
exports.handler = async (req, res, next) => {
    try {
        // 1. Parameter lesen
        const { id } = req.params;    // aus der URL: /api/books/:id
        const { search } = req.query; // aus dem Query String: ?search=...
        const { Titel } = req.body;   // aus dem JSON-Body

        // 2. Validieren
        if (!Titel) {
            return res.status(400).json({ error: 'Titel ist erforderlich' });
        }

        // 3. Datenbankoperation (Prepared Statement)
        const [result] = await db.query(sql, params);

        // 4. Antworten (mit passendem Statuscode)
        res.status(200).json(result);

    } catch (err) {
        // 5. Fehler an die Error-Handling-Middleware weitergeben
        next(err);
    }
};
```

## Hausaufgaben

1. **Ein vollständiges REST API** für dein Projekt erstellen
2. **Mindestens 2 Ressourcen** mit allen CRUD-Operationen
3. **Mit Postman testen** (Screenshots)
4. **Alle Endpunkte dokumentieren**

## Checkliste für Credit 7

- [ ] Express installiert, Server startet ohne Fehler
- [ ] Alle 5 CRUD-Endpunkte für Books funktionieren
- [ ] Controller und Routes getrennt
- [ ] Mindestens ein JOIN-Endpunkt implementiert
- [ ] Eingaben validiert, korrekte HTTP-Statuscodes (200, 201, 204, 400, 404, 500)
- [ ] Alle Endpunkte getestet (Postman-Collection exportiert, Screenshots)
- [ ] API-Dokumentation (README.md) erstellt
- [ ] Lauffähiges REST API und Dokumentation abgegeben

## Ressourcen

- [Express.js Dokumentation](https://expressjs.com/)
- [REST API Best Practices](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)
- [HTTP-Statuscodes (MDN)](https://developer.mozilla.org/de/docs/Web/HTTP/Status)
- [express-validator Dokumentation](https://express-validator.github.io/docs/)
- [CORS Package](https://github.com/expressjs/cors)
- [Postman Learning Center](https://learning.postman.com/)

## Nächste Schritte

In Lektion 9 schauen wir uns an, wie KI/AI-Tools bei der Datenbankentwicklung helfen können, und arbeiten am Projekt weiter:

- Künstliche Intelligenz im Datenbankumfeld
- Claude AI in die eigene Anwendung integrieren
- Testdaten generieren
- Datenanalyse mit KI

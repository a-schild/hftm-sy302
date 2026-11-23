# Übung 8: REST API mit Express - Lösungen

## Credit 8: REST API für die HFTM Library (10 Punkte)

Die Lösungen beziehen sich auf die praktischen Übungen aus Lektion 8 und bauen auf dem Projekt aus Lektion 7 auf. Es gelten dieselben Konventionen wie in der Lektion:

- Datenbankmodul `config/db.js` (das `db.js` aus Lektion 7)
- Controller geben Fehler mit `next(err)` an die Error-Handling-Middleware weiter
- JSON-Felder in Requests und Responses heissen wie die Spalten im Dump (`Titel`, `ISBN`, `AmountInStock`, `AuthorsID`, `PublishersID`, `BookID`, `CustomerID` usw.)

**Hinweis:** Die Tabelle `books` hat keine Preisspalte. Ein Preis gehört zu einer Ausleihe (`lends.Price`) und wird deshalb bei `POST /api/lends` übergeben.

---

## Projektstruktur

```text
library-api/
├── config/
│   └── db.js
├── controllers/
│   ├── bookController.js
│   ├── authorController.js
│   ├── lendController.js
│   ├── genreController.js
│   └── statsController.js
├── routes/
│   ├── bookRoutes.js
│   ├── authorRoutes.js
│   ├── lendRoutes.js
│   ├── genreRoutes.js
│   └── statsRoutes.js
├── middleware/
│   ├── errorHandler.js
│   └── validation.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

```bash
npm install express cors
```

---

## Übung 1: REST API für die HFTM Library (4 Punkte)

### config/db.js

Unverändert aus Lektion 7:

```javascript
// config/db.js
require('dotenv').config();
const mysql = require('mysql2');

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

module.exports = pool.promise();
```

### middleware/errorHandler.js

Wie in der Lektion. Damit werden Fremdschlüsselfehler automatisch in 400 bzw. 409 übersetzt (z.B. unbekannte `AuthorsID` beim Erstellen, Buch mit Ausleihen löschen).

```javascript
// middleware/errorHandler.js
exports.errorHandler = (err, req, res, next) => {
    console.error(err.stack);

    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: err.message });
    }

    if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ error: 'Datensatz existiert bereits' });
    }

    if (err.code === 'ER_NO_REFERENCED_ROW_2') {
        return res.status(400).json({ error: 'Referenzierter Datensatz existiert nicht' });
    }

    if (err.code === 'ER_ROW_IS_REFERENCED_2') {
        return res.status(409).json({ error: 'Datensatz wird noch verwendet' });
    }

    res.status(500).json({
        error: 'Ein unerwarteter Fehler ist aufgetreten',
        message: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
};
```

### middleware/validation.js

`validateBook` stammt aus der Lektion, `validateAuthor` und `validateLend` sind nach demselben Muster ergänzt.

```javascript
// middleware/validation.js

// Buch: Titel (max. 50 Zeichen), ISBN im Format der HFTM Library
exports.validateBook = (req, res, next) => {
    const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
    const errors = [];

    if (!Titel || Titel.trim().length === 0) {
        errors.push('Titel ist erforderlich');
    } else if (Titel.length > 50) {
        errors.push('Titel darf höchstens 50 Zeichen lang sein');
    }

    // z.B. 586-25-07337-83-2
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

    next();
};

// Autor: Firstname und Lastname (je max. 50 Zeichen), Email optional
exports.validateAuthor = (req, res, next) => {
    const { Firstname, Lastname, Email } = req.body;
    const errors = [];

    if (!Firstname || Firstname.trim().length === 0) {
        errors.push('Firstname ist erforderlich');
    } else if (Firstname.length > 50) {
        errors.push('Firstname darf höchstens 50 Zeichen lang sein');
    }

    if (!Lastname || Lastname.trim().length === 0) {
        errors.push('Lastname ist erforderlich');
    } else if (Lastname.length > 50) {
        errors.push('Lastname darf höchstens 50 Zeichen lang sein');
    }

    if (Email && (Email.length > 100 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(Email))) {
        errors.push('Email ist ungültig');
    }

    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    next();
};

// Ausleihe: BookID und CustomerID erforderlich, Price und Days optional
exports.validateLend = (req, res, next) => {
    const { BookID, CustomerID, Price, Days } = req.body;
    const errors = [];

    if (!Number.isInteger(BookID) || BookID < 1) {
        errors.push('Gültige BookID ist erforderlich');
    }

    if (!Number.isInteger(CustomerID) || CustomerID < 1) {
        errors.push('Gültige CustomerID ist erforderlich');
    }

    if (Price !== undefined && (typeof Price !== 'number' || Price < 0)) {
        errors.push('Price muss eine Zahl >= 0 sein');
    }

    if (Days !== undefined && (!Number.isInteger(Days) || Days < 1 || Days > 365)) {
        errors.push('Days muss eine ganze Zahl zwischen 1 und 365 sein');
    }

    if (errors.length > 0) {
        return res.status(400).json({ errors });
    }

    next();
};
```

### controllers/bookController.js

Die Funktion `getAllBooks` enthält bereits die erweiterte Suche aus Übung 2.

```javascript
// controllers/bookController.js
const db = require('../config/db');

// GET /api/books?search=harry&authorId=1&page=2&limit=10&sortBy=Titel&order=asc
exports.getAllBooks = async (req, res, next) => {
    try {
        const { search, authorId, sortBy, order } = req.query;

        // Pagination: Standard Seite 1 mit 10 Einträgen, maximal 100 pro Seite
        const page = Math.max(parseInt(req.query.page) || 1, 1);
        const limit = Math.min(Math.max(parseInt(req.query.limit) || 10, 1), 100);
        const offset = (page - 1) * limit;

        // Filter: Werte immer über Platzhalter
        let where = ' WHERE 1=1';
        const params = [];

        if (search) {
            where += ' AND Titel LIKE ?';
            params.push(`%${search}%`);
        }

        if (authorId) {
            where += ' AND AuthorsID = ?';
            params.push(authorId);
        }

        // Sortierung: Spalte und Richtung nur aus einer Whitelist
        const validColumns = ['ID', 'Titel', 'Published_Date', 'AmountInStock'];
        const sortColumn = validColumns.includes(sortBy) ? sortBy : 'ID';
        const sortOrder = order && order.toLowerCase() === 'desc' ? 'DESC' : 'ASC';

        const [books] = await db.query(
            `SELECT * FROM books${where} ORDER BY ${sortColumn} ${sortOrder} LIMIT ? OFFSET ?`,
            [...params, limit, offset]
        );

        // Gesamtanzahl mit denselben Filtern
        const [countResult] = await db.query(
            `SELECT COUNT(*) AS total FROM books${where}`,
            params
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

// GET /api/books/:id
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

// POST /api/books
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
        next(err); // unbekannte AuthorsID/PublishersID: 400 über errorHandler
    }
};

// PUT /api/books/:id
exports.updateBook = async (req, res, next) => {
    try {
        const { Titel, ISBN, AmountInStock, AuthorsID, PublishersID } = req.body;
        const { id } = req.params;
        const stock = AmountInStock ?? 0;

        const [result] = await db.query(
            `UPDATE books
             SET Titel = ?, ISBN = ?, AmountInStock = ?, AuthorsID = ?, PublishersID = ?
             WHERE ID = ?`,
            [Titel, ISBN, stock, AuthorsID, PublishersID, id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

        res.json({ ID: Number(id), Titel, ISBN, AmountInStock: stock, AuthorsID, PublishersID });
    } catch (err) {
        next(err);
    }
};

// DELETE /api/books/:id
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
        next(err); // Buch mit Ausleihen: 409 über errorHandler
    }
};

// GET /api/books/:id/lends - alle Ausleihen eines Buchs mit Kunde
exports.getBookLends = async (req, res, next) => {
    try {
        const [books] = await db.query('SELECT ID FROM books WHERE ID = ?', [req.params.id]);
        if (books.length === 0) {
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }

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

### controllers/authorController.js

`getAuthorBooks` gehört zu Übung 3.

```javascript
// controllers/authorController.js
const db = require('../config/db');

// GET /api/authors
exports.getAllAuthors = async (req, res, next) => {
    try {
        const [authors] = await db.query(
            'SELECT * FROM authors ORDER BY Lastname, Firstname LIMIT 100'
        );
        res.json(authors);
    } catch (err) {
        next(err);
    }
};

// GET /api/authors/:id
exports.getAuthorById = async (req, res, next) => {
    try {
        const [authors] = await db.query(
            'SELECT * FROM authors WHERE ID = ?',
            [req.params.id]
        );

        if (authors.length === 0) {
            return res.status(404).json({ error: 'Autor nicht gefunden' });
        }

        res.json(authors[0]);
    } catch (err) {
        next(err);
    }
};

// POST /api/authors
exports.createAuthor = async (req, res, next) => {
    try {
        const { Firstname, Lastname, Email } = req.body;

        const [result] = await db.query(
            'INSERT INTO authors (Firstname, Lastname, Email) VALUES (?, ?, ?)',
            [Firstname, Lastname, Email ?? null]
        );

        res.status(201).json({ ID: result.insertId, Firstname, Lastname, Email: Email ?? null });
    } catch (err) {
        next(err);
    }
};

// PUT /api/authors/:id
exports.updateAuthor = async (req, res, next) => {
    try {
        const { Firstname, Lastname, Email } = req.body;
        const { id } = req.params;

        const [result] = await db.query(
            'UPDATE authors SET Firstname = ?, Lastname = ?, Email = ? WHERE ID = ?',
            [Firstname, Lastname, Email ?? null, id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Autor nicht gefunden' });
        }

        res.json({ ID: Number(id), Firstname, Lastname, Email: Email ?? null });
    } catch (err) {
        next(err);
    }
};

// DELETE /api/authors/:id
exports.deleteAuthor = async (req, res, next) => {
    try {
        const [result] = await db.query(
            'DELETE FROM authors WHERE ID = ?',
            [req.params.id]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Autor nicht gefunden' });
        }

        res.status(204).send();
    } catch (err) {
        next(err); // Autor mit Büchern: 409 über errorHandler
    }
};

// GET /api/authors/:id/books - Bücher eines Autors (Übung 3)
exports.getAuthorBooks = async (req, res, next) => {
    try {
        const [authors] = await db.query('SELECT ID FROM authors WHERE ID = ?', [req.params.id]);
        if (authors.length === 0) {
            return res.status(404).json({ error: 'Autor nicht gefunden' });
        }

        const [books] = await db.query(
            `SELECT ID, Titel, ISBN, Published_Date, AmountInStock
             FROM books
             WHERE AuthorsID = ?
             ORDER BY Titel`,
            [req.params.id]
        );
        res.json(books);
    } catch (err) {
        next(err);
    }
};
```

### controllers/lendController.js

Die Transaktion entspricht `lendBook()` und `returnBook()` aus Lektion 7. Anstatt einen Fehler zu werfen, antwortet der Controller bei fehlendem Buch oder leerem Bestand direkt mit 404 bzw. 409.

```javascript
// controllers/lendController.js
const db = require('../config/db');

// POST /api/lends - neue Ausleihe erfassen
exports.createLend = async (req, res, next) => {
    const { BookID, CustomerID, Price, Days } = req.body;
    const days = Days ?? 30;
    let connection;

    try {
        connection = await db.getConnection();
        await connection.beginTransaction();

        // 1. Verfügbarkeit prüfen (Zeile sperren)
        const [books] = await connection.query(
            'SELECT AmountInStock FROM books WHERE ID = ? FOR UPDATE',
            [BookID]
        );
        if (books.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Buch nicht gefunden' });
        }
        if (books[0].AmountInStock < 1) {
            await connection.rollback();
            return res.status(409).json({ error: 'Buch nicht verfügbar' });
        }

        // 2. Bestand reduzieren
        await connection.query(
            'UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = ?',
            [BookID]
        );

        // 3. Ausleihe erfassen (unbekannte CustomerID: Fehler, Rollback, 400)
        const [result] = await connection.query(
            `INSERT INTO lends (BookID, CustomerID, Price, Date_From, Date_To)
             VALUES (?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY))`,
            [BookID, CustomerID, Price ?? null, days]
        );

        await connection.commit();

        const [lends] = await connection.query('SELECT * FROM lends WHERE ID = ?', [result.insertId]);
        res.status(201).json(lends[0]);
    } catch (err) {
        if (connection) await connection.rollback();
        next(err);
    } finally {
        if (connection) connection.release();
    }
};

// PUT /api/lends/:id/return - Buch zurückgeben
exports.returnLend = async (req, res, next) => {
    const { id } = req.params;
    let connection;

    try {
        connection = await db.getConnection();
        await connection.beginTransaction();

        // 1. Ausleihe suchen und sperren
        const [lends] = await connection.query(
            'SELECT BookID FROM lends WHERE ID = ? FOR UPDATE',
            [id]
        );
        if (lends.length === 0) {
            await connection.rollback();
            return res.status(404).json({ error: 'Ausleihe nicht gefunden' });
        }

        // 2. Date_To auf das aktuelle Datum setzen
        await connection.query('UPDATE lends SET Date_To = NOW() WHERE ID = ?', [id]);

        // 3. Bestand wieder erhöhen
        await connection.query(
            'UPDATE books SET AmountInStock = AmountInStock + 1 WHERE ID = ?',
            [lends[0].BookID]
        );

        await connection.commit();

        const [updated] = await connection.query('SELECT * FROM lends WHERE ID = ?', [id]);
        res.json(updated[0]);
    } catch (err) {
        if (connection) await connection.rollback();
        next(err);
    } finally {
        if (connection) connection.release();
    }
};
```

**Hinweis:** `lends` hat keine Spalte für "zurückgegeben". Ein zweiter Aufruf von `PUT /api/lends/:id/return` würde den Bestand erneut erhöhen. In einem echten Projekt sollte dafür eine eigene Spalte ergänzt werden.

### Routes

```javascript
// routes/bookRoutes.js
const express = require('express');
const router = express.Router();
const bookController = require('../controllers/bookController');
const { validateBook } = require('../middleware/validation');

router.get('/', bookController.getAllBooks);
router.get('/:id', bookController.getBookById);
router.get('/:id/lends', bookController.getBookLends);
router.post('/', validateBook, bookController.createBook);
router.put('/:id', validateBook, bookController.updateBook);
router.delete('/:id', bookController.deleteBook);

module.exports = router;
```

```javascript
// routes/authorRoutes.js
const express = require('express');
const router = express.Router();
const authorController = require('../controllers/authorController');
const { validateAuthor } = require('../middleware/validation');

router.get('/', authorController.getAllAuthors);
router.get('/:id', authorController.getAuthorById);
router.get('/:id/books', authorController.getAuthorBooks);
router.post('/', validateAuthor, authorController.createAuthor);
router.put('/:id', validateAuthor, authorController.updateAuthor);
router.delete('/:id', authorController.deleteAuthor);

module.exports = router;
```

```javascript
// routes/lendRoutes.js
const express = require('express');
const router = express.Router();
const lendController = require('../controllers/lendController');
const { validateLend } = require('../middleware/validation');

router.post('/', validateLend, lendController.createLend);
router.put('/:id/return', lendController.returnLend);

module.exports = router;
```

### server.js

```javascript
// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { errorHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/books', require('./routes/bookRoutes'));
app.use('/api/authors', require('./routes/authorRoutes'));
app.use('/api/lends', require('./routes/lendRoutes'));
app.use('/api/genres', require('./routes/genreRoutes'));   // Übung 3
app.use('/api/stats', require('./routes/statsRoutes'));    // Übung 3

// Root-Route mit Übersicht
app.get('/', (req, res) => {
    res.json({
        message: 'HFTM Library API v1.0',
        endpoints: {
            books: '/api/books',
            authors: '/api/authors',
            lends: '/api/lends',
            genres: '/api/genres',
            stats: '/api/stats'
        }
    });
});

// Unbekannte Endpunkte: 404
app.use((req, res) => {
    res.status(404).json({ error: 'Endpunkt nicht gefunden' });
});

// Fehlerbehandlung: nach allen Routes
app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`Server läuft auf http://localhost:${PORT}`);
});
```

**Bewertung Übung 1:**
- 1 Punkt: Books CRUD mit Validierung und korrekten Statuscodes (200, 201, 204, 400, 404)
- 1 Punkt: Authors CRUD
- 1 Punkt: `GET /api/books/:id/lends` (JOIN mit `customers`)
- 1 Punkt: `POST /api/lends` und `PUT /api/lends/:id/return` mit Transaktion

---

## Übung 2: Erweiterte Suche (2 Punkte)

Gelöst in `bookController.getAllBooks` (siehe oben). Die Parameter lassen sich kombinieren:

| Anfrage | Wirkung |
|---|---|
| `GET /api/books?search=harry` | `Titel LIKE '%harry%'` |
| `GET /api/books?authorId=1` | `AuthorsID = 1` |
| `GET /api/books?page=2&limit=10` | Einträge 11-20 |
| `GET /api/books?sortBy=Titel&order=asc` | `ORDER BY Titel ASC` |
| `GET /api/books?search=the&sortBy=Published_Date&order=desc&page=1&limit=5` | alles kombiniert |

Wichtige Punkte:

- Suchbegriff und Autor gehen als Platzhalter `?` in die Abfrage.
- `sortBy` und `order` können nicht als Platzhalter übergeben werden und werden deshalb gegen eine Whitelist geprüft. Ungültige Werte führen zur Standardsortierung nach `ID`.
- `COUNT(*)` verwendet dieselben Filter, damit `total` und `totalPages` stimmen.

**Response für `GET /api/books?search=lost&limit=1`:**

```json
{
    "data": [
        {
            "ID": 2,
            "ISBN": "586-25-07337-83-2",
            "Titel": "Paradise Lost",
            "Published_Date": "1985-09-19T00:00:00.000Z",
            "AmountInStock": 5,
            "AuthorsID": 1252,
            "PublishersID": 15,
            "GenresID": 20
        }
    ],
    "pagination": {
        "page": 1,
        "limit": 1,
        "total": 389,
        "totalPages": 389
    }
}
```

**Bewertung Übung 2:**
- 1 Punkt: Suche und Filter mit Prepared Statements
- 1 Punkt: Pagination und Sortierung mit Whitelist

---

## Übung 3: Relationen (2 Punkte)

`GET /api/authors/:id/books` ist bereits in `authorController.getAuthorBooks` enthalten.

### controllers/genreController.js

```javascript
// controllers/genreController.js
const db = require('../config/db');

// GET /api/genres/:id/authors - Autoren eines Genres über authors_genres
exports.getGenreAuthors = async (req, res, next) => {
    try {
        const [genres] = await db.query('SELECT ID FROM genres WHERE ID = ?', [req.params.id]);
        if (genres.length === 0) {
            return res.status(404).json({ error: 'Genre nicht gefunden' });
        }

        const sql = `
            SELECT DISTINCT
                a.ID,
                a.Firstname,
                a.Lastname
            FROM authors a
            INNER JOIN authors_genres ag ON ag.AuthorsID = a.ID
            WHERE ag.GenresID = ?
            ORDER BY a.Lastname, a.Firstname
        `;

        const [authors] = await db.query(sql, [req.params.id]);
        res.json(authors);
    } catch (err) {
        next(err);
    }
};
```

### controllers/statsController.js

```javascript
// controllers/statsController.js
const db = require('../config/db');

// GET /api/stats/books-by-genre - Anzahl Bücher pro Genre
exports.getBooksByGenre = async (req, res, next) => {
    try {
        const sql = `
            SELECT
                g.ID,
                g.Genre,
                COUNT(b.ID) AS BookCount
            FROM genres g
            LEFT JOIN books b ON b.GenresID = g.ID
            GROUP BY g.ID, g.Genre
            ORDER BY BookCount DESC, g.Genre
        `;

        const [stats] = await db.query(sql);
        res.json(stats);
    } catch (err) {
        next(err);
    }
};
```

Der `LEFT JOIN` zeigt auch Genres ohne Bücher (mit `BookCount` 0). Bücher mit `GenresID = NULL` werden nicht gezählt.

### Routes

```javascript
// routes/genreRoutes.js
const express = require('express');
const router = express.Router();
const genreController = require('../controllers/genreController');

router.get('/:id/authors', genreController.getGenreAuthors);

module.exports = router;
```

```javascript
// routes/statsRoutes.js
const express = require('express');
const router = express.Router();
const statsController = require('../controllers/statsController');

router.get('/books-by-genre', statsController.getBooksByGenre);

module.exports = router;
```

**Response `GET /api/stats/books-by-genre` (Ausschnitt):**

```json
[
    { "ID": 29, "Genre": "Essays", "BookCount": 301 },
    { "ID": 24, "Genre": "Self-help", "BookCount": 300 }
]
```

(Die Zahlen hängen vom Datenstand ab.)

**Bewertung Übung 3:**
- 1 Punkt: `GET /api/authors/:id/books` und `GET /api/genres/:id/authors` (JOIN über `authors_genres`)
- 1 Punkt: Statistik mit `GROUP BY` und `COUNT`

---

## Übung 4: Ärztezentrum API

Die Lösung hängt vom eigenen Datenbankentwurf ab. Das Beispiel verwendet die Tabellen `patients`, `doctors` und `appointments` aus Lektion 2. Die JSON-Felder heissen auch hier wie die Spalten der eigenen Datenbank.

```javascript
// controllers/patientController.js
const db = require('../config/db');

exports.getAllPatients = async (req, res, next) => {
    try {
        const [patients] = await db.query('SELECT * FROM patients ORDER BY last_name, first_name');
        res.json(patients);
    } catch (err) {
        next(err);
    }
};

exports.getPatientById = async (req, res, next) => {
    try {
        const [patients] = await db.query('SELECT * FROM patients WHERE patient_id = ?', [req.params.id]);
        if (patients.length === 0) {
            return res.status(404).json({ error: 'Patient nicht gefunden' });
        }
        res.json(patients[0]);
    } catch (err) {
        next(err);
    }
};

exports.createPatient = async (req, res, next) => {
    try {
        const { first_name, last_name, birth_date, email } = req.body;
        if (!first_name || !last_name) {
            return res.status(400).json({ error: 'first_name und last_name sind erforderlich' });
        }

        const [result] = await db.query(
            'INSERT INTO patients (first_name, last_name, birth_date, email) VALUES (?, ?, ?, ?)',
            [first_name, last_name, birth_date ?? null, email ?? null]
        );
        res.status(201).json({ patient_id: result.insertId, first_name, last_name, birth_date, email });
    } catch (err) {
        next(err); // doppelte E-Mail (UNIQUE): 409 über errorHandler
    }
};

exports.updatePatient = async (req, res, next) => {
    try {
        const { first_name, last_name, birth_date, email } = req.body;
        const [result] = await db.query(
            `UPDATE patients SET first_name = ?, last_name = ?, birth_date = ?, email = ?
             WHERE patient_id = ?`,
            [first_name, last_name, birth_date ?? null, email ?? null, req.params.id]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Patient nicht gefunden' });
        }
        res.json({ patient_id: Number(req.params.id), first_name, last_name, birth_date, email });
    } catch (err) {
        next(err);
    }
};

exports.deletePatient = async (req, res, next) => {
    try {
        const [result] = await db.query('DELETE FROM patients WHERE patient_id = ?', [req.params.id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Patient nicht gefunden' });
        }
        res.status(204).send();
    } catch (err) {
        next(err);
    }
};

// GET /api/patients/:id/appointments
exports.getPatientAppointments = async (req, res, next) => {
    try {
        const sql = `
            SELECT ap.appointment_id, ap.appointment_date, ap.appointment_time,
                   ap.reason, ap.status, d.doctor_id, d.name AS doctor_name
            FROM appointments ap
            INNER JOIN doctors d ON ap.doctor_id = d.doctor_id
            WHERE ap.patient_id = ?
            ORDER BY ap.appointment_date, ap.appointment_time
        `;
        const [appointments] = await db.query(sql, [req.params.id]);
        res.json(appointments);
    } catch (err) {
        next(err);
    }
};
```

`doctorController.js` und `appointmentController.js` werden nach demselben Muster erstellt. `GET /api/doctors/:id/appointments` entspricht `getPatientAppointments` mit `WHERE ap.doctor_id = ?` und einem JOIN auf `patients`.

```javascript
// routes/patientRoutes.js
const express = require('express');
const router = express.Router();
const patientController = require('../controllers/patientController');

router.get('/', patientController.getAllPatients);
router.get('/:id', patientController.getPatientById);
router.get('/:id/appointments', patientController.getPatientAppointments);
router.post('/', patientController.createPatient);
router.put('/:id', patientController.updatePatient);
router.delete('/:id', patientController.deletePatient);

module.exports = router;
```

---

## Übung 5: API-Dokumentation (2 Punkte)

Musterlösung für die `README.md` (Ausschnitt, die übrigen Endpunkte analog):

````markdown
# HFTM Library API

## Base URL

`http://localhost:3000/api`

## Fehlerformat

| Status | Bedeutung |
|---|---|
| 400 | Ungültige Daten, Antwort `{ "errors": [...] }` oder `{ "error": "..." }` |
| 404 | Ressource nicht gefunden |
| 409 | Konflikt (Datensatz wird noch verwendet, Buch nicht verfügbar) |
| 500 | Interner Serverfehler |

## Books

### GET /books

Liefert Bücher seitenweise.

**Query Parameters:** `search`, `authorId`, `page` (Standard 1), `limit` (Standard 10, max. 100),
`sortBy` (`ID`, `Titel`, `Published_Date`, `AmountInStock`), `order` (`asc`, `desc`)

**Response:** 200 OK, `{ "data": [...], "pagination": { "page", "limit", "total", "totalPages" } }`

### GET /books/:id

**Response:** 200 OK / 404 Not Found

### POST /books

**Body:**

```json
{
    "Titel": "The Hobbit",
    "ISBN": "978-05-47928-22-7",
    "AmountInStock": 3,
    "AuthorsID": 1,
    "PublishersID": 1
}
```

**Response:** 201 Created mit dem erstellten Buch inkl. `ID` / 400 Bad Request

### PUT /books/:id

Body wie bei POST. **Response:** 200 OK / 400 / 404

### DELETE /books/:id

**Response:** 204 No Content / 404 / 409 (Buch hat Ausleihen)

### GET /books/:id/lends

**Response:** 200 OK

```json
[
    {
        "ID": 1,
        "Date_From": "2020-01-05T00:00:00.000Z",
        "Date_To": "2020-02-05T00:00:00.000Z",
        "Price": 8.5,
        "CustomerID": 997,
        "Firstname": "Logan",
        "Lastname": "Allen"
    }
]
```

## Lends

### POST /lends

**Body:** (`Price` und `Days` optional, Standard für `Days` ist 30)

```json
{
    "BookID": 2,
    "CustomerID": 1,
    "Price": 4.5,
    "Days": 14
}
```

**Response:** 201 Created mit der neuen Ausleihe / 400 (ungültige Daten oder unbekannte `CustomerID`) /
404 (Buch nicht gefunden) / 409 (Buch nicht verfügbar)

### PUT /lends/:id/return

Setzt `Date_To` auf das aktuelle Datum und erhöht `AmountInStock`.

**Response:** 200 OK mit der aktualisierten Ausleihe / 404
````

**Bewertung Übung 5:**
- 1 Punkt: Alle Endpunkte mit Methode und URL dokumentiert
- 1 Punkt: Request- und Response-Beispiele sowie Fehlercodes

---

## Testfälle (Postman / curl)

```bash
# Books
curl "http://localhost:3000/api/books?search=lost&sortBy=Titel&order=asc&page=1&limit=5"
curl http://localhost:3000/api/books/2
curl http://localhost:3000/api/books/2301/lends

curl -X POST http://localhost:3000/api/books \
  -H "Content-Type: application/json" \
  -d '{"Titel":"Test Book","ISBN":"123-45-67890-12-3","AmountInStock":2,"AuthorsID":1,"PublishersID":1}'

curl -X PUT http://localhost:3000/api/books/<neue ID> \
  -H "Content-Type: application/json" \
  -d '{"Titel":"Test Book (Update)","ISBN":"123-45-67890-12-3","AmountInStock":4,"AuthorsID":1,"PublishersID":1}'

curl -i -X DELETE http://localhost:3000/api/books/<neue ID>

# Authors
curl -X POST http://localhost:3000/api/authors \
  -H "Content-Type: application/json" \
  -d '{"Firstname":"Test","Lastname":"Autorin","Email":"test.autorin@example.com"}'
curl http://localhost:3000/api/authors/1252/books

# Lends
curl -X POST http://localhost:3000/api/lends \
  -H "Content-Type: application/json" \
  -d '{"BookID":2,"CustomerID":1,"Price":4.5,"Days":14}'
curl -X PUT http://localhost:3000/api/lends/<neue ID>/return

# Relationen und Statistik
curl http://localhost:3000/api/genres/1/authors
curl http://localhost:3000/api/stats/books-by-genre
```

**Fehlerfälle:**

| Anfrage | Erwartet |
|---|---|
| `GET /api/books/999999` | 404 |
| `POST /api/books` ohne `Titel` | 400 mit `errors` |
| `POST /api/books` mit `"ISBN": "123"` | 400 (ISBN-Format) |
| `POST /api/books` mit `"AuthorsID": 999999` | 400 (Referenzierter Datensatz existiert nicht) |
| `DELETE /api/books/2301` (Buch mit Ausleihen) | 409 |
| `POST /api/lends` für ein Buch mit `AmountInStock` 0 | 409 |
| `POST /api/lends` mit `"CustomerID": 999999` | 400, Bestand unverändert (Rollback) |
| `PUT /api/lends/999999/return` | 404 |

**Hinweis für Windows:** Die curl-Beispiele in Git Bash ausführen oder in PowerShell `curl.exe` verwenden.

---

## Bewertungsraster Credit 8

| Übung | Punkte | Kriterien |
|---|---|---|
| **1** REST API | 4 | Books und Authors CRUD, Ausleihen eines Buchs, Ausleihe und Rückgabe mit Transaktion, Controller und Routes getrennt |
| **2** Erweiterte Suche | 2 | Suche, Filter, Pagination, Sortierung (Whitelist) |
| **3** Relationen | 2 | Bücher eines Autors, Autoren eines Genres, Statistik pro Genre |
| **5** Dokumentation | 2 | README mit Endpunkten, Beispielen und Fehlercodes |
| **TOTAL** | **10** | |

Übung 4 (Ärztezentrum API) ist Teil der Projektarbeit und wird dort bewertet.

---

## Abgabe

**Format:** ZIP-Datei mit dem kompletten Projekt

**Enthält:**
- [ ] Kompletter Code (ohne `node_modules/`)
- [ ] `.env.example` (ohne echte Zugangsdaten)
- [ ] Postman-Collection (als JSON exportiert)
- [ ] Screenshots der getesteten Endpunkte, inkl. mindestens 2 Fehlerfällen
- [ ] `README.md` mit der API-Dokumentation

**Naming:** `Credit8_Vorname_Nachname.zip`

**Deadline:** Siehe Moodle

---

## Tipps

- Statuscodes korrekt verwenden: 200 (GET, PUT), 201 (POST), 204 (DELETE), 400, 404, 409, 500
- Eingaben immer validieren und klare Fehlermeldungen zurückgeben
- In Controllern `try/catch` mit `next(err)`, keine Stack Traces an den Client senden
- Werte nur über Platzhalter `?` in SQL einsetzen, Spaltennamen für `ORDER BY` nur aus einer Whitelist
- Feste Pfade (z.B. `/with-authors`) vor `/:id` registrieren
- JSON-Felder und SQL-Spalten genau wie im Dump schreiben (`Titel`, `AuthorsID`, `AmountInStock`)

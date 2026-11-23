# Lektion 7: Node.js und Datenbanken

## Lernziele

Die/der Studierende ist in der Lage...

- Node.js zu installieren und ein Projekt mit npm einzurichten
- Von JavaScript aus eine Verbindung zu MariaDB/MySQL herzustellen
- Eine Datenbank von JavaScript aus mit Daten zu füllen und SQL-Abfragen auszuführen
- Die grundlegenden CRUD-Operationen zu implementieren
- Prepared Statements zur Vermeidung von SQL-Injection zu verstehen und anzuwenden
- Transaktionen und Fehlerbehandlung in Node.js einzusetzen

## Vorbereitung

- Node.js und npm auf dem Laptop installiert
- MariaDB-Server läuft
- HeidiSQL installiert
- Die HFTM Library Datenbank (`hftm_library`) ist importiert
- Das Demo-Projekt `db-nodejs-demo/` aus diesem Ordner liegt bereit

## Was ist Node.js?

**Node.js** ist eine JavaScript-Laufzeitumgebung, die es ermöglicht, JavaScript ausserhalb des Browsers auszuführen. Damit können Server-Anwendungen entwickelt werden, die auf Datenbanken zugreifen.

### Eigenschaften

- **JavaScript auf dem Server**: Die gleiche Sprache wie im Browser
- **Event-driven**: Ereignisse werden asynchron verarbeitet
- **Non-blocking I/O**: Sehr leistungsfähig bei vielen gleichzeitigen Verbindungen
- **NPM**: Das grösste Paket-Verzeichnis der Welt
- **Single-threaded**: Nebenläufigkeit wird über den Event Loop erreicht

### Typische Einsatzgebiete

**Gut geeignet für:**

- REST APIs
- Echtzeit-Anwendungen (Chat, Benachrichtigungen)
- Microservices
- Daten-Streaming
- IoT-Anwendungen

**Weniger geeignet für:**

- CPU-intensive Berechnungen
- Anwendungen mit viel synchroner Verarbeitung

## Installation von Node.js

### Windows

1. Von [nodejs.org](https://nodejs.org) herunterladen
2. Die LTS-Version (Long Term Support) wählen
3. Das Installationsprogramm ausführen
4. Die Installation prüfen (siehe unten)

### Installation prüfen

```bash
# Node.js-Version prüfen
node --version
# Sollte etwa v20.x.x oder neuer anzeigen

# npm-Version prüfen
npm --version
# Sollte etwa 10.x.x oder neuer anzeigen
```

## Erstes Node.js-Programm

### Hello World

```javascript
// hello.js
console.log('Hello World from Node.js!');
```

Ausführen:

```bash
node hello.js
```

### Einfacher HTTP-Server

```javascript
// server.js
const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('Hello from Node.js server!');
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
```

Ausführen:

```bash
node server.js
```

Testen: `http://localhost:3000` im Browser öffnen.

## NPM - Node Package Manager

**npm** ist der Paketmanager für Node.js und verwaltet die Bibliotheken (Packages) eines Projekts.

### Projekt initialisieren

```bash
# Neuen Ordner erstellen
mkdir db-nodejs-demo
cd db-nodejs-demo

# npm-Projekt initialisieren
npm init -y
```

Dies erstellt eine Datei `package.json` mit den Projekt-Metadaten:

```json
{
  "name": "db-nodejs-demo",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

### Packages installieren

```bash
# mysql2: Treiber für MariaDB/MySQL
npm install mysql2

# dotenv: Umgebungsvariablen aus einer .env-Datei laden
npm install dotenv

# Oder beide auf einmal
npm install mysql2 dotenv

# Express wird erst in Lektion 8 benötigt
npm install express
```

Die installierten Packages erscheinen in der `package.json`:

```json
{
  "dependencies": {
    "dotenv": "^17.2.3",
    "mysql2": "^3.15.3"
  }
}
```

### NPM-Scripts

In der `package.json` können Befehle als Scripts hinterlegt werden:

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "node test-connection.js"
  }
}
```

Ausführen:

```bash
npm start
npm run dev
npm test
```

## Umgebungsvariablen mit dotenv

Zugangsdaten (Credentials) gehören **niemals** direkt in den Code. Mit `dotenv` werden sensible Daten wie Passwörter in einer `.env`-Datei gespeichert.

### .env-Datei

Erstelle eine Datei `.env` im Projektordner (im Demo-Projekt liegt die Vorlage `env.sample`):

```ini
DB_HOST=localhost
DB_USER=hftm_library
DB_PASSWORD=hftm-2025
DB_NAME=hftm_library
DB_PORT=3306
```

### .gitignore

**Wichtig:** Die `.env`-Datei muss in `.gitignore` aufgenommen werden, damit Passwörter nicht ins Repository gelangen.

```text
node_modules/
.env
```

## Verbindung zu MariaDB/MySQL

### Das Package mysql2

**mysql2** ist der MySQL/MariaDB-Treiber für Node.js. Er ist modern, schnell und unterstützt Promises (async/await).

### Einfache Verbindung (Callback-Stil)

Eine einzelne Verbindung mit Callbacks zeigt das Grundprinzip:

```javascript
// simple-connection.js
require('dotenv').config();
const mysql = require('mysql2');

// Eine einzelne Verbindung erstellen
const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
});

// Erste Abfrage
connection.query('SELECT * FROM books LIMIT 5', (err, results) => {
    if (err) {
        console.error('Fehler bei der Abfrage:', err.message);
        return connection.end();
    }
    console.log('Bücher:', results);
    connection.end();
});
```

Für echte Anwendungen ist dieser Stil unpraktisch: Verschachtelte Callbacks werden schnell unübersichtlich ("Callback Hell") und eine einzelne Verbindung kann nur eine Abfrage gleichzeitig bearbeiten.

### Connection Pool (empfohlen)

Ein **Connection Pool** hält mehrere Verbindungen offen und verteilt die Abfragen darauf. Das ist effizient für Anwendungen mit vielen gleichzeitigen Anfragen.

Erstelle die Datei `db.js` (entspricht `db-nodejs-demo/db.js`):

```javascript
// db.js
require('dotenv').config();
const mysql = require('mysql2');

// Connection Pool erstellen (effizient für mehrere Anfragen)
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
const promisePool = pool.promise();

module.exports = promisePool;
```

### Verbindung testen

Erstelle `test-connection.js`:

```javascript
// test-connection.js
const db = require('./db');

async function testConnection() {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS result');
        console.log('Datenbankverbindung erfolgreich!');
        console.log('Test Query Result:', rows[0].result);
    } catch (error) {
        console.error('Fehler bei Datenbankverbindung:', error.message);
    } finally {
        process.exit();
    }
}

testConnection();
```

Ausführen:

```bash
node test-connection.js
```

## Async/Await mit mysql2

Die moderne Variante verwendet **async/await** statt Callbacks. `db.query()` liefert ein Array zurück: Das erste Element enthält die Zeilen, das zweite die Feld-Informationen.

```javascript
// test-read.js
const db = require('./db');

async function getAllBooks() {
    try {
        const [books] = await db.query('SELECT * FROM books LIMIT 3');
        console.log('Alle Bücher:', books);
        return books;
    } catch (error) {
        console.error('Fehler beim Lesen:', error.message);
    }
}

getAllBooks();
```

## CRUD-Operationen

Die folgenden Beispiele verwenden die Tabellen der HFTM Library Datenbank:

| Tabelle | Wichtige Spalten |
|---|---|
| `books` | `ID`, `ISBN`, `Titel`, `Published_Date`, `AmountInStock`, `AuthorsID`, `PublishersID`, `GenresID` |
| `authors` | `ID`, `Firstname`, `Lastname`, `Email` |
| `customers` | `ID`, `Lastname`, `Firstname`, `Email`, `LocationID` |
| `lends` | `ID`, `Date_From`, `Date_To`, `Price`, `CustomerID`, `BookID` |

### CREATE - Daten einfügen

```javascript
const db = require('./db');

async function createBook(title, isbn, amountInStock, authorId, publisherId) {
    try {
        const sql = `
            INSERT INTO books (Titel, ISBN, AmountInStock, AuthorsID, PublishersID)
            VALUES (?, ?, ?, ?, ?)
        `;
        const [result] = await db.query(sql, [title, isbn, amountInStock, authorId, publisherId]);
        console.log('Buch hinzugefügt mit ID:', result.insertId);
        return result.insertId;
    } catch (error) {
        console.error('Fehler beim Einfügen:', error.message);
        throw error;
    }
}

// Verwendung
createBook('Clean Code', '978-0-13-235088-4', 3, 1, 1);
```

### READ - Daten lesen

```javascript
// Alle Bücher (begrenzt auf 10)
async function getAllBooks() {
    const [rows] = await db.query('SELECT * FROM books LIMIT 10');
    return rows;
}

// Buch nach ID suchen
async function getBookById(id) {
    const [rows] = await db.query(
        'SELECT * FROM books WHERE ID = ?',
        [id]
    );
    return rows[0];
}

// Suche nach Titel (Teilstring)
async function searchBooks(searchTerm) {
    const [rows] = await db.query(
        'SELECT * FROM books WHERE Titel LIKE ?',
        [`%${searchTerm}%`]
    );
    return rows;
}
```

### UPDATE - Daten aktualisieren

```javascript
async function updateBook(id, title, isbn) {
    try {
        const sql = `
            UPDATE books
            SET Titel = ?, ISBN = ?
            WHERE ID = ?
        `;
        const [result] = await db.query(sql, [title, isbn, id]);
        console.log('Zeilen aktualisiert:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Fehler beim Aktualisieren:', error.message);
        throw error;
    }
}

// Verwendung
updateBook(1, 'Clean Code (2nd Edition)', '978-0-13-235088-4');
```

### DELETE - Daten löschen

```javascript
async function deleteBook(id) {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE ID = ?',
            [id]
        );
        console.log('Zeilen gelöscht:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Fehler beim Löschen:', error.message);
        throw error;
    }
}

// Verwendung
deleteBook(5);
```

**Hinweis:** Ein Buch, das in `lends` referenziert wird, kann wegen des Fremdschlüssels nicht gelöscht werden (Fehlercode `ER_ROW_IS_REFERENCED_2`).

## Prepared Statements und SQL-Injection

### Was ist SQL-Injection?

SQL-Injection ist eine Sicherheitslücke, bei der ein Angreifer SQL-Code über Eingabefelder in eine Abfrage einschleust.

### Unsichere Abfrage

```javascript
// NIEMALS SO MACHEN!
async function unsafeFindCustomer(userInput) {
    const sql = `SELECT * FROM customers WHERE ID = ${userInput}`;
    const [rows] = await db.query(sql);
    return rows;
}

// Angriff: userInput = "1 OR 1=1"
// Resultierende Abfrage: SELECT * FROM customers WHERE ID = 1 OR 1=1
// Gibt ALLE Kunden zurück!

async function unsafeSearch(searchTerm) {
    const sql = `SELECT * FROM books WHERE Titel = '${searchTerm}'`;
    const [rows] = await db.query(sql);
    return rows;
}

// Angriff: searchTerm = "' OR '1'='1"
// Gibt ALLE Bücher zurück!
```

**Hinweis:** mysql2 erlaubt standardmässig keine mehreren Anweisungen pro Abfrage (`multipleStatements: false`). Ein Angriff wie `'; DROP TABLE books; --` scheitert deshalb, das Auslesen fremder Daten wie oben funktioniert aber trotzdem.

### Sichere Abfrage mit Prepared Statements

Das Zeichen `?` dient als Platzhalter. Der Wert wird separat übergeben, automatisch escaped und kann den SQL-Befehl nicht verändern.

```javascript
// SICHER mit Platzhaltern
async function safeFindCustomer(userInput) {
    const [rows] = await db.query(
        'SELECT * FROM customers WHERE ID = ?',
        [userInput]
    );
    return rows;
}

async function safeSearch(searchTerm) {
    const sql = 'SELECT * FROM books WHERE Titel = ?';
    const [rows] = await db.query(sql, [searchTerm]);
    return rows;
}
```

`db.query()` ersetzt die Platzhalter clientseitig mit korrekt escapten Werten. `db.execute()` sendet hingegen ein echtes serverseitiges Prepared Statement. Beide Varianten schützen vor SQL-Injection.

### Mehrere Parameter

Die Werte im Array werden der Reihe nach den Platzhaltern zugeordnet:

```javascript
async function createAuthor(firstname, lastname, email) {
    const sql = `
        INSERT INTO authors (Firstname, Lastname, Email)
        VALUES (?, ?, ?)
    `;
    const [result] = await db.query(sql, [firstname, lastname, email]);
    return result.insertId;
}
```

## JOIN-Abfragen in Node.js

```javascript
async function getBooksWithAuthors() {
    try {
        const sql = `
            SELECT
                b.ID,
                b.Titel,
                b.ISBN,
                a.Firstname,
                a.Lastname
            FROM books b
            INNER JOIN authors a ON b.AuthorsID = a.ID
            ORDER BY b.Titel
            LIMIT 20
        `;
        const [rows] = await db.query(sql);
        return rows;
    } catch (error) {
        console.error('Fehler bei JOIN:', error.message);
        throw error;
    }
}
```

## Transaktionen

Transaktionen stellen sicher, dass mehrere Datenbankoperationen entweder alle erfolgreich sind oder alle rückgängig gemacht werden. Dafür wird eine eigene Verbindung aus dem Pool geholt.

Beispiel: Ein Buch ausleihen (Bestand prüfen, Bestand reduzieren, Ausleihe erfassen):

```javascript
async function lendBook(bookId, customerId, days = 30) {
    const connection = await db.getConnection();

    try {
        // Transaktion starten
        await connection.beginTransaction();

        // 1. Verfügbarkeit prüfen (Zeile für andere Transaktionen sperren)
        const [books] = await connection.query(
            'SELECT AmountInStock FROM books WHERE ID = ? FOR UPDATE',
            [bookId]
        );
        if (books.length === 0 || books[0].AmountInStock < 1) {
            throw new Error('Buch nicht verfügbar');
        }

        // 2. Bestand reduzieren
        await connection.query(
            'UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = ?',
            [bookId]
        );

        // 3. Ausleihe erfassen
        await connection.query(
            `INSERT INTO lends (BookID, CustomerID, Date_From, Date_To)
             VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY))`,
            [bookId, customerId, days]
        );

        // Transaktion bestätigen
        await connection.commit();
        console.log('Ausleihe erfolgreich');

    } catch (error) {
        // Bei Fehler: Transaktion rückgängig machen
        await connection.rollback();
        console.error('Ausleihe fehlgeschlagen:', error.message);
        throw error;

    } finally {
        // Verbindung immer an den Pool zurückgeben
        connection.release();
    }
}
```

## Fehlerbehandlung

Eine zentrale Hilfsfunktion liefert ein einheitliches Resultat:

```javascript
async function safeQuery(sql, params = []) {
    try {
        const [rows] = await db.query(sql, params);
        return { success: true, data: rows };
    } catch (error) {
        console.error('Datenbankfehler:', error.message);
        return { success: false, error: error.message };
    }
}

// Verwendung (await nur innerhalb einer async-Funktion)
async function main() {
    const result = await safeQuery('SELECT * FROM books WHERE ID = ?', [42]);
    if (result.success) {
        console.log('Daten:', result.data);
    } else {
        console.log('Fehler:', result.error);
    }
}

main();
```

MariaDB/MySQL-Fehler besitzen einen Code (`err.code`), mit dem gezielt reagiert werden kann:

```javascript
async function getBookSafe(id) {
    try {
        const [rows] = await db.query(
            'SELECT * FROM books WHERE ID = ?',
            [id]
        );

        if (rows.length === 0) {
            throw new Error('Buch nicht gefunden');
        }

        return rows[0];

    } catch (err) {
        if (err.code === 'ER_NO_SUCH_TABLE') {
            console.error('Tabelle existiert nicht');
        } else if (err.code === 'ER_BAD_FIELD_ERROR') {
            console.error('Spalte existiert nicht');
        } else {
            console.error('Fehler:', err.message);
        }

        throw err;
    }
}
```

## Projektstruktur

Für grössere Anwendungen (ab Lektion 8) hat sich folgende Struktur bewährt:

```text
db-nodejs-demo/
├── config/
│   └── db.js                # Datenbank-Konfiguration
├── controllers/
│   ├── bookController.js    # Logik für Bücher
│   └── authorController.js  # Logik für Autoren
├── models/
│   ├── Book.js              # Datenmodell
│   └── Author.js
├── routes/
│   ├── bookRoutes.js        # API-Routen
│   └── authorRoutes.js
├── .env                     # Umgebungsvariablen
├── .gitignore
├── package.json
└── server.js                # Einstiegspunkt
```

## Debugging

### SQL-Abfragen ausgeben

```javascript
// innerhalb einer async-Funktion
const sql = 'SELECT * FROM books WHERE AuthorsID = ?';
const params = [1];

console.log('SQL:', sql);
console.log('Parameter:', params);

const [rows] = await db.query(sql, params);
```

### Resultate ausgeben

```javascript
// innerhalb einer async-Funktion
const [rows] = await db.query('SELECT * FROM books LIMIT 5');

console.log('Anzahl Zeilen:', rows.length);
console.log('Erste Zeile:', rows[0]);
console.log('Alle Zeilen:', JSON.stringify(rows, null, 2));
```

## Praktische Übungen

### Übung 1: Setup

1. Ein neues Node.js-Projekt erstellen
2. `mysql2` und `dotenv` installieren
3. Eine `.env`-Datei mit den Zugangsdaten erstellen
4. Eine Verbindung zur HFTM Library herstellen und mit `test-connection.js` testen

### Übung 2: CRUD-Operationen

Funktionen für folgende Operationen erstellen:

```javascript
// Authors
async function getAllAuthors() { }
async function getAuthorById(id) { }
async function createAuthor(firstname, lastname, email) { }
async function updateAuthor(id, firstname, lastname, email) { }
async function deleteAuthor(id) { }

// Books
async function getAllBooks() { }
async function getBookById(id) { }
async function createBook(title, isbn, amountInStock, authorId, publisherId) { }
async function updateBook(id, title, isbn) { }
async function deleteBook(id) { }
```

### Übung 3: Erweiterte Abfragen in der HFTM Library

```javascript
// 1. Bücher nach Titel suchen
async function searchBooksByTitle(searchTerm) { }

// 2. Alle Bücher eines bestimmten Autors anzeigen
async function getBooksByAuthor(authorId) { }

// 3. Bücher mit Autoren (JOIN)
async function getBooksWithAuthors() { }

// 4. Anzahl Bücher pro Autor
async function getBookCountByAuthor() { }

// 5. Anzahl ausgeliehener Bücher pro Kunde (JOIN)
async function getLendCountByCustomer() { }

// 6. Überfällige Ausleihen (Date_To in der Vergangenheit)
async function getOverdueLoans() { }
```

### Übung 4: Transaktion

Eine Ausleihe mit Transaktion implementieren (siehe `lendBook()`):

- Verfügbarkeit prüfen
- Bestand reduzieren
- Ausleihe mit Ausleihdatum erfassen
- Bei einem Fehler Rollback ausführen

Zusätzlich die Gegenfunktion `returnBook(lendId)` implementieren: Ausleihe abschliessen (`Date_To` auf `NOW()` setzen) und den Bestand wieder erhöhen, ebenfalls in einer Transaktion.

### Übung 5: Eigene Datenbank

CRUD-Operationen für die eigene Ärztezentrum-Datenbank implementieren:

1. Patienten verwalten (CREATE, READ, UPDATE, DELETE)
2. Termine abfragen (mit JOIN zu Ärzten und Patienten)
3. Neue Termine anlegen
4. Termine stornieren

### Übung 6: SQL-Injection testen

1. Eine unsichere Abfrage mit String-Konkatenation erstellen
2. Mit einem Injection-Versuch testen (z.B. `' OR '1'='1`)
3. Die sichere Version mit Prepared Statements implementieren
4. Den Unterschied dokumentieren

## Best Practices

### Code-Struktur

**Empfohlen:**

- Connection Pool verwenden
- async/await verwenden
- Prepared Statements (Platzhalter `?`) verwenden
- Fehler sauber behandeln
- Zugangsdaten in Umgebungsvariablen ablegen
- Verbindungen schliessen bzw. an den Pool zurückgeben

**Zu vermeiden:**

- Zugangsdaten im Code
- Abfragen, die für SQL-Injection anfällig sind
- Fehler ignorieren
- Verschachtelte Callbacks (Callback Hell)
- Nicht geschlossene Verbindungen

### Sicherheit

```javascript
// GUT: Platzhalter
const [customers] = await db.query(
    'SELECT * FROM customers WHERE Email = ?',
    [userEmail]
);

// SCHLECHT: SQL-Injection möglich!
const [unsafeCustomers] = await db.query(
    `SELECT * FROM customers WHERE Email = '${userEmail}'`
);
```

## Zusammenfassung

### Wichtige Befehle

```bash
# Projekt initialisieren
npm init -y

# Packages installieren
npm install mysql2 dotenv

# Anwendung ausführen
node app.js
```

### Grundgerüst

```javascript
// db.js
require('dotenv').config();
const mysql = require('mysql2');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT
});

module.exports = pool.promise();
```

```javascript
// app.js
const db = require('./db');

async function main() {
    try {
        const [rows] = await db.query('SELECT * FROM books LIMIT 10');
        console.log(rows);
    } catch (err) {
        console.error(err);
    } finally {
        // Pool schliessen, damit das Programm beendet wird
        await db.end();
    }
}

main();
```

## Hausaufgaben

1. **Node.js-Projekt einrichten** mit Verbindung zur Datenbank
2. **CRUD-Operationen implementieren** für 2 Entitäten
3. **Alle Funktionen testen** mit verschiedenen Parametern
4. **Code dokumentieren** mit Kommentaren

## Checkliste für Credit 6

- [ ] Node.js und npm installiert
- [ ] Projekt mit `package.json` erstellt
- [ ] Datenbankverbindung funktioniert
- [ ] Mindestens 3 CRUD-Operationen implementiert
- [ ] Prepared Statements verwendet
- [ ] Code dokumentiert und getestet
- [ ] Screenshot oder Ausgabe der funktionierenden Abfragen

## Ressourcen

- [Node.js Dokumentation](https://nodejs.org/docs/latest/api/)
- [mysql2 Package](https://github.com/sidorares/node-mysql2)
- [npm Dokumentation](https://docs.npmjs.com/)
- [dotenv Dokumentation](https://github.com/motdotla/dotenv)
- [SQL-Injection Erklärung (OWASP)](https://owasp.org/www-community/attacks/SQL_Injection)

## Nächste Schritte

In Lektion 8 wird ein REST API erstellt, das diese Datenbankoperationen über HTTP-Endpunkte zugänglich macht:

- Express.js für ein REST API
- Routes und Controllers
- Middleware
- API-Tests mit Postman

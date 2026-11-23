# Lektion 7: Node.js und Datenbanken

## Lernziele

- Von JavaScript aus auf eine SQL-Datenbank zugreifen
- Eine einfache Datenbank von JavaScript aus mit Daten füllen und Abfragen ausführen
- Prepared Statements zur Vermeidung von SQL-Injection verstehen und anwenden

## Vorbereitung

- Installation von Node.js und npm auf dem Laptop
- MariaDB Server sollte laufen
- HeidiSQL installiert

## Einführung Node.js

Node.js ist eine JavaScript-Runtime-Umgebung, die es ermöglicht, JavaScript außerhalb des Browsers auszuführen. Damit können Server-Anwendungen entwickelt werden, die auf Datenbanken zugreifen.

### NPM (Node Package Manager)

NPM ist der Paketmanager für Node.js und ermöglicht die Installation von Bibliotheken (Packages).

```bash
# Node.js Version prüfen
node --version

# NPM Version prüfen
npm --version
```

## Projekt Setup

### 1. Neues Node.js Projekt erstellen

```bash
# Neuen Ordner erstellen
mkdir db-nodejs-demo
cd db-nodejs-demo

# NPM Projekt initialisieren
npm init -y
```

Dies erstellt eine `package.json` Datei mit den Projekt-Metadaten.

### 2. MySQL2 Package installieren

```bash
npm install mysql2
```

Das `mysql2` Package ermöglicht die Verbindung zu MariaDB/MySQL Datenbanken.

### 3. dotenv für Umgebungsvariablen

```bash
npm install dotenv
```

Damit können sensible Daten wie Passwörter in einer `.env` Datei gespeichert werden.

## Datenbankverbindung

### .env Datei erstellen

Erstelle eine `.env` Datei im Projektordner:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=dein_passwort
DB_NAME=hftm_library
DB_PORT=3306
```

**WICHTIG:** Die `.env` Datei sollte in `.gitignore` aufgenommen werden, damit Passwörter nicht ins Repository gelangen!

### Verbindung zur Datenbank herstellen

Erstelle eine Datei `db.js`:

```javascript
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

// Promise Wrapper für async/await
const promisePool = pool.promise();

module.exports = promisePool;
```

### Verbindung testen

Erstelle `test-connection.js`:

```javascript
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

## CRUD Operationen

### SELECT - Daten lesen

```javascript
const db = require('./db');

async function getAllBooks() {
    try {
        const [books] = await db.query('SELECT * FROM books');
        console.log('Alle Bücher:', books);
        return books;
    } catch (error) {
        console.error('Fehler beim Lesen:', error.message);
    }
}

// Buch nach ID suchen
async function getBookById(bookId) {
    try {
        const [books] = await db.query(
            'SELECT * FROM books WHERE book_id = ?',
            [bookId]
        );
        return books[0];
    } catch (error) {
        console.error('Fehler:', error.message);
    }
}
```

### INSERT - Daten einfügen

```javascript
async function addBook(title, author, isbn, year) {
    try {
        const [result] = await db.query(
            'INSERT INTO books (title, author, isbn, publication_year) VALUES (?, ?, ?, ?)',
            [title, author, isbn, year]
        );
        console.log('Buch hinzugefügt mit ID:', result.insertId);
        return result.insertId;
    } catch (error) {
        console.error('Fehler beim Einfügen:', error.message);
    }
}

// Verwendung
addBook('Clean Code', 'Robert C. Martin', '978-0132350884', 2008);
```

### UPDATE - Daten aktualisieren

```javascript
async function updateBook(bookId, title, author) {
    try {
        const [result] = await db.query(
            'UPDATE books SET title = ?, author = ? WHERE book_id = ?',
            [title, author, bookId]
        );
        console.log('Zeilen aktualisiert:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Fehler beim Aktualisieren:', error.message);
    }
}
```

### DELETE - Daten löschen

```javascript
async function deleteBook(bookId) {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE book_id = ?',
            [bookId]
        );
        console.log('Zeilen gelöscht:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Fehler beim Löschen:', error.message);
    }
}
```

## Prepared Statements und SQL-Injection

### Was ist SQL-Injection?

SQL-Injection ist eine Sicherheitslücke, bei der ein Angreifer SQL-Code in Eingabefelder einschleust.

**Beispiel einer unsicheren Abfrage:**

```javascript
// NIEMALS SO MACHEN!
const userInput = "1 OR 1=1";
const query = `SELECT * FROM users WHERE user_id = ${userInput}`;
// Resultierende Query: SELECT * FROM users WHERE user_id = 1 OR 1=1
// Gibt ALLE Benutzer zurück!
```

### Prepared Statements verwenden

Das `?` Zeichen dient als Platzhalter und verhindert SQL-Injection:

```javascript
// SICHER mit Prepared Statement
const [users] = await db.query(
    'SELECT * FROM users WHERE user_id = ?',
    [userInput]
);
```

Der Wert wird automatisch escaped und kann den SQL-Befehl nicht verändern.

## JOIN Abfragen in Node.js

```javascript
async function getBooksWithAuthors() {
    try {
        const query = `
            SELECT 
                b.book_id,
                b.title,
                b.isbn,
                a.author_name,
                a.country
            FROM books b
            INNER JOIN authors a ON b.author_id = a.author_id
            ORDER BY b.title
        `;
        const [rows] = await db.query(query);
        return rows;
    } catch (error) {
        console.error('Fehler bei JOIN:', error.message);
    }
}
```

## Transaktionen

Transaktionen stellen sicher, dass mehrere Datenbankoperationen entweder alle erfolgreich sind oder alle rückgängig gemacht werden.

```javascript
async function transferBook(fromUserId, toUserId, bookId) {
    const connection = await db.getConnection();
    
    try {
        // Transaktion starten
        await connection.beginTransaction();
        
        // Buch vom ersten User entfernen
        await connection.query(
            'DELETE FROM user_books WHERE user_id = ? AND book_id = ?',
            [fromUserId, bookId]
        );
        
        // Buch dem zweiten User zuweisen
        await connection.query(
            'INSERT INTO user_books (user_id, book_id) VALUES (?, ?)',
            [toUserId, bookId]
        );
        
        // Transaktion bestätigen
        await connection.commit();
        console.log('Transfer erfolgreich');
        
    } catch (error) {
        // Bei Fehler: Transaktion rückgängig machen
        await connection.rollback();
        console.error('Transfer fehlgeschlagen:', error.message);
        throw error;
    } finally {
        connection.release();
    }
}
```

## Fehlerbehandlung Best Practices

```javascript
async function safeQuery(query, params = []) {
    try {
        const [rows] = await db.query(query, params);
        return { success: true, data: rows };
    } catch (error) {
        console.error('Datenbank Fehler:', error.message);
        return { success: false, error: error.message };
    }
}

// Verwendung
const result = await safeQuery('SELECT * FROM books WHERE book_id = ?', [42]);
if (result.success) {
    console.log('Daten:', result.data);
} else {
    console.log('Fehler:', result.error);
}
```

## Praktische Übung

### Aufgabe 1: HFTM Library erweitern

Verwende die HFTM Library Datenbank und erstelle ein Node.js Skript mit folgenden Funktionen:

1. Alle Bücher eines bestimmten Autors anzeigen
2. Ein neues Buch hinzufügen
3. Die Anzahl der ausgeliehenen Bücher pro Benutzer anzeigen (JOIN)
4. Ein Buch als ausgeliehen markieren (mit Ausleihdatum)
5. Ein Buch zurückgeben

### Aufgabe 2: Eigene Datenbank

Implementiere CRUD-Operationen für deine Ärztezentrum-Datenbank:

1. Patienten verwalten (CREATE, READ, UPDATE, DELETE)
2. Termine abfragen (mit JOIN zu Ärzten und Patienten)
3. Neue Termine anlegen
4. Termine stornieren

### Aufgabe 3: SQL-Injection testen

1. Erstelle eine unsichere Query (String-Konkatenation)
2. Teste mit einem Injection-Versuch (z.B. `' OR '1'='1`)
3. Implementiere die sichere Version mit Prepared Statements
4. Dokumentiere den Unterschied

## Zusätzliche Ressourcen

- [MySQL2 Dokumentation](https://github.com/sidorares/node-mysql2)
- [Node.js Official Docs](https://nodejs.org/docs/latest/api/)
- [SQL Injection Erklärung (OWASP)](https://owasp.org/www-community/attacks/SQL_Injection)

## Checkliste für Credit 6

- [ ] Node.js und npm installiert
- [ ] Projekt mit `package.json` erstellt
- [ ] Datenbankverbindung funktioniert
- [ ] Mindestens 3 CRUD-Operationen implementiert
- [ ] Prepared Statements verwendet
- [ ] Code dokumentiert und getestet
- [ ] Screenshot oder Ausgabe der funktionierenden Queries

## Nächste Schritte

In der nächsten Lektion werden wir ein REST API erstellen, das diese Datenbankoperationen über HTTP-Endpoints zugänglich macht.

# Übung 7: Node.js und Datenbanken - Lösungen

## Credit 7: Node.js mit der HFTM Library (10 Punkte)

Die Lösungen beziehen sich auf die praktischen Übungen aus Lektion 7. Alle Abfragen verwenden die Tabellen und Spalten der HFTM Library genau so, wie sie im Dump `SQL-Dumps/HFTM Library.sql` definiert sind:

| Tabelle | Spalten |
|---|---|
| `books` | `ID`, `ISBN`, `Titel`, `Published_Date`, `AmountInStock`, `AuthorsID`, `PublishersID`, `GenresID` |
| `authors` | `ID`, `Firstname`, `Lastname`, `Address`, `LocationID`, `Email` |
| `customers` | `ID`, `Lastname`, `Firstname`, `Address`, `Email`, `Birthdate`, `LocationID` |
| `lends` | `ID`, `Date_From`, `Date_To`, `Price`, `CustomerID`, `BookID` |
| `genres` | `ID`, `Genre`, `Fiction` |
| `publishers` | `ID`, `Name`, `Email`, `Phonenumber` |
| `places` | `ID`, `ZIP`, `City` |

**Hinweis:** Die Tabelle `books` hat keine Preisspalte. Ein Preis existiert nur pro Ausleihe (`lends.Price`). Der Bestand eines Buchs steht in `AmountInStock`.

---

### Übung 1: Setup (2 Punkte)

#### a) Projekt erstellen und Packages installieren

```bash
# Projektordner erstellen (wird in Lektion 8 zum REST API erweitert)
mkdir library-api
cd library-api

# npm-Projekt initialisieren
npm init -y

# Treiber für MariaDB/MySQL und dotenv installieren
npm install mysql2 dotenv
```

Kontrolle der Installation:

```bash
node --version   # z.B. v20.x.x oder neuer
npm --version    # z.B. 10.x.x oder neuer
```

#### b) .env und .gitignore

**.env** (Werte an die eigene Installation anpassen):

```env
DB_HOST=localhost
DB_USER=hftm_library
DB_PASSWORD=dein_passwort
DB_NAME=hftm_library
DB_PORT=3306
```

**.gitignore:**

```text
node_modules/
.env
```

Für die Abgabe zusätzlich eine `.env.example` mit denselben Schlüsseln, aber ohne echtes Passwort beilegen.

#### c) Datenbankmodul db.js

Identisch mit `db-nodejs-demo/db.js` aus der Lektion:

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

#### d) Verbindung testen (test-connection.js)

```javascript
// test-connection.js
const db = require('./db');

async function testConnection() {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS result');
        console.log('Datenbankverbindung erfolgreich!');
        console.log('Test Query Result:', rows[0].result);

        // Zusätzlich: verbundene Datenbank und Tabellen anzeigen
        const [info] = await db.query('SELECT DATABASE() AS db');
        console.log('Datenbank:', info[0].db);

        const [tables] = await db.query('SHOW TABLES');
        tables.forEach(table => console.log('  -', Object.values(table)[0]));
    } catch (error) {
        console.error('Fehler bei Datenbankverbindung:', error.message);
    } finally {
        await db.end(); // Pool schliessen, damit das Programm beendet wird
    }
}

testConnection();
```

**Erwartete Ausgabe:**

```text
Datenbankverbindung erfolgreich!
Test Query Result: 2
Datenbank: hftm_library
  - authors
  - authors_genres
  - authors_publishers
  - books
  - customers
  - genres
  - lends
  - places
  - publishers
```

**Bewertung:**
- 1 Punkt: Projekt mit `package.json`, `mysql2` und `dotenv` installiert, `.env` nicht im Git
- 1 Punkt: `test-connection.js` verbindet sich erfolgreich mit `hftm_library`

---

### Übung 2: CRUD-Operationen (3 Punkte)

#### authors.js

```javascript
// authors.js
const db = require('./db');

// Alle Autoren (die Tabelle ist gross, darum begrenzen)
async function getAllAuthors() {
    const [rows] = await db.query(
        'SELECT * FROM authors ORDER BY Lastname, Firstname LIMIT 20'
    );
    return rows;
}

// Autor nach ID (undefined, wenn nicht vorhanden)
async function getAuthorById(id) {
    const [rows] = await db.query(
        'SELECT * FROM authors WHERE ID = ?',
        [id]
    );
    return rows[0];
}

// Neuen Autor erfassen, liefert die neue ID
async function createAuthor(firstname, lastname, email) {
    try {
        const sql = `
            INSERT INTO authors (Firstname, Lastname, Email)
            VALUES (?, ?, ?)
        `;
        const [result] = await db.query(sql, [firstname, lastname, email]);
        console.log('Autor hinzugefügt mit ID:', result.insertId);
        return result.insertId;
    } catch (error) {
        console.error('Fehler beim Einfügen:', error.message);
        throw error;
    }
}

// Autor aktualisieren, liefert true, wenn eine Zeile betroffen war
async function updateAuthor(id, firstname, lastname, email) {
    try {
        const sql = `
            UPDATE authors
            SET Firstname = ?, Lastname = ?, Email = ?
            WHERE ID = ?
        `;
        const [result] = await db.query(sql, [firstname, lastname, email, id]);
        console.log('Zeilen aktualisiert:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        console.error('Fehler beim Aktualisieren:', error.message);
        throw error;
    }
}

// Autor löschen
async function deleteAuthor(id) {
    try {
        const [result] = await db.query(
            'DELETE FROM authors WHERE ID = ?',
            [id]
        );
        console.log('Zeilen gelöscht:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        // Autor wird noch in books, authors_genres oder authors_publishers verwendet
        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
            console.error('Autor kann nicht gelöscht werden: Er wird noch referenziert');
        } else {
            console.error('Fehler beim Löschen:', error.message);
        }
        throw error;
    }
}

module.exports = { getAllAuthors, getAuthorById, createAuthor, updateAuthor, deleteAuthor };
```

#### books.js

```javascript
// books.js
const db = require('./db');

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

// Neues Buch erfassen (Titel max. 50 Zeichen, ISBN im Format XXX-XX-XXXXX-XX-X)
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
        // AuthorsID oder PublishersID existiert nicht
        if (error.code === 'ER_NO_REFERENCED_ROW_2') {
            console.error('Autor oder Verlag existiert nicht');
        } else {
            console.error('Fehler beim Einfügen:', error.message);
        }
        throw error;
    }
}

// Titel und ISBN eines Buchs ändern
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

// Buch löschen (scheitert, wenn Ausleihen in lends darauf verweisen)
async function deleteBook(id) {
    try {
        const [result] = await db.query(
            'DELETE FROM books WHERE ID = ?',
            [id]
        );
        console.log('Zeilen gelöscht:', result.affectedRows);
        return result.affectedRows > 0;
    } catch (error) {
        if (error.code === 'ER_ROW_IS_REFERENCED_2') {
            console.error('Buch kann nicht gelöscht werden: Es existieren Ausleihen');
        } else {
            console.error('Fehler beim Löschen:', error.message);
        }
        throw error;
    }
}

module.exports = { getAllBooks, getBookById, createBook, updateBook, deleteBook };
```

#### Test-Script test-crud.js

Das Script legt einen Testautor und ein Testbuch an, ändert beide und löscht sie am Schluss wieder. Das Buch muss vor dem Autor gelöscht werden, weil `books.AuthorsID` auf `authors.ID` verweist.

```javascript
// test-crud.js
const db = require('./db');
const authors = require('./authors');
const books = require('./books');

async function testCrud() {
    let authorId;
    let bookId;

    try {
        // CREATE
        authorId = await authors.createAuthor('Test', 'Autorin', 'test.autorin@example.com');
        bookId = await books.createBook('Node.js und Datenbanken', '978-30-12345-67-8', 3, authorId, 1);

        // READ
        console.log('Autor:', await authors.getAuthorById(authorId));
        console.log('Buch:', await books.getBookById(bookId));
        console.log('Erste Bücher:', (await books.getAllBooks()).map(b => b.Titel));
        console.log('Erste Autoren:', (await authors.getAllAuthors()).length);

        // UPDATE
        await authors.updateAuthor(authorId, 'Test', 'Autorin-Muster', 'test.muster@example.com');
        await books.updateBook(bookId, 'Node.js und Datenbanken (2. Auflage)', '978-30-12345-67-9');
        console.log('Geändertes Buch:', (await books.getBookById(bookId)).Titel);
    } catch (error) {
        console.error('Test fehlgeschlagen:', error.message);
    } finally {
        // DELETE (Aufräumen: zuerst das Buch, dann den Autor)
        if (bookId) await books.deleteBook(bookId);
        if (authorId) await authors.deleteAuthor(authorId);
        await db.end();
    }
}

testCrud();
```

**Bewertung:**
- 1.5 Punkte: Alle 5 Funktionen für `authors` korrekt
- 1.5 Punkte: Alle 5 Funktionen für `books` korrekt (Spaltennamen gemäss Dump, Platzhalter `?`)

---

### Übung 3: Erweiterte Abfragen in der HFTM Library (2 Punkte)

```javascript
// queries.js
const db = require('./db');

// 1. Bücher nach Titel suchen (Teilstring)
async function searchBooksByTitle(searchTerm) {
    const [rows] = await db.query(
        'SELECT ID, Titel, ISBN, AmountInStock FROM books WHERE Titel LIKE ? ORDER BY Titel',
        [`%${searchTerm}%`]
    );
    return rows;
}

// 2. Alle Bücher eines bestimmten Autors
async function getBooksByAuthor(authorId) {
    const [rows] = await db.query(
        'SELECT ID, Titel, ISBN, Published_Date FROM books WHERE AuthorsID = ? ORDER BY Titel',
        [authorId]
    );
    return rows;
}

// 3. Bücher mit Autoren (JOIN)
async function getBooksWithAuthors() {
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
}

// 4. Anzahl Bücher pro Autor (LEFT JOIN: auch Autoren ohne Bücher)
async function getBookCountByAuthor() {
    const sql = `
        SELECT
            a.ID,
            a.Firstname,
            a.Lastname,
            COUNT(b.ID) AS BookCount
        FROM authors a
        LEFT JOIN books b ON b.AuthorsID = a.ID
        GROUP BY a.ID, a.Firstname, a.Lastname
        ORDER BY BookCount DESC, a.Lastname
        LIMIT 20
    `;
    const [rows] = await db.query(sql);
    return rows;
}

// 5. Anzahl ausgeliehener Bücher pro Kunde (JOIN)
async function getLendCountByCustomer() {
    const sql = `
        SELECT
            c.ID,
            c.Firstname,
            c.Lastname,
            COUNT(l.ID) AS LendCount
        FROM customers c
        INNER JOIN lends l ON l.CustomerID = c.ID
        GROUP BY c.ID, c.Firstname, c.Lastname
        ORDER BY LendCount DESC
        LIMIT 20
    `;
    const [rows] = await db.query(sql);
    return rows;
}

// 6. Überfällige Ausleihen (Date_To in der Vergangenheit)
async function getOverdueLoans() {
    const sql = `
        SELECT
            l.ID,
            l.Date_From,
            l.Date_To,
            DATEDIFF(NOW(), l.Date_To) AS DaysOverdue,
            b.Titel,
            c.Firstname,
            c.Lastname
        FROM lends l
        INNER JOIN books b ON l.BookID = b.ID
        INNER JOIN customers c ON l.CustomerID = c.ID
        WHERE l.Date_To < NOW()
        ORDER BY l.Date_To
        LIMIT 50
    `;
    const [rows] = await db.query(sql);
    return rows;
}

module.exports = {
    searchBooksByTitle,
    getBooksByAuthor,
    getBooksWithAuthors,
    getBookCountByAuthor,
    getLendCountByCustomer,
    getOverdueLoans
};
```

**Hinweis zu 6:** Die Tabelle `lends` hat keine Spalte für "zurückgegeben". Darum gelten hier alle Ausleihen mit `Date_To` in der Vergangenheit als überfällig. Da die Beispieldaten aus den Jahren ab 2020 stammen, liefert die Abfrage viele Treffer.

**Testaufruf (Beispiel):**

```javascript
// test-queries.js
const db = require('./db');
const q = require('./queries');

async function main() {
    try {
        console.log(await q.searchBooksByTitle('Lost'));
        console.log(await q.getBooksByAuthor(1252));
        console.table(await q.getBookCountByAuthor());
        console.table(await q.getLendCountByCustomer());
        console.table((await q.getOverdueLoans()).slice(0, 5));
    } catch (error) {
        console.error(error.message);
    } finally {
        await db.end();
    }
}

main();
```

**Bewertung:**
- 1 Punkt: Abfragen 1-3 korrekt (LIKE mit Platzhalter, WHERE, JOIN)
- 1 Punkt: Abfragen 4-6 korrekt (GROUP BY mit COUNT, JOIN über `lends`, Datumsvergleich)

---

### Übung 4: Transaktion (2 Punkte)

```javascript
// lends.js
const db = require('./db');

// Buch ausleihen: Bestand prüfen, Bestand reduzieren, Ausleihe erfassen
async function lendBook(bookId, customerId, days = 30) {
    const connection = await db.getConnection();

    try {
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

        // 3. Ausleihe mit Ausleihdatum erfassen
        const [result] = await connection.query(
            `INSERT INTO lends (BookID, CustomerID, Date_From, Date_To)
             VALUES (?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY))`,
            [bookId, customerId, days]
        );

        await connection.commit();
        console.log('Ausleihe erfolgreich, ID:', result.insertId);
        return result.insertId;

    } catch (error) {
        // Bei Fehler (auch bei unbekannter CustomerID): alles rückgängig machen
        await connection.rollback();
        console.error('Ausleihe fehlgeschlagen:', error.message);
        throw error;

    } finally {
        connection.release();
    }
}

// Buch zurückgeben: Ausleihe abschliessen und Bestand wieder erhöhen
async function returnBook(lendId) {
    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        // 1. Ausleihe suchen und sperren
        const [lends] = await connection.query(
            'SELECT BookID FROM lends WHERE ID = ? FOR UPDATE',
            [lendId]
        );
        if (lends.length === 0) {
            throw new Error('Ausleihe nicht gefunden');
        }
        const bookId = lends[0].BookID;

        // 2. Ausleihe abschliessen
        await connection.query(
            'UPDATE lends SET Date_To = NOW() WHERE ID = ?',
            [lendId]
        );

        // 3. Bestand wieder erhöhen
        await connection.query(
            'UPDATE books SET AmountInStock = AmountInStock + 1 WHERE ID = ?',
            [bookId]
        );

        await connection.commit();
        console.log('Rückgabe erfolgreich');
        return true;

    } catch (error) {
        await connection.rollback();
        console.error('Rückgabe fehlgeschlagen:', error.message);
        throw error;

    } finally {
        connection.release();
    }
}

module.exports = { lendBook, returnBook };
```

**Test:**

```javascript
// test-lends.js
const db = require('./db');
const { lendBook, returnBook } = require('./lends');

async function main() {
    try {
        const [before] = await db.query('SELECT AmountInStock FROM books WHERE ID = ?', [2]);
        console.log('Bestand vorher:', before[0].AmountInStock);

        const lendId = await lendBook(2, 1, 14);   // Buch 2 an Kunde 1 für 14 Tage
        const [during] = await db.query('SELECT AmountInStock FROM books WHERE ID = ?', [2]);
        console.log('Bestand nach Ausleihe:', during[0].AmountInStock);

        await returnBook(lendId);
        const [after] = await db.query('SELECT AmountInStock FROM books WHERE ID = ?', [2]);
        console.log('Bestand nach Rückgabe:', after[0].AmountInStock);

        // Fehlerfall: Kunde existiert nicht, Rollback, Bestand bleibt gleich
        await lendBook(2, 999999).catch(() => {});
        const [check] = await db.query('SELECT AmountInStock FROM books WHERE ID = ?', [2]);
        console.log('Bestand nach fehlgeschlagener Ausleihe:', check[0].AmountInStock);
    } finally {
        await db.end();
    }
}

main();
```

Beim Fehlerfall schlägt das `INSERT` wegen des Fremdschlüssels `FK_lends_customers` fehl (`ER_NO_REFERENCED_ROW_2`). Dank Rollback wird auch die Reduktion von `AmountInStock` rückgängig gemacht.

**Hinweis:** Weil `lends` keine Spalte für "zurückgegeben" besitzt, kann `returnBook()` eine Ausleihe nicht von einer bereits abgeschlossenen unterscheiden. Ein zweiter Aufruf mit derselben ID würde den Bestand erneut erhöhen. In einem echten Projekt sollte dafür eine Spalte (z.B. `Returned_Date`) ergänzt werden.

**Bewertung:**
- 1 Punkt: `lendBook()` mit `beginTransaction`, `commit`, `rollback` und `release`
- 1 Punkt: `returnBook()` setzt `Date_To` und erhöht `AmountInStock` in einer Transaktion

---

### Übung 5: Eigene Datenbank (Ärztezentrum)

Die Lösung hängt vom eigenen Datenbankentwurf ab. Das Beispiel verwendet die Tabellen `patients`, `doctors` und `appointments` aus Lektion 2 und dasselbe Modul `db.js` (mit `DB_NAME` auf die eigene Datenbank gesetzt).

```javascript
// aerztezentrum.js
const db = require('./db');

// 1. Patienten verwalten
async function getAllPatients() {
    const [rows] = await db.query('SELECT * FROM patients ORDER BY last_name, first_name');
    return rows;
}

async function getPatientById(id) {
    const [rows] = await db.query('SELECT * FROM patients WHERE patient_id = ?', [id]);
    return rows[0];
}

async function createPatient(firstName, lastName, birthDate, email) {
    const [result] = await db.query(
        'INSERT INTO patients (first_name, last_name, birth_date, email) VALUES (?, ?, ?, ?)',
        [firstName, lastName, birthDate, email]
    );
    return result.insertId;
}

async function updatePatient(id, firstName, lastName, birthDate, email) {
    const [result] = await db.query(
        `UPDATE patients
         SET first_name = ?, last_name = ?, birth_date = ?, email = ?
         WHERE patient_id = ?`,
        [firstName, lastName, birthDate, email, id]
    );
    return result.affectedRows > 0;
}

async function deletePatient(id) {
    const [result] = await db.query('DELETE FROM patients WHERE patient_id = ?', [id]);
    return result.affectedRows > 0;
}

// 2. Termine abfragen (JOIN zu Ärzten und Patienten)
async function getAppointments() {
    const sql = `
        SELECT
            ap.appointment_id,
            ap.appointment_date,
            ap.appointment_time,
            ap.status,
            d.name AS doctor,
            CONCAT(p.first_name, ' ', p.last_name) AS patient
        FROM appointments ap
        INNER JOIN doctors d ON ap.doctor_id = d.doctor_id
        INNER JOIN patients p ON ap.patient_id = p.patient_id
        ORDER BY ap.appointment_date, ap.appointment_time
    `;
    const [rows] = await db.query(sql);
    return rows;
}

// 3. Neuen Termin anlegen
async function createAppointment(patientId, doctorId, date, time, reason) {
    const [result] = await db.query(
        `INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, reason)
         VALUES (?, ?, ?, ?, ?)`,
        [patientId, doctorId, date, time, reason]
    );
    return result.insertId;
}

// 4. Termin stornieren (Status setzen statt löschen, damit die Historie erhalten bleibt)
async function cancelAppointment(appointmentId) {
    const [result] = await db.query(
        "UPDATE appointments SET status = 'cancelled' WHERE appointment_id = ?",
        [appointmentId]
    );
    return result.affectedRows > 0;
}

module.exports = {
    getAllPatients, getPatientById, createPatient, updatePatient, deletePatient,
    getAppointments, createAppointment, cancelAppointment
};
```

Diese Übung ist die Grundlage für das Ärztezentrum-API in Lektion 8 und wird dort bewertet.

---

### Übung 6: SQL-Injection testen (1 Punkt)

```javascript
// injection.js
const db = require('./db');

// 1. UNSICHER: Eingabe wird direkt in den SQL-String eingesetzt
async function unsafeSearch(searchTerm) {
    const sql = `SELECT ID, Titel FROM books WHERE Titel = '${searchTerm}'`;
    console.log('SQL:', sql);
    const [rows] = await db.query(sql);
    return rows;
}

// 3. SICHER: Platzhalter, der Wert wird separat übergeben
async function safeSearch(searchTerm) {
    const sql = 'SELECT ID, Titel FROM books WHERE Titel = ?';
    const [rows] = await db.query(sql, [searchTerm]);
    return rows;
}

async function main() {
    const attack = "' OR '1'='1";

    try {
        // 2. Injection-Versuch
        const unsafe = await unsafeSearch(attack);
        console.log('Unsicher, Anzahl Treffer:', unsafe.length);   // alle Bücher

        const safe = await safeSearch(attack);
        console.log('Sicher, Anzahl Treffer:', safe.length);       // 0

        // Normale Suche funktioniert bei beiden gleich
        console.log((await safeSearch('Paradise Lost')).length);  // 1
    } finally {
        await db.end();
    }
}

main();
```

**Ausgabe (gekürzt):**

```text
SQL: SELECT ID, Titel FROM books WHERE Titel = '' OR '1'='1'
Unsicher, Anzahl Treffer: <Anzahl aller Bücher>
Sicher, Anzahl Treffer: 0
1
```

**4. Dokumentation des Unterschieds:**

- In der unsicheren Version wird der Text `' OR '1'='1` Teil des SQL-Befehls. Die Bedingung `'1'='1'` ist immer wahr, darum liefert die Abfrage alle Bücher.
- In der sicheren Version ersetzt mysql2 den Platzhalter `?` durch einen korrekt escapten Wert. Die Datenbank sucht nach einem Buch, dessen `Titel` wörtlich `' OR '1'='1` lautet, und findet keines.
- Ein Angriff mit mehreren Anweisungen (`'; DROP TABLE books; --`) scheitert bei mysql2 wegen `multipleStatements: false`. Das Auslesen fremder Daten funktioniert aber trotzdem, deshalb immer Platzhalter verwenden.

**Bewertung:**
- 1 Punkt: Unsichere und sichere Version, Injection nachgewiesen und Unterschied dokumentiert

---

## Bewertungsraster Credit 7

| Übung | Punkte | Kriterien |
|---|---|---|
| **1** Setup | 2 | Projekt, Packages, `.env`, Verbindung funktioniert |
| **2** CRUD | 3 | Je 5 Funktionen für `authors` und `books`, Prepared Statements |
| **3** Abfragen | 2 | Alle 6 Abfragen mit korrekten Tabellen und Spalten |
| **4** Transaktion | 2 | `lendBook()` und `returnBook()` mit Commit/Rollback |
| **6** SQL-Injection | 1 | Angriff gezeigt, sichere Variante, Unterschied dokumentiert |
| **TOTAL** | **10** | |

Übung 5 (Ärztezentrum) fliesst in die Bewertung des Ärztezentrum-API in Lektion 8 ein.

---

## Abgabe

**Format:** ZIP-Datei mit dem kompletten Projekt

**Enthält:**
- [ ] Alle Dateien (ohne `node_modules/`)
- [ ] `.env.example` (OHNE echte Zugangsdaten!)
- [ ] Screenshots oder Ausgaben von:
  - [ ] `node test-connection.js`
  - [ ] `node test-crud.js`
  - [ ] `node test-queries.js` und `node test-lends.js`
  - [ ] `node injection.js`
- [ ] Kommentare im Code

**Naming:** `Credit7_Vorname_Nachname.zip`

**Deadline:** Siehe Moodle

---

## Tipps

**Empfohlen:**
- `.env` NIEMALS committen
- Immer `try/catch` bei async-Funktionen
- Prepared Statements (Platzhalter `?`) verwenden
- Verbindungen aus dem Pool mit `release()` zurückgeben
- Am Ende eines Scripts den Pool mit `db.end()` schliessen
- Tabellen- und Spaltennamen genau wie im Dump schreiben (`Titel`, `AuthorsID`, `AmountInStock`)

**Zu vermeiden:**
- Zugangsdaten im Code
- SQL-Strings mit Benutzereingaben zusammensetzen
- Fehler ignorieren
- `node_modules/` in Git committen

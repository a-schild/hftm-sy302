# Übung 7: Node.js und Datenbanken - Lösungen

## Credit 7: Node.js Setup & Erste Schritte (10 Punkte)

### Aufgabe 1: Node.js Installation & Projekt-Setup (3 Punkte)

#### a) Installation überprüfen (1 Punkt)

**Aufgabe:** Installiere Node.js und npm, überprüfe die Versionen.

**Lösung:**
```bash
# Installation überprüfen
node --version
# Erwartete Ausgabe: v18.x.x oder höher

npm --version
# Erwartete Ausgabe: 9.x.x oder höher
```

**Screenshot:** Zeige beide Versionen im Terminal

**Bewertung:**
- 1 Punkt: Beide Befehle funktionieren und zeigen aktuelle Versionen

---

#### b) Neues Projekt initialisieren (1 Punkt)

**Aufgabe:** Erstelle ein neues Node.js Projekt.

**Lösung:**
```bash
# Verzeichnis erstellen
mkdir library-api
cd library-api

# Projekt initialisieren
npm init -y
```

**Erwartetes Ergebnis:** package.json Datei wird erstellt

```json
{
  "name": "library-api",
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

**Bewertung:**
- 1 Punkt: package.json existiert und ist korrekt formatiert

---

#### c) Dependencies installieren (1 Punkt)

**Aufgabe:** Installiere die benötigten Packages.

**Lösung:**
```bash
npm install mysql2 dotenv express
npm install --save-dev nodemon
```

**Erwartetes package.json:**
```json
{
  "name": "library-api",
  "version": "1.0.0",
  "description": "Library API with Node.js",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "node test-connection.js"
  },
  "dependencies": {
    "dotenv": "^16.3.1",
    "express": "^4.18.2",
    "mysql2": "^3.6.5"
  },
  "devDependencies": {
    "nodemon": "^3.0.2"
  },
  "keywords": ["api", "database", "library"],
  "author": "Dein Name",
  "license": "ISC"
}
```

**Bewertung:**
- 1 Punkt: Alle Dependencies installiert, package.json korrekt

---

### Aufgabe 2: Projektstruktur & Datenbankverbindung (4 Punkte)

#### a) Projektstruktur erstellen (1 Punkt)

**Aufgabe:** Erstelle die folgende Struktur:

```
library-api/
├── config/
│   └── database.js
├── controllers/
│   └── bookController.js
├── routes/
│   └── bookRoutes.js
├── .env
├── .gitignore
├── package.json
├── server.js
└── test-connection.js
```

**Lösung:**
```bash
mkdir config controllers routes
touch config/database.js
touch controllers/bookController.js
touch routes/bookRoutes.js
touch .env .gitignore server.js test-connection.js
```

**.gitignore:**
```
node_modules/
.env
*.log
.DS_Store
```

**Bewertung:**
- 1 Punkt: Alle Verzeichnisse und Dateien vorhanden, .gitignore korrekt

---

#### b) Environment Variables (.env) (1 Punkt)

**Aufgabe:** Erstelle die .env Datei mit Datenbank-Credentials.

**Lösung .env:**
```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=dein_passwort
DB_NAME=hftm_library
DB_PORT=3306

# Server Configuration
PORT=3000
NODE_ENV=development
```

**Bewertung:**
- 1 Punkt: .env Datei vorhanden mit allen erforderlichen Variablen

---

#### c) Datenbankverbindung (config/database.js) (1 Punkt)

**Aufgabe:** Erstelle einen Connection Pool für die Datenbank.

**Lösung config/database.js:**
```javascript
// config/database.js
require('dotenv').config();
const mysql = require('mysql2/promise');

// Erstelle Connection Pool
const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0
});

// Optional: Test connection beim Start
pool.getConnection()
    .then(connection => {
        console.log('✅ Database connection pool created');
        connection.release();
    })
    .catch(err => {
        console.error('❌ Error creating database pool:', err.message);
    });

module.exports = pool;
```

**Erklärung:**
- `mysql.createPool()`: Erstellt einen Verbindungspool (effizienter als einzelne Verbindungen)
- `waitForConnections: true`: Wartet, wenn alle Verbindungen belegt sind
- `connectionLimit: 10`: Max. 10 gleichzeitige Verbindungen
- `queueLimit: 0`: Unbegrenzte Warteschlange

**Bewertung:**
- 1 Punkt: Connection Pool korrekt konfiguriert mit allen wichtigen Optionen

---

#### d) Verbindung testen (test-connection.js) (1 Punkt)

**Aufgabe:** Teste die Datenbankverbindung.

**Lösung test-connection.js:**
```javascript
// test-connection.js
const pool = require('./config/database');

async function testConnection() {
    let connection;
    
    try {
        // Hole Verbindung aus Pool
        connection = await pool.getConnection();
        console.log('✅ Successfully connected to database');
        
        // Teste mit einfacher Query
        const [rows] = await connection.query('SELECT 1 + 1 AS result');
        console.log('✅ Test query result:', rows[0].result);
        
        // Zeige Datenbank-Info
        const [info] = await connection.query('SELECT DATABASE() as db');
        console.log('✅ Connected to database:', info[0].db);
        
        // Zeige Tabellen
        const [tables] = await connection.query('SHOW TABLES');
        console.log('✅ Available tables:', tables.length);
        tables.forEach(table => {
            console.log('  -', Object.values(table)[0]);
        });
        
        console.log('\n🎉 Database connection test successful!');
        process.exit(0);
        
    } catch (err) {
        console.error('❌ Database connection test failed:');
        console.error('Error:', err.message);
        process.exit(1);
        
    } finally {
        // Gebe Verbindung zurück an Pool
        if (connection) connection.release();
    }
}

// Führe Test aus
testConnection();
```

**Test ausführen:**
```bash
node test-connection.js
```

**Erwartete Ausgabe:**
```
✅ Successfully connected to database
✅ Test query result: 2
✅ Connected to database: hftm_library
✅ Available tables: 8
  - authors
  - books
  - customers
  - genres
  - lends
  - places
  - publishers
  - authors_publishers

🎉 Database connection test successful!
```

**Bewertung:**
- 1 Punkt: Test läuft erfolgreich durch, zeigt alle Tabellen

---

### Aufgabe 3: CRUD Funktionen implementieren (3 Punkte)

**Aufgabe:** Implementiere alle CRUD-Operationen für Bücher.

#### Lösung: controllers/bookController.js

```javascript
// controllers/bookController.js
const pool = require('../config/database');

/**
 * CREATE - Neues Buch erstellen
 */
async function createBook(title, authorId, isbn, price = null) {
    try {
        const [result] = await pool.query(
            'INSERT INTO books (title, author_id, isbn, price) VALUES (?, ?, ?, ?)',
            [title, authorId, isbn, price]
        );
        
        console.log(`✅ Book created with ID: ${result.insertId}`);
        return result.insertId;
        
    } catch (err) {
        console.error('❌ Error creating book:', err.message);
        throw err;
    }
}

/**
 * READ ALL - Alle Bücher abrufen
 */
async function getAllBooks(limit = 10) {
    try {
        const [books] = await pool.query(
            'SELECT * FROM books LIMIT ?',
            [limit]
        );
        
        console.log(`✅ Retrieved ${books.length} books`);
        return books;
        
    } catch (err) {
        console.error('❌ Error getting books:', err.message);
        throw err;
    }
}

/**
 * READ ONE - Ein Buch nach ID abrufen
 */
async function getBookById(id) {
    try {
        const [books] = await pool.query(
            'SELECT * FROM books WHERE id = ?',
            [id]
        );
        
        if (books.length === 0) {
            throw new Error(`Book with ID ${id} not found`);
        }
        
        console.log(`✅ Book found: ${books[0].title}`);
        return books[0];
        
    } catch (err) {
        console.error('❌ Error getting book:', err.message);
        throw err;
    }
}

/**
 * UPDATE - Buch aktualisieren
 */
async function updateBook(id, title, price) {
    try {
        const [result] = await pool.query(
            'UPDATE books SET title = ?, price = ? WHERE id = ?',
            [title, price, id]
        );
        
        if (result.affectedRows === 0) {
            throw new Error(`Book with ID ${id} not found`);
        }
        
        console.log(`✅ Book updated (ID: ${id}), rows affected: ${result.affectedRows}`);
        return result.affectedRows > 0;
        
    } catch (err) {
        console.error('❌ Error updating book:', err.message);
        throw err;
    }
}

/**
 * DELETE - Buch löschen
 */
async function deleteBook(id) {
    try {
        const [result] = await pool.query(
            'DELETE FROM books WHERE id = ?',
            [id]
        );
        
        if (result.affectedRows === 0) {
            throw new Error(`Book with ID ${id} not found`);
        }
        
        console.log(`✅ Book deleted (ID: ${id}), rows affected: ${result.affectedRows}`);
        return result.affectedRows > 0;
        
    } catch (err) {
        console.error('❌ Error deleting book:', err.message);
        throw err;
    }
}

/**
 * Bonus: Bücher mit Autoren (JOIN)
 */
async function getBooksWithAuthors(limit = 10) {
    try {
        const [books] = await pool.query(`
            SELECT 
                b.id,
                b.title,
                b.isbn,
                b.price,
                CONCAT(a.firstname, ' ', a.lastname) AS author_name,
                a.id AS author_id
            FROM books b
            INNER JOIN authors a ON b.author_id = a.id
            LIMIT ?
        `, [limit]);
        
        console.log(`✅ Retrieved ${books.length} books with authors`);
        return books;
        
    } catch (err) {
        console.error('❌ Error getting books with authors:', err.message);
        throw err;
    }
}

module.exports = {
    createBook,
    getAllBooks,
    getBookById,
    updateBook,
    deleteBook,
    getBooksWithAuthors
};
```

---

#### Test-Script für CRUD Funktionen

**Erstelle: test-crud.js**

```javascript
// test-crud.js
const {
    createBook,
    getAllBooks,
    getBookById,
    updateBook,
    deleteBook,
    getBooksWithAuthors
} = require('./controllers/bookController');

async function testCRUD() {
    console.log('='.repeat(50));
    console.log('CRUD OPERATIONS TEST');
    console.log('='.repeat(50));
    
    let newBookId;
    
    try {
        // 1. CREATE
        console.log('\n1️⃣  CREATE: Creating new book...');
        newBookId = await createBook(
            'Node.js & Databases Test',
            1, // Autor ID 1
            'TEST-123-456',
            29.99
        );
        console.log(`   Book created with ID: ${newBookId}`);
        
        // 2. READ ALL
        console.log('\n2️⃣  READ ALL: Getting all books...');
        const allBooks = await getAllBooks(5);
        console.log(`   Found ${allBooks.length} books`);
        allBooks.forEach(book => {
            console.log(`   - ${book.title} (ID: ${book.id})`);
        });
        
        // 3. READ ONE
        console.log('\n3️⃣  READ ONE: Getting book by ID...');
        const oneBook = await getBookById(newBookId);
        console.log(`   Book: ${oneBook.title}`);
        console.log(`   ISBN: ${oneBook.isbn}`);
        console.log(`   Price: ${oneBook.price} CHF`);
        
        // 4. UPDATE
        console.log('\n4️⃣  UPDATE: Updating book...');
        await updateBook(newBookId, 'Node.js & Databases UPDATED', 34.99);
        const updated = await getBookById(newBookId);
        console.log(`   Updated title: ${updated.title}`);
        console.log(`   Updated price: ${updated.price} CHF`);
        
        // 5. JOIN
        console.log('\n5️⃣  JOIN: Getting books with authors...');
        const booksWithAuthors = await getBooksWithAuthors(3);
        booksWithAuthors.forEach(book => {
            console.log(`   - "${book.title}" by ${book.author_name}`);
        });
        
        // 6. DELETE
        console.log('\n6️⃣  DELETE: Deleting test book...');
        await deleteBook(newBookId);
        console.log(`   Book deleted (ID: ${newBookId})`);
        
        console.log('\n' + '='.repeat(50));
        console.log('✅ ALL CRUD OPERATIONS SUCCESSFUL!');
        console.log('='.repeat(50));
        
        process.exit(0);
        
    } catch (err) {
        console.error('\n' + '='.repeat(50));
        console.error('❌ ERROR IN CRUD OPERATIONS:');
        console.error(err.message);
        console.error('='.repeat(50));
        
        // Cleanup: Lösche Test-Buch falls noch vorhanden
        if (newBookId) {
            try {
                await deleteBook(newBookId);
                console.log('🧹 Cleanup: Test book deleted');
            } catch (cleanupErr) {
                // Ignore cleanup errors
            }
        }
        
        process.exit(1);
    }
}

// Test ausführen
testCRUD();
```

**Test ausführen:**
```bash
node test-crud.js
```

**Erwartete Ausgabe:**
```
==================================================
CRUD OPERATIONS TEST
==================================================

1️⃣  CREATE: Creating new book...
✅ Book created with ID: 21
   Book created with ID: 21

2️⃣  READ ALL: Getting all books...
✅ Retrieved 5 books
   Found 5 books
   - The Great Gatsby (ID: 1)
   - To Kill a Mockingbird (ID: 2)
   - 1984 (ID: 3)
   - Pride and Prejudice (ID: 4)
   - The Catcher in the Rye (ID: 5)

3️⃣  READ ONE: Getting book by ID...
✅ Book found: Node.js & Databases Test
   Book: Node.js & Databases Test
   ISBN: TEST-123-456
   Price: 29.99 CHF

4️⃣  UPDATE: Updating book...
✅ Book updated (ID: 21), rows affected: 1
✅ Book found: Node.js & Databases UPDATED
   Updated title: Node.js & Databases UPDATED
   Updated price: 34.99 CHF

5️⃣  JOIN: Getting books with authors...
✅ Retrieved 3 books with authors
   - "The Great Gatsby" by F. Scott Fitzgerald
   - "To Kill a Mockingbird" by Harper Lee
   - "1984" by George Orwell

6️⃣  DELETE: Deleting test book...
✅ Book deleted (ID: 21), rows affected: 1
   Book deleted (ID: 21)

==================================================
✅ ALL CRUD OPERATIONS SUCCESSFUL!
==================================================
```

---

## Bewertungsraster Credit 7

| Aufgabe | Punkte | Kriterien |
|---------|--------|-----------|
| **1a** Installation | 1 | Node.js & npm installiert, Versionen stimmen |
| **1b** Projekt Init | 1 | package.json korrekt erstellt |
| **1c** Dependencies | 1 | Alle Packages installiert |
| **2a** Struktur | 1 | Alle Verzeichnisse/Dateien vorhanden |
| **2b** .env | 1 | Credentials korrekt konfiguriert |
| **2c** Database Config | 1 | Connection Pool korrekt |
| **2d** Test Connection | 1 | Verbindung erfolgreich getestet |
| **3** CRUD Funktionen | 3 | Alle 5 Funktionen korrekt (CREATE, READ ALL, READ ONE, UPDATE, DELETE) |
| **TOTAL** | **10** | |

---

## Abgabe

**Format:** ZIP-Datei mit komplettem Projekt

**Enthält:**
- [ ] Alle Dateien (außer node_modules/)
- [ ] .env.example (OHNE echte Credentials!)
- [ ] Screenshots von:
  - [ ] `node --version` und `npm --version`
  - [ ] `node test-connection.js` Ausgabe
  - [ ] `node test-crud.js` Ausgabe
- [ ] README.md mit Installation Instructions

**Naming:** `Credit7_Vorname_Nachname.zip`

**Deadline:** Siehe Moodle

---

## Tipps

✅ **Do's:**
- .env NIEMALS committen
- Immer try-catch bei async Funktionen
- Prepared Statements verwenden (?)
- Connection aus Pool freigeben (.release())
- Aussagekräftige Fehlermeldungen

❌ **Don'ts:**
- Credentials im Code
- SQL Injection ermöglichen
- Fehler ignorieren
- Connection Pool nicht schließen
- node_modules/ in Git committen

---

**Viel Erfolg! 🚀**

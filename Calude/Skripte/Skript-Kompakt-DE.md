# SY302 Databases - Kompakt-Skript (Vollständig)

**HFTM Systemtechnik | Lektionen 1-13**

Dieses Skript deckt alle 13 Lektionen ab und dient als Referenz und Lernhilfe.

**Umfang:** ~70 Seiten | Alle wichtigen Konzepte mit Beispielen

---

# TEIL 1: SQL GRUNDLAGEN (Lektionen 1-6)

## Lektion 1: Einführung in Datenbanken

### Was ist eine Datenbank?

Eine **Datenbank** ist eine strukturierte Sammlung von Daten.

**Vorteile:**
- ✅ Datenkonsistenz
- ✅ Keine Redundanz
- ✅ Mehrbenutzer-Zugriff
- ✅ Sicherheit & Zugriffsrechte
- ✅ Backup & Recovery

### DBMS (Database Management System)

**Bekannte DBMS:**
- MySQL / MariaDB
- PostgreSQL
- Oracle
- Microsoft SQL Server

### Relationale Datenbanken

**Grundkonzepte:**
- **Tabelle**: Sammlung von Daten
- **Zeile**: Ein Datensatz
- **Spalte**: Eigenschaft
- **Primary Key**: Eindeutige ID
- **Foreign Key**: Verweis auf andere Tabelle

### Datentypen

**Numerisch:**
```sql
INT           -- Ganzzahl
DECIMAL(10,2) -- Genau (für Geld)
FLOAT         -- Ungefähr
```

**Text:**
```sql
VARCHAR(255)  -- Variable Länge
TEXT          -- Lange Texte
CHAR(10)      -- Fixe Länge
```

**Datum/Zeit:**
```sql
DATE          -- Nur Datum
DATETIME      -- Datum + Zeit
TIMESTAMP     -- Auto-Update
```

---

## Lektion 2: Datenbankdesign & Normalisierung

### ER-Diagramm (Entity-Relationship)

**Elemente:**
- **Entität**: Objekt (Rechteck)
- **Attribut**: Eigenschaft (Oval)
- **Beziehung**: Verbindung (Raute)
- **Primary Key**: Unterstrichen

### Beziehungstypen

**1:1** - Person ↔ Reisepass
**1:N** - Autor ↔ Bücher  
**N:M** - Studenten ↔ Kurse (benötigt Junction Table)

### Normalisierung

**1. Normalform (1NF):**
- ✅ Atomare Werte
- ✅ Primary Key vorhanden

**2. Normalform (2NF):**
- ✅ 1NF erfüllt
- ✅ Keine Teilabhängigkeiten

**3. Normalform (3NF):**
- ✅ 2NF erfüllt
- ✅ Keine transitiven Abhängigkeiten

---

## Lektion 3: SQL DDL (Data Definition Language)

### CREATE TABLE

```sql
CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    isbn VARCHAR(17) UNIQUE,
    price DECIMAL(10,2) DEFAULT 0.00,
    author_id INT NOT NULL,
    
    FOREIGN KEY (author_id) REFERENCES authors(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
```

### Constraints

```sql
PRIMARY KEY       -- Eindeutige ID
FOREIGN KEY       -- Verweis
UNIQUE            -- Keine Duplikate
NOT NULL          -- Pflichtfeld
CHECK             -- Bedingung
DEFAULT           -- Standardwert
AUTO_INCREMENT    -- Automatisch hochzählen
```

### ALTER TABLE

```sql
-- Spalte hinzufügen
ALTER TABLE books ADD COLUMN description TEXT;

-- Spalte ändern
ALTER TABLE books MODIFY COLUMN title VARCHAR(300);

-- Spalte löschen
ALTER TABLE books DROP COLUMN description;
```

---

## Lektion 4: SQL DML (Data Manipulation Language)

### INSERT

```sql
INSERT INTO authors (first_name, last_name) VALUES
    ('George', 'Orwell'),
    ('Jane', 'Austen');
```

### SELECT

```sql
-- Grundlagen
SELECT * FROM books;
SELECT title, price FROM books;

-- WHERE
SELECT * FROM books WHERE price > 50;
SELECT * FROM books WHERE title LIKE '%Harry%';

-- ORDER BY
SELECT * FROM books ORDER BY price DESC;

-- LIMIT
SELECT * FROM books LIMIT 10;
```

### UPDATE

```sql
UPDATE books 
SET price = 29.99 
WHERE id = 1;
```

### DELETE

```sql
DELETE FROM books WHERE id = 1;
```

### Aggregationsfunktionen

```sql
SELECT 
    COUNT(*) AS anzahl,
    SUM(price) AS total,
    AVG(price) AS durchschnitt,
    MIN(price) AS min,
    MAX(price) AS max
FROM books;
```

### GROUP BY

```sql
SELECT author_id, COUNT(*) AS anzahl
FROM books
GROUP BY author_id
HAVING anzahl > 3;
```

---

## Lektion 5: SQL JOINs

### INNER JOIN

```sql
SELECT books.title, authors.name
FROM books
INNER JOIN authors ON books.author_id = authors.id;
```

### LEFT JOIN

```sql
SELECT authors.name, COUNT(books.id) AS anzahl
FROM authors
LEFT JOIN books ON authors.id = books.author_id
GROUP BY authors.id;
```

### Mehrfach-JOINs

```sql
SELECT 
    books.title,
    authors.name,
    categories.name AS category
FROM books
INNER JOIN authors ON books.author_id = authors.id
LEFT JOIN categories ON books.category_id = categories.id;
```

---

## Lektion 6: DCL, TCL & Test-Vorbereitung

### DCL (Data Control Language)

```sql
-- Benutzer erstellen
CREATE USER 'app_user'@'localhost' IDENTIFIED BY 'password';

-- Rechte vergeben
GRANT SELECT, INSERT ON mydatabase.* TO 'app_user'@'localhost';
FLUSH PRIVILEGES;

-- Rechte entziehen
REVOKE INSERT ON mydatabase.* FROM 'app_user'@'localhost';
```

### TCL (Transaction Control Language)

```sql
START TRANSACTION;

UPDATE accounts SET balance = balance - 100 WHERE id = 1;
UPDATE accounts SET balance = balance + 100 WHERE id = 2;

COMMIT;      -- Speichern
-- oder
ROLLBACK;    -- Rückgängig
```

---

# TEIL 2: BACKEND DEVELOPMENT (Lektionen 7-13)

## Lektion 7: Node.js & Datenbanken

### Node.js Setup

```bash
npm init -y
npm install express mysql2
```

### Express Server

```javascript
const express = require('express');
const app = express();

app.use(express.json());

app.get('/', (req, res) => {
    res.send('Hello World!');
});

app.listen(3000);
```

### MySQL Verbindung

```javascript
const mysql = require('mysql2');

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'library'
});

module.exports = pool.promise();
```

### Queries ausführen

```javascript
const db = require('./config/database');

// SELECT
const [books] = await db.query('SELECT * FROM books');

// INSERT
const [result] = await db.query(
    'INSERT INTO books (title, author_id) VALUES (?, ?)',
    [title, authorId]
);

// UPDATE
await db.query(
    'UPDATE books SET title = ? WHERE id = ?',
    [newTitle, id]
);

// DELETE
await db.query('DELETE FROM books WHERE id = ?', [id]);
```

---

## Lektion 8: REST API Development

### HTTP-Methoden

| Methode | Zweck | Beispiel |
|---------|-------|----------|
| GET | Lesen | `GET /api/books` |
| POST | Erstellen | `POST /api/books` |
| PUT | Ersetzen | `PUT /api/books/1` |
| DELETE | Löschen | `DELETE /api/books/1` |

### CRUD API

```javascript
const express = require('express');
const router = express.Router();
const db = require('../config/database');

// CREATE
router.post('/', async (req, res) => {
    const { title, author_id } = req.body;
    const [result] = await db.query(
        'INSERT INTO books (title, author_id) VALUES (?, ?)',
        [title, author_id]
    );
    res.status(201).json({ id: result.insertId });
});

// READ ALL
router.get('/', async (req, res) => {
    const [books] = await db.query('SELECT * FROM books');
    res.json(books);
});

// READ ONE
router.get('/:id', async (req, res) => {
    const [books] = await db.query(
        'SELECT * FROM books WHERE id = ?',
        [req.params.id]
    );
    if (books.length === 0) {
        return res.status(404).json({ error: 'Not found' });
    }
    res.json(books[0]);
});

// UPDATE
router.put('/:id', async (req, res) => {
    const { title, author_id } = req.body;
    await db.query(
        'UPDATE books SET title = ?, author_id = ? WHERE id = ?',
        [title, author_id, req.params.id]
    );
    res.json({ message: 'Updated' });
});

// DELETE
router.delete('/:id', async (req, res) => {
    await db.query('DELETE FROM books WHERE id = ?', [req.params.id]);
    res.status(204).send();
});

module.exports = router;
```

---

## Lektion 9: KI & Datenbanken

### KI-Tools

- ChatGPT
- Claude
- GitHub Copilot
- Perplexity AI

### Anwendungsfälle

**SQL-Queries generieren:**
```
"Erstelle SQL-Query für alle Bücher mit mehr als 3 Ausleihen"
```

**Code-Review:**
```
"Review diesen Code auf Sicherheitsprobleme"
```

**Optimierung:**
```
"Optimiere diese Query für bessere Performance"
```

### Best Practices

✅ **Do:**
- Spezifische Prompts
- Code selbst prüfen
- Als Lernwerkzeug nutzen

❌ **Don't:**
- Blind kopieren
- Sicherheit ignorieren

---

## Lektion 10: NoSQL & MongoDB

### MongoDB Grundlagen

```javascript
const { MongoClient } = require('mongodb');

const client = new MongoClient('mongodb://localhost:27017');
const db = client.db('library');
const books = db.collection('books');

// CREATE
await books.insertOne({
    title: 'Harry Potter',
    author: 'J.K. Rowling',
    year: 1997
});

// READ
const allBooks = await books.find().toArray();
const oneBook = await books.findOne({ title: 'Harry Potter' });

// UPDATE
await books.updateOne(
    { title: 'Harry Potter' },
    { $set: { year: 1998 } }
);

// DELETE
await books.deleteOne({ title: 'Harry Potter' });
```

### SQL vs. NoSQL

| Feature | SQL | NoSQL |
|---------|-----|-------|
| Schema | Fix | Flexibel |
| Skalierung | Vertikal | Horizontal |
| Transaktionen | ACID | Eventual Consistency |
| Beziehungen | JOINs | Embedded/Refs |

---

## Lektion 11: ORMs & Frameworks

### Sequelize (ORM)

```bash
npm install sequelize mysql2
```

**Model definieren:**
```javascript
const { Sequelize, DataTypes } = require('sequelize');

const sequelize = new Sequelize('database', 'user', 'password', {
    host: 'localhost',
    dialect: 'mysql'
});

const Book = sequelize.define('Book', {
    title: {
        type: DataTypes.STRING,
        allowNull: false
    },
    price: {
        type: DataTypes.DECIMAL(10, 2),
        defaultValue: 0
    }
});

await sequelize.sync();
```

**CRUD Operationen:**
```javascript
// CREATE
const book = await Book.create({
    title: 'Harry Potter',
    price: 29.99
});

// READ
const books = await Book.findAll();
const book = await Book.findByPk(1);
const harryBooks = await Book.findAll({
    where: { title: { [Op.like]: '%Harry%' } }
});

// UPDATE
await Book.update(
    { price: 34.99 },
    { where: { id: 1 } }
);

// DELETE
await Book.destroy({ where: { id: 1 } });
```

---

## Lektion 12: MQTT & Security

### MQTT Grundlagen

```bash
npm install mqtt
```

**Publisher:**
```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    client.publish('sensors/temperature', '22.5');
});
```

**Subscriber:**
```javascript
const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://test.mosquitto.org');

client.on('connect', () => {
    client.subscribe('sensors/#');
});

client.on('message', (topic, message) => {
    console.log(`${topic}: ${message.toString()}`);
});
```

### Security Best Practices

**1. SQL-Injection verhindern:**
```javascript
// ❌ Unsicher
const query = `SELECT * FROM users WHERE name = '${userName}'`;

// ✅ Sicher (Prepared Statements)
const [users] = await db.query(
    'SELECT * FROM users WHERE name = ?',
    [userName]
);
```

**2. Passwörter hashen:**
```bash
npm install bcrypt
```

```javascript
const bcrypt = require('bcrypt');

// Hashen
const hashedPassword = await bcrypt.hash(password, 10);

// Vergleichen
const valid = await bcrypt.compare(password, hashedPassword);
```

**3. JWT Authentication:**
```bash
npm install jsonwebtoken
```

```javascript
const jwt = require('jsonwebtoken');

// Token erstellen
const token = jwt.sign(
    { userId: user.id },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
);

// Token prüfen
jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) return res.status(403).json({ error: 'Invalid token' });
    req.user = decoded;
    next();
});
```

**4. Environment Variables:**
```bash
npm install dotenv
```

**.env:**
```
DB_PASSWORD=secret123
JWT_SECRET=supersecret
```

**Code:**
```javascript
require('dotenv').config();
const password = process.env.DB_PASSWORD;
```

**5. Security Headers:**
```bash
npm install helmet
```

```javascript
const helmet = require('helmet');
app.use(helmet());
```

**6. Rate Limiting:**
```bash
npm install express-rate-limit
```

```javascript
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 Minuten
    max: 100 // Max 100 Requests
});

app.use('/api/', limiter);
```

---

## Lektion 13: Datenschutz, Backups & Abschluss

### DSGVO (GDPR)

**Grundprinzipien:**
1. Rechtmäßigkeit & Transparenz
2. Zweckbindung
3. Datenminimierung
4. Richtigkeit
5. Speicherbegrenzung
6. Integrität & Vertraulichkeit

**Betroffenenrechte:**
- ✅ Auskunftsrecht
- ✅ Recht auf Berichtigung
- ✅ Recht auf Löschung ("Recht auf Vergessenwerden")
- ✅ Recht auf Datenübertragbarkeit

**Implementierung:**

**1. Einwilligung:**
```javascript
const userSchema = {
    email: 'VARCHAR(255)',
    consent_marketing: 'BOOLEAN DEFAULT FALSE',
    consent_date: 'DATETIME'
};
```

**2. Datenexport:**
```javascript
router.get('/me/data-export', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    const [userData] = await db.query(
        'SELECT * FROM users WHERE user_id = ?',
        [userId]
    );
    
    const [orders] = await db.query(
        'SELECT * FROM orders WHERE user_id = ?',
        [userId]
    );
    
    res.json({
        personal_data: userData[0],
        orders: orders,
        export_date: new Date()
    });
});
```

**3. Recht auf Löschung:**
```javascript
router.delete('/me', authenticateToken, async (req, res) => {
    const userId = req.user.userId;
    
    // Soft Delete
    await db.query(`
        UPDATE users 
        SET deletion_requested = TRUE,
            deletion_date = DATE_ADD(NOW(), INTERVAL 30 DAY)
        WHERE user_id = ?
    `, [userId]);
    
    res.json({ message: 'Deletion requested' });
});
```

### Datenbank-Backups

**3-2-1 Regel:**
- **3** Kopien der Daten
- **2** verschiedene Medien
- **1** Kopie extern/offsite

**Backup-Arten:**

**1. Full Backup:**
```bash
mysqldump -u root -p mydatabase > backup.sql
mysqldump -u root -p mydatabase | gzip > backup.sql.gz
```

**2. Automated Backups:**
```bash
# Cron Job (täglich 2:00 Uhr)
0 2 * * * mysqldump -u root -p mydatabase > /backups/db_$(date +\%Y\%m\%d).sql
```

**3. Backup wiederherstellen:**
```bash
mysql -u root -p mydatabase < backup.sql
gunzip < backup.sql.gz | mysql -u root -p mydatabase
```

**Node.js Backup Script:**
```javascript
const { exec } = require('child_process');

class DatabaseBackup {
    async createBackup() {
        const timestamp = new Date().toISOString();
        const filename = `backup_${timestamp}.sql`;
        
        const command = `mysqldump -u ${this.user} -p${this.password} ${this.database} > ${filename}`;
        
        return new Promise((resolve, reject) => {
            exec(command, (error) => {
                if (error) reject(error);
                else resolve(filename);
            });
        });
    }
    
    async deleteOldBackups(days = 30) {
        // Alte Backups löschen (älter als X Tage)
    }
}
```

### Disaster Recovery

**RTO & RPO:**
- **RTO** (Recovery Time Objective): Maximale Ausfallzeit
- **RPO** (Recovery Point Objective): Akzeptabler Datenverlust

**Notfallplan:**
1. Situation einschätzen
2. Letztes funktionierendes Backup finden
3. Test-Restore durchführen
4. Produktiv-Restore
5. Dokumentation

### Monitoring

```javascript
// Health Check Endpoint
router.get('/health', async (req, res) => {
    try {
        await db.query('SELECT 1');
        res.json({ status: 'healthy', database: 'connected' });
    } catch (error) {
        res.status(503).json({ status: 'unhealthy' });
    }
});

// Backup Status
router.get('/backup-status', async (req, res) => {
    const files = fs.readdirSync('./backups');
    const latestBackup = files.sort().reverse()[0];
    
    const stats = fs.statSync(`./backups/${latestBackup}`);
    const age = Date.now() - stats.mtimeMs;
    const ageHours = age / (1000 * 60 * 60);
    
    res.json({
        latestBackup,
        ageHours: Math.round(ageHours),
        status: ageHours < 24 ? 'ok' : 'warning'
    });
});
```

---

## Projekt-Präsentationen

### Struktur (5-7 Minuten)

1. **Projekt vorstellen** (1 min)
   - Was macht die App?
   - Zielgruppe?

2. **Datenbankdesign** (2 min)
   - ER-Diagramm
   - Tabellen & Beziehungen
   - Normalisierung

3. **Live-Demo** (3 min)
   - Frontend zeigen
   - CRUD-Operationen
   - Besondere Features

4. **Tech-Stack** (1 min)
   - Technologien
   - Herausforderungen

### Bewertungskriterien

- **Datenbankdesign** (15 Punkte)
- **Implementation** (10 Punkte)
- **REST API** (30 Punkte)
- **Frontend** (25 Punkte)
- **Präsentation** (20 Punkte)

**Total: 100 Punkte**

---

## Kursrückblick

### Was wir gelernt haben

**Wochen 1-6: SQL Grundlagen**
- Datenbanken & Normalisierung
- SQL DDL, DML, DCL, TCL
- JOINs & Komplexe Queries

**Wochen 7-9: Backend**
- Node.js + Express
- REST API Development
- KI & Datenbanken

**Wochen 10-11: Advanced**
- NoSQL & MongoDB
- ORMs & Frameworks

**Wochen 12-13: Projekt**
- MQTT & IoT
- Security & DSGVO
- Backups & Recovery

### Wichtige Konzepte

1. **Normalisierung** - Redundanz vermeiden
2. **ACID** - Transaktionen
3. **Prepared Statements** - SQL-Injection verhindern
4. **MVC-Pattern** - Code-Struktur
5. **REST** - API-Design
6. **DSGVO** - Datenschutz
7. **Backups** - Datensicherheit

---

## Cheat Sheets

### SQL Quick Reference

```sql
-- DATABASE
CREATE DATABASE dbname;
USE dbname;
DROP DATABASE dbname;

-- TABLE
CREATE TABLE tablename (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    FOREIGN KEY (other_id) REFERENCES other(id)
);
ALTER TABLE tablename ADD COLUMN newcol VARCHAR(50);
DROP TABLE tablename;

-- INSERT
INSERT INTO tablename (col1, col2) VALUES ('val1', 'val2');

-- SELECT
SELECT * FROM tablename WHERE condition;
SELECT col1, col2 FROM tablename ORDER BY col1 DESC LIMIT 10;

-- JOIN
SELECT a.*, b.name 
FROM table_a a
INNER JOIN table_b b ON a.b_id = b.id;

-- UPDATE
UPDATE tablename SET col1 = 'newval' WHERE id = 1;

-- DELETE
DELETE FROM tablename WHERE id = 1;

-- AGGREGATE
SELECT COUNT(*), SUM(price), AVG(price) FROM products GROUP BY category;

-- TRANSACTION
START TRANSACTION;
-- queries here
COMMIT; -- or ROLLBACK;
```

### Node.js/Express Quick Reference

```javascript
// Setup
const express = require('express');
const app = express();
app.use(express.json());

// Routes
app.get('/api/items', async (req, res) => {
    const [items] = await db.query('SELECT * FROM items');
    res.json(items);
});

app.post('/api/items', async (req, res) => {
    const { name } = req.body;
    const [result] = await db.query(
        'INSERT INTO items (name) VALUES (?)',
        [name]
    );
    res.status(201).json({ id: result.insertId });
});

app.put('/api/items/:id', async (req, res) => {
    const { name } = req.body;
    await db.query(
        'UPDATE items SET name = ? WHERE id = ?',
        [name, req.params.id]
    );
    res.json({ message: 'Updated' });
});

app.delete('/api/items/:id', async (req, res) => {
    await db.query('DELETE FROM items WHERE id = ?', [req.params.id]);
    res.status(204).send();
});

app.listen(3000, () => console.log('Server running'));
```

---

## Prüfungsvorbereitung

### SQL-Test Themen

1. ✅ CREATE TABLE (DDL)
2. ✅ INSERT, UPDATE, DELETE (DML)
3. ✅ SELECT mit WHERE, ORDER BY, LIMIT
4. ✅ Aggregationsfunktionen
5. ✅ GROUP BY, HAVING
6. ✅ JOINs (INNER, LEFT)
7. ✅ Normalisierung (1NF, 2NF, 3NF)

### Projekt-Checkliste

- [ ] Datenbankdesign (ER-Diagramm, SQL)
- [ ] REST API (mindestens 3 Ressourcen)
- [ ] Frontend (dynamisch mit API)
- [ ] CRUD-Operationen funktionieren
- [ ] Dokumentation (README, API-Docs)
- [ ] Code auf GitHub
- [ ] SQL-Dump der Datenbank

---

## Ressourcen

### Online-Kurse
- [MySQL for Developers](https://planetscale.com/courses/mysql-for-developers)
- [MongoDB University](https://university.mongodb.com/)
- [SQL Tutorial - W3Schools](https://www.w3schools.com/sql/)

### Tools
- [DB Fiddle](https://www.db-fiddle.com/) - SQL Online-Editor
- [DrawSQL](https://drawsql.app/) - ER-Diagramme
- [DBeaver](https://dbeaver.io/) - DB-Client

### Dokumentation
- [MariaDB Docs](https://mariadb.com/kb/)
- [Express.js](https://expressjs.com/)
- [Node.js](https://nodejs.org/docs)

---

**🎉 Viel Erfolg bei Projekt und Prüfung! 🎉**

© 2024 HFTM - Alle Rechte vorbehalten

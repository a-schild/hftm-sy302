# Datenbanken - Kompaktes Skript für Studierende

## SY302 Databases | HFTM Systemtechnik

**Autor:** A. Schild  
**Version:** 1.0  
**Datum:** Dezember 2024  

---

## Inhaltsverzeichnis

1. [Grundlagen Datenbanken](#1-grundlagen-datenbanken)
2. [Datenbankdesign & ER-Modellierung](#2-datenbankdesign--er-modellierung)
3. [SQL DDL - Strukturen definieren](#3-sql-ddl---strukturen-definieren)
4. [SQL DML - Daten manipulieren](#4-sql-dml---daten-manipulieren)
5. [JOINs & Aggregationen](#5-joins--aggregationen)
6. [Transaktionen & Berechtigungen](#6-transaktionen--berechtigungen)
7. [Node.js & Datenbanken](#7-nodejs--datenbanken)
8. [REST API mit Express](#8-rest-api-mit-express)
9. [Sicherheit & Best Practices](#9-sicherheit--best-practices)
10. [Projekt-Entwicklung](#10-projekt-entwicklung)

---

## 1. Grundlagen Datenbanken

### Was ist eine Datenbank?

Eine **Datenbank** ist eine organisierte Sammlung von strukturierten Daten, die elektronisch gespeichert und abgerufen werden können.

**Vorteile:**
- Datenkonsistenz
- Mehrbenutzer-Zugriff
- Datensicherheit
- Datenintegrität
- Backup & Recovery

### DBMS - Database Management System

Ein **DBMS** ist Software zur Verwaltung von Datenbanken.

**Beispiele:**
- MySQL / MariaDB (Open Source)
- PostgreSQL (Open Source)
- Oracle Database (Kommerziell)
- Microsoft SQL Server (Kommerziell)
- MongoDB (NoSQL)

### ACID-Eigenschaften

**A**tomicity (Atomarität)
- Transaktion komplett oder gar nicht

**C**onsistency (Konsistenz)
- Daten bleiben in gültigem Zustand

**I**solation (Isolation)
- Transaktionen beeinflussen sich nicht

**D**urability (Dauerhaftigkeit)
- Bestätigte Änderungen bleiben permanent

### SQL vs NoSQL

| Aspekt | SQL | NoSQL |
|--------|-----|-------|
| Schema | Fest | Flexibel |
| Struktur | Tabellen | Dokumente/Key-Value |
| Skalierung | Vertikal | Horizontal |
| Beziehungen | JOINs | Embedded/Referenced |
| Beispiele | MySQL, PostgreSQL | MongoDB, Redis |

---

## 2. Datenbankdesign & ER-Modellierung

### ER-Diagramm (Entity-Relationship)

**Komponenten:**
- **Entitäten** (Rechtecke): Objekte/Dinge
- **Attribute** (Ovale): Eigenschaften
- **Beziehungen** (Rauten): Verbindungen

### Kardinalitäten

**1:1** (Eins-zu-Eins)
- Ein Student hat einen Studentenausweis
- Ein Studentenausweis gehört einem Studenten

**1:N** (Eins-zu-Viele)
- Ein Autor schreibt mehrere Bücher
- Ein Buch hat einen Autor

**N:M** (Viele-zu-Viele)
- Studierende besuchen Kurse
- Kurse haben Studierende
- **Lösung:** Junction Table (Zwischentabelle)

### Normalformen

**1. Normalform (1NF)**
- Atomare Werte (keine Listen in Feldern)
- Eindeutiger Primary Key

**2. Normalform (2NF)**
- 1NF erfüllt
- Keine Teilabhängigkeiten vom Schlüssel

**3. Normalform (3NF)**
- 2NF erfüllt
- Keine transitiven Abhängigkeiten

**Beispiel - Nicht normalisiert:**
```
Bestellung: id, kunde_name, kunde_adresse, artikel1, artikel2, artikel3
```

**Normalisiert:**
```
Kunden: id, name, adresse
Bestellungen: id, kunde_id, datum
Bestellpositionen: id, bestellung_id, artikel_id, menge
Artikel: id, name, preis
```

---

## 3. SQL DDL - Strukturen definieren

### Datenbank erstellen

```sql
CREATE DATABASE bibliothek;
USE bibliothek;
```

### Tabelle erstellen

```sql
CREATE TABLE autoren (
    id INT PRIMARY KEY AUTO_INCREMENT,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    geburtsdatum DATE,
    INDEX idx_nachname (nachname)
);
```

### Wichtige Datentypen

**Numerisch:**
- `INT` - Ganzzahl
- `DECIMAL(10,2)` - Festkommazahl (z.B. Preise)
- `FLOAT` - Fließkommazahl

**Text:**
- `VARCHAR(n)` - Variable Länge bis n
- `TEXT` - Langer Text
- `CHAR(n)` - Feste Länge n

**Datum/Zeit:**
- `DATE` - Nur Datum
- `TIME` - Nur Zeit
- `DATETIME` - Datum und Zeit
- `TIMESTAMP` - Unix Timestamp

**Boolean:**
- `BOOLEAN` oder `TINYINT(1)`

### Constraints (Einschränkungen)

```sql
CREATE TABLE buecher (
    id INT PRIMARY KEY AUTO_INCREMENT,
    titel VARCHAR(200) NOT NULL,
    isbn VARCHAR(17) UNIQUE,
    preis DECIMAL(10,2) CHECK (preis >= 0),
    autor_id INT NOT NULL,
    erscheinungsjahr INT DEFAULT YEAR(CURDATE()),
    
    FOREIGN KEY (autor_id) 
        REFERENCES autoren(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

**Constraint-Typen:**
- `PRIMARY KEY` - Eindeutiger Hauptschlüssel
- `FOREIGN KEY` - Verweis auf andere Tabelle
- `UNIQUE` - Eindeutige Werte
- `NOT NULL` - Wert erforderlich
- `CHECK` - Bedingung prüfen
- `DEFAULT` - Standardwert

### Tabelle ändern

```sql
-- Spalte hinzufügen
ALTER TABLE buecher ADD COLUMN seitenzahl INT;

-- Spalte ändern
ALTER TABLE buecher MODIFY COLUMN titel VARCHAR(300);

-- Spalte löschen
ALTER TABLE buecher DROP COLUMN seitenzahl;

-- Index hinzufügen
ALTER TABLE buecher ADD INDEX idx_titel (titel);
```

### Tabelle löschen

```sql
DROP TABLE buecher;
```

---

## 4. SQL DML - Daten manipulieren

### INSERT - Daten einfügen

**Einzelne Zeile:**
```sql
INSERT INTO autoren (vorname, nachname, geburtsdatum)
VALUES ('J.K.', 'Rowling', '1965-07-31');
```

**Mehrere Zeilen:**
```sql
INSERT INTO autoren (vorname, nachname) VALUES
    ('George', 'Orwell'),
    ('Jane', 'Austen'),
    ('Mark', 'Twain');
```

**Mit Subquery:**
```sql
INSERT INTO archiv_buecher
SELECT * FROM buecher WHERE erscheinungsjahr < 2000;
```

### SELECT - Daten abfragen

**Grundstruktur:**
```sql
SELECT spalten
FROM tabelle
WHERE bedingung
ORDER BY spalte
LIMIT anzahl;
```

**Beispiele:**
```sql
-- Alle Spalten
SELECT * FROM buecher;

-- Bestimmte Spalten
SELECT titel, preis FROM buecher;

-- Mit Bedingung
SELECT * FROM buecher WHERE preis < 30;

-- Mit LIKE (Pattern Matching)
SELECT * FROM buecher WHERE titel LIKE '%Harry%';

-- Sortiert
SELECT * FROM buecher ORDER BY preis DESC;

-- Begrenzt
SELECT * FROM buecher LIMIT 10;

-- Mit DISTINCT (keine Duplikate)
SELECT DISTINCT autor_id FROM buecher;
```

**WHERE Operatoren:**
- `=` Gleich
- `!=` oder `<>` Ungleich
- `>`, `<`, `>=`, `<=` Vergleiche
- `BETWEEN` Bereich
- `IN` Liste von Werten
- `LIKE` Pattern Matching
- `IS NULL` / `IS NOT NULL`

### Aggregationsfunktionen

```sql
-- Anzahl
SELECT COUNT(*) FROM buecher;

-- Summe
SELECT SUM(preis) FROM buecher;

-- Durchschnitt
SELECT AVG(preis) FROM buecher;

-- Minimum/Maximum
SELECT MIN(preis), MAX(preis) FROM buecher;
```

### UPDATE - Daten aktualisieren

```sql
-- Einzelne Zeile
UPDATE buecher 
SET preis = 29.99 
WHERE id = 1;

-- Mehrere Spalten
UPDATE buecher 
SET preis = preis * 1.1, 
    erscheinungsjahr = 2024
WHERE autor_id = 5;

-- Mit Berechnung
UPDATE buecher 
SET preis = preis * 0.9
WHERE erscheinungsjahr < 2020;
```

⚠️ **WICHTIG:** Immer WHERE verwenden, sonst werden ALLE Zeilen geändert!

### DELETE - Daten löschen

```sql
-- Einzelne Zeile
DELETE FROM buecher WHERE id = 1;

-- Mehrere Zeilen
DELETE FROM buecher WHERE erscheinungsjahr < 2000;

-- Alle Zeilen (mit Vorsicht!)
DELETE FROM buecher;

-- Schneller: Tabelle leeren
TRUNCATE TABLE buecher;
```

⚠️ **WICHTIG:** Immer WHERE verwenden, sonst werden ALLE Zeilen gelöscht!

---

## 5. JOINs & Aggregationen

### INNER JOIN

Nur Zeilen wo Übereinstimmung in beiden Tabellen.

```sql
SELECT 
    b.titel,
    a.vorname,
    a.nachname
FROM buecher b
INNER JOIN autoren a ON b.autor_id = a.id;
```

### LEFT JOIN

Alle Zeilen aus linker Tabelle, auch ohne Match.

```sql
SELECT 
    a.vorname,
    a.nachname,
    COUNT(b.id) AS anzahl_buecher
FROM autoren a
LEFT JOIN buecher b ON a.id = b.autor_id
GROUP BY a.id;
```

### RIGHT JOIN

Alle Zeilen aus rechter Tabelle, auch ohne Match.

```sql
SELECT 
    b.titel,
    a.nachname
FROM autoren a
RIGHT JOIN buecher b ON a.id = b.autor_id;
```

### Mehrfache JOINs

```sql
SELECT 
    b.titel,
    CONCAT(a.vorname, ' ', a.nachname) AS autor,
    v.name AS verlag
FROM buecher b
INNER JOIN autoren a ON b.autor_id = a.id
LEFT JOIN verlage v ON b.verlag_id = v.id;
```

### GROUP BY

```sql
SELECT 
    autor_id,
    COUNT(*) AS anzahl,
    AVG(preis) AS durchschnittspreis
FROM buecher
GROUP BY autor_id;
```

### HAVING

Wie WHERE, aber nach GROUP BY.

```sql
SELECT 
    autor_id,
    COUNT(*) AS anzahl
FROM buecher
GROUP BY autor_id
HAVING anzahl > 3;
```

### UNION

Kombiniert Ergebnisse mehrerer Queries.

```sql
SELECT titel FROM buecher WHERE preis < 20
UNION
SELECT titel FROM buecher WHERE erscheinungsjahr > 2020;

-- Mit Duplikaten
SELECT titel FROM buecher WHERE preis < 20
UNION ALL
SELECT titel FROM buecher WHERE erscheinungsjahr > 2020;
```

---

## 6. Transaktionen & Berechtigungen

### Transaktionen

```sql
START TRANSACTION;

UPDATE konten SET betrag = betrag - 100 WHERE id = 1;
UPDATE konten SET betrag = betrag + 100 WHERE id = 2;

-- Alles speichern
COMMIT;

-- Oder rückgängig machen
ROLLBACK;
```

**ACID-Prinzipien:**
- **A**tomicity: Alles oder nichts
- **C**onsistency: Gültiger Zustand
- **I**solation: Unabhängig
- **D**urability: Dauerhaft gespeichert

### Benutzer & Berechtigungen (DCL)

```sql
-- Benutzer erstellen
CREATE USER 'student'@'localhost' 
IDENTIFIED BY 'sicheres_passwort';

-- Rechte vergeben
GRANT SELECT, INSERT, UPDATE, DELETE 
ON bibliothek.* 
TO 'student'@'localhost';

-- Alle Rechte vergeben
GRANT ALL PRIVILEGES 
ON bibliothek.* 
TO 'admin'@'localhost';

-- Rechte entziehen
REVOKE DELETE 
ON bibliothek.* 
FROM 'student'@'localhost';

-- Änderungen aktivieren
FLUSH PRIVILEGES;
```

**Berechtigungstypen:**
- `SELECT` - Lesen
- `INSERT` - Einfügen
- `UPDATE` - Ändern
- `DELETE` - Löschen
- `CREATE` - Erstellen
- `DROP` - Löschen (Struktur)
- `ALTER` - Ändern (Struktur)
- `ALL PRIVILEGES` - Alle Rechte

---

## 7. Node.js & Datenbanken

### Setup

```bash
npm init -y
npm install mysql2 dotenv express
```

### Connection Pool

```javascript
// config/database.js
require('dotenv').config();
const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    connectionLimit: 10
});

module.exports = pool;
```

### CRUD Operationen

```javascript
const pool = require('./config/database');

// CREATE
async function createBook(title, authorId) {
    const [result] = await pool.query(
        'INSERT INTO books (title, author_id) VALUES (?, ?)',
        [title, authorId]
    );
    return result.insertId;
}

// READ
async function getAllBooks() {
    const [books] = await pool.query('SELECT * FROM books');
    return books;
}

// UPDATE
async function updateBook(id, title) {
    await pool.query(
        'UPDATE books SET title = ? WHERE id = ?',
        [title, id]
    );
}

// DELETE
async function deleteBook(id) {
    await pool.query('DELETE FROM books WHERE id = ?', [id]);
}
```

---

## 8. REST API mit Express

### Express Server

```javascript
const express = require('express');
const app = express();

app.use(express.json());

// Routes
app.get('/api/books', async (req, res) => {
    const [books] = await pool.query('SELECT * FROM books');
    res.json(books);
});

app.get('/api/books/:id', async (req, res) => {
    const [books] = await pool.query(
        'SELECT * FROM books WHERE id = ?',
        [req.params.id]
    );
    res.json(books[0]);
});

app.post('/api/books', async (req, res) => {
    const { title, author_id } = req.body;
    const [result] = await pool.query(
        'INSERT INTO books (title, author_id) VALUES (?, ?)',
        [title, author_id]
    );
    res.status(201).json({ id: result.insertId });
});

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
```

### HTTP Status Codes

- `200` OK - Erfolgreich
- `201` Created - Erstellt
- `204` No Content - Kein Inhalt (z.B. nach DELETE)
- `400` Bad Request - Fehlerhafte Anfrage
- `401` Unauthorized - Nicht authentifiziert
- `403` Forbidden - Keine Berechtigung
- `404` Not Found - Nicht gefunden
- `500` Internal Server Error - Serverfehler

---

## 9. Sicherheit & Best Practices

### SQL Injection verhindern

❌ **NIEMALS SO:**
```javascript
const query = `SELECT * FROM users WHERE username = '${username}'`;
```

✅ **IMMER SO:**
```javascript
const [users] = await pool.query(
    'SELECT * FROM users WHERE username = ?',
    [username]
);
```

### Password Hashing

```javascript
const bcrypt = require('bcryptjs');

// Hash erstellen
const hashedPassword = await bcrypt.hash(password, 10);

// Vergleichen
const isValid = await bcrypt.compare(password, hashedPassword);
```

### JWT Authentication

```javascript
const jwt = require('jsonwebtoken');

// Token erstellen
const token = jwt.sign(
    { userId: user.id },
    process.env.JWT_SECRET,
    { expiresIn: '24h' }
);

// Token verifizieren
const decoded = jwt.verify(token, process.env.JWT_SECRET);
```

### Input Validation

```javascript
const { body, validationResult } = require('express-validator');

app.post('/api/books',
    body('title').isLength({ min: 3, max: 200 }),
    body('price').isFloat({ min: 0 }),
    async (req, res) => {
        const errors = validationResult(req);
        if (!errors.isEmpty()) {
            return res.status(400).json({ errors: errors.array() });
        }
        // ...
    }
);
```

---

## 10. Projekt-Entwicklung

### Projektstruktur

```
project/
├── config/
│   └── database.js
├── controllers/
│   └── bookController.js
├── routes/
│   └── bookRoutes.js
├── middleware/
│   ├── auth.js
│   └── validation.js
├── .env
├── .gitignore
├── package.json
└── server.js
```

### Best Practices

✅ **DO:**
- Prepared Statements verwenden
- Passwords hashen (bcrypt)
- Input validieren
- Error Handling
- Environment Variables (.env)
- Git verwenden
- Code kommentieren

❌ **DON'T:**
- Credentials im Code
- SQL Injection ermöglichen
- Fehler ignorieren
- node_modules/ committen
- Ohne Backup arbeiten

### ER-Diagramm zeichnen

1. Entitäten identifizieren
2. Attribute definieren
3. Beziehungen festlegen
4. Kardinalitäten bestimmen
5. Primary Keys markieren
6. Foreign Keys eintragen

### Checkliste Projekt-Abgabe

- [ ] Code funktioniert
- [ ] Alle CRUD-Operationen
- [ ] README.md mit Anleitung
- [ ] ER-Diagramm
- [ ] SQL Dump
- [ ] .env.example (ohne echte Credentials)
- [ ] Dokumentation API-Endpoints
- [ ] Git Repository
- [ ] Präsentation vorbereitet

---

## Anhang: Wichtige SQL-Befehle Referenz

### DDL (Data Definition Language)
```sql
CREATE DATABASE name;
CREATE TABLE name (...);
ALTER TABLE name ADD COLUMN ...;
DROP TABLE name;
```

### DML (Data Manipulation Language)
```sql
INSERT INTO table VALUES (...);
SELECT * FROM table WHERE ...;
UPDATE table SET ... WHERE ...;
DELETE FROM table WHERE ...;
```

### DCL (Data Control Language)
```sql
GRANT privileges ON database.* TO 'user'@'host';
REVOKE privileges ON database.* FROM 'user'@'host';
```

### TCL (Transaction Control Language)
```sql
START TRANSACTION;
COMMIT;
ROLLBACK;
```

---

## Glossar

**ACID** - Atomicity, Consistency, Isolation, Durability

**API** - Application Programming Interface

**CRUD** - Create, Read, Update, Delete

**DDL** - Data Definition Language

**DML** - Data Manipulation Language

**ER-Diagramm** - Entity-Relationship-Diagramm

**Foreign Key** - Fremdschlüssel

**JWT** - JSON Web Token

**ORM** - Object-Relational Mapping

**Primary Key** - Primärschlüssel

**REST** - Representational State Transfer

**SQL** - Structured Query Language

---

**Ende des Skripts**

© 2024 HFTM - Alle Rechte vorbehalten

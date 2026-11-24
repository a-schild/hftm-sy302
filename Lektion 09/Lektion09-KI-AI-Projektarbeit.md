# Lektion 9: KI/AI im Datenbankumfeld & Projektarbeit

## Lernziele

Die Studierenden sind in der Lage...

- Zu erklären, wie KI im Datenbankumfeld eingesetzt werden kann
- Die aktuellen KI-Tools im Datenbankumfeld richtig einzusetzen
- SQL-Abfragen mit KI (z.B. Claude) zu generieren, zu analysieren und zu optimieren
- Testdaten und Dokumentation mit KI zu generieren
- Die Grenzen der KI-Tools zu erkennen und kritisch mit KI-generierten Lösungen umzugehen
- Die gelernte Theorie im Projekt anzuwenden

## KI und Datenbanken

**Künstliche Intelligenz (KI)** verändert die Art und Weise, wie mit Datenbanken gearbeitet wird.

### Anwendungsfälle von KI im Datenbankumfeld

**1. Generierung von SQL-Abfragen**

- Komplexe Abfragen in natürlicher Sprache formulieren
- Bestehende Abfragen optimieren
- SQL-Abfragen debuggen

**2. Generierung von Testdaten**

- Realistische Datensätze erstellen
- Konsistente Daten generieren
- Produktionsdaten anonymisieren

**3. Datenbankmodellierung**

- ER-Diagramme aus Beschreibungen erstellen
- Verbesserungen am Design vorschlagen
- Normalisierung überprüfen

**4. Optimierung und Analyse**

- Performance analysieren
- Indizes vorschlagen
- Engpässe identifizieren

**5. Dokumentation**

- Dokumentation automatisch generieren
- Code-Kommentare erstellen
- Komplexe Abfragen erklären

### Übersicht der wichtigsten KI-Tools

| Tool | Verwendung | Stärken | Schwächen |
|------|------------|---------|-----------|
| ChatGPT | Code-Generierung, Debugging, Dokumentation | Schnelle Lösungen, gute Erklärungen | Manchmal veraltete Syntax |
| GitHub Copilot | Inline Code-Completion | IDE-Integration, Kontext-aware | Kostenpflichtig |
| Claude | Komplexe Probleme, Architektur, Analyse und Optimierung | Längere Kontexte, detaillierte Antworten | - |
| Tabnine | Code-Vorschläge in der IDE | Kann lokal betrieben werden | Weniger stark bei komplexen Aufgaben |
| DB-GPT | SQL-Generierung aus natürlicher Sprache | Spezialisiert auf Datenbanken | Noch in Entwicklung |

### Klassische Datenbank-Tools

KI-Tools ersetzen die klassischen Werkzeuge nicht, sondern ergänzen sie:

1. **MySQL Workbench**: Visueller Query-Builder
2. **DataGrip**: Professionelle IDE
3. **pgAdmin**: Für PostgreSQL
4. **DBeaver**: Plattformübergreifend

## Gute Prompts schreiben

### Präzise formulieren

❌ Schlecht:

```text
Gib mir SQL für Bücher
```

✅ Gut:

```text
Datenbankschema (MariaDB):
- books (id, title, author_id, genre_id, published_date)
- authors (id, firstname, lastname)
- genres (id, genre)

Aufgabe: Erstelle eine SQL-Abfrage, die alle Bücher mit ihren Autoren zeigt,
gruppiert nach Genre, mit der Anzahl Bücher pro Genre.
```

### Kontext bereitstellen

- Datenbankschema angeben
- Gewünschtes Ergebnis beschreiben
- Constraints erwähnen (z.B. "verwende INNER JOIN, nicht LEFT JOIN")
- Datenbanktyp angeben (MariaDB/MySQL, PostgreSQL, etc.)

### Ergebnisse kritisch überprüfen

KI macht Fehler! Immer:

- SQL-Syntax überprüfen
- Logik nachvollziehen
- Mit Testdaten testen
- Performance berücksichtigen

## KI für SQL-Abfragen

### SQL-Abfragen generieren

**Beispiel 1 – Ärztezentrum**

**Prompt:**

```text
Gegeben ist folgendes Datenbankschema:

Tabelle: patients (patient_id, first_name, last_name, birth_date)
Tabelle: doctors (doctor_id, name, specialization)
Tabelle: appointments (appointment_id, patient_id, doctor_id, appointment_date, status)

Erstelle eine SQL-Abfrage, die alle Termine von Patienten zeigt, die älter als 50 Jahre sind,
zusammen mit dem Namen des behandelnden Arztes.
```

**KI-generierte Lösung:**

```sql
SELECT
    p.first_name,
    p.last_name,
    TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE()) AS age,
    d.name AS doctor_name,
    a.appointment_date
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
WHERE TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE()) > 50
ORDER BY a.appointment_date DESC;
```

**Beispiel 2 – HFTM Library**

**Prompt:**

```text
Schreibe eine SQL-Abfrage, um:
- Alle Bücher zu finden, die nach 2010 veröffentlicht wurden
- Mit ihren Autoren
- Sortiert nach Titel
- Nur verfügbare Bücher (Lagerbestand > 0)

Tabellen: books (id, title, author_id, published_date, amount_in_stock)
          authors (id, firstname, lastname)
```

**Antwort von Claude:**

```sql
SELECT
    b.title,
    b.published_date,
    b.amount_in_stock,
    CONCAT(a.firstname, ' ', a.lastname) AS author_name
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE b.published_date > '2010-12-31'
    AND b.amount_in_stock > 0
ORDER BY b.title;
```

### Abfragen optimieren

**Prompt:**

```text
Optimiere diese Abfrage:

SELECT * FROM books
WHERE author_id IN (
    SELECT id FROM authors WHERE lastname LIKE '%Smith%'
);
```

**Antwort von Claude:**

```sql
-- Mit JOIN statt Subquery
SELECT b.*
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE a.lastname LIKE '%Smith%';

-- Oder mit EXISTS (je nach Optimizer gleich schnell oder schneller)
SELECT b.*
FROM books b
WHERE EXISTS (
    SELECT 1
    FROM authors a
    WHERE a.id = b.author_id
        AND a.lastname LIKE '%Smith%'
);

-- Hinweis: LIKE mit führendem '%' kann keinen Index nutzen
```

### Komplexe Abfragen erklären

**Prompt:**

```text
Erkläre diese Abfrage im Detail:

SELECT
    g.genre,
    COUNT(b.id) AS book_count,
    AVG(b.amount_in_stock) AS avg_stock
FROM genres g
LEFT JOIN books b ON g.id = b.genre_id
GROUP BY g.id, g.genre
HAVING COUNT(b.id) > 5
ORDER BY book_count DESC;
```

**Antwort von Claude:**

Diese Abfrage analysiert die Buch-Genres:

1. **SELECT**: Wählt den Genre-Namen, zählt die Bücher und berechnet den durchschnittlichen Lagerbestand
2. **LEFT JOIN**: Bezieht alle Genres ein, auch solche ohne Bücher
3. **GROUP BY**: Gruppiert nach Genre
4. **HAVING**: Filtert nur Genres mit mehr als 5 Büchern
5. **ORDER BY**: Sortiert nach Anzahl Bücher (absteigend)

## Testdaten generieren

### Mit Claude AI

**Prompt:**

```text
Generiere 10 INSERT-Statements für die Tabelle books mit realistischen Daten:

CREATE TABLE books (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255) NOT NULL,
    author_id INT,
    isbn VARCHAR(20),
    published_date DATE,
    price DECIMAL(10,2),
    amount_in_stock INT
);

Die author_id müssen zwischen 1 und 50 liegen.
```

**Antwort von Claude:**

```sql
INSERT INTO books (title, author_id, isbn, published_date, price, amount_in_stock) VALUES
('The Midnight Library', 12, '978-0525559474', '2020-08-13', 24.99, 45),
('Project Hail Mary', 8, '978-0593135204', '2021-05-04', 28.99, 32),
('The Seven Husbands of Evelyn Hugo', 23, '978-1501161933', '2017-06-13', 16.99, 67),
('Atomic Habits', 15, '978-0735211292', '2018-10-16', 27.00, 89),
('Where the Crawdads Sing', 34, '978-0735219090', '2018-08-14', 26.00, 54),
('Educated', 41, '978-0399590504', '2018-02-20', 28.00, 43),
('The Silent Patient', 19, '978-1250301697', '2019-02-05', 26.99, 38),
('Circe', 28, '978-0316556347', '2018-04-10', 27.00, 51),
('The Invisible Life of Addie LaRue', 7, '978-0765387561', '2020-10-06', 27.99, 29),
('Anxious People', 12, '978-1501160837', '2020-09-08', 27.00, 41);
```

### Node.js-Script mit KI

```javascript
// generateTestData.js
const Anthropic = require('@anthropic-ai/sdk');
const pool = require('./config/database');

const client = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY
});

async function generateTestData() {
    const prompt = `
    Generiere 20 INSERT-Statements für eine Tabelle authors:
    CREATE TABLE authors (
        id INT PRIMARY KEY AUTO_INCREMENT,
        firstname VARCHAR(50),
        lastname VARCHAR(50),
        email VARCHAR(100),
        birth_date DATE
    );

    Realistische Daten mit unterschiedlichen Namen und Geburtsdaten zwischen 1950 und 1990.
    `;

    const message = await client.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 2000,
        messages: [{
            role: 'user',
            content: prompt
        }]
    });

    const sqlStatements = message.content[0].text;
    console.log('Generated SQL:', sqlStatements);

    // Optional: Direkt ausführen (erst nach Kontrolle!)
    // Mehrere Statements auf einmal erfordern multipleStatements: true im Pool
    // await pool.query(sqlStatements);
}

generateTestData();
```

## KI für Datenbankdesign

### ER-Diagramm erstellen

**Prompt:**

```text
Erstelle ein Datenbankdesign für ein Restaurantmanagement-System:

Anforderungen:
- Tabellen: Menu items, Orders, Customers, Employees, Tables
- Ein Kunde kann mehrere Bestellungen haben
- Eine Bestellung kann mehrere Menu items haben
- Mitarbeiter bedienen die Tische
- N:M-Beziehungen, wo sinnvoll

Format: Strukturierter Text mit Tabellen, Spalten und Beziehungen
```

**Antwort von Claude:**

```text
TABLES:

customers
- customer_id (PK)
- first_name
- last_name
- email
- phone
- created_at

menu_items
- item_id (PK)
- name
- description
- price
- category
- available

orders
- order_id (PK)
- customer_id (FK → customers)
- table_id (FK → tables)
- employee_id (FK → employees)
- order_date
- total_amount
- status

order_items (Junction Table)
- order_item_id (PK)
- order_id (FK → orders)
- item_id (FK → menu_items)
- quantity
- item_price

tables
- table_id (PK)
- table_number
- capacity
- status

employees
- employee_id (PK)
- first_name
- last_name
- position
- hire_date

RELATIONS:
- customers 1:N orders
- orders N:M menu_items (via order_items)
- tables 1:N orders
- employees 1:N orders
```

### Prompt für ein vollständigeres Design

Für ein umfassenderes Design kann der Prompt erweitert werden:

```text
Ich möchte eine Datenbank für ein Restaurantmanagement-System erstellen.

Anforderungen:
- Verwaltung von Tischen, Reservierungen, Bestellungen
- Mehrere Standorte (Restaurants)
- Mitarbeiter mit verschiedenen Rollen (Koch, Kellner, Manager)
- Speisekarte mit Kategorien und Allergenen
- Kundenverwaltung mit Treueprogramm

Erstelle:
1. Ein ER-Diagramm (textuell beschrieben)
2. Tabellenstrukturen mit Datentypen
3. Beziehungen zwischen Tabellen
4. Wichtige Constraints
```

## KI für Code-Reviews und Refactoring

### Prompt-Template für Code-Review

```text
Ich habe folgenden Code für einen REST API Endpoint geschrieben.
Bitte überprüfe auf:
1. SQL-Injection Sicherheit
2. Error Handling
3. HTTP-Statuscodes
4. Performance-Probleme
5. Best Practices

[Code hier einfügen]
```

### Prompt-Template für Refactoring

```text
Der folgende Code funktioniert, ist aber nicht optimal strukturiert.
Bitte refactore den Code nach:
1. MVC-Pattern
2. DRY-Prinzip (Don't Repeat Yourself)
3. Bessere Fehlerbehandlung
4. Verwendung von async/await statt Callbacks

[Code hier einfügen]
```

## KI-unterstützte Debugging-Strategie

### Schritt 1: Fehlermeldung analysieren

```text
Ich erhalte folgenden Fehler beim Ausführen meines Node.js Codes:

Error: ER_BAD_FIELD_ERROR: Unknown column 'amount_in_stok' in 'field list'

Kontext:
- Ich verwende mysql2 mit Node.js und MariaDB
- Tabelle: books mit Spalten: id, title, author_id, isbn, amount_in_stock
- Query: SELECT id, title, amount_in_stok FROM books

Was ist das Problem und wie behebe ich es?
```

### Schritt 2: Code-Kontext hinzufügen

Wenn die erste Antwort nicht hilft:

```text
Hier ist mein vollständiger Code:

[Code einfügen]

Der Fehler tritt in Zeile X auf. Was könnte das Problem sein?
```

### Schritt 3: Iterativ verfeinern

Nach jeder KI-Antwort:

- Testen
- Wenn der Fehler bleibt: Mehr Kontext geben
- Wenn es funktioniert: Verstehen, WARUM es funktioniert

## Typische KI-Fehler und wie man sie erkennt

### Fehler 1: Falsche JOIN-Logik

```sql
-- Aufgabe: "Alle Bücher, die nie ausgeliehen wurden"
-- KI generiert manchmal:
SELECT b.title
FROM books b
INNER JOIN lends l ON l.book_id = b.id
WHERE l.id IS NULL;

-- Problem: INNER JOIN liefert nur Bücher MIT Ausleihen,
-- die WHERE-Bedingung ist daher nie erfüllt (leeres Resultat)

-- Richtig (LEFT JOIN):
SELECT b.title
FROM books b
LEFT JOIN lends l ON l.book_id = b.id
WHERE l.id IS NULL;
```

### Fehler 2: Unsichere Queries (SQL-Injection)

```javascript
// KI könnte generieren:
const query = `SELECT * FROM users WHERE username = '${username}'`;

// Richtig (Prepared Statement):
const query = 'SELECT * FROM users WHERE username = ?';
db.query(query, [username]);
```

### Fehler 3: N+1 Query Problem

```javascript
// Ineffizient (N+1 Problem):
const [books] = await db.query('SELECT * FROM books');
for (const book of books) {
    const [authors] = await db.query('SELECT * FROM authors WHERE id = ?', [book.author_id]);
    book.author = authors[0];
}

// Richtig (1 Query mit JOIN):
const query = `
    SELECT b.*, a.firstname, a.lastname
    FROM books b
    JOIN authors a ON b.author_id = a.id
`;
const [booksWithAuthors] = await db.query(query);
```

### Fehler 4: Veraltete Syntax

```javascript
// KI könnte alte mysql-Syntax verwenden:
var mysql = require('mysql');
var connection = mysql.createConnection({...});

// Modern (mysql2 mit Promises):
const mysql = require('mysql2/promise');
const connection = await mysql.createConnection({...});
```

## Claude AI in die eigene Anwendung integrieren

### Installation

```bash
npm install @anthropic-ai/sdk
```

### Konfiguration

```javascript
// config/claude.js
const Anthropic = require('@anthropic-ai/sdk');

const client = new Anthropic({
    apiKey: process.env.ANTHROPIC_API_KEY
});

module.exports = client;
```

Der API-Key gehört in die `.env`-Datei und nie ins Git-Repository.

### Beispiel: SQL-Abfrage-Generator

```javascript
// controllers/aiController.js
const claude = require('../config/claude');

exports.generateQuery = async (req, res) => {
    try {
        const { description, tables } = req.body;

        const prompt = `
        Generiere eine SQL-Abfrage für: ${description}

        Verfügbares Datenbankschema:
        ${tables}

        Antworte nur mit der SQL-Abfrage, ohne Erklärung.
        `;

        const message = await claude.messages.create({
            model: 'claude-sonnet-4-20250514',
            max_tokens: 1024,
            messages: [{
                role: 'user',
                content: prompt
            }]
        });

        const sqlQuery = message.content[0].text;

        res.json({
            query: sqlQuery,
            description: description
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error generating query' });
    }
};
```

### Beispiel: Datenanalyse

```javascript
exports.analyzeData = async (req, res) => {
    try {
        const { query, data } = req.body;

        const prompt = `
        Analysiere diese Daten aus der Datenbank:

        Abfrage: ${query}
        Resultate: ${JSON.stringify(data, null, 2)}

        Liefere:
        1. Zusammenfassung der wichtigsten Erkenntnisse
        2. Interessante Trends
        3. Empfehlungen
        `;

        const message = await claude.messages.create({
            model: 'claude-sonnet-4-20250514',
            max_tokens: 2000,
            messages: [{
                role: 'user',
                content: prompt
            }]
        });

        const analysis = message.content[0].text;

        res.json({
            analysis: analysis,
            dataPoints: data.length
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Error analyzing data' });
    }
};
```

## Automatische Dokumentation

### Code-Kommentare generieren

**Prompt:**

```text
Füge dieser Funktion JSDoc-Kommentare hinzu:

async function getBooksWithAuthors() {
    const sql = `
        SELECT b.*, a.firstname, a.lastname
        FROM books b
        INNER JOIN authors a ON b.author_id = a.id
        WHERE b.amount_in_stock > 0
    `;
    const [rows] = await pool.query(sql);
    return rows;
}
```

**Antwort von Claude:**

```javascript
/**
 * Liest alle verfügbaren Bücher mit ihren Autoren
 *
 * Verknüpft die Tabellen books und authors, um die vollständigen
 * Informationen zu erhalten. Liefert nur Bücher, die an Lager sind.
 *
 * @async
 * @returns {Promise<Array>} Array von Objekten mit den Details zu Büchern und Autoren
 * @throws {Error} Wenn die Datenbankabfrage fehlschlägt
 *
 * @example
 * const books = await getBooksWithAuthors();
 * // [{id: 1, title: "Book", firstname: "John", lastname: "Doe"}, ...]
 */
async function getBooksWithAuthors() {
    const sql = `
        SELECT
            b.*,
            a.firstname,
            a.lastname
        FROM books b
        INNER JOIN authors a ON b.author_id = a.id
        WHERE b.amount_in_stock > 0
    `;
    const [rows] = await pool.query(sql);
    return rows;
}
```

### README für das API generieren

**Prompt:**

```text
Generiere ein README.md für dieses API:

Endpoints:
- GET /api/books
- GET /api/books/:id
- POST /api/books
- PUT /api/books/:id
- DELETE /api/books/:id
- GET /api/authors
- POST /api/authors

Datenbank: MariaDB
Tech Stack: Node.js, Express, mysql2
```

## Praktische Übungen

### Übung 1: SQL mit KI generieren

Verwende ChatGPT/Claude, um folgende Queries zu erstellen:

**Datenbank:** HFTM Library

1. Alle Bücher, die aktuell ausgeliehen sind
2. Top 5 Kunden mit den meisten Ausleihen
3. Bücher, die nie ausgeliehen wurden
4. Durchschnittliche Ausleihdauer pro Buch

**Aufgabe:**

- Lass dir die Queries von KI generieren
- Teste sie in deiner Datenbank
- Dokumentiere Fehler und Korrekturen
- Erkläre, warum die Query so funktioniert

### Übung 2: Code-Review mit KI

Nimm deinen eigenen REST API Code von Lektion 8:

- Lass ihn von KI reviewen
- Implementiere 3 Verbesserungsvorschläge
- Dokumentiere, was verbessert wurde

### Übung 3: Fehlerbehebung

Hier ist bewusst fehlerhafter Code:

```javascript
const express = require('express');
const app = express();

app.get('/api/users/:id', (req, res) => {
    const userId = req.params.id;
    const query = `SELECT * FROM users WHERE user_id = ${userId}`;

    db.query(query, (error, results) => {
        res.json(results);
    });
});
```

**Aufgaben:**

1. Finde alle Fehler (mindestens 4!)
2. Nutze KI, um Verbesserungen zu finden
3. Implementiere die korrekte Version
4. Erkläre jeden Fehler

### Übung 4: Abfrage-Generator

Einen Endpoint erstellen, der:

1. Eine Beschreibung in natürlicher Sprache entgegennimmt
2. Mit Claude eine SQL-Abfrage generiert
3. Die Abfrage validiert
4. Die Abfrage ausführt und die Resultate zurückgibt

### Übung 5: Testdaten

Claude verwenden, um:

1. 50 realistische Kunden zu generieren
2. 100 Ausleihen zu generieren
3. Die Konsistenz der Daten sicherzustellen (Daten, Beträge)

### Übung 6: Dokumentation

Automatisch generieren:

1. API-Dokumentation (Markdown)
2. Kommentare für alle Funktionen
3. ER-Diagramm als Text

## Projektarbeit: DB-Design Review

### Checkpoint: Datenbankdesign

Heute ist die Abgabe des DB-Designs für euer Webprojekt.

**Checkliste:**

- [ ] ER-Diagramm mit 4-5 Entitäten
- [ ] Mindestens 5x 1:N Beziehungen
- [ ] Mindestens 2x N:M Beziehungen
- [ ] Normalisierung (3. Normalform)
- [ ] Datentypen definiert
- [ ] Primary Keys und Foreign Keys dokumentiert

### KI-gestützter Design-Review

Nutze KI für einen Self-Review:

```text
Hier ist mein ER-Diagramm für [Projektthema]:

[Beschreibung einfügen]

Bitte überprüfe:
1. Ist die Normalisierung korrekt (1NF, 2NF, 3NF)?
2. Sind die Beziehungen sinnvoll?
3. Fehlen wichtige Tabellen/Felder?
4. Gibt es Redundanzen?
5. Sind die Datentypen passend gewählt?
```

### Implementierung starten

Nach dem Design-Review:

1. **SQL-Script erstellen**
    - CREATE TABLE Statements
    - PRIMARY KEY und FOREIGN KEY Constraints
    - Testdaten INSERT Statements

2. **Datenbank in MariaDB anlegen**

    ```bash
    mysql -u root -p -e "CREATE DATABASE projektname;"
    mysql -u root -p projektname < path/to/schema.sql
    ```

3. **Node.js Projekt aufsetzen**

    ```bash
    npm init -y
    npm install express mysql2 dotenv cors
    ```

4. **Erste API Endpoints**
    - Mindestens eine Ressource vollständig (CRUD)
    - Datenbankverbindung testen

### Hands-on Session: Timeboxing (90 Minuten)

**Phase 1: Review & Planning (20 min)**

- DB-Design mit KI reviewen
- Todo-Liste erstellen
- Prioritäten setzen

**Phase 2: Implementation (50 min)**

- SQL-Script finalisieren
- Datenbank anlegen
- 2-3 API Endpoints implementieren

**Phase 3: Testing & Debugging (20 min)**

- Endpoints mit Postman/Thunder Client testen
- Fehler beheben (mit KI-Unterstützung)
- Fortschritt dokumentieren

## Best Practices und Sicherheit

### Ergebnisse validieren

```javascript
// Von KI generierte SQL-Abfragen immer validieren
async function validateAndExecuteQuery(generatedSQL) {
    try {
        const sql = generatedSQL.trim().replace(/;\s*$/, '');

        // 1. Nur einzelne SELECT-Abfragen zulassen
        if (!/^SELECT\s/i.test(sql) || sql.includes(';')) {
            throw new Error('Only single SELECT statements are allowed');
        }

        // 2. Mit einem DB-Benutzer ausführen, der nur Leserechte hat
        const [rows] = await readOnlyPool.query(sql);

        return rows;

    } catch (err) {
        console.error('Generated query failed:', err);
        throw err;
    }
}
```

### Zugriff einschränken

```javascript
// SQL-Generierung nicht direkt für Endbenutzer freigeben
exports.generateQuery = async (req, res) => {
    // Authentifizierung prüfen
    if (!req.user || !req.user.isAdmin) {
        return res.status(403).json({ error: 'Forbidden' });
    }

    // Rate Limiting
    // Input validieren
    // Abfrage generieren
};
```

### Datenschutz bei KI-Nutzung

⚠️ **Was NICHT an KI weitergeben:**

- **Echte Produktionsdaten** (Namen, Adressen, etc.)
- **Passwörter oder API-Keys**
- **Interne Firmendaten**
- **Personenbezogene Daten (DSG/DSGVO!)**

✅ **Was OK ist:**

- Anonymisierte Beispieldaten
- Schema-Strukturen (ohne Daten)
- Fehlermeldungen (ohne sensible Infos)
- Konzeptionelle Fragen

**Tipp:** Dummy-Daten wie "Max Mustermann" oder "test@example.com" verwenden.

**Wichtig für die Sicherheit:**

- Nie Produktionsdaten an KI senden
- Generierte Abfragen immer validieren
- SQL-Generierung nicht für Endbenutzer freigeben
- Datenschutz einhalten

## Grenzen und ethische Überlegungen

### Wann KI einsetzen

✅ **Gut:**

- Testdaten generieren
- Code dokumentieren
- SQL lernen
- Abfragen optimieren
- Performance analysieren

❌ **Problematisch:**

- Menschliches Verständnis vollständig ersetzen
- Nicht validiertes SQL in Produktion ausführen
- Sensible Daten mit KI teilen
- Resultaten blind vertrauen

### KI ist gut bei

1. **Boilerplate-Code**
2. **Standard-Patterns**
3. **Syntax-Fragen**
4. **Dokumentation**
5. **Code-Erklärungen**
6. **Einfachen Refactorings**

### KI ist NICHT gut bei

1. **Komplexer Business-Logik**
    - Spezifische Geschäftsregeln
    - Branchenspezifische Anforderungen

2. **Performance-Optimierung**
    - Index-Strategien
    - Query-Optimierung für grosse Datenmengen

3. **Sicherheitskonzepten**
    - Vollständige Security-Audits
    - Penetration Testing

4. **Architektur-Entscheidungen**
    - Technologie-Auswahl für spezifische Anforderungen
    - Skalierungs-Strategien

### KI und Lernen

⚠️ **Achtung:**

- KI-Code ohne Verständnis übernehmen = Schummeln
- KI zur Erklärung nutzen = Lernen

**Richtige Nutzung:**

1. Erst selbst versuchen
2. KI für Erklärungen nutzen
3. Code verstehen und anpassen
4. Dokumentieren, was von KI kam

### KI im Beruf

- Viele Firmen haben KI-Richtlinien
- Keine sensiblen Daten an öffentliche KI-Tools
- KI als Werkzeug, nicht als Ersatz für Denken

### Zukunft von KI im Datenbankumfeld

- **Automatische Optimierung**: KI schlägt automatisch Indizes vor
- **Anomalie-Erkennung**: Erkennen ungewöhnlicher Muster
- **Self-tuning Databases**: Datenbanken, die sich selbst optimieren
- **Natural Language Queries**: Abfragen in natürlicher Sprache
- **Automated Testing**: Automatisch generierte Tests

## Zusammenfassung

KI kann helfen bei:

- ✅ Generierung von SQL-Abfragen
- ✅ Erstellung von Testdaten
- ✅ Automatischer Dokumentation
- ✅ Optimierung von Abfragen
- ✅ Datenanalyse
- ✅ Code-Reviews und Debugging

Aber immer:

- ⚠️ Resultate validieren
- ⚠️ Sensible Daten schützen
- ⚠️ Das menschliche Verständnis behalten
- ⚠️ In einer sicheren Umgebung testen

## Checkliste für Credit 8

- [ ] Mindestens 3 SQL-Queries mit KI generiert und getestet
- [ ] Code-Review mit KI durchgeführt
- [ ] 3 Verbesserungen implementiert
- [ ] DB-Design mit KI reviewt
- [ ] Dokumentation: Was hat KI geholfen? Was nicht?
- [ ] Screenshot/Beweis der KI-Interaktion

## Hausaufgaben

1. **Projektarbeit fortsetzen:**
    - Mindestens 3 CRUD-Endpoints implementieren
    - Alle Endpoints testen
    - Dokumentation erstellen

2. **KI im Projekt einsetzen:**
    - Claude AI in das Projekt integrieren
    - Einen Endpoint für die Generierung von Abfragen erstellen
    - Testdaten mit KI generieren
    - Das API mit Hilfe von KI dokumentieren

3. **Vorbereitung Lektion 10:**
    - MongoDB Account erstellen (MongoDB Atlas)
    - Konzept NoSQL vs. SQL recherchieren

## Reflexionsfragen

- Wo hat dir KI am meisten geholfen?
- Wo waren die Grenzen?
- Welche Fehler hat die KI gemacht?
- Was hast du durch KI-Nutzung gelernt?
- Was hättest du ohne KI nicht geschafft?

## Ressourcen

- [Anthropic Dokumentation](https://docs.anthropic.com/)
- [Claude AI](https://claude.ai/)
- [GitHub Copilot Dokumentation](https://github.com/features/copilot)
- [ChatGPT Best Practices](https://platform.openai.com/docs/guides/prompt-engineering)
- [Best Practices for AI Code Generation](https://github.blog/2023-06-20-how-to-write-better-prompts-for-github-copilot/)
- [AI Code Review Tools](https://github.com/marketplace?category=code-review&type=apps)

## Nächste Schritte

In Lektion 10 schauen wir uns NoSQL-Datenbanken und MongoDB an – ein ganz anderes Datenbankkonzept als das relationale Modell:

- NoSQL und MongoDB
- Unterschiede SQL vs. NoSQL
- CRUD-Operationen in MongoDB
- Wann welche Datenbank verwenden

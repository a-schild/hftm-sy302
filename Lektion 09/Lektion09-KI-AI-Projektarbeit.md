# Lektion 9: KI/AI im Datenbankumfeld & Projektarbeit

## Lernziele

- Die aktuellen KI-Tools im Datenbankumfeld richtig einsetzen
- Die Grenzen der KI-Tools zu erkennen
- Die gelernte Theorie im Projekt anzuwenden
- Kritisch mit KI-generierten Lösungen umgehen

## KI-Tools im Datenbankumfeld

### Übersicht der wichtigsten Tools

| Tool | Verwendung | Stärken | Schwächen |
|------|------------|---------|-----------|
| ChatGPT | Code-Generierung, Debugging | Schnelle Lösungen, gute Erklärungen | Manchmal veraltete Syntax |
| GitHub Copilot | Inline Code-Completion | IDE-Integration, Kontext-aware | Kostenpflichtig |
| Claude | Komplexe Probleme, Architektur | Längere Kontexte, detaillierte Antworten | - |
| DB-GPT | SQL-Generierung aus natürlicher Sprache | Spezialisiert auf Datenbanken | Noch in Entwicklung |

### KI für SQL-Generierung

**Beispiel-Prompt:**
```
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

### Best Practices für KI-Nutzung

**1. Gute Prompts schreiben**

❌ Schlecht:
```
Gib mir SQL für Bücher
```

✅ Gut:
```
Datenbankschema:
- books (book_id, title, author_id, isbn, publication_year)
- authors (author_id, name, country)

Aufgabe: Erstelle eine SQL-Abfrage, die alle Bücher mit ihren Autoren zeigt,
gruppiert nach Land des Autors, mit der Anzahl Bücher pro Land.
```

**2. Kontext bereitstellen**

- Datenbankschema angeben
- Gewünschtes Ergebnis beschreiben
- Constraints erwähnen (z.B. "verwende INNER JOIN nicht LEFT JOIN")
- Datenbanktyp angeben (MySQL, PostgreSQL, etc.)

**3. Kritisch überprüfen**

KI macht Fehler! Immer:
- SQL-Syntax überprüfen
- Logik nachvollziehen
- Mit Testdaten testen
- Performance berücksichtigen

## Typische KI-Fehler und wie man sie erkennt

### Fehler 1: Falsche JOIN-Logik

```sql
-- KI generiert manchmal:
SELECT * FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date > '2024-01-01'
AND c.country = 'Switzerland';

-- Problem: Funktioniert, aber ineffizient wenn Index auf country fehlt
```

### Fehler 2: Unsichere Queries (SQL-Injection)

```javascript
// KI könnte generieren:
const query = `SELECT * FROM users WHERE username = '${username}'`;

// Richtig:
const query = 'SELECT * FROM users WHERE username = ?';
db.query(query, [username]);
```

### Fehler 3: N+1 Query Problem

```javascript
// Ineffizient (N+1 Problem):
const books = await db.query('SELECT * FROM books');
for (let book of books) {
    const author = await db.query('SELECT * FROM authors WHERE author_id = ?', [book.author_id]);
    book.author = author[0];
}

// Richtig (1 Query mit JOIN):
const query = `
    SELECT b.*, a.name as author_name
    FROM books b
    JOIN authors a ON b.author_id = a.author_id
`;
const books = await db.query(query);
```

### Fehler 4: Veraltete Syntax

```javascript
// KI könnte alte mysql Syntax verwenden:
var mysql = require('mysql');
var connection = mysql.createConnection({...});

// Modern (mysql2 mit Promises):
const mysql = require('mysql2/promise');
const connection = await mysql.createConnection({...});
```

## KI für Code-Reviews nutzen

### Prompt-Template für Code-Review

```
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

```
Der folgende Code funktioniert, ist aber nicht optimal strukturiert.
Bitte refactore den Code nach:
1. MVC-Pattern
2. DRY-Prinzip (Don't Repeat Yourself)
3. Bessere Fehlerbehandlung
4. Verwendung von async/await statt Callbacks

[Code hier einfügen]
```

## KI für Datenbankdesign

### Prompt für ER-Diagramm

```
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

## Datenschutz bei KI-Nutzung

### ⚠️ Was NICHT an KI weitergeben:

- **Echte Produktionsdaten** (Namen, Adressen, etc.)
- **Passwörter oder API-Keys**
- **Interne Firmendaten**
- **Personenbezogene Daten (DSGVO!)**

### ✅ Was OK ist:

- Anonymisierte Beispieldaten
- Schema-Strukturen (ohne Daten)
- Fehlermeldungen (ohne sensible Infos)
- Konzeptionelle Fragen

**Tipp:** Verwende Dummy-Daten wie "Max Mustermann", "test@example.com"

## KI-unterstützte Debugging-Strategie

### Schritt 1: Fehlermeldung analysieren

```
Ich erhalte folgenden Fehler beim Ausführen meines Node.js Codes:

Error: ER_BAD_FIELD_ERROR: Unknown column 'auther_name' in 'field list'

Kontext:
- Ich verwende mysql2 mit Node.js
- Tabelle: books mit Spalten: book_id, title, author_name, isbn
- Query: SELECT book_id, title, auther_name FROM books

Was ist das Problem und wie behebe ich es?
```

### Schritt 2: Code-Kontext hinzufügen

Wenn die erste Antwort nicht hilft:

```
Hier ist mein vollständiger Code:

[Code einfügen]

Der Fehler tritt in Zeile X auf. Was könnte das Problem sein?
```

### Schritt 3: Iterativ verfeinern

Nach jeder KI-Antwort:
- Testen
- Wenn Fehler bleibt: Mehr Kontext geben
- Wenn funktioniert: Verstehen WARUM es funktioniert

## Praktische Übungen

### Übung 1: SQL mit KI generieren

Verwende ChatGPT/Claude um folgende Queries zu erstellen:

**Datenbank:** HFTM Library

1. Alle Bücher, die aktuell ausgeliehen sind
2. Top 5 Benutzer mit den meisten Ausleihen
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
2. Nutze KI um Verbesserungen zu finden
3. Implementiere die korrekte Version
4. Erkläre jeden Fehler

## Projektarbeit: DB-Design Review

### Checkpoint: Datenbankdesign

Heute ist die Abgabe des DB-Designs für euer Webprojekt.

**Checkliste:**
- [ ] ER-Diagramm mit 4-5 Entitäten
- [ ] Mindestens 2x 1:N Beziehungen
- [ ] Mindestens 1x N:M Beziehung
- [ ] Normalisierung (3. Normalform)
- [ ] Datentypen definiert
- [ ] Primary Keys und Foreign Keys dokumentiert

### KI-gestützter Design-Review

Nutze KI für einen Self-Review:

```
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
   mysql -u root -p
   CREATE DATABASE projektname;
   USE projektname;
   SOURCE path/to/schema.sql;
   ```

3. **Node.js Projekt aufsetzen**
   ```bash
   npm init -y
   npm install express mysql2 dotenv cors
   ```

4. **Erste API Endpoints**
   - Mindestens eine Ressource vollständig (CRUD)
   - Datenbankverbindung testen

## Grenzen von KI erkennen

### KI ist NICHT gut bei:

1. **Komplexen Business-Logik**
   - Spezifische Geschäftsregeln
   - Branchen-spezifische Anforderungen

2. **Performance-Optimierung**
   - Index-Strategien
   - Query-Optimierung für große Datenmengen

3. **Sicherheitskonzepte**
   - Vollständige Security-Audits
   - Penetration Testing

4. **Architektur-Entscheidungen**
   - Technologie-Auswahl für spezifische Anforderungen
   - Skalierungs-Strategien

### KI ist gut bei:

1. **Boilerplate-Code**
2. **Standard-Patterns**
3. **Syntax-Fragen**
4. **Dokumentation**
5. **Code-Erklärungen**
6. **Einfache Refactorings**

## Ethische Überlegungen

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

## Hands-on Session: Projektarbeit

### Timeboxing (90 Minuten)

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

## Zusätzliche Ressourcen

- [GitHub Copilot Dokumentation](https://github.com/features/copilot)
- [ChatGPT Best Practices](https://platform.openai.com/docs/guides/prompt-engineering)
- [AI Code Review Tools](https://github.com/marketplace?category=code-review&type=apps)

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

2. **Vorbereitung Lektion 10:**
   - MongoDB Account erstellen (MongoDB Atlas)
   - Konzept NoSQL vs. SQL recherchieren

## Reflexionsfragen

- Wo hat dir KI am meisten geholfen?
- Wo waren die Grenzen?
- Welche Fehler hat die KI gemacht?
- Was hast du durch KI-Nutzung gelernt?
- Was hättest du ohne KI nicht geschafft?

## Nächste Schritte

In Lektion 10 schauen wir uns NoSQL-Datenbanken und MongoDB an - ein ganz anderes Datenbankkonzept als das relationale Modell.

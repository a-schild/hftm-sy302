# Lektion 6: SQL-Repetition & Projekt-Kickoff

## Übersicht

**Teil 1:** SQL-Repetition und Beispieltest als Vorbereitung auf die Theorieprüfung in Unit 7 (90 Minuten)
**Teil 2:** Projekt-Kickoff und Themenwahl (30 Minuten)

## Teil 1: Vorbereitung auf die Theorieprüfung SQL

Die Theorieprüfung findet in **Unit 7** statt (vor dem Node.js-Teil). Heute repetieren wir den Stoff und lösen einen Beispieltest.

### Format der Theorieprüfung (Unit 7)

- **Dauer:** 90 Minuten
- **Gewichtung:** 30% der Gesamtnote
- **Hilfsmittel:** Keine (ausser Stift und Papier)
- **Format:** Schriftlich oder am Computer

### Prüfungsthemen

#### 1. Datenmodellierung (25%)

**ER-Diagramme:**
- Entitäten identifizieren
- Attribute definieren
- Beziehungen (1:1, 1:N, N:M) erkennen
- Kardinalitäten bestimmen
- Primary und Foreign Keys

**Normalisierung:**
- 1. Normalform (1NF): Atomare Werte
- 2. Normalform (2NF): Volle funktionale Abhängigkeit
- 3. Normalform (3NF): Keine transitiven Abhängigkeiten
- Redundanzen erkennen und eliminieren

**Beispiel-Aufgaben:**
```
1. Gegeben ist folgende Tabelle. Identifiziere Redundanzen und Anomalien.
2. Normalisiere die Tabelle bis zur 3. Normalform.
3. Erstelle ein ER-Diagramm für folgendes Szenario: [...]
4. Zeichne die Beziehungen zwischen folgenden Entitäten: [...]
```

#### 2. SQL DDL (20%)

**CREATE TABLE:**
- Datentypen wählen
- Constraints definieren (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT)
- AUTO_INCREMENT
- ON DELETE / ON UPDATE Actions

**ALTER TABLE:**
- Spalten hinzufügen/ändern/löschen
- Constraints hinzufügen/entfernen

**Beispiel-Aufgaben:**
```sql
1. Erstelle eine Tabelle 'orders' mit folgenden Anforderungen: [...]
2. Füge eine Foreign Key Constraint hinzu: [...]
3. Ändere den Datentyp einer Spalte: [...]
4. Was ist der Unterschied zwischen CHAR und VARCHAR?
```

#### 3. SQL DML (25%)

**INSERT:**
- Einzelne und mehrere Zeilen
- Mit Subqueries
- DEFAULT-Werte

**SELECT:**
- WHERE-Bedingungen (=, !=, >, <, LIKE, IN, BETWEEN, IS NULL)
- ORDER BY, LIMIT, OFFSET
- DISTINCT
- Logische Operatoren (AND, OR, NOT)

**UPDATE:**
- Mit WHERE
- Mit Subqueries
- Mehrere Spalten

**DELETE:**
- Mit WHERE
- Mit Subqueries

**Beispiel-Aufgaben:**
```sql
1. Füge einen neuen Kunden ein: [...]
2. Finde alle Bücher die im Jahr 2020 publiziert wurden
3. Aktualisiere den Preis aller Bücher eines Verlags
4. Lösche alle Kunden ohne Bestellungen
```

#### 4. JOINs (20%)

**JOIN-Typen:**
- INNER JOIN
- LEFT JOIN
- RIGHT JOIN
- Unterschiede erklären

**N:M Beziehungen:**
- Über Zwischentabelle joinen

**Mehrere JOINs:**
- 3-4 Tabellen verbinden

**Beispiel-Aufgaben:**
```sql
1. Zeige alle Bücher mit ihren Autoren (INNER JOIN)
2. Zeige alle Autoren, auch ohne Bücher (LEFT JOIN)
3. Finde Autoren ohne Bücher
4. Liste alle Bestellungen mit Kunde und Produkten
```

#### 5. Aggregat-Funktionen (10%)

**Funktionen:**
- COUNT, SUM, AVG, MIN, MAX
- GROUP BY
- HAVING

**Beispiel-Aufgaben:**
```sql
1. Wie viele Bücher hat jeder Autor?
2. Durchschnittspreis aller Bücher pro Genre
3. Genres mit mehr als 10 Büchern
4. Top 5 Kunden nach Bestellwert
```

### Beispieltest (zum Üben)

#### Aufgabe 1: ER-Diagramm (8 Punkte)

Ein Fitnessstudio möchte ein Buchungssystem für Kurse einführen.

**Anforderungen:**
- Mitglieder haben Name, Geburtsdatum, Mitgliedsnummer
- Kurse haben Name, Beschreibung, maximale Teilnehmerzahl
- Trainer haben Name, Spezialisierung
- Ein Kurs wird von einem Trainer geleitet
- Ein Mitglied kann mehrere Kurse buchen
- Ein Kurs kann mehrere Teilnehmer haben
- Buchungen haben ein Buchungsdatum

**Aufgaben:**
a) Zeichne ein ER-Diagramm mit allen Entitäten, Attributen und Beziehungen
b) Markiere Primary Keys
c) Gib die Kardinalitäten an

#### Aufgabe 2: Normalisierung (6 Punkte)

Gegeben ist folgende Tabelle:

```
Kursbuchungen:
┌────────┬──────────┬──────────────┬─────────────┬───────────┬─────────────┐
│ MitglID│ Name     │ Kurs1        │ Kurs2       │ TrainerK1 │ TrainerK2   │
├────────┼──────────┼──────────────┼─────────────┼───────────┼─────────────┤
│ 1      │ Müller   │ Yoga         │ Spinning    │ Anna      │ Tom         │
│ 2      │ Schmidt  │ Yoga         │ NULL        │ Anna      │ NULL        │
└────────┴──────────┴──────────────┴─────────────┴───────────┴─────────────┘
```

a) Welche Normalform-Verletzungen siehst du? (2 Punkte)
b) Normalisiere bis zur 3. Normalform (4 Punkte)

#### Aufgabe 3: SQL DDL (10 Punkte)

Erstelle die Tabellen für das Fitnessstudio:

a) Tabelle `members` mit:
   - member_id (Primary Key, Auto Increment)
   - first_name, last_name (nicht NULL)
   - birth_date
   - membership_number (UNIQUE)
   - created_at (Default: aktueller Zeitstempel)

b) Tabelle `courses` mit passenden Spalten und Constraints

c) Tabelle `bookings` (Zwischentabelle) mit Foreign Keys und ON DELETE CASCADE

#### Aufgabe 4: SQL DML (12 Punkte)

Gegeben ist die HFTM Library Datenbank.

a) Füge ein neues Buch ein: "Database Systems" von "Ramakrishnan", ISBN "978-0072465631", Jahr 2002 (2 Punkte)

b) Finde alle Bücher die zwischen 2000 und 2010 publiziert wurden, sortiert nach Titel (2 Punkte)

c) Aktualisiere alle Bücher des Verlags "Old Press" zum Verlag "New Press" (2 Punkte)

d) Lösche alle Genres die keine Bücher haben (2 Punkte)

e) Zeige die 10 neuesten Bücher mit Autor und Genre (4 Punkte)

#### Aufgabe 5: JOINs (10 Punkte)

a) Liste alle Bücher mit Autorennamen (INNER JOIN) (2 Punkte)

b) Zeige alle Autoren, auch ohne Bücher (LEFT JOIN) (2 Punkte)

c) Finde Autoren die keine Bücher haben (3 Punkte)

d) Zeige alle aktuellen Ausleihen mit Kundenname, Buchtitel und Rückgabedatum (3 Punkte)

#### Aufgabe 6: Aggregationen (8 Punkte)

a) Wie viele Bücher gibt es pro Genre? (2 Punkte)

b) Welcher Autor hat die meisten Bücher geschrieben? (Top 5) (3 Punkte)

c) Durchschnittliche Anzahl Bücher pro Verlag (2 Punkte)

d) Genres mit mindestens 20 Büchern (1 Punkt)

#### Aufgabe 7: Transaktionen (6 Punkte)

a) Erkläre was ACID bedeutet (2 Punkte)

b) Schreibe eine Transaktion für folgendes Szenario:
   - Ein Kunde leiht ein Buch aus
   - Bestand muss reduziert werden
   - Ausleihe muss eingetragen werden
   - Bei Fehler: Rollback (4 Punkte)

### Lösungshinweise

**Zeitmanagement:**
- 5 Min: Test durchlesen
- 20 Min: ER-Diagramm und Normalisierung
- 15 Min: SQL DDL
- 30 Min: SQL DML und JOINs
- 15 Min: Aggregationen
- 5 Min: Durchsehen und Korrigieren

**Tipps:**
- Lies Aufgaben genau
- Syntax-Fehler vermeiden
- Bei Unsicherheit: Kommentare schreiben
- Zeit im Auge behalten
- Einfache Aufgaben zuerst

## Teil 2: Projekt-Kickoff

Nach der Repetition starten wir mit dem Hauptprojekt des Kurses!

### Projektübersicht

**Ziel:** Dynamische Webanwendung mit REST API und Datenbank

**Gewichtung:** 50% der Gesamtnote

**Komponenten:**
1. Datenbankdesign (ER-Diagramm + SQL)
2. REST API Backend (Node.js + Express)
3. Frontend (HTML/CSS/JavaScript)
4. Dokumentation
5. Präsentation

### Projektziele

#### 1. Datenbankdesign (15 Punkte)

- ER-Diagramm mit 4-5 Entitäten
- Mindestens 2x 1:N Beziehungen
- Mindestens 1x N:M Beziehung
- Normalisierung bis 3. Normalform
- SQL-Script für Tabellenerstellung
- Testdaten

#### 2. Datenbank-Implementation (10 Punkte)

- CREATE TABLE Statements
- PRIMARY KEY und FOREIGN KEY Constraints
- Passende Datentypen
- Testdaten (mind. 5 pro Tabelle)
- Funktionierender DB-Dump

#### 3. REST API Backend (30 Punkte)

**Mindestanforderungen:**
- Node.js + Express
- Datenbankanbindung (mysql2)
- Mindestens eine Ressource mit allen CRUD-Operationen:
  - GET /api/resource (alle)
  - GET /api/resource/:id (einer)
  - POST /api/resource (erstellen)
  - PUT /api/resource/:id (aktualisieren)
  - DELETE /api/resource/:id (löschen)

**Zusätzlich:**
- Mindestens 2 Endpoints mit JOIN-Operationen
- Prepared Statements (SQL-Injection Schutz)
- Error Handling mit passenden HTTP-Status-Codes
- .env für Credentials

#### 4. Frontend-Anbindung (25 Punkte)

- Dynamisches Frontend (kein statisches HTML)
- GET - Daten anzeigen
- POST - Daten erstellen (Formular)
- PUT - Daten bearbeiten
- DELETE - Daten löschen (mit Bestätigung)
- Responsive Design (optional, Bonus)

#### 5. Präsentation (20 Punkte)

- Live-Demo (5-7 Minuten)
- DB-Design erklären
- Alle CRUD-Operationen zeigen
- Fachfragen beantworten
- Zeit einhalten
- Professionelles Auftreten

### Projekt-Themen

#### Vorschlag 1: Bibliotheksverwaltung

**Entitäten:** Bücher, Autoren, Genres, Ausleihen, Benutzer

**Features:**
- Bücher verwalten (CRUD)
- Ausleihen erfassen
- Suche nach Titel/Autor/Genre
- Überfällige Ausleihen anzeigen

#### Vorschlag 2: Event-Manager

**Entitäten:** Events, Veranstalter, Locations, Teilnehmer, Kategorien

**Features:**
- Events erstellen und verwalten
- Teilnehmer anmelden/abmelden
- Filterung nach Datum/Kategorie
- Kalenderansicht

#### Vorschlag 3: Rezeptverwaltung

**Entitäten:** Rezepte, Zutaten, Kategorien, Bewertungen, Autoren

**Features:**
- Rezepte hinzufügen/bearbeiten
- Zutaten verwalten
- Bewertungen abgeben
- Suche nach Zutaten/Kategorie

#### Vorschlag 4: Projektmanagement-Tool (Simplified)

**Entitäten:** Projekte, Tasks, Team-Mitglieder, Status, Prioritäten

**Features:**
- Tasks erstellen/verschieben
- Team-Mitglieder zuweisen
- Status aktualisieren
- Kanban-Board Ansicht

#### Vorschlag 5: Fahrzeugverwaltung

**Entitäten:** Fahrzeuge, Besitzer, Services, Reparaturen, Werkstätten

**Features:**
- Fahrzeuge registrieren
- Services dokumentieren
- Service-Historie anzeigen
- Erinnerungen für Wartung

#### Eigenes Thema

Du kannst auch ein eigenes Thema wählen, solange es die Anforderungen erfüllt:

**Checkliste eigenes Thema:**
- [ ] 4-5 Entitäten möglich?
- [ ] Mind. 2x 1:N Beziehungen?
- [ ] Mind. 1x N:M Beziehung?
- [ ] CRUD-Operationen sinnvoll?
- [ ] Interessant für dich?
- [ ] Umsetzbar in 6 Wochen?

### Meilensteine

| Woche | Meilenstein | Abgabe |
|-------|-------------|--------|
| Unit 6 | Themenwahl | - |
| Unit 8 | DB-Design | ER-Diagramm + SQL-Script |
| Unit 9-11 | Projektarbeit | - |
| Unit 12 | Komplettes Projekt | Code, Doku, DB-Dump |
| Unit 13 | Präsentation | Live-Demo |

### Projekt Setup

**Verzeichnisstruktur:**
```
mein-projekt/
├── database/
│   ├── schema.sql           # CREATE TABLE Statements
│   ├── data.sql             # INSERT Statements (Testdaten)
│   └── er-diagram.png       # ER-Diagramm
├── backend/
│   ├── node_modules/
│   ├── controllers/
│   ├── routes/
│   ├── config/
│   │   └── database.js
│   ├── .env
│   ├── .gitignore
│   ├── package.json
│   └── server.js
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── app.js
├── docs/
│   ├── README.md            # Projektbeschreibung
│   ├── API.md               # API-Dokumentation
│   └── SETUP.md             # Setup-Anleitung
└── README.md
```

### Heute zu erledigen

1. **Thema wählen** (oder eigenes definieren)
2. **Anforderungen aufschreiben**
   - Welche Entitäten?
   - Welche Beziehungen?
   - Welche Features?
3. **Erste Skizze** des ER-Diagramms

### Nächste Woche (Unit 7)

- **Theorieprüfung SQL** (90 Minuten, 30% der Gesamtnote)
- Detailliertes ER-Diagramm (Abgabe DB-Design in Unit 8)
- SQL-Script für Tabellen
- Node.js Projekt aufsetzen
- Erste API-Endpoints

### Bewertungskriterien (Detail)

**Datenbankdesign (15 Punkte):**
- ER-Diagramm vollständig (5P)
- Normalisierung korrekt (4P)
- Beziehungen sinnvoll (3P)
- Datentypen passend (3P)

**Implementation (10 Punkte):**
- SQL-Script funktioniert (4P)
- Testdaten vorhanden (3P)
- Constraints korrekt (3P)

**REST API (30 Punkte):**
- CRUD vollständig (10P)
- JOIN-Operationen (10P)
- Prepared Statements (5P)
- API-Dokumentation (5P)

**Frontend (25 Punkte):**
- GET - Anzeigen (5P)
- POST - Erstellen (7P)
- PUT - Bearbeiten (7P)
- DELETE - Löschen (6P)

**Präsentation (20 Punkte):**
- Live-Demo (8P)
- DB-Design erklärt (4P)
- Fachfragen (4P)
- Zeit/Professionalität (4P)

## Ressourcen für das Projekt

### Tutorials & Dokumentation

- [Node.js Official Docs](https://nodejs.org/docs)
- [Express.js Guide](https://expressjs.com/en/guide/routing.html)
- [MySQL2 Package](https://github.com/sidorares/node-mysql2)
- [REST API Best Practices](https://stackoverflow.blog/2020/03/02/best-practices-for-rest-api-design/)

### Tools

- **DB Design:** dbdiagram.io, draw.io
- **API Testing:** Postman, Thunder Client (VS Code)
- **Frontend:** VS Code, Live Server Extension
- **Git:** GitHub, GitLab

### Beispiel-Projekte

Im Moodle findest du Beispiel-Projekte von vorherigen Semestern zur Inspiration.

## Tipps für den Erfolg

### Zeitmanagement

- **Woche 7:** 20% (DB-Design)
- **Woche 8-9:** 40% (Backend)
- **Woche 10-11:** 30% (Frontend)
- **Woche 12:** 10% (Testing, Doku, Polish)

### Häufige Fehler vermeiden

❌ **Zu spät anfangen**
✅ Früh mit DB-Design starten

❌ **Zu komplexes Thema**
✅ Lieber einfach und gut als komplex und kaputt

❌ **Keine Dokumentation**
✅ README und API-Docs von Anfang an pflegen

❌ **Kein Testing**
✅ Regelmässig testen (Postman für API)

❌ **Keine Versionskontrolle**
✅ Git von Anfang an nutzen

### Support

- **Forum:** Fragen im Moodle-Forum
- **Office Hours:** Nach Vereinbarung
- **Peer-Review:** Mit Kommilitonen austauschen

## Checkliste für heute

- [ ] Beispieltest gelöst und mit den Lösungshinweisen verglichen
- [ ] Thema gewählt
- [ ] Erste Ideen notiert
- [ ] Anforderungen überlegt
- [ ] Fragen notiert

## Nächste Schritte

**Bis nächste Woche:**
1. ER-Diagramm zeichnen
2. Entitäten und Attribute definieren
3. Beziehungen festlegen
4. Normalisierung prüfen

**Für Unit 7:**
- Theorieprüfung SQL: Stoff von Lektion 1–5 repetieren
- Node.js installieren
- MariaDB läuft
- Text-Editor bereit (VS Code empfohlen)

## Zusammenfassung

- **Theorieprüfung (Unit 7):** 30% der Note, Grundlagen abgeprüft
- **Projekt:** 50% der Note, praktische Anwendung
- **Credits:** 20% der Note, kontinuierliche Mitarbeit
- **Start:** Heute mit Themenwahl
- **Ziel:** Funktionierende Webanwendung mit DB

Viel Erfolg bei der Prüfungsvorbereitung und beim Projekt! 🚀

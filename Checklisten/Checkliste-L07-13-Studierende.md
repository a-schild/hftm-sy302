# Checklisten für Studierende - Lektionen 7-13

## Checklist 7: Lektion 7 - Node.js und Datenbanken

### Theorieprüfung SQL (Teil 1, 90 Min., 30% der Gesamtnote)
- [ ] Stoff von Lektion 1–5 repetiert (siehe Lektion 6, Teil 1)
- [ ] Beispieltest aus Lektion 6 gelöst
- [ ] Ausgeruht und rechtzeitig da

### Node.js Setup
- [ ] Node.js installiert (Version geprüft)
- [ ] npm funktioniert
- [ ] Projekt initialisiert (npm init -y)
- [ ] Packages installiert (mysql2, dotenv, express)
- [ ] package.json vorhanden

### Raspberry Pi: Node.js
- [ ] Node.js und npm auf dem Raspberry Pi installiert
- [ ] Hello World (`node hello.js`) läuft
- [ ] Webserver auf Port 3000 im Browser erreichbar

### Datenbankverbindung
- [ ] .env-Datei erstellt
- [ ] .gitignore für .env und node_modules
- [ ] database.js mit Connection Pool
- [ ] Verbindung erfolgreich getestet
- [ ] Fehlerbehandlung implementiert

### CRUD-Funktionen
- [ ] Funktion CREATE (INSERT)
- [ ] Funktion READ ALL (SELECT *)
- [ ] Funktion READ ONE (SELECT mit WHERE)
- [ ] Funktion UPDATE
- [ ] Funktion DELETE
- [ ] Alle Funktionen getestet
- [ ] Prepared Statements verwendet
- [ ] Async/Await korrekt

### Credit 6
- [ ] Projektstruktur korrekt
- [ ] Alle CRUD-Funktionen implementiert
- [ ] Testskript funktioniert
- [ ] Screenshots gemacht
- [ ] Code kommentiert
- [ ] Als ZIP abgegeben

---

## Checklist 8: Lektion 8 - REST API mit Express

### Abgabe DB-Design (Unit 8)
- [ ] ER-Diagramm des Projekts
- [ ] SQL-Script (CREATE TABLE)
- [ ] Abgegeben

### Express Setup
- [ ] Express installiert
- [ ] server.js erstellt
- [ ] Middleware konfiguriert (json, urlencoded)
- [ ] CORS konfiguriert
- [ ] Server startet ohne Fehler

### REST-Endpoints
- [ ] GET /api/books (alle)
- [ ] GET /api/books/:id (einzeln)
- [ ] POST /api/books (erstellen)
- [ ] PUT /api/books/:id (aktualisieren)
- [ ] DELETE /api/books/:id (löschen)
- [ ] Korrekte HTTP-Statuscodes (200, 201, 404, 500)
- [ ] Fehlerbehandlung in allen Routes

### Controller & Routes
- [ ] bookController.js erstellt
- [ ] bookRoutes.js erstellt
- [ ] Controller von den Routes getrennt
- [ ] Code gut strukturiert

### Tests
- [ ] Postman installiert
- [ ] Collection erstellt
- [ ] Alle Endpoints getestet
- [ ] Screenshots gemacht

### JOIN-Endpoint
- [ ] Endpoint mit JOIN implementiert
- [ ] Bücher mit Autoren verknüpft
- [ ] Getestet

### Credit 7
- [ ] Alle 5 CRUD-Endpoints funktionieren
- [ ] JOIN-Endpoint implementiert
- [ ] Postman-Collection exportiert
- [ ] Screenshots aller Tests
- [ ] Code abgegeben

---

## Checklist 9: Lektion 9 - KI & Datenbanken

### Claude AI Integration (optional)
- [ ] Anthropic API Key erhalten
- [ ] @anthropic-ai/sdk installiert
- [ ] Grundintegration getestet

### SQL-Generierung
- [ ] Claude für SQL-Abfragen verwendet
- [ ] Abfragen vor der Ausführung validiert
- [ ] Resultate dokumentiert

### Projektarbeit
- [ ] Projektthema definiert
- [ ] ER-Diagramm erstellt
- [ ] SQL-DDL-Skript geschrieben
- [ ] Datenbank implementiert

### Credit 8
- [ ] Abgegeben (Aufgaben siehe Lektion 9, «Checkliste für Credit 8»)

---

## Checklist 10: Lektion 10 - NoSQL & MongoDB

### MongoDB Setup
- [ ] MongoDB installiert ODER
- [ ] MongoDB Atlas Account erstellt
- [ ] Verbindung erfolgreich
- [ ] Compass installiert (optional)

### MongoDB-Grundlagen
- [ ] Datenbank erstellt
- [ ] Collection erstellt
- [ ] Dokumente eingefügt
- [ ] Abfragen ausgeführt

### Mongoose (optional)
- [ ] Mongoose installiert
- [ ] Schema definiert
- [ ] Model erstellt
- [ ] CRUD mit Mongoose

### SQL vs. NoSQL verstanden
- [ ] Unterschiede klar
- [ ] Wann SQL, wann NoSQL
- [ ] Vor- und Nachteile bekannt

### Entscheid für das Projekt
- [ ] SQL oder NoSQL gewählt (mit Begründung)
- [ ] Implementierung begonnen

### Credit 9
- [ ] Abgegeben (Aufgaben siehe Lektion 10, «Checkliste für Credit 9»)

---

## Checklist 11: Lektion 11 - ORM & Sequelize

### Sequelize Setup (falls verwendet)
- [ ] Sequelize installiert
- [ ] Sequelize-cli installiert
- [ ] Konfiguration erstellt
- [ ] Verbindung getestet

### Models
- [ ] Alle Models definiert
- [ ] Validierung implementiert
- [ ] Associations definiert

### Migrations
- [ ] Migrationsdateien erstellt
- [ ] Migrations ausgeführt
- [ ] Seeders erstellt (optional)

### Projektfortschritt
- [ ] Backend-API zu 80% fertig
- [ ] Alle CRUD-Endpoints funktionieren
- [ ] JOINs/Relationen implementiert
- [ ] Fehlerbehandlung vorhanden

### Credit 10
- [ ] Abgegeben (Aufgaben siehe Lektion 11, «Checkliste für Credit 10»)

---

## Checklist 12: Lektion 12 - Security & MQTT

### JWT-Authentifizierung (falls implementiert)
- [ ] jsonwebtoken installiert
- [ ] bcrypt installiert
- [ ] Register-Endpoint
- [ ] Login-Endpoint
- [ ] Geschützte Routes mit Middleware

### Security
- [ ] helmet installiert und konfiguriert
- [ ] CORS korrekt konfiguriert
- [ ] express-rate-limit implementiert
- [ ] Input-Validierung (express-validator)
- [ ] Überall Prepared Statements

### MQTT (optional)
- [ ] Package mqtt installiert
- [ ] Verbindung zum Broker
- [ ] Publish/Subscribe getestet

### Projektstand
- [ ] Backend vollständig
- [ ] Frontend begonnen
- [ ] Dokumentation begonnen

---

## Checklist 13: Lektion 13 - Abschluss & Präsentation

### Projekt vollständig
- [ ] Backend-API fertig
- [ ] Frontend fertig
- [ ] Alle CRUD-Operationen funktionieren
- [ ] Responsive Design (optional)

### Datenbank
- [ ] Finales ER-Diagramm
- [ ] Alle Tabellen erstellt
- [ ] Foreign Keys korrekt
- [ ] Testdaten vorhanden
- [ ] Dump erstellt

### Dokumentation
- [ ] README.md mit:
  - [ ] Projektbeschreibung
  - [ ] Installationsanleitung
  - [ ] API-Dokumentation
  - [ ] Screenshots
- [ ] Code kommentiert
- [ ] Git-Repository aufgeräumt

### Tests
- [ ] Alle Funktionen getestet
- [ ] Grenzfälle geprüft
- [ ] Fehlerbehandlung getestet
- [ ] Keine kritischen Bugs

### Buffet (optional): MongoDB auf dem Raspberry Pi
- [ ] MongoDB per Docker auf dem Raspberry Pi gestartet
- [ ] Übungen aus Lektion 10 auf dem Raspberry Pi ausgeführt

### Präsentation
- [ ] Präsentation vorbereitet (5-7 Min.)
- [ ] Live-Demo geprobt
- [ ] Zeit gestoppt
- [ ] Notfallplan (Video/Screenshots)
- [ ] Fragen vorbereitet

### Abgabe
- [ ] Code auf GitLab (Abgabe nach Unit 12, Termin gemäss Kursplanung)
- [ ] README.md vollständig
- [ ] SQL-Dump
- [ ] Datei .env.example
- [ ] Präsentation bereit

---

## Master-Checklist: Projektabschluss

### Backend (30 Punkte)
- [ ] Alle CRUD-Endpoints funktionieren (10P)
- [ ] Mindestens 2 JOIN-Endpoints (10P)
- [ ] Überall Prepared Statements (5P)
- [ ] Fehlerbehandlung (5P)

### Frontend (25 Punkte)
- [ ] GET - Daten anzeigen (5P)
- [ ] POST - Daten erstellen (7P)
- [ ] PUT - Daten bearbeiten (7P)
- [ ] DELETE - Daten löschen (6P)

### Datenbank (15 Punkte)
- [ ] ER-Diagramm (5P)
- [ ] 4-5 Tabellen (4P)
- [ ] Normalisierung (3P)
- [ ] SQL-Skript funktioniert (3P)

### Dokumentation (10 Punkte)
- [ ] README vollständig (4P)
- [ ] API-Dokumentation (3P)
- [ ] Code kommentiert (3P)

### Präsentation (20 Punkte)
- [ ] Live-Demo (8P)
- [ ] DB-Design erklärt (4P)
- [ ] Fragen beantwortet (4P)
- [ ] Zeit & Professionalität (4P)

**TOTAL: 100 Punkte = 50% der Gesamtnote**

---

## Projekt-Timeline

| Unit | Meilensteine | Erledigt |
|-------|--------------|----------|
| 6 | Thema gewählt | ☐ |
| 7 | Theorieprüfung SQL, Node.js Setup, DB-Verbindung | ☐ |
| 8 | DB-Design abgegeben, REST API CRUD | ☐ |
| 9 | Projektarbeit (mit KI-Unterstützung) | ☐ |
| 10 | Backend vollständig | ☐ |
| 11 | Frontend 50% | ☐ |
| 12 | Frontend vollständig, Doku, Abgabe auf GitLab | ☐ |
| 13 | Präsentation | ☐ |

---

## Kurzreferenz: Wichtige Befehle

### Node.js / npm
```bash
npm init -y
npm install package-name
npm install --save-dev package-name
npm start
node filename.js
```

### Git
```bash
git init
git add .
git commit -m "message"
git push origin main
```

### MySQL / MariaDB
```bash
mysql -u root -p
SOURCE script.sql;
mysqldump -u root -p dbname > dump.sql
```

---

## Häufige Fehler vermeiden

### Backend
- ❌ Credentials im Code
- ❌ Keine Fehlerbehandlung
- ❌ SQL-Injection möglich
- ❌ CORS nicht konfiguriert
- ❌ Keine Input-Validierung

- ✅ .env für Credentials
- ✅ Überall try-catch
- ✅ Prepared Statements
- ✅ CORS korrekt konfiguriert
- ✅ Validierungs-Middleware

### Frontend
- ❌ API-URL hart codiert
- ❌ Keine Fehlermeldungen
- ❌ Kein Ladezustand
- ❌ Keine Bestätigung bei DELETE

- ✅ API_URL als Variable
- ✅ Rückmeldung an Benutzer bei Fehlern
- ✅ Ladeindikatoren
- ✅ Bestätigungsdialog bei DELETE

### Projekt
- ❌ Zu spät begonnen
- ❌ Zu komplex geplant
- ❌ Keine Backups
- ❌ Git nicht verwendet

- ✅ Früh beginnen
- ✅ Zuerst MVP, dann erweitern
- ✅ Regelmässige Commits
- ✅ Git von Anfang an

---

## Tipps für die Präsentation

### Vorbereitung
- ✅ Demo mehrmals proben
- ✅ Backup-Video aufnehmen
- ✅ Zeit stoppen (5-7 Min.)
- ✅ Fragen antizipieren

### Während der Präsentation
- ✅ Ruhig bleiben
- ✅ Langsam sprechen
- ✅ Funktionen zeigen, nicht Code
- ✅ Bei Fehlern: Backup zeigen

### Häufige Fragen
- Warum diese Technologie?
- Wie ist die DB aufgebaut?
- Wie würde man X erweitern?
- Was war die grösste Herausforderung?

---

## Ressourcen

**Dokumentation:**
- Node.js: nodejs.org/docs
- Express: expressjs.com
- MySQL: dev.mysql.com/doc

**Tutorials:**
- freeCodeCamp.org
- MDN Web Docs
- YouTube (Traversy Media, Net Ninja)

**Tools:**
- Postman für API-Tests
- VS Code für die Entwicklung
- GitLab für die Versionskontrolle
- Figma für UI-Design (optional)

---

**Viel Erfolg mit dem Projekt! 🚀**

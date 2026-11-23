# SY302 Databases - Kursunterlagen Übersicht

## Status: VOLLSTÄNDIG ✅

Alle 13 Lektionen sind in **Deutsch** und **Französisch** erstellt!

---

## Deutsche Lektionen (Komplett)

### ✅ Lektion 1: Daten, Datenbanken und DBMS
**Pfad:** `Lektion 01/Lektion01-Daten-Datenbanken-DBMS.md`
**Themen:** Grundlagen, Datentypen, DBMS-Arten, ER-Diagramme

### ✅ Lektion 2: Datenbankdesign & SQL DDL
**Pfad:** `Lektion 02/Lektion02-Datenbankdesign-SQL-DDL.md`
**Themen:** ER-Modellierung, Normalformen, CREATE TABLE, Constraints

### ✅ Lektion 3: SQL DML
**Pfad:** `Lektion 03/Lektion03-SQL-DML.md`
**Themen:** INSERT, UPDATE, DELETE, SELECT, WHERE, Subqueries

### ✅ Lektion 4: SQL JOINs & UNION
**Pfad:** `Lektion 04/Lektion04-SQL-JOINs-UNION.md`
**Themen:** INNER JOIN, LEFT JOIN, RIGHT JOIN, UNION, Aggregationen

### ✅ Lektion 5: SQL Erweitert - DCL & TCL
**Pfad:** `Lektion 05/Lektion05-SQL-Erweitert-DCL-TCL.md`
**Themen:** GRANT, REVOKE, Transactions, ACID, Berechtigungen

### ✅ Lektion 6: SQL Test & Projektstart
**Pfad:** `Lektion 06/Lektion06-SQL-Test-Projektstart.md`
**Themen:** Testvorbereitung, Projektthemen, Anforderungen

### ✅ Lektion 7: Node.js und Datenbanken
**Pfad:** `Lektion 07/Lektion07-NodeJS-Datenbanken.md`
**Themen:** Node.js Setup, mysql2, Connection Pool, CRUD

### ✅ Lektion 8: REST API mit Express.js
**Pfad:** `Lektion 08/Lektion08-REST-API-Express.md`
**Themen:** Express, REST Principles, CRUD API, Middleware

### ✅ Lektion 9: KI im Datenbank-Umfeld
**Pfad:** `Lektion 09/Lektion09-KI-Datenbank-Umfeld.md`
**Themen:** Claude AI, SQL-Generierung, Testdaten, Optimierung

### ✅ Lektion 10: NoSQL & MongoDB
**Pfad:** `Lektion 10/Lektion10-NoSQL-MongoDB.md`
**Themen:** NoSQL Konzepte, MongoDB, CRUD, Mongoose, SQL vs NoSQL

### ✅ Lektion 11: Express Frameworks & ORM
**Pfad:** `Lektion 11/Lektion11-Express-ORM.md`
**Themen:** Sequelize, Models, Migrations, Associations

### ✅ Lektion 12: MQTT & Sicherheit
**Pfad:** `Lektion 12/Lektion12-MQTT-Sicherheit.md`
**Themen:** MQTT Protocol, JWT, bcrypt, API Security, Rate Limiting

### ✅ Lektion 13: Datenschutz, Backups & Abschluss
**Pfad:** `Lektion 13/Lektion13-Datenschutz-Backups-Abschluss.md`
**Themen:** DSGVO, Backup-Strategien, Performance, Monitoring, Zusammenfassung

---

## Französische Lektionen (Komplett)

### ✅ Leçon 1: Données, Bases de données et SGBD
**Pfad:** `Lektion 01/Lecon01-Donnees-BDD-SGBD-FR.md`

### ✅ Leçon 2: Conception de BDD & SQL DDL
**Pfad:** `Lektion 02/Lecon02-Conception-BDD-SQL-DDL-FR.md`

### ✅ Leçon 3: SQL DML
**Pfad:** `Lektion 03/Lecon03-SQL-DML-FR.md`

### ✅ Leçon 4: SQL JOINs & UNION
**Pfad:** `Lektion 04/Lecon04-SQL-JOINs-UNION-FR.md`

### ✅ Leçon 5: SQL Avancé (DCL & TCL)
**Pfad:** `Lektion 05/Lecon05-SQL-Avance-DCL-TCL-FR.md`

### ✅ Leçon 6: Test SQL & Lancement du projet
**Pfad:** `Lektion 06/Lecon06-Test-SQL-Lancement-Projet-FR.md`

### ✅ Leçon 7: Node.js et Bases de données
**Pfad:** `Lektion 07/Lecon07-NodeJS-Databases-FR.md`

### ✅ Leçon 8: API REST avec Express.js
**Pfad:** `Lektion 08/Lecon08-REST-API-Express-FR.md`

### ✅ Leçon 9: IA dans l'environnement de base de données
**Pfad:** `Lektion 09/Lecon09-IA-Databases-FR.md`

### ✅ Leçon 10: NoSQL & MongoDB
**Pfad:** `Lektion 10/Lecon10-NoSQL-MongoDB-FR.md`

### ✅ Leçon 11: Frameworks Express & ORM
**Pfad:** `Lektion 11/Lecon11-Express-ORM-FR.md`

### ✅ Leçon 12: MQTT & Sécurité
**Pfad:** `Lektion 12/Lecon12-MQTT-Securite-FR.md`

### ✅ Leçon 13: Protection des données, Sauvegardes & Conclusion
**Pfad:** `Lektion 13/Lecon13-Protection-Donnees-Conclusion-FR.md`

---

## Wichtige Hinweise

### Einheitlichkeit

**Code-Beispiele:**
- ✅ Alle Code-Beispiele sind auf **Englisch** (identisch in DE & FR)
- ✅ SQL-Befehle sind identisch
- ✅ Tabellennamen: `customers`, `orders`, `books`, `authors`

**Erklärungstexte:**
- ✅ Deutsche Erklärungen in DE-Dateien
- ✅ Französische Erklärungen in FR-Dateien

**Struktur:**
- ✅ Jede Lektion hat die gleiche Struktur
- ✅ Lernziele, Theorie, Beispiele, Übungen, Ressourcen

### Beispieldatenbank

**HFTM Library** wird durchgehend verwendet:
- `books` (id, title, author_id, publisher_id, isbn, published_date)
- `authors` (id, firstname, lastname, email, birth_date)
- `publishers` (id, name, address, email)
- `genres` (id, genre)
- `customers` (id, firstname, lastname, email, location_id)
- `places` (id, zip, city)
- `lends` (id, customer_id, book_id, date_from, date_to, price)

### Dateinamen-Konvention

**Deutsch:**
- `LektionXX-Thema.md`

**Französisch:**
- `LeconXX-Theme-FR.md`

### Ordnerstruktur

```
SY302 Databases/
├── Lektion 01/
│   ├── Lektion01-Daten-Datenbanken-DBMS.md
│   └── Lecon01-Donnees-BDD-SGBD-FR.md
├── Lektion 02/
│   ├── Lektion02-Datenbankdesign-SQL-DDL.md
│   └── Lecon02-Conception-BDD-SQL-DDL-FR.md
├── ... (Lektionen 03-13)
└── README-Uebersicht.md (diese Datei)
```

---

## Verwendung

### Für Studierende

1. **Lektion wählen** (Deutsch oder Französisch)
2. **Durcharbeiten** der Theorie
3. **Code-Beispiele** selbst ausführen
4. **Übungen** bearbeiten
5. **Hausaufgaben** (Credits) einreichen

### Für Dozierende

1. **Präsentation** vorbereiten
2. **Live-Demos** der Code-Beispiele
3. **Übungen** betreuen
4. **Credits** bewerten
5. **Projekte** begleiten

---

## Kursziele (13 Wochen)

### Wochen 1-6: SQL & Grundlagen (30% der Note: Test)
- Datenbankdesign
- SQL DDL & DML
- JOINs & Aggregationen
- Transaktionen
- **Test in Woche 6**

### Wochen 7-12: Backend & Projekt (50% der Note: Projekt)
- Node.js + Express
- REST API
- MongoDB
- Sicherheit
- **Projekt entwickeln**

### Woche 13: Abschluss (20% der Note: Credits)
- Präsentationen
- **Finale Bewertung**

---

## Notenzusammensetzung

| Komponente | Gewichtung | Details |
|------------|-----------|---------|
| **Credits** | 20% | Wöchentliche Hausaufgaben |
| **Test SQL** | 30% | Woche 6 (90 Minuten) |
| **Projekt** | 50% | API + Frontend + DB + Präsentation |
| **Total** | 100% | |

---

## Technologie-Stack

### Pflicht
- MariaDB / MySQL
- Node.js
- Express.js
- HTML/CSS/JavaScript

### Optional
- MongoDB
- Sequelize ORM
- Redis (Caching)
- MQTT
- JWT Authentication

---

## Zusätzliche Ressourcen

### Tools
- **HeidiSQL** - MySQL Client
- **Postman** - API Testing
- **VS Code** - Editor
- **MongoDB Compass** - MongoDB GUI

### Online-Ressourcen
- [W3Schools SQL](https://www.w3schools.com/sql/)
- [Node.js Docs](https://nodejs.org/docs)
- [Express Guide](https://expressjs.com/)
- [MongoDB University](https://university.mongodb.com/)

---

## Support & Fragen

- **Forum:** Moodle
- **Email:** [Dozentenadresse]
- **Sprechstunde:** Nach Vereinbarung

---

**Erstellt:** Dezember 2024
**Letzte Aktualisierung:** Dezember 2024
**Version:** 1.0 (Vollständig)

**Status:** ✅ Alle 13 Lektionen in DE & FR komplett erstellt!

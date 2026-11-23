# Checklisten für Studierende - Lektionen 1-6

## Checklist 1: Lektion 1 - Grundlagen

### Theorie verstanden
- [ ] Ich kann erklären, was eine Datenbank ist
- [ ] Ich kenne den Unterschied zwischen Daten und Informationen
- [ ] Ich verstehe, was ein DBMS ist und welche Vorteile es bietet
- [ ] Ich kann ACID-Eigenschaften erklären
- [ ] Ich kenne verschiedene DBMS-Arten (SQL vs NoSQL)

### Praktische Fähigkeiten
- [ ] MariaDB/MySQL ist installiert
- [ ] HeidiSQL oder anderer Client ist installiert
- [ ] Ich kann eine Verbindung zur Datenbank herstellen
- [ ] Ich kann einfache SQL-Befehle ausführen

### Credit 1
- [ ] Theoriefragen beantwortet
- [ ] Alle 4 Aufgaben vollständig
- [ ] Abgabe als PDF/Word
- [ ] Fristgerecht eingereicht

---

## Checklist 2: Lektion 2 - Datenbankdesign & DDL

### Theorie verstanden
- [ ] Ich kann ER-Diagramme lesen und erstellen
- [ ] Ich verstehe Kardinalitäten (1:1, 1:N, N:M)
- [ ] Ich kenne die 3 Normalformen (1NF, 2NF, 3NF)
- [ ] Ich kann Redundanzen in Datenmodellen erkennen

### SQL DDL
- [ ] Ich kann eine Datenbank erstellen (CREATE DATABASE)
- [ ] Ich kann Tabellen erstellen (CREATE TABLE)
- [ ] Ich kenne alle wichtigen Datentypen (INT, VARCHAR, DATE, etc.)
- [ ] Ich kann Constraints definieren:
  - [ ] PRIMARY KEY
  - [ ] FOREIGN KEY
  - [ ] NOT NULL
  - [ ] UNIQUE
  - [ ] CHECK
  - [ ] DEFAULT
- [ ] Ich kann Tabellen ändern (ALTER TABLE)
- [ ] Ich kann Tabellen löschen (DROP TABLE)

### Credit 2 - Wasserkarten
- [ ] Excel-Liste mit Datenfeldern erstellt
  - [ ] Mindestens 10 Felder
  - [ ] Datentypen definiert
  - [ ] Constraints angegeben
- [ ] ER-Diagramm erstellt
  - [ ] Mindestens 3 Entitäten
  - [ ] Alle Attribute vorhanden
  - [ ] Primary Keys markiert
  - [ ] Beziehungen mit Kardinalitäten
- [ ] SQL DDL Script geschrieben
  - [ ] CREATE DATABASE
  - [ ] Alle 3 Tabellen mit CREATE TABLE
  - [ ] Alle Constraints implementiert
  - [ ] Testdaten eingefügt (optional)
- [ ] Alle Dateien als ZIP abgegeben

---

## Checklist 3: Lektion 3 - SQL DML

### INSERT verstanden
- [ ] Ich kann einzelne Zeilen einfügen
- [ ] Ich kann mehrere Zeilen auf einmal einfügen
- [ ] Ich kann Subqueries in INSERT verwenden
- [ ] Ich verstehe AUTO_INCREMENT

### SELECT verstanden
- [ ] Ich kann alle Daten abfragen (SELECT *)
- [ ] Ich kann spezifische Spalten wählen
- [ ] Ich kann WHERE-Bedingungen verwenden:
  - [ ] Vergleichsoperatoren (=, !=, >, <)
  - [ ] LIKE für Pattern Matching
  - [ ] IN für Listen
  - [ ] BETWEEN für Bereiche
  - [ ] IS NULL / IS NOT NULL
- [ ] Ich kann Ergebnisse sortieren (ORDER BY)
- [ ] Ich kann Ergebnisse begrenzen (LIMIT, OFFSET)
- [ ] Ich kann DISTINCT verwenden
- [ ] Ich verstehe Aggregationsfunktionen:
  - [ ] COUNT()
  - [ ] SUM()
  - [ ] AVG()
  - [ ] MIN(), MAX()

### UPDATE verstanden
- [ ] Ich kann einzelne Zeilen aktualisieren
- [ ] Ich kann mehrere Zeilen aktualisieren
- [ ] Ich verwende IMMER WHERE (außer bewusst alle)
- [ ] Ich kann mit Subqueries updaten
- [ ] Ich teste UPDATE-Befehle erst mit SELECT

### DELETE verstanden
- [ ] Ich kann einzelne Zeilen löschen
- [ ] Ich verwende IMMER WHERE (außer bewusst alle)
- [ ] Ich verstehe den Unterschied DELETE vs TRUNCATE
- [ ] Ich teste DELETE-Befehle erst mit SELECT

### Raspberry Pi: MariaDB
- [ ] Mit SSH auf den Raspberry Pi verbunden
- [ ] MariaDB installiert und abgesichert (mariadb-secure-installation)
- [ ] Benutzer `student` angelegt

### Credit 3 - HFTM Library
- [ ] HFTM Library Datenbank importiert
- [ ] Alle INSERT-Übungen gelöst
- [ ] Alle SELECT-Übungen gelöst
- [ ] Alle UPDATE-Übungen gelöst
- [ ] Alle DELETE-Übungen gelöst
- [ ] SQL-Datei mit allen Lösungen erstellt
- [ ] Code kommentiert
- [ ] Abgegeben als .sql Datei

---

## Checklist 4: Lektion 4 - JOINs & UNION

### JOINs verstanden
- [ ] Ich verstehe INNER JOIN
- [ ] Ich verstehe LEFT JOIN
- [ ] Ich verstehe RIGHT JOIN
- [ ] Ich kenne den Unterschied zwischen den JOINs
- [ ] Ich kann mehrere Tabellen joinen
- [ ] Ich kann N:M Beziehungen über Junction Tables joinen

### Aggregationen mit JOINs
- [ ] Ich kann GROUP BY mit JOINs verwenden
- [ ] Ich verstehe HAVING
- [ ] Ich kann nach gejointen Daten aggregieren

### UNION verstanden
- [ ] Ich verstehe UNION
- [ ] Ich kenne den Unterschied UNION vs UNION ALL
- [ ] Ich kann Ergebnisse verschiedener Queries kombinieren

### Raspberry Pi: HeidiSQL über SSH-Tunnel
- [ ] SSH-Tunnel eingerichtet (HeidiSQL oder `ssh -L`)
- [ ] HFTM Library auf dem Raspberry Pi importiert
- [ ] JOIN-Aufgaben auf dem Raspberry Pi ausgeführt

### Credit 4
- [ ] Alle INNER JOIN Übungen gelöst
- [ ] Alle LEFT JOIN Übungen gelöst
- [ ] Aggregations-Übungen mit JOINs gelöst
- [ ] UNION Übungen gelöst
- [ ] SQL-Datei abgegeben

---

## Checklist 5: Lektion 5 - DCL & TCL

### DCL (Data Control Language)
- [ ] Ich kann Benutzer erstellen (CREATE USER)
- [ ] Ich kann Rechte vergeben (GRANT)
- [ ] Ich kann Rechte entziehen (REVOKE)
- [ ] Ich verstehe verschiedene Berechtigungen:
  - [ ] SELECT, INSERT, UPDATE, DELETE
  - [ ] CREATE, ALTER, DROP
  - [ ] ALL PRIVILEGES
- [ ] Ich kann ein Berechtigungskonzept erstellen
- [ ] Ich kenne das Prinzip der minimalen Rechte

### TCL (Transaction Control Language)
- [ ] Ich verstehe, was Transaktionen sind
- [ ] Ich kann ACID erklären:
  - [ ] Atomicity
  - [ ] Consistency
  - [ ] Isolation
  - [ ] Durability
- [ ] Ich kann Transaktionen verwenden:
  - [ ] START TRANSACTION
  - [ ] COMMIT
  - [ ] ROLLBACK
- [ ] Ich weiß, wann Transaktionen nötig sind
- [ ] Ich verstehe Isolation Levels

### Raspberry Pi: MariaDB im Netzwerk
- [ ] bind-address auf 0.0.0.0 gesetzt, MariaDB neu gestartet
- [ ] Benutzer `student`@`192.168.%` mit minimalen Rechten angelegt
- [ ] Direkt (ohne Tunnel) mit HeidiSQL verbunden

### Credit 5 - Medizinisches Zentrum
- [ ] Berechtigungskonzept erstellt
  - [ ] 4 Rollen beschrieben
  - [ ] Berechtigungsmatrix ausgefüllt
  - [ ] SQL-Befehle für alle Benutzer
- [ ] Transaktionen implementiert
  - [ ] Terminbuchung mit Transaktion
  - [ ] Patientenüberweisung mit Transaktion
  - [ ] ACID für beide erklärt
- [ ] Dokumentation vollständig
- [ ] Abgegeben

---

## Checklist 6: Vorbereitung Theorieprüfung (Unit 7)

### Wiederholung Theorie
- [ ] ER-Diagramme: Ich kann sie zeichnen und lesen
- [ ] Normalformen: Ich erkenne Verstöße und kann normalisieren
- [ ] Kardinalitäten: Ich verstehe 1:1, 1:N, N:M
- [ ] ACID: Ich kann alle 4 Eigenschaften erklären
- [ ] Constraints: Ich kenne alle wichtigen

### Wiederholung SQL DDL
- [ ] CREATE DATABASE / USE
- [ ] CREATE TABLE mit allen Constraints
- [ ] ALTER TABLE
- [ ] DROP TABLE
- [ ] Datentypen richtig wählen

### Wiederholung SQL DML
- [ ] INSERT (einfach, mehrfach, mit Subquery)
- [ ] SELECT (WHERE, ORDER BY, LIMIT)
- [ ] UPDATE (mit WHERE!)
- [ ] DELETE (mit WHERE!)
- [ ] Aggregationen (COUNT, SUM, AVG, MIN, MAX)

### Wiederholung JOINs
- [ ] INNER JOIN
- [ ] LEFT JOIN
- [ ] RIGHT JOIN
- [ ] Mehrfache JOINs
- [ ] GROUP BY mit JOINs
- [ ] HAVING

### Wiederholung Transaktionen
- [ ] START TRANSACTION / COMMIT / ROLLBACK
- [ ] ACID erklären können
- [ ] Anwendungsfälle kennen

### Test-Vorbereitung praktisch
- [ ] Alle alten Übungen nochmal durchgegangen
- [ ] Beispiel-ER-Diagramme gezeichnet
- [ ] Beispiel-Tabellen erstellt
- [ ] Verschiedene JOINs geübt
- [ ] Mock-Test durchgeführt
- [ ] Zeitmanagement geübt (90 Minuten)

### Am Prüfungstag (Unit 7)
- [ ] Ausgeruht und rechtzeitig da
- [ ] Stift und Papier dabei
- [ ] Ruhe bewahren
- [ ] Zeit im Auge behalten
- [ ] Einfache Aufgaben zuerst
- [ ] Am Schluss nochmal durchlesen

---

## Master-Checklist: Credits 1-5

| Credit | Thema | Abgabedatum | Status | Punkte (0–5) |
|--------|-------|-------------|--------|------|
| Credit 1 | Grundlagen | __________ | ☐ | ____ |
| Credit 2 | Datenbankdesign | __________ | ☐ | ____ |
| Credit 3 | SQL DML | __________ | ☐ | ____ |
| Credit 4 | JOINs & UNION | __________ | ☐ | ____ |
| Credit 5 | DCL & TCL | __________ | ☐ | ____ |

**Credits gesamt (Credit 1–10): ___ / 20% der Gesamtnote**

Jeder Credit wird mit 0–5 Punkten bewertet, eine fristgerechte, vollständige Abgabe mit 5 Punkten. Nicht abgegebene Credits geben 0 Punkte.

**Theorieprüfung SQL (Unit 7): ___ / 30% der Gesamtnote**

---

## Quick Reference: Wichtigste SQL-Befehle

### DDL (Data Definition Language)
```sql
CREATE DATABASE name;
CREATE TABLE name (...);
ALTER TABLE name ...;
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
CREATE USER 'user'@'host' IDENTIFIED BY 'password';
GRANT privileges ON database.* TO 'user'@'host';
REVOKE privileges ON database.* FROM 'user'@'host';
```

### TCL (Transaction Control Language)
```sql
START TRANSACTION;
COMMIT;
ROLLBACK;
```

### JOINs
```sql
SELECT ... FROM t1 INNER JOIN t2 ON ...;
SELECT ... FROM t1 LEFT JOIN t2 ON ...;
SELECT ... FROM t1 RIGHT JOIN t2 ON ...;
```

---

## Häufige Fehler vermeiden

❌ **Fehler:** UPDATE/DELETE ohne WHERE
✅ **Richtig:** Immer WHERE verwenden (außer bewusst alle)

❌ **Fehler:** SELECT * verwenden
✅ **Richtig:** Nur benötigte Spalten auswählen

❌ **Fehler:** Keine PRIMARY KEYs definieren
✅ **Richtig:** Jede Tabelle braucht einen PRIMARY KEY

❌ **Fehler:** VARCHAR ohne Limit
✅ **Richtig:** Immer Länge angeben (VARCHAR(100))

❌ **Fehler:** FLOAT für Geldbeträge
✅ **Richtig:** DECIMAL(10,2) verwenden

❌ **Fehler:** Keine FOREIGN KEYs
✅ **Richtig:** Beziehungen mit FOREIGN KEY implementieren

❌ **Fehler:** SQL Injection Risiko
✅ **Richtig:** Prepared Statements verwenden

---

## Hilfreiche Ressourcen

**Online:**
- W3Schools SQL Tutorial
- SQLZoo (interaktive Übungen)
- Stack Overflow (Fragen & Antworten)

**Tools:**
- HeidiSQL (MySQL Client)
- MySQL Workbench (Alternative)
- dbdiagram.io (ER-Diagramme online)

**Im Kurs:**
- Moodle Forum für Fragen
- Sprechstunden beim Dozenten
- Lerngruppen mit Kommilitonen

---

**Viel Erfolg! 🚀**

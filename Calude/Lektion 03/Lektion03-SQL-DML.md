# Lektion 3: SQL DML - Data Manipulation Language

## Lernziele

Der/die Studierende ist in der Lage...
- Die DML Befehle zu erklären und anzuwenden
- Einfache SQL DML Befehle zu verwenden
- Eine einfache Datenbank mit Daten zu füllen und Abfragen auszuführen
- CREATE, UPDATE, DELETE Operationen durchzuführen

## Was ist DML?

**DML (Data Manipulation Language)** = SQL-Befehle zur Manipulation von Daten

Die vier Grund-Operationen (CRUD):
- **C**reate → `INSERT`
- **R**ead → `SELECT`
- **U**pdate → `UPDATE`
- **D**elete → `DELETE`

## Die HFTM Library Datenbank

Für diese Lektion arbeiten wir mit der **HFTM Library** Datenbank.

### Datenbank-Schema

**Haupttabellen:**
- `authors` - Autoren
- `books` - Bücher
- `publishers` - Verlage
- `genres` - Genres
- `customers` - Kunden
- `places` - Orte
- `lends` - Ausleihen

**Beziehungstabellen:**
- `authors_publishers` - N:M zwischen Autoren und Verlagen
- `authors_genres` - N:M zwischen Autoren und Genres

### Datenbank einrichten

```sql
-- 1. Datenbank erstellen
CREATE DATABASE hftm_library;
USE hftm_library;

-- 2. SQL-Script ausführen
SOURCE /path/to/HFTM_Library.sql;

-- 3. Tabellen prüfen
SHOW TABLES;

-- 4. Struktur einer Tabelle anzeigen
DESCRIBE authors;
-- oder
SHOW COLUMNS FROM authors;
```

## INSERT - Daten einfügen

### Syntax

```sql
-- Alle Spalten
INSERT INTO tabelle VALUES (wert1, wert2, wert3, ...);

-- Bestimmte Spalten
INSERT INTO tabelle (spalte1, spalte2) VALUES (wert1, wert2);

-- Mehrere Zeilen auf einmal
INSERT INTO tabelle (spalte1, spalte2) VALUES 
    (wert1a, wert2a),
    (wert1b, wert2b),
    (wert1c, wert2c);
```

### Beispiele

**Einfacher INSERT:**
```sql
-- Einen Autor hinzufügen
INSERT INTO authors (lastname, firstname) 
VALUES ('Tolkien', 'J.R.R.');
```

**Mehrere Datensätze:**
```sql
-- Mehrere Orte auf einmal
INSERT INTO places (zip, city) VALUES 
    (33016, 'Ottawa'), 
    (33017, 'Mississauga'), 
    (33018, 'Hamilton'), 
    (33019, 'Oshawa');
```

**Mit Subquery:**
```sql
-- Autor mit LocationID aus places-Tabelle
INSERT INTO authors (lastname, firstname, Adresse, LocationID, Email) 
VALUES ( 
    'Jordan', 
    'Robert',
    'Fiktionsstrasse 12',
    (SELECT id FROM places WHERE zip='25000'),
    'robert.jordan@hftm.ch'
);
```

### AUTO_INCREMENT

Bei PRIMARY KEY mit AUTO_INCREMENT muss die ID **nicht** angegeben werden:

```sql
-- ID wird automatisch vergeben
INSERT INTO authors (lastname, firstname) 
VALUES ('King', 'Stephen');

-- Letzte eingefügte ID abfragen
SELECT LAST_INSERT_ID();
```

### DEFAULT Werte

```sql
-- Tabelle mit Default-Werten
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- INSERT ohne status und created_at
INSERT INTO users (username) VALUES ('max_mueller');
-- status wird automatisch 'active', created_at wird aktueller Zeitstempel
```

## SELECT - Daten abfragen

### Grundlegende SELECT Syntax

```sql
-- Alle Spalten, alle Zeilen
SELECT * FROM tabelle;

-- Bestimmte Spalten
SELECT spalte1, spalte2 FROM tabelle;

-- Mit WHERE-Bedingung
SELECT * FROM tabelle WHERE bedingung;

-- Mit ORDER BY (Sortierung)
SELECT * FROM tabelle ORDER BY spalte ASC;  -- Aufsteigend
SELECT * FROM tabelle ORDER BY spalte DESC; -- Absteigend

-- Mit LIMIT (Anzahl begrenzen)
SELECT * FROM tabelle LIMIT 10;

-- LIMIT mit OFFSET (für Pagination)
SELECT * FROM tabelle LIMIT 10 OFFSET 20;  -- Zeilen 21-30
```

### WHERE-Bedingungen

**Vergleichsoperatoren:**
```sql
-- Gleich
SELECT * FROM authors WHERE lastname = 'Tolkien';

-- Ungleich
SELECT * FROM authors WHERE lastname != 'Tolkien';
-- oder
SELECT * FROM authors WHERE lastname <> 'Tolkien';

-- Größer / Kleiner
SELECT * FROM places WHERE zip > 33015;
SELECT * FROM books WHERE Published_Date < '2000-01-01';

-- Größer-gleich / Kleiner-gleich
SELECT * FROM places WHERE zip >= 33016 AND zip <= 33019;
```

**Logische Operatoren:**
```sql
-- AND
SELECT * FROM authors 
WHERE lastname = 'Matthews' AND firstname = 'Summer';

-- OR
SELECT * FROM authors 
WHERE lastname = 'Hornby' OR lastname = 'Rowling';

-- Kombiniert (Klammern beachten!)
SELECT * FROM books 
WHERE (Published_Date > '2000-01-01' AND GenresID = 3) 
   OR (Published_Date < '1950-01-01');

-- NOT
SELECT * FROM authors WHERE NOT lastname = 'Tolkien';
```

**LIKE - Mustersuche:**
```sql
-- Nachname beginnt mit 'M'
SELECT * FROM authors WHERE lastname LIKE 'M%';

-- Nachname endet mit 'son'
SELECT * FROM authors WHERE lastname LIKE '%son';

-- Nachname enthält 'ann'
SELECT * FROM authors WHERE lastname LIKE '%ann%';

-- Genau 5 Zeichen (mit _)
SELECT * FROM authors WHERE lastname LIKE '_____';

-- Case-insensitive in MySQL/MariaDB (Standard)
SELECT * FROM authors WHERE lastname LIKE 'tolkien';
```

**IN - Liste von Werten:**
```sql
-- Nachname ist Tolkien, Rowling oder King
SELECT * FROM authors 
WHERE lastname IN ('Tolkien', 'Rowling', 'King');

-- Mit Subquery
SELECT * FROM books 
WHERE AutorID IN (SELECT id FROM authors WHERE lastname LIKE 'M%');
```

**BETWEEN - Wertebereich:**
```sql
-- ZIP zwischen 33016 und 33019
SELECT * FROM places 
WHERE zip BETWEEN 33016 AND 33019;

-- Datum zwischen zwei Werten
SELECT * FROM books 
WHERE Published_Date BETWEEN '2000-01-01' AND '2010-12-31';
```

**IS NULL / IS NOT NULL:**
```sql
-- Email ist nicht gesetzt
SELECT * FROM authors WHERE Email IS NULL;

-- Email ist gesetzt
SELECT * FROM authors WHERE Email IS NOT NULL;
```

### Sortierung (ORDER BY)

```sql
-- Aufsteigend (Standard)
SELECT * FROM authors ORDER BY lastname ASC;
-- oder einfach
SELECT * FROM authors ORDER BY lastname;

-- Absteigend
SELECT * FROM authors ORDER BY lastname DESC;

-- Mehrere Spalten
SELECT * FROM authors 
ORDER BY lastname ASC, firstname ASC;

-- Nach berechneter Spalte
SELECT firstname, lastname, YEAR(CURDATE()) - YEAR(Birthdate) AS age
FROM authors 
ORDER BY age DESC;
```

### LIMIT und OFFSET

```sql
-- Nur die ersten 10
SELECT * FROM books LIMIT 10;

-- Zeilen 11-20 (für Pagination)
SELECT * FROM books LIMIT 10 OFFSET 10;

-- Kurzform (LIMIT offset, count)
SELECT * FROM books LIMIT 10, 10;  -- Zeilen 11-20
```

### DISTINCT - Duplikate entfernen

```sql
-- Alle verschiedenen Genres
SELECT DISTINCT GenresID FROM books;

-- Alle verschiedenen Kombinationen
SELECT DISTINCT AutorID, GenresID FROM books;
```

## UPDATE - Daten aktualisieren

### Syntax

```sql
UPDATE tabelle 
SET spalte1 = wert1, spalte2 = wert2
WHERE bedingung;
```

⚠️ **WICHTIG:** Ohne WHERE werden **ALLE** Zeilen aktualisiert!

### Beispiele

**Einfaches UPDATE:**
```sql
-- PLZ von Oshawa ändern
UPDATE places 
SET zip = 33020
WHERE city = 'Oshawa';
```

**Mehrere Spalten:**
```sql
-- Autor-Daten aktualisieren
UPDATE authors 
SET lastname = 'Armistead', 
    firstname = 'Maupin' 
WHERE lastname = 'Matthews' AND firstname = 'Summer';
```

**Mit Subquery:**
```sql
-- Verleger für alle Bücher von 'B & W Publishing' ändern
UPDATE books 
SET PublishersID = (SELECT ID FROM Publishers WHERE Name = 'Lakewater Press') 
WHERE PublishersID = (SELECT ID FROM Publishers WHERE Name = 'B & W Publishing');
```

**Mit IN und Subquery:**
```sql
-- LocationID für alle Autoren mit Nachname beginnend mit 'Z' setzen
UPDATE authors 
SET Locationid = (SELECT id FROM places WHERE zip = 97499)
WHERE lastname LIKE 'Z%';
```

### String-Funktionen in UPDATE

```sql
-- Leerzeichen am Anfang entfernen
UPDATE books 
SET Title = TRIM(Title) 
WHERE Title LIKE ' %';

-- Zu Großbuchstaben
UPDATE authors 
SET lastname = UPPER(lastname);

-- Zu Kleinbuchstaben
UPDATE authors 
SET email = LOWER(email);

-- Teilstring ersetzen
UPDATE books 
SET Title = REPLACE(Title, 'old', 'new');
```

### Datums-Funktionen in UPDATE

```sql
-- 14 Tage zum Rückgabedatum addieren
UPDATE lends 
SET Date_To = DATE_ADD(Date_To, INTERVAL 14 DAY) 
WHERE Date_To >= CURDATE();

-- Datum auf ersten des Monats setzen
UPDATE events 
SET event_date = DATE_FORMAT(event_date, '%Y-%m-01');
```

### Berechnungen in UPDATE

```sql
-- Preis um 10% erhöhen
UPDATE books 
SET Price = Price * 1.10;

-- Bestand um 5 reduzieren
UPDATE books 
SET AmountInStock = AmountInStock - 5 
WHERE ISBN = 'ISBN-00001';
```

## DELETE - Daten löschen

### Syntax

```sql
DELETE FROM tabelle 
WHERE bedingung;
```

⚠️ **WICHTIG:** Ohne WHERE werden **ALLE** Zeilen gelöscht!

### Beispiele

**Einzelne Zeile löschen:**
```sql
-- Ort 'Oshawa' löschen
DELETE FROM places 
WHERE city = 'Oshawa';
```

**Mit Subquery:**
```sql
-- Alle Bücher eines Autors löschen
DELETE FROM books 
WHERE AutorID = (
    SELECT ID FROM authors 
    WHERE firstname = 'Daphne' AND lastname = 'Scott'
);
```

**Mehrere Zeilen:**
```sql
-- Alle alten Ausleihen löschen
DELETE FROM lends 
WHERE Date_To < '2020-01-01';

-- Alle Bücher ohne Bestand
DELETE FROM books 
WHERE AmountInStock = 0;
```

### TRUNCATE vs. DELETE

```sql
-- DELETE: Löscht Zeilen einzeln, kann rückgängig gemacht werden
DELETE FROM books;

-- TRUNCATE: Schneller, löscht alle Daten, setzt AUTO_INCREMENT zurück
TRUNCATE TABLE books;
```

**Unterschiede:**
| Feature | DELETE | TRUNCATE |
|---------|--------|----------|
| WHERE möglich | ✅ Ja | ❌ Nein |
| Geschwindigkeit | Langsamer | Schneller |
| Rollback | ✅ Ja | ❌ Nein |
| AUTO_INCREMENT | Bleibt | Wird zurückgesetzt |
| Triggers | Werden ausgelöst | Werden nicht ausgelöst |

## Subqueries (Unterabfragen)

Subqueries können in INSERT, UPDATE, DELETE und SELECT verwendet werden.

### In WHERE

```sql
-- Bücher aller Autoren mit Nachname 'M%'
SELECT * FROM books 
WHERE AutorID IN (
    SELECT id FROM authors WHERE lastname LIKE 'M%'
);
```

### In INSERT

```sql
-- Kunde mit LocationID aus Subquery
INSERT INTO Customers (lastname, firstname, LocationID)
VALUES ('Müller', 'Max', 
    (SELECT id FROM places WHERE zip = '25000')
);
```

### In UPDATE

```sql
-- Genre eines Buchs ändern
UPDATE books 
SET GenresID = (SELECT id FROM genres WHERE Genre = 'Science fiction') 
WHERE Title = 'Nineteen Eighty Four';
```

### In DELETE

```sql
-- Alle Bücher eines bestimmten Verlags löschen
DELETE FROM books 
WHERE PublishersID = (
    SELECT ID FROM Publishers WHERE Name = 'Unwanted Press'
);
```

## Wichtige SQL-Funktionen

### String-Funktionen

```sql
-- Länge eines Strings
SELECT LENGTH('Hello');  -- 5

-- Großbuchstaben / Kleinbuchstaben
SELECT UPPER('hello');   -- 'HELLO'
SELECT LOWER('HELLO');   -- 'hello'

-- Teilstring
SELECT SUBSTRING('Hello World', 1, 5);  -- 'Hello'
SELECT LEFT('Hello', 2);                 -- 'He'
SELECT RIGHT('Hello', 2);                -- 'lo'

-- Leerzeichen entfernen
SELECT TRIM('  Hello  ');        -- 'Hello'
SELECT LTRIM('  Hello');         -- 'Hello'
SELECT RTRIM('Hello  ');         -- 'Hello'

-- String-Verkettung
SELECT CONCAT('Hello', ' ', 'World');    -- 'Hello World'
SELECT CONCAT_WS('-', '2024', '10', '10');  -- '2024-10-10'

-- Ersetzen
SELECT REPLACE('Hello World', 'World', 'SQL');  -- 'Hello SQL'

-- Auffüllen
SELECT LPAD('5', 3, '0');   -- '005'
SELECT RPAD('5', 3, '0');   -- '500'
```

### Datums-Funktionen

```sql
-- Aktuelles Datum/Zeit
SELECT CURDATE();           -- 2024-10-10
SELECT CURTIME();           -- 14:30:00
SELECT NOW();               -- 2024-10-10 14:30:00

-- Datum-Teile extrahieren
SELECT YEAR('2024-10-10');   -- 2024
SELECT MONTH('2024-10-10');  -- 10
SELECT DAY('2024-10-10');    -- 10
SELECT DAYNAME('2024-10-10'); -- 'Thursday'

-- Datum formatieren
SELECT DATE_FORMAT(NOW(), '%d.%m.%Y');        -- '10.10.2024'
SELECT DATE_FORMAT(NOW(), '%W, %M %d, %Y');  -- 'Thursday, October 10, 2024'

-- Datum-Berechnungen
SELECT DATE_ADD('2024-10-10', INTERVAL 7 DAY);   -- 2024-10-17
SELECT DATE_SUB('2024-10-10', INTERVAL 1 MONTH); -- 2024-09-10

-- Differenz zwischen Daten
SELECT DATEDIFF('2024-12-31', '2024-01-01');  -- 365
```

### Numerische Funktionen

```sql
-- Rundung
SELECT ROUND(3.14159, 2);    -- 3.14
SELECT CEIL(3.1);            -- 4
SELECT FLOOR(3.9);           -- 3

-- Mathematische Funktionen
SELECT ABS(-5);              -- 5
SELECT SQRT(16);             -- 4
SELECT POWER(2, 3);          -- 8
SELECT MOD(10, 3);           -- 1 (Rest von 10/3)

-- Zufallszahlen
SELECT RAND();               -- 0.xxx (zwischen 0 und 1)
SELECT FLOOR(RAND() * 100);  -- 0-99
```

## Praktische Aufgaben

### Aufgabe 1: Neuer Autor und Bücher

1. Füge einen neuen Ort hinzu: Biel/Bienne, PLZ 25000
2. Füge einen neuen Autor hinzu: Robert Jordan
3. Füge einen neuen Verlag hinzu: hftm Publishing
4. Verknüpfe den Autor mit dem Verlag
5. Füge 3 Bücher der "Wheel of Time" Serie hinzu
6. Füge einen neuen Kunden hinzu
7. Erstelle 3 Ausleihen für den Kunden

### Aufgabe 2: Daten aktualisieren

1. Ändere die E-Mail von 'Sleepytown Press' auf 'john.sleepy@mail.com'
2. Entferne führende Leerzeichen aus allen Buchtiteln
3. Aktualisiere die Adresse von Abdul Murphy
4. Ändere das Genre von "Nineteen Eighty Four" auf "Science fiction"
5. Verlängere alle aktiven Ausleihen um 14 Tage

### Aufgabe 3: Spalten hinzufügen und befüllen

1. Füge Spalten für Tag, Monat, Jahr des Geburtsdatums hinzu
2. Befülle diese Spalten aus dem Birthdate-Feld
3. Füge eine Spalte für Schweizer Datumsformat hinzu (DD.MM.YYYY)
4. Befülle diese Spalte

### Aufgabe 4: Komplexe Queries

1. Finde alle Bücher von Autoren mit Nachname beginnend mit 'M'
2. Finde alle Verlage ohne zugeordnete Autoren
3. Liste alle überfälligen Ausleihen auf
4. Zähle Bücher pro Genre

## Best Practices

### DO's ✅

- **WHERE immer verwenden** bei UPDATE und DELETE
- **Subqueries testen** vor dem Verwenden in UPDATE/DELETE
- **Transaktionen verwenden** bei mehreren zusammenhängenden Änderungen
- **Daten vorher prüfen** mit SELECT
- **Backups erstellen** vor größeren Änderungen

### DON'Ts ❌

- **Niemals UPDATE/DELETE ohne WHERE** (außer bewusst gewollt)
- **Keine komplexen Subqueries** ohne Test
- **Keine SQL-Injection** (immer Prepared Statements in Applikationen)
- **Nicht direkt in Produktion** ändern ohne Test

### Sicherheits-Tipp

```sql
-- Immer zuerst als SELECT testen!

-- 1. SELECT zum Testen
SELECT * FROM books WHERE PublishersID = 5;

-- 2. Wenn richtig, dann UPDATE
UPDATE books SET Price = Price * 1.1 WHERE PublishersID = 5;
```

## Transaktionen

```sql
-- Transaktion starten
START TRANSACTION;
-- oder
BEGIN;

-- Mehrere Operationen
INSERT INTO customers (...) VALUES (...);
INSERT INTO lends (...) VALUES (...);
UPDATE books SET AmountInStock = AmountInStock - 1 WHERE id = 1;

-- Alles bestätigen
COMMIT;

-- Oder bei Fehler alles rückgängig machen
ROLLBACK;
```

## Hausaufgaben

### Aufgabe für Credit 3

Fertigstelle alle DML-Aufgaben aus dem Aufgabenblatt:
- INSERT Operationen (Aufgaben 1-4)
- UPDATE Operationen (Aufgaben 5)
- Dokumentiere deine SQL-Befehle
- Teste alle Queries mit SELECT

**Abgabe:**
- SQL-Datei mit allen Befehlen
- Kommentare zu wichtigen/komplexen Queries
- Screenshots der Ergebnisse

## Zusätzliche Ressourcen

- [SQL DML Tutorial - W3Schools](https://www.w3schools.com/sql/sql_insert.asp)
- [MySQL String Functions](https://dev.mysql.com/doc/refman/8.0/en/string-functions.html)
- [MySQL Date Functions](https://dev.mysql.com/doc/refman/8.0/en/date-and-time-functions.html)
- [SQL Subqueries](https://www.geeksforgeeks.org/sql-subquery/)

## Nächste Schritte

In Lektion 4 lernen wir:
- SQL JOINs (INNER, LEFT, RIGHT, FULL)
- UNION
- Komplexe Queries über mehrere Tabellen
- Aggregat-Funktionen (COUNT, SUM, AVG, etc.)

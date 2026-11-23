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
SOURCE /path/to/HFTM Library.sql;   -- Datei liegt im Ordner "Lektion 03"

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
INSERT INTO authors (Lastname, Firstname) 
VALUES ('Tolkien', 'J.R.R.');
```

**Mehrere Datensätze:**
```sql
-- Mehrere Orte auf einmal
INSERT INTO places (ZIP, City) VALUES 
    (33016, 'Ottawa'), 
    (33017, 'Mississauga'), 
    (33018, 'Hamilton'), 
    (33019, 'Oshawa');
```

**Mit Subquery:**
```sql
-- Autor mit LocationID aus places-Tabelle
INSERT INTO authors (Lastname, Firstname, Address, LocationID, Email) 
VALUES ( 
    'Jordan', 
    'Robert',
    'Fiktionsstrasse 12',
    (SELECT ID FROM places WHERE ZIP='25000'),
    'robert.jordan@hftm.ch'
);
```

### AUTO_INCREMENT

Bei PRIMARY KEY mit AUTO_INCREMENT muss die ID **nicht** angegeben werden:

```sql
-- ID wird automatisch vergeben
INSERT INTO authors (Lastname, Firstname) 
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
SELECT * FROM authors WHERE Lastname = 'Tolkien';

-- Ungleich
SELECT * FROM authors WHERE Lastname != 'Tolkien';
-- oder
SELECT * FROM authors WHERE Lastname <> 'Tolkien';

-- Grösser / Kleiner
SELECT * FROM places WHERE ZIP > 33015;
SELECT * FROM books WHERE Published_Date < '2000-01-01';

-- Grösser-gleich / Kleiner-gleich
SELECT * FROM places WHERE ZIP >= 33016 AND ZIP <= 33019;
```

**Logische Operatoren:**
```sql
-- AND
SELECT * FROM authors 
WHERE Lastname = 'Matthews' AND Firstname = 'Summer';

-- OR
SELECT * FROM authors 
WHERE Lastname = 'Hornby' OR Lastname = 'Rowling';

-- Kombiniert (Klammern beachten!)
SELECT * FROM books 
WHERE (Published_Date > '2000-01-01' AND GenresID = 3) 
   OR (Published_Date < '1950-01-01');

-- NOT
SELECT * FROM authors WHERE NOT Lastname = 'Tolkien';
```

**LIKE - Mustersuche:**
```sql
-- Nachname beginnt mit 'M'
SELECT * FROM authors WHERE Lastname LIKE 'M%';

-- Nachname endet mit 'son'
SELECT * FROM authors WHERE Lastname LIKE '%son';

-- Nachname enthält 'ann'
SELECT * FROM authors WHERE Lastname LIKE '%ann%';

-- Genau 5 Zeichen (mit _)
SELECT * FROM authors WHERE Lastname LIKE '_____';

-- Case-insensitive in MySQL/MariaDB (Standard)
SELECT * FROM authors WHERE Lastname LIKE 'tolkien';
```

**IN - Liste von Werten:**
```sql
-- Nachname ist Tolkien, Rowling oder King
SELECT * FROM authors 
WHERE Lastname IN ('Tolkien', 'Rowling', 'King');

-- Mit Subquery
SELECT * FROM books 
WHERE AuthorsID IN (SELECT ID FROM authors WHERE Lastname LIKE 'M%');
```

**BETWEEN - Wertebereich:**
```sql
-- ZIP zwischen 33016 und 33019
SELECT * FROM places 
WHERE ZIP BETWEEN 33016 AND 33019;

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
SELECT * FROM authors ORDER BY Lastname ASC;
-- oder einfach
SELECT * FROM authors ORDER BY Lastname;

-- Absteigend
SELECT * FROM authors ORDER BY Lastname DESC;

-- Mehrere Spalten
SELECT * FROM authors 
ORDER BY Lastname ASC, Firstname ASC;

-- Nach berechneter Spalte
SELECT Firstname, Lastname, YEAR(CURDATE()) - YEAR(Birthdate) AS age
FROM customers 
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
SELECT DISTINCT AuthorsID, GenresID FROM books;
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
SET ZIP = 33020
WHERE City = 'Oshawa';
```

**Mehrere Spalten:**
```sql
-- Autor-Daten aktualisieren
UPDATE authors 
SET Lastname = 'Armistead', 
    Firstname = 'Maupin' 
WHERE Lastname = 'Matthews' AND Firstname = 'Summer';
```

**Mit Subquery:**
```sql
-- Verleger für alle Bücher von 'B & W Publishing' ändern
UPDATE books 
SET PublishersID = (SELECT ID FROM publishers WHERE Name = 'Lakewater Press') 
WHERE PublishersID = (SELECT ID FROM publishers WHERE Name = 'B & W Publishing');
```

**Mit IN und Subquery:**
```sql
-- LocationID für alle Autoren mit Nachname beginnend mit 'Z' setzen
UPDATE authors 
SET LocationID = (SELECT ID FROM places WHERE ZIP = 97499)
WHERE Lastname LIKE 'Z%';
```

### String-Funktionen in UPDATE

```sql
-- Leerzeichen am Anfang entfernen
UPDATE books 
SET Titel = TRIM(Titel) 
WHERE Titel LIKE ' %';

-- Zu Grossbuchstaben
UPDATE authors 
SET Lastname = UPPER(Lastname);

-- Zu Kleinbuchstaben
UPDATE authors 
SET Email = LOWER(Email);

-- Teilstring ersetzen
UPDATE books 
SET Titel = REPLACE(Titel, 'old', 'new');
```

### Datums-Funktionen in UPDATE

```sql
-- 14 Tage zum Rückgabedatum addieren
UPDATE lends 
SET Date_To = DATE_ADD(Date_To, INTERVAL 14 DAY) 
WHERE Date_To >= CURDATE();

-- Ausleihbeginn auf den Ersten des Monats setzen
UPDATE lends 
SET Date_From = DATE_FORMAT(Date_From, '%Y-%m-01');
```

### Berechnungen in UPDATE

```sql
-- Ausleihpreis um 10% erhöhen
UPDATE lends 
SET Price = Price * 1.10;

-- Bestand um 5 reduzieren
UPDATE books 
SET AmountInStock = AmountInStock - 5 
WHERE ISBN = '642-71-22112-41-5';
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
WHERE City = 'Oshawa';
```

**Mit Subquery:**
```sql
-- Alle Bücher eines Autors löschen
DELETE FROM books 
WHERE AuthorsID = (
    SELECT ID FROM authors 
    WHERE Firstname = 'Daphne' AND Lastname = 'Scott'
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
WHERE AuthorsID IN (
    SELECT ID FROM authors WHERE Lastname LIKE 'M%'
);
```

### In INSERT

```sql
-- Kunde mit LocationID aus Subquery
INSERT INTO customers (Lastname, Firstname, LocationID)
VALUES ('Müller', 'Max', 
    (SELECT ID FROM places WHERE ZIP = '25000')
);
```

### In UPDATE

```sql
-- Genre eines Buchs ändern
UPDATE books 
SET GenresID = (SELECT ID FROM genres WHERE Genre = 'Science Fiction') 
WHERE Titel = 'Nineteen Eighty Four';
```

### In DELETE

```sql
-- Alle Bücher eines bestimmten Verlags löschen
DELETE FROM books 
WHERE PublishersID = (
    SELECT ID FROM publishers WHERE Name = 'Unwanted Press'
);
```

## Wichtige SQL-Funktionen

### String-Funktionen

```sql
-- Länge eines Strings
SELECT LENGTH('Hello');  -- 5

-- Grossbuchstaben / Kleinbuchstaben
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
4. Ändere das Genre von "Nineteen Eighty Four" auf "Science Fiction"
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
- **Backups erstellen** vor grösseren Änderungen

### DON'Ts ❌

- **Niemals UPDATE/DELETE ohne WHERE** (ausser bewusst gewollt)
- **Keine komplexen Subqueries** ohne Test
- **Keine SQL-Injection** (immer Prepared Statements in Applikationen)
- **Nicht direkt in Produktion** ändern ohne Test

### Sicherheits-Tipp

```sql
-- Immer zuerst als SELECT testen!

-- 1. SELECT zum Testen
SELECT * FROM books WHERE PublishersID = 5;

-- 2. Wenn richtig, dann UPDATE
UPDATE books SET AmountInStock = AmountInStock + 1 WHERE PublishersID = 5;
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
UPDATE books SET AmountInStock = AmountInStock - 1 WHERE ID = 1;

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

# Übungsblatt 3: SQL DML

## Credit 3 - HFTM Library Operations (10 Punkte)

### Vorbereitung

Stelle sicher, dass die HFTM Library Datenbank installiert ist:

```sql
SOURCE HFTM Library.sql;   -- Datei liegt im Ordner "Lektion 03"
USE hftm_library;
```

---

## Teil A: INSERT Operations (3 Punkte)

### Aufgabe 1: Neuer Ort (0.5 Punkte)

Füge einen neuen Ort hinzu: Biel/Bienne, PLZ 25000

```sql
-- Deine Lösung hier
```

### Aufgabe 2: Neuer Autor (1 Punkt)

Füge den Autor Robert Jordan mit folgenden Daten hinzu:
- Vorname: Robert
- Nachname: Jordan
- E-Mail: robert.jordan@fantasy.com
- Ort: Der Ort mit PLZ 25000

```sql
-- Deine Lösung hier
```

### Aufgabe 3: Neuer Verlag (0.5 Punkte)

Füge den Verlag "HFTM Publishing" hinzu mit E-Mail: info@hftm.ch

```sql
-- Deine Lösung hier
```

### Aufgabe 4: Neue Bücher (1 Punkt)

Füge 3 Bücher der Serie "Das Rad der Zeit" von Robert Jordan hinzu:
- "Das Auge der Welt", ISBN: 978-3-492-26019-9, Jahr: 1990
- "Die Grosse Jagd", ISBN: 978-3-492-26020-5, Jahr: 1990
- "Der Drache erwacht", ISBN: 978-3-492-26021-2, Jahr: 1991

Alle bei HFTM Publishing, Genre: Fantasy, Lagerbestand (`AmountInStock`): 5

> Hinweis: Die Tabelle `books` hat keine Preisspalte. Preise werden pro Ausleihe in `lends.Price` gespeichert.

```sql
-- Deine Lösung hier
```

---

## Teil B: SELECT Queries (4 Punkte)

### Aufgabe 5: Einfache Abfragen (1 Punkt)

**a)** Alle Bücher, die nach dem Jahr 2000 publiziert wurden:

```sql
-- Deine Lösung hier
```

**b)** Alle Autoren, deren Nachname mit 'M' beginnt:

```sql
-- Deine Lösung hier
```

**c)** Alle Verlage sortiert nach Name:

```sql
-- Deine Lösung hier
```

**d)** Die 10 teuersten Ausleihen (`lends.Price`):

```sql
-- Deine Lösung hier
```

### Aufgabe 6: WHERE mit Operatoren (1 Punkt)

**a)** Alle Ausleihen mit einem Preis zwischen 10 und 30 CHF:

```sql
-- Deine Lösung hier
```

**b)** Alle Bücher deren Titel "Harry" oder "Potter" enthält:

```sql
-- Deine Lösung hier
```

**c)** Alle Kunden OHNE E-Mail-Adresse:

```sql
-- Deine Lösung hier
```

### Aufgabe 7: Aggregationen (1 Punkt)

**a)** Anzahl aller Bücher:

```sql
-- Deine Lösung hier
```

**b)** Durchschnittlicher Ausleihpreis aller Ausleihen:

```sql
-- Deine Lösung hier
```

**c)** Höchster und tiefster Ausleihpreis:

```sql
-- Deine Lösung hier
```

**d)** Anzahl Bücher pro Verlag:

```sql
-- Deine Lösung hier
```

### Aufgabe 8: Komplexe Abfrage (1 Punkt)

Finde alle Bücher von Autoren, deren E-Mail-Adresse bei "gmail.com" endet, 
die nach 2010 publiziert wurden und von denen mehr als 20 Exemplare an Lager sind.
Sortiere nach Lagerbestand (`AmountInStock`) absteigend.

```sql
-- Deine Lösung hier
```

---

## Teil C: UPDATE Operations (2 Punkte)

### Aufgabe 9: Preisanpassungen (1 Punkt)

**a)** Erhöhe den Ausleihpreis (`lends.Price`) aller Ausleihen von Büchern von "HFTM Publishing" um 10%:

```sql
-- Deine Lösung hier
```

**b)** Setze das Publikationsdatum (`Published_Date`) auf den 1.1.2000 für alle Bücher ohne Datum:

```sql
-- Deine Lösung hier
```

### Aufgabe 10: Datenkorrektur (1 Punkt)

**a)** Ändere den Namen des Autors "Matthews, Summer" zu "Armistead, Maupin":

```sql
-- Deine Lösung hier
```

**b)** Aktualisiere die E-Mail von "Sleepytown Press" zu "info@sleepytown.com":

```sql
-- Deine Lösung hier
```

---

## Teil D: DELETE Operations (1 Punkt)

### Aufgabe 11: Daten löschen (1 Punkt)

**a)** Lösche alle Bücher, die keinen Lagerbestand haben (`AmountInStock` = 0):

```sql
-- Deine Lösung hier
```

**b)** Lösche den Ort "Oshawa" (nur wenn keine Autoren damit verknüpft sind):

```sql
-- Deine Lösung hier
```

---

## Lösungen

### Teil A: INSERT Operations

```sql
-- Aufgabe 1
INSERT INTO places (ZIP, City) VALUES (25000, 'Biel/Bienne');

-- Aufgabe 2
INSERT INTO authors (Firstname, Lastname, Email, LocationID) VALUES (
    'Robert',
    'Jordan',
    'robert.jordan@fantasy.com',
    (SELECT ID FROM places WHERE ZIP = 25000)
);

-- Aufgabe 3
INSERT INTO publishers (Name, Email) VALUES 
    ('HFTM Publishing', 'info@hftm.ch');

-- Aufgabe 4
INSERT INTO books (Titel, ISBN, AuthorsID, PublishersID, GenresID, Published_Date, AmountInStock) VALUES
    ('Das Auge der Welt', '978-3-492-26019-9', 
     (SELECT ID FROM authors WHERE Lastname = 'Jordan' AND Firstname = 'Robert'),
     (SELECT ID FROM publishers WHERE Name = 'HFTM Publishing'),
     (SELECT ID FROM genres WHERE Genre = 'Fantasy'),
     '1990-01-15', 5),
    ('Die Grosse Jagd', '978-3-492-26020-5',
     (SELECT ID FROM authors WHERE Lastname = 'Jordan' AND Firstname = 'Robert'),
     (SELECT ID FROM publishers WHERE Name = 'HFTM Publishing'),
     (SELECT ID FROM genres WHERE Genre = 'Fantasy'),
     '1990-11-15', 5),
    ('Der Drache erwacht', '978-3-492-26021-2',
     (SELECT ID FROM authors WHERE Lastname = 'Jordan' AND Firstname = 'Robert'),
     (SELECT ID FROM publishers WHERE Name = 'HFTM Publishing'),
     (SELECT ID FROM genres WHERE Genre = 'Fantasy'),
     '1991-10-15', 5);
```

### Teil B: SELECT Queries

```sql
-- Aufgabe 5a
SELECT * FROM books WHERE Published_Date > '2000-12-31';

-- Aufgabe 5b
SELECT * FROM authors WHERE Lastname LIKE 'M%';

-- Aufgabe 5c
SELECT * FROM publishers ORDER BY Name;

-- Aufgabe 5d
SELECT * FROM lends ORDER BY Price DESC LIMIT 10;

-- Aufgabe 6a
SELECT * FROM lends WHERE Price BETWEEN 10 AND 30;

-- Aufgabe 6b
SELECT * FROM books WHERE Titel LIKE '%Harry%' OR Titel LIKE '%Potter%';

-- Aufgabe 6c
SELECT * FROM customers WHERE Email IS NULL;

-- Aufgabe 7a
SELECT COUNT(*) AS total_books FROM books;

-- Aufgabe 7b
SELECT AVG(Price) AS average_price FROM lends;

-- Aufgabe 7c
SELECT MAX(Price) AS most_expensive, MIN(Price) AS cheapest FROM lends;

-- Aufgabe 7d
SELECT p.Name, COUNT(b.ID) AS book_count
FROM publishers p
LEFT JOIN books b ON p.ID = b.PublishersID
GROUP BY p.ID, p.Name
ORDER BY book_count DESC;

-- Aufgabe 8
SELECT b.*
FROM books b
INNER JOIN authors a ON b.AuthorsID = a.ID
WHERE a.Email LIKE '%gmail.com'
    AND b.Published_Date > '2010-12-31'
    AND b.AmountInStock > 20
ORDER BY b.AmountInStock DESC;
```

### Teil C: UPDATE Operations

```sql
-- Aufgabe 9a
UPDATE lends 
SET Price = Price * 1.10
WHERE BookID IN (
    SELECT ID FROM books
    WHERE PublishersID = (SELECT ID FROM publishers WHERE Name = 'HFTM Publishing')
);

-- Aufgabe 9b
UPDATE books 
SET Published_Date = '2000-01-01'
WHERE Published_Date IS NULL;

-- Aufgabe 10a
UPDATE authors 
SET Firstname = 'Armistead', Lastname = 'Maupin'
WHERE Firstname = 'Summer' AND Lastname = 'Matthews';

-- Aufgabe 10b
UPDATE publishers 
SET Email = 'info@sleepytown.com'
WHERE Name = 'Sleepytown Press';
```

### Teil D: DELETE Operations

```sql
-- Aufgabe 11a
DELETE FROM books WHERE AmountInStock = 0;

-- Aufgabe 11b
-- Erst prüfen ob Autoren existieren
SELECT COUNT(*) FROM authors WHERE LocationID = (SELECT ID FROM places WHERE City = 'Oshawa');
-- Wenn 0, dann löschen:
DELETE FROM places WHERE City = 'Oshawa';
```

---

## Bewertungsraster

| Teil | Aufgabe | Punkte | Erreicht |
|------|---------|--------|----------|
| A | INSERT (1-4) | 3 | |
| B | SELECT (5-8) | 4 | |
| C | UPDATE (9-10) | 2 | |
| D | DELETE (11) | 1 | |
| **Total** | | **10** | |

---

## Tipps

### INSERT
✅ Nutze Subqueries für Foreign Keys
✅ Überprüfe mit SELECT ob Daten korrekt eingefügt

### SELECT
✅ WHERE vor ORDER BY und LIMIT
✅ LIKE mit % für Wildcards
✅ IS NULL (nicht = NULL!)

### UPDATE
✅ IMMER erst mit SELECT testen!
✅ WHERE nicht vergessen
✅ Berechnungen: `Price * 1.10` für +10%

### DELETE
✅ IMMER erst mit SELECT testen!
✅ WHERE nicht vergessen
✅ Bei Foreign Keys: CASCADE beachten

---

## Abgabe

**Format:** .sql Datei mit allen Lösungen
**Deadline:** Siehe Moodle
**Naming:** `Credit3_Vorname_Nachname.sql`

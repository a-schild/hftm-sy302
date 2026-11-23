# Übungsblatt 3: SQL DML

## Credit 3 - HFTM Library Operations (10 Punkte)

### Vorbereitung

Stelle sicher, dass die HFTM Library Datenbank installiert ist:

```sql
SOURCE HFTM_Library.sql;
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
- "Die Große Jagd", ISBN: 978-3-492-26020-5, Jahr: 1990
- "Der Drache erwacht", ISBN: 978-3-492-26021-2, Jahr: 1991

Alle bei HFTM Publishing, Preis: 24.90 CHF, Stock: 5

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

**d)** Die 10 teuersten Bücher:

```sql
-- Deine Lösung hier
```

### Aufgabe 6: WHERE mit Operatoren (1 Punkt)

**a)** Alle Bücher zwischen 10 und 30 CHF:

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

**b)** Durchschnittspreis aller Bücher:

```sql
-- Deine Lösung hier
```

**c)** Teuerstes und günstigstes Buch:

```sql
-- Deine Lösung hier
```

**d)** Anzahl Bücher pro Verlag:

```sql
-- Deine Lösung hier
```

### Aufgabe 8: Komplexe Abfrage (1 Punkt)

Finde alle Bücher von Autoren, deren E-Mail-Adresse bei "gmail.com" endet, 
die nach 2010 publiziert wurden und mehr als 20 CHF kosten.
Sortiere nach Preis absteigend.

```sql
-- Deine Lösung hier
```

---

## Teil C: UPDATE Operations (2 Punkte)

### Aufgabe 9: Preisanpassungen (1 Punkt)

**a)** Erhöhe den Preis aller Bücher von "HFTM Publishing" um 10%:

```sql
-- Deine Lösung hier
```

**b)** Setze das Publikationsjahr auf 2000 für alle Bücher ohne Datum:

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

**a)** Lösche alle Bücher, die 0 Stock haben:

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
INSERT INTO places (zip, city) VALUES (25000, 'Biel/Bienne');

-- Aufgabe 2
INSERT INTO authors (firstname, lastname, email, location_id) VALUES (
    'Robert',
    'Jordan',
    'robert.jordan@fantasy.com',
    (SELECT id FROM places WHERE zip = 25000)
);

-- Aufgabe 3
INSERT INTO publishers (name, email) VALUES 
    ('HFTM Publishing', 'info@hftm.ch');

-- Aufgabe 4
INSERT INTO books (title, isbn, author_id, publisher_id, published_date, price, amount_in_stock) VALUES
    ('Das Auge der Welt', '978-3-492-26019-9', 
     (SELECT id FROM authors WHERE lastname = 'Jordan' AND firstname = 'Robert'),
     (SELECT id FROM publishers WHERE name = 'HFTM Publishing'),
     '1990-01-15', 24.90, 5),
    ('Die Große Jagd', '978-3-492-26020-5',
     (SELECT id FROM authors WHERE lastname = 'Jordan' AND firstname = 'Robert'),
     (SELECT id FROM publishers WHERE name = 'HFTM Publishing'),
     '1990-11-15', 24.90, 5),
    ('Der Drache erwacht', '978-3-492-26021-2',
     (SELECT id FROM authors WHERE lastname = 'Jordan' AND firstname = 'Robert'),
     (SELECT id FROM publishers WHERE name = 'HFTM Publishing'),
     '1991-10-15', 24.90, 5);
```

### Teil B: SELECT Queries

```sql
-- Aufgabe 5a
SELECT * FROM books WHERE published_date > '2000-12-31';

-- Aufgabe 5b
SELECT * FROM authors WHERE lastname LIKE 'M%';

-- Aufgabe 5c
SELECT * FROM publishers ORDER BY name;

-- Aufgabe 5d
SELECT * FROM books ORDER BY price DESC LIMIT 10;

-- Aufgabe 6a
SELECT * FROM books WHERE price BETWEEN 10 AND 30;

-- Aufgabe 6b
SELECT * FROM books WHERE title LIKE '%Harry%' OR title LIKE '%Potter%';

-- Aufgabe 6c
SELECT * FROM customers WHERE email IS NULL;

-- Aufgabe 7a
SELECT COUNT(*) AS total_books FROM books;

-- Aufgabe 7b
SELECT AVG(price) AS average_price FROM books;

-- Aufgabe 7c
SELECT MAX(price) AS most_expensive, MIN(price) AS cheapest FROM books;

-- Aufgabe 7d
SELECT p.name, COUNT(b.id) AS book_count
FROM publishers p
LEFT JOIN books b ON p.id = b.publisher_id
GROUP BY p.id, p.name
ORDER BY book_count DESC;

-- Aufgabe 8
SELECT b.*
FROM books b
INNER JOIN authors a ON b.author_id = a.id
WHERE a.email LIKE '%gmail.com'
    AND b.published_date > '2010-12-31'
    AND b.price > 20
ORDER BY b.price DESC;
```

### Teil C: UPDATE Operations

```sql
-- Aufgabe 9a
UPDATE books 
SET price = price * 1.10
WHERE publisher_id = (SELECT id FROM publishers WHERE name = 'HFTM Publishing');

-- Aufgabe 9b
UPDATE books 
SET published_date = '2000-01-01'
WHERE published_date IS NULL;

-- Aufgabe 10a
UPDATE authors 
SET firstname = 'Armistead', lastname = 'Maupin'
WHERE firstname = 'Summer' AND lastname = 'Matthews';

-- Aufgabe 10b
UPDATE publishers 
SET email = 'info@sleepytown.com'
WHERE name = 'Sleepytown Press';
```

### Teil D: DELETE Operations

```sql
-- Aufgabe 11a
DELETE FROM books WHERE amount_in_stock = 0;

-- Aufgabe 11b
-- Erst prüfen ob Autoren existieren
SELECT COUNT(*) FROM authors WHERE location_id = (SELECT id FROM places WHERE city = 'Oshawa');
-- Wenn 0, dann löschen:
DELETE FROM places WHERE city = 'Oshawa';
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
✅ Berechnungen: `price * 1.10` für +10%

### DELETE
✅ IMMER erst mit SELECT testen!
✅ WHERE nicht vergessen
✅ Bei Foreign Keys: CASCADE beachten

---

## Abgabe

**Format:** .sql Datei mit allen Lösungen
**Deadline:** Siehe Moodle
**Naming:** `Credit3_Vorname_Nachname.sql`

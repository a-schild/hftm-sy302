# Lektion 4: SQL JOINs & UNION

## Lernziele

Der/die Studierende ist in der Lage...
- Einfache SQL DML Befehle zu verwenden
- Eine einfache Datenbank mit Daten zu füllen und Abfragen auszuführen
- JOINs zu verstehen und anzuwenden
- Daten aus mehreren Tabellen zu kombinieren

## Warum JOINs?

In relationalen Datenbanken sind Daten über **mehrere Tabellen verteilt**. Mit JOINs können wir diese Daten wieder **zusammenführen**.

### Beispiel

```
Tabelle: books                 Tabelle: authors
┌────┬────────┬──────────┐    ┌────┬──────────┬───────────┐
│ id │ title  │ author_id│    │ id │ name     │ country   │
├────┼────────┼──────────┤    ├────┼──────────┼───────────┤
│ 1  │ Hobbit │ 10       │    │ 10 │ Tolkien  │ UK        │
│ 2  │ 1984   │ 15       │    │ 15 │ Orwell   │ UK        │
└────┴────────┴──────────┘    └────┴──────────┴───────────┘
```

**Ziel:** Bücher mit Autorennamen anzeigen

```
┌────────┬──────────┐
│ title  │ name     │
├────────┼──────────┤
│ Hobbit │ Tolkien  │
│ 1984   │ Orwell   │
└────────┴──────────┘
```

## INNER JOIN

Der **INNER JOIN** gibt nur Zeilen zurück, die in **beiden** Tabellen eine Übereinstimmung haben.

### Syntax

```sql
SELECT spalten
FROM tabelle1
INNER JOIN tabelle2 ON tabelle1.spalte = tabelle2.spalte;
```

### Venn-Diagramm

```
┌──────────┐  ┌──────────┐
│          │  │          │
│   A      │  │     B    │
│      ┌───┼──┼───┐      │
│      │///│  │///│      │
│      │///│  │///│      │
│      └───┼──┼───┘      │
│          │  │          │
└──────────┘  └──────────┘
     Nur die Schnittmenge
```

### Beispiele

**Bücher mit Autorennamen:**
```sql
SELECT 
    books.Title,
    authors.lastname,
    authors.firstname
FROM books
INNER JOIN authors ON books.AutorID = authors.ID;
```

**Mit Aliassen (kürzer):**
```sql
SELECT 
    b.Title,
    a.lastname,
    a.firstname
FROM books b
INNER JOIN authors a ON b.AutorID = a.ID;
```

**Mehrere JOINs:**
```sql
SELECT 
    b.Title,
    a.lastname AS author,
    g.Genre,
    p.Name AS publisher
FROM books b
INNER JOIN authors a ON b.AutorID = a.ID
INNER JOIN genres g ON b.GenresID = g.ID
INNER JOIN Publishers p ON b.PublishersID = p.ID;
```

**Mit WHERE-Bedingung:**
```sql
SELECT 
    b.Title,
    a.lastname
FROM books b
INNER JOIN authors a ON b.AutorID = a.ID
WHERE a.lastname = 'Tolkien';
```

## LEFT JOIN (LEFT OUTER JOIN)

Der **LEFT JOIN** gibt **alle Zeilen** aus der linken Tabelle zurück, auch wenn keine Übereinstimmung in der rechten Tabelle existiert.

### Syntax

```sql
SELECT spalten
FROM tabelle1
LEFT JOIN tabelle2 ON tabelle1.spalte = tabelle2.spalte;
```

### Venn-Diagramm

```
┌──────────┐  ┌──────────┐
│//////////│  │          │
│//////////│  │     B    │
│//////┌───┼──┼───┐      │
│//////│///│  │///│      │
│//////│///│  │///│      │
│//////└───┼──┼───┘      │
│//////////│  │          │
└──────────┘  └──────────┘
   Alle aus A + Schnittmenge
```

### Beispiele

**Alle Autoren mit ihren Büchern (auch Autoren ohne Bücher):**
```sql
SELECT 
    a.lastname,
    a.firstname,
    b.Title
FROM authors a
LEFT JOIN books b ON a.ID = b.AutorID
ORDER BY a.lastname;
```

**Autoren OHNE Bücher finden:**
```sql
SELECT 
    a.lastname,
    a.firstname
FROM authors a
LEFT JOIN books b ON a.ID = b.AutorID
WHERE b.ID IS NULL;
```

**Kunden mit Anzahl Ausleihen:**
```sql
SELECT 
    c.lastname,
    c.firstname,
    COUNT(l.ID) AS anzahl_ausleihen
FROM Customers c
LEFT JOIN lends l ON c.ID = l.CustomerID
GROUP BY c.ID, c.lastname, c.firstname
ORDER BY anzahl_ausleihen DESC;
```

## RIGHT JOIN (RIGHT OUTER JOIN)

Der **RIGHT JOIN** gibt **alle Zeilen** aus der rechten Tabelle zurück, auch wenn keine Übereinstimmung in der linken Tabelle existiert.

### Syntax

```sql
SELECT spalten
FROM tabelle1
RIGHT JOIN tabelle2 ON tabelle1.spalte = tabelle2.spalte;
```

### Venn-Diagramm

```
┌──────────┐  ┌──────────┐
│          │  │//////////│
│   A      │  │//////////│
│      ┌───┼──┼───┐//////│
│      │///│  │///│//////│
│      │///│  │///│//////│
│      └───┼──┼───┘//////│
│          │  │//////////│
└──────────┘  └──────────┘
   Schnittmenge + Alle aus B
```

### Beispiel

**Alle Bücher mit Autoren (auch Bücher ohne zugeordneten Autor):**
```sql
SELECT 
    b.Title,
    a.lastname,
    a.firstname
FROM authors a
RIGHT JOIN books b ON a.ID = b.AutorID;
```

**Hinweis:** RIGHT JOIN wird seltener verwendet. Meist kann man den Query mit LEFT JOIN umschreiben:

```sql
-- Gleiche Abfrage mit LEFT JOIN
SELECT 
    b.Title,
    a.lastname,
    a.firstname
FROM books b
LEFT JOIN authors a ON b.AutorID = a.ID;
```

## FULL OUTER JOIN

Der **FULL OUTER JOIN** gibt **alle Zeilen** aus beiden Tabellen zurück.

### Venn-Diagramm

```
┌──────────┐  ┌──────────┐
│//////////│  │//////////│
│//////////│  │//////////│
│//////┌───┼──┼───┐//////│
│//////│///│  │///│//////│
│//////│///│  │///│//////│
│//////└───┼──┼───┘//////│
│//////////│  │//////////│
└──────────┘  └──────────┘
        Alles aus A und B
```

**WICHTIG:** MySQL/MariaDB unterstützt FULL OUTER JOIN nicht direkt!

### Workaround mit UNION

```sql
-- Simulation mit UNION
SELECT 
    a.lastname,
    b.Title
FROM authors a
LEFT JOIN books b ON a.ID = b.AutorID

UNION

SELECT 
    a.lastname,
    b.Title
FROM authors a
RIGHT JOIN books b ON a.ID = b.AutorID;
```

## CROSS JOIN

Der **CROSS JOIN** erstellt das **kartesische Produkt** beider Tabellen (jede Zeile aus A mit jeder Zeile aus B).

### Beispiel

```sql
-- Alle Kombinationen von Autoren und Genres
SELECT 
    a.lastname,
    g.Genre
FROM authors a
CROSS JOIN genres g;
```

**Ergebnis:**
```
Wenn authors 100 Zeilen hat und genres 10 Zeilen,
ergibt das 100 * 10 = 1000 Zeilen!
```

**Verwendung:**
- Selten in Praxis
- Testdaten generieren
- Alle möglichen Kombinationen

## SELF JOIN

Ein **SELF JOIN** verbindet eine Tabelle mit sich selbst.

### Beispiel: Mitarbeiter und ihre Vorgesetzten

```sql
-- Tabelle: employees
-- id | name      | manager_id
-- 1  | Boss      | NULL
-- 2  | Manager1  | 1
-- 3  | Employee1 | 2

SELECT 
    e.name AS employee,
    m.name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

**Ergebnis:**
```
┌───────────┬──────────┐
│ employee  │ manager  │
├───────────┼──────────┤
│ Boss      │ NULL     │
│ Manager1  │ Boss     │
│ Employee1 │ Manager1 │
└───────────┴──────────┘
```

## N:M Beziehungen mit JOINs

Bei N:M Beziehungen müssen wir über die **Zwischentabelle** joinen.

### Beispiel: Autoren und Verlage

```sql
-- Alle Autoren mit ihren Verlagen
SELECT 
    a.lastname,
    a.firstname,
    p.Name AS publisher
FROM authors a
INNER JOIN authors_Publishers ap ON a.ID = ap.autorid
INNER JOIN Publishers p ON ap.PublishersID = p.ID;
```

### Beispiel: Autoren und ihre Genres

```sql
-- Autoren mit allen ihren Genres
SELECT 
    a.lastname,
    a.firstname,
    GROUP_CONCAT(g.Genre SEPARATOR ', ') AS genres
FROM authors a
INNER JOIN authors_genres ag ON a.ID = ag.autorsid
INNER JOIN genres g ON ag.GenresID = g.ID
GROUP BY a.ID, a.lastname, a.firstname;
```

## UNION

**UNION** kombiniert die Ergebnisse von zwei oder mehr SELECT-Statements **vertikal** (Zeilen untereinander).

### Syntax

```sql
SELECT spalten FROM tabelle1
UNION
SELECT spalten FROM tabelle2;
```

### Regeln für UNION

1. Gleiche **Anzahl Spalten** in jedem SELECT
2. Spalten müssen **kompatible Datentypen** haben
3. Spalten werden nach **Position** kombiniert (nicht nach Name)
4. **UNION** entfernt Duplikate
5. **UNION ALL** behält Duplikate

### Beispiele

**Einfache UNION:**
```sql
-- Alle Autoren und alle Kunden in einer Liste
SELECT lastname, firstname, 'Author' AS type
FROM authors
UNION
SELECT lastname, firstname, 'Customer' AS type
FROM Customers
ORDER BY lastname;
```

**UNION ALL (mit Duplikaten):**
```sql
SELECT lastname FROM authors
UNION ALL
SELECT lastname FROM Customers;
-- Wenn ein Name in beiden Tabellen ist, erscheint er 2x
```

**Praktisches Beispiel: Vollständige Kontaktliste**
```sql
SELECT 
    CONCAT(firstname, ' ', lastname) AS name,
    email,
    'Author' AS category
FROM authors
WHERE email IS NOT NULL

UNION

SELECT 
    CONCAT(firstname, ' ', lastname) AS name,
    email,
    'Customer' AS category
FROM Customers
WHERE email IS NOT NULL

ORDER BY name;
```

## Aggregat-Funktionen mit JOINs

### COUNT, SUM, AVG, MIN, MAX

```sql
-- Anzahl Bücher pro Autor
SELECT 
    a.lastname,
    a.firstname,
    COUNT(b.ID) AS anzahl_buecher
FROM authors a
LEFT JOIN books b ON a.ID = b.AutorID
GROUP BY a.ID, a.lastname, a.firstname
ORDER BY anzahl_buecher DESC;

-- Durchschnittliche Anzahl Bücher pro Verlag
SELECT 
    p.Name,
    AVG(b.AmountInStock) AS avg_stock,
    SUM(b.AmountInStock) AS total_stock
FROM Publishers p
LEFT JOIN books b ON p.ID = b.PublishersID
GROUP BY p.ID, p.Name;

-- Ältestes und neuestes Buch pro Genre
SELECT 
    g.Genre,
    MIN(b.Published_Date) AS oldest,
    MAX(b.Published_Date) AS newest
FROM genres g
INNER JOIN books b ON g.ID = b.GenresID
GROUP BY g.ID, g.Genre;
```

## HAVING - Filterung nach Aggregation

**WHERE** filtert vor der Gruppierung, **HAVING** filtert nach der Gruppierung.

```sql
-- Autoren mit mehr als 5 Büchern
SELECT 
    a.lastname,
    a.firstname,
    COUNT(b.ID) AS anzahl_buecher
FROM authors a
INNER JOIN books b ON a.ID = b.AutorID
GROUP BY a.ID, a.lastname, a.firstname
HAVING COUNT(b.ID) > 5
ORDER BY anzahl_buecher DESC;

-- Genres mit durchschnittlich mehr als 100 Büchern auf Lager
SELECT 
    g.Genre,
    AVG(b.AmountInStock) AS avg_stock
FROM genres g
INNER JOIN books b ON g.ID = b.GenresID
GROUP BY g.ID, g.Genre
HAVING AVG(b.AmountInStock) > 100;
```

## Praktische Aufgaben

### Aufgabe 1: Einfache JOINs

1. Liste alle Bücher mit Autor-Namen, Genre und Verlag
2. Zeige alle Kunden mit ihrem Wohnort (city)
3. Finde alle aktuellen Ausleihen mit Kunden- und Buchtitel

### Aufgabe 2: LEFT JOIN

1. Zeige alle Autoren, auch solche ohne Bücher
2. Finde alle Verlage ohne Bücher
3. Liste alle Kunden mit Anzahl ihrer Ausleihen (auch 0)

### Aufgabe 3: Aggregationen

1. Wie viele Bücher hat jeder Autor geschrieben?
2. Welches Genre hat die meisten Bücher?
3. Wie viele Ausleihen gab es pro Monat?
4. Welcher Kunde hat die meisten Bücher ausgeliehen?

### Aufgabe 4: Komplexe Queries

1. Autoren mit ihren Genres (als kommaseparierte Liste)
2. Top 5 meistausgeliehene Bücher mit Autor
3. Verlage mit Anzahl Autoren und Büchern
4. Durchschnittliche Ausleihdauer pro Genre

### Lösungsbeispiele

**Beispiel 1: Bücher mit allen Details**
```sql
SELECT 
    b.Title,
    CONCAT(a.firstname, ' ', a.lastname) AS author,
    g.Genre,
    p.Name AS publisher,
    b.Published_Date,
    b.AmountInStock
FROM books b
INNER JOIN authors a ON b.AutorID = a.ID
INNER JOIN genres g ON b.GenresID = g.ID
INNER JOIN Publishers p ON b.PublishersID = p.ID
ORDER BY b.Title;
```

**Beispiel 2: Top 10 Autoren nach Buchanzahl**
```sql
SELECT 
    a.lastname,
    a.firstname,
    COUNT(b.ID) AS book_count
FROM authors a
LEFT JOIN books b ON a.ID = b.AutorID
GROUP BY a.ID, a.lastname, a.firstname
ORDER BY book_count DESC
LIMIT 10;
```

**Beispiel 3: Überfällige Ausleihen**
```sql
SELECT 
    CONCAT(c.firstname, ' ', c.lastname) AS customer,
    b.Title,
    l.Date_From,
    l.Date_To,
    DATEDIFF(CURDATE(), l.Date_To) AS days_overdue
FROM lends l
INNER JOIN Customers c ON l.CustomerID = c.ID
INNER JOIN books b ON l.BookID = b.ID
WHERE l.Date_To < CURDATE()
ORDER BY days_overdue DESC;
```

## Best Practices

### Performance-Tipps

1. **Indizes auf JOIN-Spalten**: Primary und Foreign Keys sollten indiziert sein
2. **SELECT nur benötigte Spalten**: Nicht `SELECT *` in Production
3. **WHERE vor JOIN**: Filtere Daten früh
4. **INNER JOIN bevorzugen**: Wenn möglich (ist schneller als OUTER JOINs)

### Lesbarkeit

```sql
-- Gut formatiert
SELECT 
    b.Title,
    a.lastname,
    g.Genre
FROM books b
INNER JOIN authors a 
    ON b.AutorID = a.ID
INNER JOIN genres g 
    ON b.GenresID = g.ID
WHERE b.Published_Date > '2000-01-01'
ORDER BY b.Title;
```

### Aliasse verwenden

```sql
-- Eindeutige Aliasse verwenden
SELECT 
    b.Title,          -- b für books
    a.lastname,       -- a für authors
    pub.Name          -- pub für Publishers
FROM books b
INNER JOIN authors a ON b.AutorID = a.ID
INNER JOIN Publishers pub ON b.PublishersID = pub.ID;
```

## Häufige Fehler vermeiden

### 1. Cartesian Product (vergessene JOIN-Bedingung)

❌ **Falsch:**
```sql
-- Erzeugt JEDE Kombination!
SELECT * FROM books, authors;
```

✅ **Richtig:**
```sql
SELECT * FROM books b
INNER JOIN authors a ON b.AutorID = a.ID;
```

### 2. Ambiguous Column Names

❌ **Falsch:**
```sql
-- Wenn beide Tabellen 'id' haben
SELECT id FROM books b
INNER JOIN authors a ON b.AutorID = a.ID;
-- Error: Column 'id' in field list is ambiguous
```

✅ **Richtig:**
```sql
SELECT b.id, a.id FROM books b
INNER JOIN authors a ON b.AutorID = a.ID;
```

### 3. GROUP BY ohne Aggregat-Funktion

❌ **Falsch:**
```sql
-- Ohne Aggregat-Funktion macht GROUP BY keinen Sinn
SELECT a.lastname FROM authors a
GROUP BY a.lastname;
```

✅ **Richtig:**
```sql
-- Mit COUNT
SELECT a.lastname, COUNT(*) AS count FROM authors a
GROUP BY a.lastname;
```

## Zusammenfassung

### JOIN-Typen im Überblick

| JOIN-Typ | Beschreibung | Verwendung |
|----------|--------------|------------|
| INNER JOIN | Nur übereinstimmende Zeilen | Standard, am häufigsten |
| LEFT JOIN | Alle aus linker Tabelle | "Auch ohne Match" |
| RIGHT JOIN | Alle aus rechter Tabelle | Selten (als LEFT umschreiben) |
| FULL OUTER | Alle aus beiden Tabellen | In MySQL via UNION |
| CROSS JOIN | Kartesisches Produkt | Selten, Testdaten |
| SELF JOIN | Tabelle mit sich selbst | Hierarchien |

### UNION vs JOIN

- **JOIN**: Kombiniert Spalten (horizontal) aus verschiedenen Tabellen
- **UNION**: Kombiniert Zeilen (vertikal) aus verschiedenen Queries

## Hausaufgaben für Credit 4

1. Implementiere die Ärztezentrum-Datenbank aus Lektion 2
2. Füge Testdaten ein (mind. 5 Datensätze pro Tabelle)
3. Erstelle einen DB-Dump (.sql Datei)
4. Führe 10 verschiedene JOIN-Queries aus
5. Dokumentiere alle Queries mit Kommentaren

## Zusätzliche Ressourcen

- [SQL JOINs Visualized](https://joins.spathon.com/)
- [SQL JOIN Tutorial - W3Schools](https://www.w3schools.com/sql/sql_join.asp)
- [Visual Representation of SQL Joins](https://www.codeproject.com/Articles/33052/Visual-Representation-of-SQL-Joins)

## Nächste Schritte

In Lektion 5 lernen wir:
- Advanced SQL (DCL, TCL)
- Transaktionen und ACID
- Berechtigungen und User-Management
- Stored Procedures und Triggers (Einführung)

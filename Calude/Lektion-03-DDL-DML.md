# SQL - DDL und DML

---

## Agenda

- SQL Überblick und Kategorien
- DDL (Data Definition Language)
- Datentypen
- Constraints und Integritätsbedingungen
- DML (Data Manipulation Language)
- Praktische Beispiele
- Übungen

---

## SQL: Structured Query Language

**SQL ist eine deklarative Sprache:**
- Beschreibt WAS gemacht werden soll
- Nicht WIE es gemacht werden soll
- DBMS optimiert die Ausführung

**Standardisiert:** ANSI/ISO Standard
**Dialekte:** MySQL, PostgreSQL, Oracle, SQL Server, SQLite

---

## SQL Kategorien

```
SQL
├── DDL (Data Definition Language)
│   └── CREATE, ALTER, DROP, TRUNCATE
├── DML (Data Manipulation Language)
│   └── SELECT, INSERT, UPDATE, DELETE
├── DCL (Data Control Language)
│   └── GRANT, REVOKE
└── TCL (Transaction Control Language)
    └── COMMIT, ROLLBACK, SAVEPOINT
```

---

## DDL: Data Definition Language

**Zweck:** Definition und Verwaltung der Datenbankstruktur

**Hauptbefehle:**
- `CREATE` - Objekte erstellen (Tabellen, Indizes, Views)
- `ALTER` - Objekte ändern
- `DROP` - Objekte löschen
- `TRUNCATE` - Tabelleninhalte schnell löschen

**Wichtig:** DDL-Befehle sind nicht rückgängig zu machen!

---

## CREATE TABLE: Grundsyntax

```sql
CREATE TABLE tabellenname (
    spalte1 DATENTYP [CONSTRAINT],
    spalte2 DATENTYP [CONSTRAINT],
    ...
    [CONSTRAINT constraint_name]
);
```

**Beispiel:**
```sql
CREATE TABLE kunde (
    kunde_id INT PRIMARY KEY AUTO_INCREMENT,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Wichtige Datentypen: Zahlen

**Ganzzahlen:**
```sql
TINYINT     -- 1 Byte  (-128 bis 127)
SMALLINT    -- 2 Bytes (-32768 bis 32767)
MEDIUMINT   -- 3 Bytes
INT         -- 4 Bytes (-2^31 bis 2^31-1)
BIGINT      -- 8 Bytes
```

**Dezimalzahlen:**
```sql
DECIMAL(p,s)  -- Exakt: DECIMAL(10,2) für Geldbeträge
NUMERIC(p,s)  -- Synonym für DECIMAL
FLOAT         -- Approximativ, 4 Bytes
DOUBLE        -- Approximativ, 8 Bytes
```

---

## Wichtige Datentypen: Text

```sql
CHAR(n)         -- Feste Länge, bis 255 Zeichen
VARCHAR(n)      -- Variable Länge, bis 65535 Zeichen
TEXT            -- Bis 65535 Zeichen
MEDIUMTEXT      -- Bis 16 MB
LONGTEXT        -- Bis 4 GB

-- Verwendung:
name VARCHAR(100)       -- Namen, Adressen
beschreibung TEXT       -- Längere Texte
notizen LONGTEXT        -- Sehr lange Inhalte
```

---

## Wichtige Datentypen: Datum und Zeit

```sql
DATE            -- 'YYYY-MM-DD'
TIME            -- 'HH:MM:SS'
DATETIME        -- 'YYYY-MM-DD HH:MM:SS'
TIMESTAMP       -- Automatische Zeitstempel
YEAR            -- 'YYYY'

-- Beispiele:
geburtsdatum DATE
bestellzeit DATETIME
erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
geaendert_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP 
             ON UPDATE CURRENT_TIMESTAMP
```

---

## Wichtige Datentypen: Weitere

```sql
BOOLEAN / BOOL          -- TINYINT(1): 0 = false, 1 = true
ENUM('wert1','wert2')   -- Vordefinierte Werteliste
JSON                    -- JSON Dokumente (MySQL 5.7+)
BLOB                    -- Binary Large Object
```

**Beispiele:**
```sql
aktiv BOOLEAN DEFAULT TRUE
status ENUM('offen', 'in_bearbeitung', 'abgeschlossen')
einstellungen JSON
```

---

## Constraints: NOT NULL und DEFAULT

**NOT NULL:** Wert muss vorhanden sein
```sql
CREATE TABLE produkt (
    produkt_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    preis DECIMAL(10,2) NOT NULL,
    beschreibung TEXT
);
```

**DEFAULT:** Standardwert bei fehlender Angabe
```sql
CREATE TABLE bestellung (
    bestellung_id INT PRIMARY KEY,
    status VARCHAR(20) DEFAULT 'offen',
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Constraints: PRIMARY KEY

**Eigenschaften:**
- Eindeutig identifiziert jeden Datensatz
- Automatisch NOT NULL und UNIQUE
- Nur ein Primary Key pro Tabelle
- Kann aus mehreren Spalten bestehen (zusammengesetzter Schlüssel)

```sql
-- Einfacher Primary Key
CREATE TABLE kunde (
    kunde_id INT PRIMARY KEY AUTO_INCREMENT
);

-- Zusammengesetzter Primary Key
CREATE TABLE bestellung_position (
    bestellung_id INT,
    position_nr INT,
    PRIMARY KEY (bestellung_id, position_nr)
);
```

---

## Constraints: FOREIGN KEY

**Zweck:** Referentielle Integrität sicherstellen

```sql
CREATE TABLE bestellung (
    bestellung_id INT PRIMARY KEY AUTO_INCREMENT,
    kunde_id INT NOT NULL,
    bestelldatum DATE NOT NULL,
    FOREIGN KEY (kunde_id) REFERENCES kunde(kunde_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
```

**Visualisierung:**
```
KUNDE (kunde_id) ←─── BESTELLUNG (kunde_id)
    1                      n
```

---

## Foreign Key: Referenzielle Aktionen

```sql
ON DELETE CASCADE       -- Löscht abhängige Datensätze
ON DELETE SET NULL      -- Setzt FK auf NULL
ON DELETE RESTRICT      -- Verhindert Löschen
ON DELETE NO ACTION     -- Wie RESTRICT

ON UPDATE CASCADE       -- Propagiert Änderungen
ON UPDATE RESTRICT      -- Verhindert Änderungen
```

**Beispiel:**
```sql
FOREIGN KEY (kategorie_id) REFERENCES kategorie(kategorie_id)
    ON DELETE SET NULL      -- Produkt bleibt, Kategorie wird NULL
    ON UPDATE CASCADE       -- ID-Änderung wird propagiert
```

---

## Constraints: UNIQUE und CHECK

**UNIQUE:** Wert muss eindeutig sein (NULL erlaubt)
```sql
CREATE TABLE mitarbeiter (
    mitarbeiter_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    steuer_nr VARCHAR(20) UNIQUE
);
```

**CHECK:** Bedingte Überprüfung
```sql
CREATE TABLE produkt (
    produkt_id INT PRIMARY KEY,
    preis DECIMAL(10,2) CHECK (preis >= 0),
    lagerbestand INT CHECK (lagerbestand >= 0),
    rabatt DECIMAL(5,2) CHECK (rabatt BETWEEN 0 AND 100)
);
```

---

## ALTER TABLE: Struktur ändern

**Spalte hinzufügen:**
```sql
ALTER TABLE kunde
ADD telefon VARCHAR(20);

ALTER TABLE kunde
ADD COLUMN geburtsdatum DATE AFTER nachname;
```

**Spalte ändern:**
```sql
ALTER TABLE kunde
MODIFY email VARCHAR(150) NOT NULL;

ALTER TABLE kunde
CHANGE alt_name neuer_name VARCHAR(100);
```

---

## ALTER TABLE: Weitere Operationen

**Spalte löschen:**
```sql
ALTER TABLE kunde
DROP COLUMN telefon;
```

**Constraint hinzufügen:**
```sql
ALTER TABLE bestellung
ADD CONSTRAINT fk_kunde
FOREIGN KEY (kunde_id) REFERENCES kunde(kunde_id);

ALTER TABLE produkt
ADD CONSTRAINT chk_preis CHECK (preis > 0);
```

**Constraint löschen:**
```sql
ALTER TABLE bestellung
DROP FOREIGN KEY fk_kunde;
```

---

## DROP und TRUNCATE

**DROP TABLE:** Tabelle komplett löschen
```sql
DROP TABLE IF EXISTS temporaere_tabelle;
```

**TRUNCATE TABLE:** Alle Daten löschen, Struktur behalten
```sql
TRUNCATE TABLE log_tabelle;
```

**Unterschied zu DELETE:**
- TRUNCATE ist schneller
- TRUNCATE setzt AUTO_INCREMENT zurück
- TRUNCATE kann nicht rückgängig gemacht werden (kein Rollback)
- DELETE kann mit WHERE eingeschränkt werden

---

## DML: Data Manipulation Language

**Zweck:** Daten manipulieren und abfragen

**Hauptbefehle:**
- `INSERT` - Daten einfügen
- `SELECT` - Daten abfragen
- `UPDATE` - Daten ändern
- `DELETE` - Daten löschen

**Wichtig:** DML-Befehle können mit Transaktionen rückgängig gemacht werden

---

## INSERT: Daten einfügen

**Einzelner Datensatz:**
```sql
INSERT INTO kunde (vorname, nachname, email)
VALUES ('Max', 'Mustermann', 'max@example.com');
```

**Mehrere Datensätze:**
```sql
INSERT INTO kunde (vorname, nachname, email)
VALUES 
    ('Anna', 'Schmidt', 'anna@example.com'),
    ('Peter', 'Müller', 'peter@example.com'),
    ('Lisa', 'Weber', 'lisa@example.com');
```

**Alle Spalten (Reihenfolge beachten!):**
```sql
INSERT INTO kunde
VALUES (NULL, 'Tom', 'Braun', 'tom@example.com', NOW());
```

---

## INSERT: Spezialfälle

**Mit Unterabfrage:**
```sql
INSERT INTO archiv_kunde (kunde_id, name, email)
SELECT kunde_id, CONCAT(vorname, ' ', nachname), email
FROM kunde
WHERE erstellt_am < '2020-01-01';
```

**INSERT IGNORE:** Fehler ignorieren
```sql
INSERT IGNORE INTO kunde (email, vorname, nachname)
VALUES ('duplicate@example.com', 'Test', 'User');
```

**ON DUPLICATE KEY UPDATE:**
```sql
INSERT INTO statistik (datum, zugriffe)
VALUES ('2025-10-20', 1)
ON DUPLICATE KEY UPDATE zugriffe = zugriffe + 1;
```

---

## SELECT: Grundlagen

**Einfache Abfrage:**
```sql
SELECT * FROM kunde;

SELECT vorname, nachname, email
FROM kunde;
```

**Mit Bedingung:**
```sql
SELECT vorname, nachname
FROM kunde
WHERE nachname = 'Müller';

SELECT *
FROM produkt
WHERE preis > 100 AND lagerbestand > 0;
```

---

## SELECT: WHERE Operatoren

```sql
-- Vergleichsoperatoren
preis = 99.99
preis != 99.99  oder  preis <> 99.99
preis > 50
preis >= 50
preis < 100
preis <= 100

-- Logische Operatoren
preis > 50 AND preis < 100
kategorie = 'Elektronik' OR kategorie = 'Computer'
NOT (preis > 1000)

-- Bereichsabfragen
preis BETWEEN 50 AND 100
preis NOT BETWEEN 50 AND 100
```

---

## SELECT: Weitere WHERE Operatoren

```sql
-- Pattern Matching
name LIKE 'M%'          -- Beginnt mit M
name LIKE '%mann'       -- Endet mit mann
name LIKE '%er%'        -- Enthält er
name LIKE 'M_ller'      -- _ steht für genau 1 Zeichen

-- IN Operator
kategorie IN ('Elektronik', 'Computer', 'Handy')
kunde_id IN (1, 5, 7, 12)

-- NULL Prüfung
email IS NULL
email IS NOT NULL
```

---

## SELECT: Sortierung und Limitierung

**ORDER BY:** Ergebnisse sortieren
```sql
SELECT * FROM kunde
ORDER BY nachname ASC;          -- Aufsteigend (Standard)

SELECT * FROM kunde
ORDER BY nachname DESC;         -- Absteigend

SELECT * FROM kunde
ORDER BY nachname ASC, vorname ASC;  -- Mehrere Spalten
```

**LIMIT:** Anzahl Ergebnisse begrenzen
```sql
SELECT * FROM kunde
LIMIT 10;                       -- Erste 10

SELECT * FROM kunde
LIMIT 10 OFFSET 20;            -- 10 Datensätze ab Position 20
```

---

## SELECT: Aggregatfunktionen

```sql
-- Anzahl
SELECT COUNT(*) FROM kunde;
SELECT COUNT(DISTINCT email) FROM kunde;

-- Summe, Durchschnitt, Min, Max
SELECT SUM(preis) FROM bestellung;
SELECT AVG(preis) FROM produkt;
SELECT MIN(preis), MAX(preis) FROM produkt;

-- Mit Bedingung
SELECT COUNT(*) FROM kunde
WHERE erstellt_am >= '2025-01-01';
```

---

## SELECT: GROUP BY und HAVING

**GROUP BY:** Gruppierung
```sql
SELECT kategorie, COUNT(*) as anzahl
FROM produkt
GROUP BY kategorie;

SELECT kunde_id, COUNT(*) as anzahl_bestellungen, SUM(betrag) as gesamt
FROM bestellung
GROUP BY kunde_id;
```

**HAVING:** Filter nach Aggregation
```sql
SELECT kategorie, COUNT(*) as anzahl
FROM produkt
GROUP BY kategorie
HAVING COUNT(*) > 5;            -- Nur Kategorien mit > 5 Produkten
```

---

## UPDATE: Daten ändern

**Einzelnes Feld:**
```sql
UPDATE kunde
SET email = 'neuemail@example.com'
WHERE kunde_id = 5;
```

**Mehrere Felder:**
```sql
UPDATE produkt
SET preis = preis * 1.1,        -- 10% Preiserhöhung
    geaendert_am = NOW()
WHERE kategorie = 'Elektronik';
```

**WICHTIG:** Ohne WHERE werden ALLE Datensätze geändert!
```sql
UPDATE produkt
SET lagerbestand = 0;           -- Alle auf 0 setzen!
```

---

## UPDATE: Berechnungen und Joins

**Mit Berechnungen:**
```sql
UPDATE produkt
SET preis = preis * 0.9         -- 10% Rabatt
WHERE lagerbestand > 100;

UPDATE bestellung
SET status = 'abgeschlossen',
    abschluss_datum = NOW()
WHERE status = 'versandt' 
  AND versandt_am < DATE_SUB(NOW(), INTERVAL 7 DAY);
```

**Mit JOIN (MySQL):**
```sql
UPDATE produkt p
JOIN kategorie k ON p.kategorie_id = k.kategorie_id
SET p.preis = p.preis * 0.8
WHERE k.name = 'Ausverkauf';
```

---

## DELETE: Daten löschen

**Mit Bedingung:**
```sql
DELETE FROM kunde
WHERE kunde_id = 5;

DELETE FROM log_eintraege
WHERE erstellt_am < DATE_SUB(NOW(), INTERVAL 90 DAY);
```

**Alle Datensätze löschen:**
```sql
DELETE FROM temporaere_daten;   -- Langsam, aber mit Rollback
TRUNCATE TABLE temporaere_daten; -- Schnell, kein Rollback
```

**WICHTIG:** Ohne WHERE werden ALLE Datensätze gelöscht!

---

## DELETE: Kaskadierung

**Mit Foreign Key Constraints:**
```sql
-- Wenn ON DELETE CASCADE definiert:
DELETE FROM kunde WHERE kunde_id = 5;
-- Löscht automatisch alle Bestellungen dieses Kunden

-- Wenn ON DELETE RESTRICT:
-- Fehler: Kann nicht gelöscht werden, abhängige Daten vorhanden
```

**Manuelles kaskadierendes Löschen:**
```sql
DELETE FROM bestellung_position WHERE bestellung_id = 100;
DELETE FROM bestellung WHERE bestellung_id = 100;
```

---

## Transaktionen: ACID

**Atomicity:** Alles oder nichts
**Consistency:** Datenbank bleibt konsistent
**Isolation:** Transaktionen beeinflussen sich nicht
**Durability:** Gespeicherte Daten bleiben erhalten

```sql
START TRANSACTION;

INSERT INTO bestellung (kunde_id, betrag) VALUES (5, 99.99);
UPDATE kunde SET bestellungen = bestellungen + 1 WHERE kunde_id = 5;

COMMIT;     -- Alles speichern
-- ROLLBACK;  -- Alles rückgängig machen
```

---

## Praktisches Beispiel: Online-Shop

**Schritt 1: Tabellen erstellen**
```sql
CREATE TABLE kategorie (
    kategorie_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    beschreibung TEXT
);

CREATE TABLE produkt (
    produkt_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(200) NOT NULL,
    beschreibung TEXT,
    preis DECIMAL(10,2) NOT NULL CHECK (preis >= 0),
    lagerbestand INT DEFAULT 0 CHECK (lagerbestand >= 0),
    kategorie_id INT,
    erstellt_am TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (kategorie_id) REFERENCES kategorie(kategorie_id)
        ON DELETE SET NULL
);
```

---

## Praktisches Beispiel: Daten einfügen

```sql
-- Kategorien einfügen
INSERT INTO kategorie (name, beschreibung)
VALUES 
    ('Elektronik', 'Elektronische Geräte'),
    ('Bücher', 'Bücher aller Art'),
    ('Kleidung', 'Mode und Bekleidung');

-- Produkte einfügen
INSERT INTO produkt (name, preis, lagerbestand, kategorie_id)
VALUES 
    ('Laptop Dell XPS', 1299.00, 15, 1),
    ('iPhone 15', 999.00, 30, 1),
    ('SQL für Einsteiger', 39.90, 100, 2),
    ('T-Shirt Basic', 19.90, 200, 3);
```

---

## Praktisches Beispiel: Abfragen

```sql
-- Alle Produkte einer Kategorie
SELECT p.name, p.preis, k.name as kategorie
FROM produkt p
JOIN kategorie k ON p.kategorie_id = k.kategorie_id
WHERE k.name = 'Elektronik';

-- Top 3 teuerste Produkte
SELECT name, preis
FROM produkt
ORDER BY preis DESC
LIMIT 3;

-- Anzahl Produkte pro Kategorie
SELECT k.name, COUNT(*) as anzahl_produkte, AVG(p.preis) as durchschnittspreis
FROM kategorie k
LEFT JOIN produkt p ON k.kategorie_id = p.kategorie_id
GROUP BY k.kategorie_id, k.name;
```

---

## Praktisches Beispiel: Updates

```sql
-- Preiserhöhung für Elektronik
UPDATE produkt
SET preis = preis * 1.05
WHERE kategorie_id = (
    SELECT kategorie_id FROM kategorie WHERE name = 'Elektronik'
);

-- Lagerbestand nach Verkauf
START TRANSACTION;

UPDATE produkt
SET lagerbestand = lagerbestand - 1
WHERE produkt_id = 1 AND lagerbestand > 0;

-- Prüfen ob Update erfolgreich
-- Wenn ja: COMMIT, sonst: ROLLBACK

COMMIT;
```

---

## Best Practices: DDL

- **Immer PRIMARY KEY definieren**
- **Foreign Keys für referentielle Integrität**
- **NOT NULL für Pflichtfelder**
- **DEFAULT Werte wo sinnvoll**
- **CHECK Constraints für Wertebereiche**
- **Aussagekräftige Namen** (snake_case)
- **Dokumentation** der Constraints
- **Backup vor ALTER TABLE**

---

## Best Practices: DML

- **Immer WHERE bei UPDATE/DELETE** (außer bewusst alle)
- **Transaktionen für zusammenhängende Operationen**
- **LIMIT bei großen Datenmengen**
- **Indizes für häufige WHERE/JOIN Spalten**
- **Prepared Statements** gegen SQL Injection
- **SELECT nur benötigte Spalten** (nicht immer *)
- **Aggregatfunktionen statt Programmlogik**

---

## Übung 1: Tabelle erstellen

**Aufgabe:** Erstellen Sie eine Tabelle `mitarbeiter` mit:
- Mitarbeiter-ID (Primary Key, Auto Increment)
- Vorname und Nachname (Pflichtfelder)
- Email (eindeutig)
- Gehalt (nur positive Werte)
- Abteilung (ENUM: 'IT', 'Verkauf', 'Personal', 'Verwaltung')
- Einstellungsdatum
- Vorgesetzter-ID (Foreign Key auf mitarbeiter)

---

## Übung 2: Daten manipulieren

**Gegeben:** Die Tabelle aus Übung 1

**Aufgaben:**
1. Fügen Sie 5 Mitarbeiter ein
2. Erhöhen Sie das Gehalt aller IT-Mitarbeiter um 10%
3. Ändern Sie die Abteilung eines Mitarbeiters
4. Finden Sie den Mitarbeiter mit dem höchsten Gehalt
5. Berechnen Sie das Durchschnittsgehalt pro Abteilung
6. Löschen Sie Mitarbeiter, die vor 2015 eingestellt wurden

---

## Übung 3: Komplexes Szenario

**Szenario:** Bibliothekssystem
1. Erstellen Sie Tabellen für: Autor, Buch, Mitglied, Ausleihe
2. Definieren Sie alle Beziehungen mit Foreign Keys
3. Fügen Sie Testdaten ein (mindestens 3 je Tabelle)
4. Schreiben Sie Queries für:
   - Alle ausgeliehenen Bücher
   - Bücher die überfällig sind (> 30 Tage)
   - Top 3 meistausgeliehene Bücher
   - Mitglieder ohne aktive Ausleihen

---

## Zusammenfassung DDL

- **CREATE:** Struktur definieren
- **ALTER:** Struktur ändern
- **DROP:** Struktur löschen
- **Constraints:** Datenintegrität sichern
- **Datentypen:** Passend wählen
- **Foreign Keys:** Beziehungen abbilden

---

## Zusammenfassung DML

- **INSERT:** Daten einfügen
- **SELECT:** Daten abfragen (mit WHERE, ORDER BY, LIMIT)
- **UPDATE:** Daten ändern
- **DELETE:** Daten löschen
- **Aggregatfunktionen:** COUNT, SUM, AVG, MIN, MAX
- **GROUP BY:** Gruppierung mit HAVING
- **Transaktionen:** ACID Eigenschaften

---

## Nächste Lektion

- JOIN Operationen (INNER, LEFT, RIGHT, FULL)
- Subqueries und verschachtelte Abfragen
- Views und Stored Procedures
- Indizes und Performance-Optimierung
- Query Execution Plans

---

## Fragen?

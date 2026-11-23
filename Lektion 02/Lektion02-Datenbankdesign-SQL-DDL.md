# Lektion 2: Datenbankdesign & SQL DDL

## Lernziele

Der/die Studierende ist in der Lage...
- Den Datenbankdesignprozess zu erklären
- Eine relationale Datenbank mit 3 Tabellen zu modellieren
- Ein ERD lesen und zu erstellen
- Ein einfaches ERD mittels SQL Befehlen umzusetzen

## Datenbankdesign-Prozess

Ein gutes Datenbankdesign ist die Grundlage für eine funktionierende Applikation!

### Phasen des Datenbankdesigns

```
1. Anforderungsanalyse
        ↓
2. Konzeptuelles Design (ER-Modell)
        ↓
3. Logisches Design (Relationen)
        ↓
4. Normalisierung
        ↓
5. Physisches Design (SQL DDL)
```

## 1. Anforderungsanalyse

### Fragen stellen

- **Welche Daten** müssen gespeichert werden?
- **Wer** nutzt die Datenbank?
- **Welche Operationen** werden ausgeführt?
- **Welche Beziehungen** gibt es zwischen Daten?
- **Welche Constraints** (Einschränkungen) gelten?

### Beispiel: Ärztezentrum

**Szenario:** Ein Ärztezentrum möchte Patienten, Ärzte und Termine verwalten.

**Anforderungen:**
- Patienten haben Name, Geburtsdatum, Adresse, Telefon
- Ärzte haben Name, Fachgebiet, Telefon
- Termine verbinden Patienten mit Ärzten
- Ein Patient kann mehrere Termine haben
- Ein Arzt kann mehrere Termine haben
- Termine haben Datum, Uhrzeit, Grund

## 2. ER-Modell (Entity-Relationship)

Ein **ER-Diagramm** visualisiert Entitäten und ihre Beziehungen.

### Grundelemente

**Entität (Entity):**
- Ein Objekt der realen Welt
- Darstellung: Rechteck
- Beispiel: Patient, Arzt, Termin

**Attribut:**
- Eigenschaft einer Entität
- Darstellung: Oval
- Beispiel: Name, Geburtsdatum, Adresse

**Primärschlüssel (Primary Key):**
- Eindeutige Identifikation einer Entität
- Darstellung: Unterstrichenes Attribut
- Beispiel: PatientenID, ArztID

**Beziehung (Relationship):**
- Verbindung zwischen Entitäten
- Darstellung: Raute
- Beispiel: "hat Termin bei"

### Kardinalitäten

Beschreiben, wie viele Entitäten in Beziehung stehen:

**1:1 (Eins-zu-Eins)**
- Ein A gehört zu genau einem B
- Ein B gehört zu genau einem A
- Beispiel: Person ↔ Reisepass

**1:N (Eins-zu-Viele)**
- Ein A kann mehrere B haben
- Ein B gehört zu genau einem A
- Beispiel: Autor → Bücher (Ein Autor schreibt viele Bücher)

**N:M (Viele-zu-Viele)**
- Ein A kann mehrere B haben
- Ein B kann mehrere A haben
- Beispiel: Studenten ↔ Kurse (Studenten belegen mehrere Kurse, Kurse haben mehrere Studenten)

### ER-Diagramm Notation (Chen-Notation)

```
┌─────────────┐
│   Patient   │  ← Entität
│─────────────│
│ PatientenID │  ← Primary Key (unterstrichen)
│ Name        │  ← Attribut
│ Geburtsdatum│
└─────────────┘
       │
       │ 1
       │
       ◇ hat Termin bei  ← Beziehung
       │
       │ N
       │
┌─────────────┐
│    Arzt     │
│─────────────│
│ ArztID      │
│ Name        │
│ Fachgebiet  │
└─────────────┘
```

### Beispiel: Ärztezentrum ER-Diagramm

```
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│   Patient    │          │    Termin    │          │     Arzt     │
│──────────────│          │──────────────│          │──────────────│
│ PatientenID  │ 1     N  │ TerminID     │ N     1  │ ArztID       │
│ Vorname      │──────────│ PatientenID  │──────────│ Name         │
│ Nachname     │          │ ArztID       │          │ Fachgebiet   │
│ Geburtsdatum │          │ Datum        │          │ Telefon      │
│ Adresse      │          │ Uhrzeit      │          └──────────────┘
│ Telefon      │          │ Grund        │
└──────────────┘          └──────────────┘
```

**Beziehungen:**
- Ein Patient hat N Termine (1:N)
- Ein Arzt hat N Termine (1:N)
- Ein Termin gehört zu 1 Patient und 1 Arzt

## 3. Normalisierung

**Ziel:** Redundanz minimieren, Datenintegrität maximieren

### Normalformen

#### 1. Normalform (1NF)

**Regel:** Jedes Attribut enthält nur atomare (unteilbare) Werte

❌ **Nicht 1NF:**
```
┌────┬──────────┬─────────────────────────┐
│ ID │ Name     │ Telefonnummern          │
├────┼──────────┼─────────────────────────┤
│ 1  │ Müller   │ 079 123 45 67, 031 123  │
└────┴──────────┴─────────────────────────┘
```

✅ **1NF:**
```
┌────┬──────────┬───────────────┬─────────┐
│ ID │ Name     │ Telefon1      │ Telefon2│
├────┼──────────┼───────────────┼─────────┤
│ 1  │ Müller   │ 079 123 45 67 │ 031 123 │
└────┴──────────┴───────────────┴─────────┘
```

**Oder besser: Separate Tabelle**
```
Personen:                  Telefonnummern:
┌────┬──────────┐         ┌────┬───────────┬───────────────┐
│ ID │ Name     │         │ ID │ PersonID  │ Nummer        │
├────┼──────────┤         ├────┼───────────┼───────────────┤
│ 1  │ Müller   │         │ 1  │ 1         │ 079 123 45 67 │
└────┴──────────┘         │ 2  │ 1         │ 031 123 45 00 │
                          └────┴───────────┴───────────────┘
```

#### 2. Normalform (2NF)

**Regel:** 1NF + Alle Nicht-Schlüssel-Attribute sind voll funktional abhängig vom Primärschlüssel

**Problem:** Teilabhängigkeiten

❌ **Nicht 2NF:**
```
Bestellpositionen:
┌───────────┬────────────┬──────────────┬────────────┬───────┐
│BestellungID│ ProduktID │ Produktname  │ Menge      │ Preis │
├───────────┼────────────┼──────────────┼────────────┼───────┤
│ 1         │ 101        │ Laptop       │ 2          │ 1200  │
│ 1         │ 102        │ Maus         │ 5          │ 25    │
└───────────┴────────────┴──────────────┴────────────┴───────┘
```
Problem: `Produktname` hängt nur von `ProduktID` ab, nicht von `BestellungID`

✅ **2NF:**
```
Bestellpositionen:                  Produkte:
┌───────────┬────────────┬────────┐ ┌────────────┬──────────────┬───────┐
│BestellungID│ ProduktID │ Menge  │ │ ProduktID  │ Produktname  │ Preis │
├───────────┼────────────┼────────┤ ├────────────┼──────────────┼───────┤
│ 1         │ 101        │ 2      │ │ 101        │ Laptop       │ 1200  │
│ 1         │ 102        │ 5      │ │ 102        │ Maus         │ 25    │
└───────────┴────────────┴────────┘ └────────────┴──────────────┴───────┘
```

#### 3. Normalform (3NF)

**Regel:** 2NF + Keine transitiven Abhängigkeiten

**Problem:** Ein Nicht-Schlüssel-Attribut hängt von einem anderen Nicht-Schlüssel-Attribut ab

❌ **Nicht 3NF:**
```
Mitarbeiter:
┌────┬──────────┬──────────────┬──────────────┐
│ ID │ Name     │ Abteilung    │ Abt_Standort │
├────┼──────────┼──────────────┼──────────────┤
│ 1  │ Müller   │ IT           │ Bern         │
│ 2  │ Schmidt  │ IT           │ Bern         │
│ 3  │ Meyer    │ HR           │ Zürich       │
└────┴──────────┴──────────────┴──────────────┘
```
Problem: `Abt_Standort` hängt von `Abteilung` ab, nicht direkt von ID

✅ **3NF:**
```
Mitarbeiter:                      Abteilungen:
┌────┬──────────┬──────────────┐ ┌──────────────┬──────────┬──────────┐
│ ID │ Name     │ Abteilung_ID │ │ Abteilung_ID │ Name     │ Standort │
├────┼──────────┼──────────────┤ ├──────────────┼──────────┼──────────┤
│ 1  │ Müller   │ 1            │ │ 1            │ IT       │ Bern     │
│ 2  │ Schmidt  │ 1            │ │ 2            │ HR       │ Zürich   │
│ 3  │ Meyer    │ 2            │ └──────────────┴──────────┴──────────┘
└────┴──────────┴──────────────┘
```

## 4. SQL DDL (Data Definition Language)

SQL-Befehle zum **Definieren** der Datenbankstruktur.

### Datentypen in MariaDB/MySQL

**Numerische Typen:**
```sql
INT             -- Ganzzahl (-2147483648 bis 2147483647)
BIGINT          -- Große Ganzzahl
DECIMAL(10,2)   -- Festkommazahl (10 Stellen, 2 Nachkommastellen)
FLOAT           -- Fließkommazahl
DOUBLE          -- Doppelt-genaue Fließkommazahl
```

**Text-Typen:**
```sql
CHAR(10)        -- Feste Länge (immer 10 Zeichen, mit Leerzeichen aufgefüllt)
VARCHAR(255)    -- Variable Länge (bis 255 Zeichen)
TEXT            -- Längerer Text (bis 65,535 Zeichen)
LONGTEXT        -- Sehr langer Text (bis 4GB)
```

**Datum/Zeit-Typen:**
```sql
DATE            -- Datum (YYYY-MM-DD)
TIME            -- Zeit (HH:MM:SS)
DATETIME        -- Datum und Zeit (YYYY-MM-DD HH:MM:SS)
TIMESTAMP       -- Zeitstempel (automatisch bei INSERT/UPDATE)
YEAR            -- Jahr (YYYY)
```

**Andere Typen:**
```sql
BOOLEAN         -- TRUE/FALSE (wird als TINYINT(1) gespeichert)
ENUM('A','B')   -- Aufzählung
JSON            -- JSON-Daten
BLOB            -- Binärdaten (z.B. Bilder)
```

### CREATE DATABASE

```sql
-- Datenbank erstellen
CREATE DATABASE arztpraxis;

-- Mit Character Set
CREATE DATABASE arztpraxis 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

-- Datenbank auswählen
USE arztpraxis;

-- Datenbank löschen (VORSICHT!)
DROP DATABASE arztpraxis;

-- Datenbank nur löschen wenn sie existiert
DROP DATABASE IF EXISTS arztpraxis;
```

### CREATE TABLE

**Grundstruktur:**
```sql
CREATE TABLE tabellenname (
    spalte1 DATENTYP [CONSTRAINTS],
    spalte2 DATENTYP [CONSTRAINTS],
    ...
    [TABLE CONSTRAINTS]
);
```

**Beispiel: Patienten-Tabelle**
```sql
CREATE TABLE patients (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    address VARCHAR(255),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Beispiel: Ärzte-Tabelle**
```sql
CREATE TABLE doctors (
    doctor_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Beispiel: Termine-Tabelle mit Foreign Keys**
```sql
CREATE TABLE appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason VARCHAR(255),
    status ENUM('scheduled', 'completed', 'cancelled') DEFAULT 'scheduled',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key Constraints
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(doctor_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
```

### Constraints (Einschränkungen)

**PRIMARY KEY:**
- Eindeutige Identifikation jeder Zeile
- Kann nicht NULL sein
- Pro Tabelle nur ein Primary Key

```sql
-- Als Spalten-Constraint
column_name INT PRIMARY KEY

-- Als Tabellen-Constraint
PRIMARY KEY (column_name)

-- Zusammengesetzter Primary Key
PRIMARY KEY (column1, column2)
```

**FOREIGN KEY:**
- Referenziert Primary Key einer anderen Tabelle
- Gewährleistet referentielle Integrität

```sql
FOREIGN KEY (spalte) REFERENCES andere_tabelle(spalte)
    ON DELETE CASCADE        -- Beim Löschen des Parents
    ON UPDATE CASCADE        -- Beim Update des Parents
```

**ON DELETE / ON UPDATE Optionen:**
- `CASCADE`: Automatisch mitlöschen/ändern
- `SET NULL`: Auf NULL setzen
- `RESTRICT`: Löschen/Ändern verhindern
- `NO ACTION`: Keine Aktion (Standard)

**NOT NULL:**
- Feld darf nicht leer sein

```sql
column_name VARCHAR(50) NOT NULL
```

**UNIQUE:**
- Wert muss eindeutig sein (darf aber NULL sein)

```sql
email VARCHAR(100) UNIQUE
```

**DEFAULT:**
- Standardwert wenn nichts angegeben

```sql
status VARCHAR(20) DEFAULT 'active'
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
```

**CHECK:**
- Bedingung muss erfüllt sein

```sql
age INT CHECK (age >= 0 AND age <= 150)
price DECIMAL(10,2) CHECK (price > 0)
```

**AUTO_INCREMENT:**
- Automatische Hochzählung (meist für Primary Keys)

```sql
id INT PRIMARY KEY AUTO_INCREMENT
```

### ALTER TABLE

Bestehende Tabellen ändern:

```sql
-- Spalte hinzufügen
ALTER TABLE patients 
ADD COLUMN insurance VARCHAR(50);

-- Spalte ändern
ALTER TABLE patients 
MODIFY COLUMN phone VARCHAR(30);

-- Spalte umbenennen
ALTER TABLE patients 
CHANGE COLUMN phone phone_number VARCHAR(30);

-- Spalte löschen
ALTER TABLE patients 
DROP COLUMN insurance;

-- Constraint hinzufügen
ALTER TABLE appointments
ADD CONSTRAINT fk_patient
FOREIGN KEY (patient_id) REFERENCES patients(patient_id);

-- Constraint löschen
ALTER TABLE appointments
DROP FOREIGN KEY fk_patient;

-- Tabelle umbenennen
ALTER TABLE appointments 
RENAME TO medical_appointments;
```

### DROP TABLE

```sql
-- Tabelle löschen
DROP TABLE appointments;

-- Tabelle nur löschen wenn sie existiert
DROP TABLE IF EXISTS appointments;

-- Mehrere Tabellen löschen
DROP TABLE IF EXISTS appointments, patients, doctors;
```

### TRUNCATE TABLE

Alle Daten löschen, Struktur behalten:

```sql
-- Alle Zeilen löschen (schneller als DELETE)
TRUNCATE TABLE appointments;

-- WICHTIG: AUTO_INCREMENT wird zurückgesetzt!
```

## N:M Beziehungen in SQL

Bei N:M Beziehungen braucht man eine **Zwischentabelle** (Junction Table).

**Beispiel: Studenten und Kurse**

```
Student (N) ←→ (M) Kurs
```

**Lösung:**
```
Student (1) → (N) Einschreibungen (N) ← (1) Kurs
```

```sql
-- Studenten Tabelle
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE
);

-- Kurse Tabelle
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    credits INT
);

-- Zwischentabelle (Junction Table)
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE DEFAULT (CURRENT_DATE),
    grade DECIMAL(3,1),
    
    FOREIGN KEY (student_id) REFERENCES students(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id)
        ON DELETE CASCADE,
        
    -- Ein Student kann sich nur einmal für einen Kurs einschreiben
    UNIQUE (student_id, course_id)
);
```

## Praktische Übung: Gewässerkarte

### Vorbereitungsauftrag (Credit 2)

**Gewässerkarte BE-Nord:** [Link zur Karte]

**Aufgabe:**
1. Analysiere die Gewässerkarte
2. Ermittle welche **Daten** vorhanden sind
3. Definiere passende **Datentypen**
4. Erstelle eine Excel-Liste mit:
   - Spalte 1: Datenfeld-Name
   - Spalte 2: Beschreibung
   - Spalte 3: Datentyp (SQL)
   - Spalte 4: Constraints (NOT NULL, UNIQUE, etc.)

**Beispiel-Zeilen:**
```
| Feld         | Beschreibung        | Datentyp     | Constraints |
|--------------|---------------------|--------------|-------------|
| gewaesser_id | Eindeutige ID       | INT          | PRIMARY KEY, AUTO_INCREMENT |
| name         | Name des Gewässers  | VARCHAR(100) | NOT NULL    |
| typ          | See, Fluss, Bach    | ENUM(...)    | NOT NULL    |
| laenge_km    | Länge in Kilometern | DECIMAL(6,2) | CHECK > 0   |
```

## Zusammenfassung

### Der Design-Prozess

1. **Anforderungen** sammeln
2. **ER-Diagramm** erstellen
3. **Normalisieren** (1NF, 2NF, 3NF)
4. **SQL DDL** schreiben
5. **Testen** mit Beispieldaten

### Wichtige SQL DDL Befehle

```sql
CREATE DATABASE    -- Datenbank erstellen
CREATE TABLE       -- Tabelle erstellen
ALTER TABLE        -- Tabelle ändern
DROP TABLE         -- Tabelle löschen
TRUNCATE TABLE     -- Alle Daten löschen
```

### Best Practices

✅ **Namenskonventionen:**
- Tabellen: Plural, lowercase, snake_case (`students`, `course_enrollments`)
- Spalten: Singular, lowercase, snake_case (`first_name`, `student_id`)
- Primary Keys: `tabelle_id` (z.B. `student_id`)
- Foreign Keys: Wie referenzierte Spalte (z.B. `student_id`)

✅ **Primary Keys:**
- Immer AUTO_INCREMENT verwenden
- INT oder BIGINT
- Nie natürliche Schlüssel (E-Mail, Username) als PK

✅ **Datentypen:**
- VARCHAR statt CHAR (außer fixe Länge bekannt)
- DECIMAL für Geld (nicht FLOAT!)
- TIMESTAMP für Zeitstempel mit Auto-Update
- ENUM für fixe Werte-Listen

✅ **Constraints:**
- Foreign Keys immer definieren
- NOT NULL wo sinnvoll
- CHECK Constraints für Validierung
- UNIQUE wo Duplikate nicht erlaubt

❌ **Zu vermeiden:**
- Leerzeichen in Namen
- Reservierte Wörter als Namen (z.B. `order`, `user`)
- Mehrere Werte in einem Feld (1NF!)
- Zu breite VARCHAR (z.B. VARCHAR(10000))

## Hausaufgaben

1. **ER-Diagramm Gewässerkarte fertigstellen**
   - Mindestens 3 Entitäten
   - Beziehungen definieren
   - Attribute mit Datentypen

2. **SQL Script erstellen**
   - CREATE DATABASE
   - CREATE TABLE für alle Entitäten
   - Mit allen Constraints
   - Kommentare zu wichtigen Entscheidungen

3. **Datenbank in MariaDB anlegen**
   - HeidiSQL verwenden
   - Script ausführen
   - Mit SHOW TABLES prüfen

## Tools

- **dbdiagram.io**: ER-Diagramme online erstellen
- **draw.io**: Allgemeines Diagramm-Tool
- **HeidiSQL**: MySQL/MariaDB Client
- **MySQL Workbench**: Alternative mit ER-Designer

## Zusätzliche Ressourcen

- [SQL DDL Tutorial - W3Schools](https://www.w3schools.com/sql/sql_create_table.asp)
- [Database Normalization](https://www.geeksforgeeks.org/normal-forms-in-dbms/)
- [ER Diagram Tutorial](https://www.lucidchart.com/pages/er-diagrams)
- [MariaDB Data Types](https://mariadb.com/kb/en/data-types/)

## Nächste Schritte

In Lektion 3 lernen wir:
- SQL DML (Data Manipulation Language)
- INSERT, UPDATE, DELETE
- Einfache SELECT Queries
- Arbeiten mit der HFTM Library Datenbank

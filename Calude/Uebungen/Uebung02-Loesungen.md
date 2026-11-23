# Übungsblatt 2: Datenbankdesign & SQL DDL

## Credit 2 - Wasserkarten BE-Nord (10 Punkte)

### Aufgabe 1: Datenanalyse (3 Punkte)

Analysiere die Wasserkarten BE-Nord und erstelle eine Excel-Liste mit allen relevanten Datenfeldern.

**Zu erfassen:**
- Feldname
- Beschreibung
- Datentyp (SQL)
- Constraints (NOT NULL, UNIQUE, etc.)

**Beispiel:**
```
| Feldname      | Beschreibung           | Datentyp     | Constraints        |
|---------------|------------------------|--------------|--------------------|
| waterway_id   | Eindeutige ID          | INT          | PRIMARY KEY, AUTO  |
| name          | Name des Gewässers     | VARCHAR(100) | NOT NULL           |
| type          | Art (See, Fluss, Bach) | ENUM(...)    | NOT NULL           |
| length_km     | Länge in km            | DECIMAL(6,2) | CHECK (length > 0) |
```

**Mindestens 10 Felder erfassen!**

---

### Aufgabe 2: ER-Diagramm (4 Punkte)

Erstelle ein ER-Diagramm für die Wasserkarten-Datenbank.

**Anforderungen:**
- Mindestens **3 Entitäten**
- Mindestens **2 Beziehungen** (1:N oder N:M)
- Alle Attribute mit Datentypen
- Primary Keys markiert
- Kardinalitäten angegeben

**Mögliche Entitäten:**
- Waterways (Gewässer)
- Municipalities (Gemeinden)
- WaterSources (Quellen)
- Tributaries (Zuflüsse)
- Bridges (Brücken)

**Tool-Empfehlungen:**
- dbdiagram.io (online)
- draw.io
- Lucidchart
- Hand-gezeichnet (sauber!)

---

### Aufgabe 3: SQL DDL Script (3 Punkte)

Schreibe das komplette SQL DDL Script für deine Datenbank.

**Anforderungen:**
```sql
-- 1. Datenbank erstellen
CREATE DATABASE waterways_be_north;
USE waterways_be_north;

-- 2. Alle Tabellen mit CREATE TABLE
-- Mindestens 3 Tabellen
-- Mit allen Constraints (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK)
-- Mit sinnvollen Datentypen

-- 3. Testdaten (optional, aber empfohlen)
-- Mindestens 3 INSERT-Statements pro Tabelle
```

**Beispiel-Struktur:**
```sql
CREATE TABLE waterways (
    waterway_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type ENUM('Lake', 'River', 'Stream') NOT NULL,
    length_km DECIMAL(6,2),
    municipality_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (municipality_id) REFERENCES municipalities(municipality_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CHECK (length_km > 0)
);
```

---

## Bewertungsraster

### Aufgabe 1: Datenanalyse (3 Punkte)

| Kriterium | Punkte | Erreicht |
|-----------|--------|----------|
| Excel-Liste vorhanden | 0.5 | |
| Min. 10 Felder erfasst | 1 | |
| Datentypen korrekt | 1 | |
| Constraints sinnvoll | 0.5 | |
| **Subtotal** | **3** | |

### Aufgabe 2: ER-Diagramm (4 Punkte)

| Kriterium | Punkte | Erreicht |
|-----------|--------|----------|
| Min. 3 Entitäten | 1 | |
| Alle Attribute vorhanden | 1 | |
| Primary Keys markiert | 0.5 | |
| Beziehungen korrekt | 1 | |
| Kardinalitäten angegeben | 0.5 | |
| **Subtotal** | **4** | |

### Aufgabe 3: SQL DDL (3 Punkte)

| Kriterium | Punkte | Erreicht |
|-----------|--------|----------|
| CREATE DATABASE | 0.5 | |
| Min. 3 Tabellen | 1 | |
| PRIMARY KEYs definiert | 0.5 | |
| FOREIGN KEYs korrekt | 0.5 | |
| Constraints vollständig | 0.5 | |
| **Subtotal** | **3** | |

**Gesamtpunktzahl: 10**

---

## Lösungsbeispiel

### Beispiel-Entitäten:

**1. Waterways (Gewässer)**
- waterway_id (PK)
- name
- type (Lake/River/Stream)
- length_km
- source_location
- mouth_location
- municipality_id (FK)

**2. Municipalities (Gemeinden)**
- municipality_id (PK)
- name
- canton
- population
- area_km2

**3. Bridges (Brücken)**
- bridge_id (PK)
- name
- waterway_id (FK)
- construction_year
- bridge_type
- length_m

### Beispiel ER-Diagramm (Text):

```
┌─────────────────┐         ┌─────────────────┐
│  Municipalities │         │    Waterways    │
│─────────────────│         │─────────────────│
│ municipality_id │ 1     N │ waterway_id     │
│ name            │─────────│ name            │
│ canton          │  has    │ type            │
│ population      │         │ length_km       │
└─────────────────┘         │ municipality_id │
                            └─────────────────┘
                                    │
                                    │ 1
                                    │
                                    │ N
                                    │
                            ┌─────────────────┐
                            │     Bridges     │
                            │─────────────────│
                            │ bridge_id       │
                            │ name            │
                            │ waterway_id     │
                            │ construction_yr │
                            └─────────────────┘
```

### Beispiel SQL DDL:

```sql
-- Datenbank erstellen
CREATE DATABASE waterways_be_north
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE waterways_be_north;

-- Tabelle: Municipalities
CREATE TABLE municipalities (
    municipality_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    canton CHAR(2) NOT NULL DEFAULT 'BE',
    population INT,
    area_km2 DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE KEY (name, canton),
    CHECK (population >= 0),
    CHECK (area_km2 > 0)
);

-- Tabelle: Waterways
CREATE TABLE waterways (
    waterway_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    type ENUM('Lake', 'River', 'Stream', 'Canal') NOT NULL,
    length_km DECIMAL(6,2),
    source_location VARCHAR(100),
    mouth_location VARCHAR(100),
    municipality_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (municipality_id) 
        REFERENCES municipalities(municipality_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    
    CHECK (length_km > 0),
    INDEX idx_name (name),
    INDEX idx_type (type)
);

-- Tabelle: Bridges
CREATE TABLE bridges (
    bridge_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    waterway_id INT NOT NULL,
    construction_year YEAR,
    bridge_type ENUM('Arch', 'Beam', 'Suspension', 'Truss') DEFAULT 'Beam',
    length_m DECIMAL(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (waterway_id) 
        REFERENCES waterways(waterway_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    
    CHECK (construction_year >= 1800 AND construction_year <= YEAR(CURDATE())),
    CHECK (length_m > 0)
);

-- Testdaten
INSERT INTO municipalities (name, canton, population, area_km2) VALUES
    ('Bern', 'BE', 134000, 51.60),
    ('Biel/Bienne', 'BE', 55000, 21.13),
    ('Thun', 'BE', 43500, 21.57);

INSERT INTO waterways (name, type, length_km, municipality_id) VALUES
    ('Aare', 'River', 295.00, 1),
    ('Bielersee', 'Lake', 15.00, 2),
    ('Thunersee', 'Lake', 17.50, 3);

INSERT INTO bridges (name, waterway_id, construction_year, bridge_type, length_m) VALUES
    ('Kornhausbrücke', 1, 1898, 'Arch', 45.50),
    ('Kirchenfeldbrücke', 1, 1883, 'Arch', 229.00),
    ('Schüssinselbrücke', 1, 1970, 'Beam', 85.00);
```

---

## Tipps

### Datenanalyse:
✅ Alle sichtbaren Informationen erfassen
✅ Überlegen: Was könnte noch relevant sein?
✅ An Normalisierung denken (keine redundanten Daten)

### ER-Diagramm:
✅ Erst skizzieren, dann sauber zeichnen
✅ Auf Kardinalitäten achten
✅ Primary Keys immer markieren
✅ Klare Beziehungsnamen wählen

### SQL DDL:
✅ Mit einfacher Struktur beginnen
✅ Constraints schrittweise hinzufügen
✅ Testen in HeidiSQL/MySQL Workbench
✅ Kommentare für komplexe Constraints

---

## Häufige Fehler vermeiden

❌ **Keine Primary Keys** - Immer definieren!
❌ **Fehlende Foreign Keys** - Beziehungen müssen implementiert sein
❌ **Falsche Datentypen** - VARCHAR für Zahlen ist falsch
❌ **Keine Constraints** - NOT NULL, CHECK etc. verwenden
❌ **Spaces in Namen** - Besser: `waterway_name` statt `waterway name`
❌ **Zu generische Namen** - `id` statt `waterway_id`

---

## Abgabe

**Dateien:**
1. Excel-Datei (Datenanalyse)
2. ER-Diagramm (PNG/PDF)
3. SQL-Script (.sql Datei)

**Deadline:** Siehe Moodle
**Upload:** Als ZIP-Datei in Moodle

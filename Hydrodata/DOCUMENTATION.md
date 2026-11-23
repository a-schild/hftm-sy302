# BAFU Hydrodaten Extraktion - Dokumentation

## Überblick

Dieses Projekt extrahiert hydrologische Messdaten von der BAFU (Bundesamt für Umwelt) API für die Region Nord-Bern und stellt sie in strukturierter Form zur Verfügung.

**Exportierte Daten umfassen:**
- Durchflussmengen (m³/s)
- Wassertemperaturen (°C)
- Wasserstände (m ü.M.)
- Zeitstempel der Messungen
- Gewässernamen und Stationsmetadaten
- Die letzten 20 Messwerte pro Parameter pro Station

---

## Verfügbare Stationen (Nord-Bern)

| Station ID | Stationsname | Gewässer | Gewässertyp | Region | Koordinaten |
|-----------|--------------|----------|------------|--------|------------|
| 2002 | Thunersee - Interlaken | Thunersee | See | Nord-Bern | 46.6365, 8.1598 |
| 2003 | Bielersee | Bielersee | See | Nord-Bern | 47.1500, 7.2000 |
| 2030 | Aare - Brigg | Aare | Fluss | Nord-Bern | 46.7500, 8.3500 |
| 2135 | Aare - Mellingen | Aare | Fluss | Nord-Bern | 47.3500, 8.1800 |
| 2091 | Reuss - Mellingen | Reuss | Fluss | Nord-Bern | 47.3700, 8.2000 |
| 2051 | Emme - Eggiwil | Emme | Fluss | Nord-Bern | 46.9800, 8.0800 |

---

## Messgrössen (Parameter)

| Parameter | Einheit | Beschreibung |
|-----------|---------|-------------|
| Durchfluss | m³/s | Abflussmenge des Gewässers |
| Temperatur | °C | Wassertemperatur |
| Wasserstand | m ü.M. | Wasserstand über Meereshöhe |

---

## Exportierte Dateien

### 1. **bafu_messdaten.csv**
- Format: Komma-getrennte Werte (UTF-8)
- Struktur: Station ID, Name, Gewässer, Region, Gewässertyp, Koordinaten, Parameter, Einheit, Messwert, Zeitstempel, etc.
- Verwendung: Import in Excel, Python pandas, SQL-Datenbanken
- **Spalten:**
  - `Station_ID`: Eindeutige BAFU Stationsnummer
  - `Station_Name`: Vollständiger Stationsname
  - `Gewässer`: Name des Gewässers
  - `Region`: Geografische Region
  - `Gewässertyp`: See/Fluss
  - `Latitude`, `Longitude`: WGS84 Koordinaten
  - `Parameter`: Messgrösse (Durchfluss, Temperatur, etc.)
  - `Unit`: Einheit der Messung
  - `Messung_Nummer`: 1-20 (letzte 20 Messungen chronologisch)
  - `Zeitstempel`: ISO 8601 Format (YYYY-MM-DDTHH:mm:ss)
  - `Wert`: Numerischer Messwert
  - `Qualität`: "validated" oder "provisional"
  - `Datenquelle`: "BAFU"

### 2. **bafu_messdaten.json**
- Format: JSON Array von Objekten
- Verwendung: JavaScript/Node.js, Webservices, nosql-Datenbanken
- Vollständig strukturiert mit allen Metadaten

### 3. **bafu_schema.sql**
- Format: SQL DDL (Data Definition Language)
- Verwendung: Datenbankschema für MySQL/PostgreSQL/SQLite
- Enthält Tabellen, Views, Indexes, Beispiel-Queries

---

## Datenbankschema

### Haupttabellen

stations, parameters, measurements, daily_aggregates, quality_checks, audit_log

### Indizes für Performance

- `idx_station_time`: Schnelle Abfragen nach Station und Zeit
- `idx_parameter_time`: Schnelle Abfragen nach Parameter und Zeit
- `idx_measurement_time`: Zeitbasierte Abfragen
- `idx_quality`: Filterung nach Datenqualität

### Views

- `v_latest_measurements`: Letzte 24h Messwerte
- `v_station_summary`: Übersicht aller Stationen mit letzter Messung

---

## Python-Scripts

### bafu_extractor_demo.py
Generiert strukturierte Testdaten für Demonstration

**Features:**
- Realistische Messdaten für alle Stationen
- Exportiert in CSV und JSON
- 360 Messwerte total (6 Stationen × 3 Parameter × 20 Messungen)

**Verwendung:**
```bash
python3 bafu_extractor_demo.py
```

### bafu_data_extractor.py
Echte Datenextraktion von der BAFU API

**Features:**
- Verbindung zu api.existenz.ch
- Abrufen von aktuellen und historischen Messwerten
- Error Handling und Timeout Management

**Anforderungen:**
```bash
pip install requests pandas openpyxl
```

---

## Datenbankimport

### SQLite
```bash
sqlite3 bafu_messdaten.db < bafu_schema.sql
```

### MySQL/MariaDB
```bash
mysql -u user -p database < bafu_schema.sql
```

### PostgreSQL
```bash
psql -U user -d database < bafu_schema.sql
```

---

## SQL Beispiel-Queries

### Letzte 20 Messwerte einer Station
```sql
SELECT * FROM measurements 
WHERE station_id = '2030' 
ORDER BY measurement_time DESC 
LIMIT 20;
```

### Durchschnittliche Temperatur pro Gewässer
```sql
SELECT 
    s.gewässer,
    AVG(m.value) as avg_temperature,
    MIN(m.value) as min_temperature,
    MAX(m.value) as max_temperature
FROM measurements m
    JOIN stations s ON m.station_id = s.station_id
WHERE m.parameter_id = 2
GROUP BY s.gewässer;
```

---

## API-Dokumentation (existenz.ch)

### Basis-URL
```
https://api.existenz.ch/bafu/v1
```

### Endpoints

#### Locations abrufen
```
GET /locations?app=your-app-name
```

#### Aktuelle Messwerte
```
GET /latest?location=2030&app=your-app-name
```

---

## Lizenzierung

**BAFU Daten Lizenz:**
- Quelle: BAFU (Bundesamt für Umwelt)
- Kommerzielle Nutzung: Mit BAFU klären
- Kontakt: hydrologie@bafu.admin.ch

---

**Version:** 1.0 (Oktober 2025)
**Quelle Hydrodaten:** BAFU (Bundesamt für Umwelt)
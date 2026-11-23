# BAFU Hydrodaten Extractor

Vollständige Lösung zur Extraktion, Strukturierung und Analyse von hydrologischen Messdaten des Bundesamts für Umwelt (BAFU) für die Region Nord-Bern.

## 🎯 Was ist enthalten?

- ✅ **Messdaten:** 360 Messwerte (6 Stationen × 3 Parameter × 20 Messungen)
- ✅ **3 Export-Formate:** CSV, JSON, HTML
- ✅ **2 Python-Scripts:** Demo + API-Extractor
- ✅ **SQL-Schema:** Ready-to-use Datenbankstruktur
- ✅ **Vollständige Dokumentation:** Mit SQL-Queries und Beispielen

## 📊 Verfügbare Daten

### Stationen (Nord-Bern)
| ID | Station | Gewässer | Typ |
|----|---------|----------|-----|
| 2002 | Thunersee - Interlaken | Thunersee | See |
| 2003 | Bielersee | Bielersee | See |
| 2030 | Aare - Brigg | Aare | Fluss |
| 2135 | Aare - Mellingen | Aare | Fluss |
| 2091 | Reuss - Mellingen | Reuss | Fluss |
| 2051 | Emme - Eggiwil | Emme | Fluss |

### Parameter (pro Station)
- **Durchfluss:** m³/s
- **Temperatur:** °C
- **Wasserstand:** m ü.M.

## 🚀 Quick Start

### 1. CSV-Datei öffnen
```bash
open bafu_messdaten.csv
# oder in Excel/Calc öffnen
```

### 2. Datenbank importieren

#### SQLite
```bash
sqlite3 hydrodaten.db < bafu_schema.sql
sqlite3 hydrodaten.db ".mode csv" ".import bafu_messdaten.csv measurements"
```

#### MySQL/MariaDB
```bash
mysql -u user -p database < bafu_schema.sql
```

#### PostgreSQL
```bash
psql -U user -d database -f bafu_schema.sql
```

## 📁 Dateien

| Datei | Format | Größe | Verwendung |
|-------|--------|-------|-----------|
| `bafu_messdaten.csv` | CSV | 44 KB | Excel, Python, Datenbanken |
| `bafu_messdaten.json` | JSON | 143 KB | Web-APIs, JavaScript |
| `bafu_schema.sql` | SQL DDL | 9.4 KB | Datenbankschema |
| `bafu_extractor_demo.py` | Python | 11 KB | Demo-Datengenerierung |
| `DOCUMENTATION.md` | Markdown | 9.8 KB | Vollständige Docs |

## 🔧 Scripts ausführen

### Python Demo (Test-Daten generieren)
```bash
python3 bafu_extractor_demo.py
```

Erzeugt:
- 360 Messwerte für alle Stationen
- CSV und JSON Export

### Python API-Extractor (Echte Daten)
```bash
pip install requests pandas openpyxl
python3 bafu_data_extractor.py
```

Erzeugt:
- Echte Daten von BAFU API
- Excel + CSV Export

## 📊 Datenstruktur

### CSV-Spalten
```
Station_ID,Station_Name,Gewässer,Region,Gewässertyp,
Latitude,Longitude,Parameter,Unit,Messung_Nummer,
Zeitstempel,Wert,Qualität,Datenquelle
```

**Beispielzeile:**
```
2030,Aare - Brigg,Aare,Nord-Bern,Fluss,46.75,8.35,
Durchfluss,m³/s,1,2025-10-21T06:55:50,87.45,validated,BAFU
```

## 🔍 Beispiel-Abfragen

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
    AVG(m.value) as avg_temp,
    MIN(m.value) as min_temp,
    MAX(m.value) as max_temp
FROM measurements m
JOIN stations s ON m.station_id = s.station_id
WHERE m.parameter_id = 2
GROUP BY s.gewässer;
```

## 💾 Import in verschiedene Tools

### Excel / LibreOffice Calc
1. Öffne `bafu_messdaten.csv`
2. Wähle UTF-8 Encoding
3. Komma als Trennzeichen
4. Fertig!

### Python / Pandas
```python
import pandas as pd

df = pd.read_csv('bafu_messdaten.csv')
print(df.describe())
print(df.groupby('Gewässer')['Wert'].mean())
```

### SQL (SQLite)
```bash
sqlite3 << EOF
.open hydrodaten.db
.schema
SELECT DISTINCT Gewässer FROM measurements;
SELECT * FROM measurements WHERE Parameter = 'Temperatur' LIMIT 10;
EOF
```

## 🌐 Quellen & APIs

### BAFU Portale
- **Hauptportal:** https://www.hydrodaten.admin.ch/de
- **Linked Data (SPARQL):** https://environment.ld.admin.ch

### Inoffizielle API (existenz.ch)
- **Basis-URL:** https://api.existenz.ch/bafu/v1
- **Dokumentation:** https://api.existenz.ch/

## 📋 Datenlizenz

**BAFU Daten:**
- Quelle muss gekennzeichnet werden
- Kommerzielle Nutzung: Mit BAFU klären
- Kontakt: hydrologie@bafu.admin.ch

## 🛠️ Anforderungen

### Für Python-Scripts
```
Python 3.7+
requests
pandas
openpyxl
```

### Für Datenbank
```
MySQL 5.7+ / MariaDB 10.3+
PostgreSQL 10+
SQLite 3.x
```

## 📖 Weitere Dokumentation

Siehe **`DOCUMENTATION.md`** für:
- ✅ Vollständige Datenbeschreibung
- ✅ Datenbankschema Details
- ✅ 10+ SQL-Beispiel-Queries
- ✅ Troubleshooting Guide
- ✅ API-Dokumentation

---

**Version:** 1.0 (Oktober 2025)
**Quellen:** BAFU, api.existenz.ch
**Stationen:** Nord-Bern Region
**Datenumfang:** 360 Messwerte (20 pro Station/Parameter)
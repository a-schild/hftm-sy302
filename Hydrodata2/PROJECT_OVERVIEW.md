# Hydrodata Project - Canton Bern
## Complete Project Overview

### Project Structure

```
Hydrodata2/
│
├── hydrodata_extractor.py          # Basic data extraction script
├── hydrodata_extractor_detail.py   # Extended script (20 measurements/station)
├── db_import.py                    # Database import utility
├── config_template.py              # Configuration template
│
├── hydrodata_schema.sql            # Complete database schema
├── DATABASE_ERD.md                 # Entity-Relationship Diagram
│
└── README.md                       # Main documentation
```

---

## Quick Start Guide

### 1. Prerequisites

**Software Requirements:**
- Python 3.8 or higher
- MySQL 8.0 or PostgreSQL 13+ 
- pip (Python package manager)

**Python Libraries:**
```bash
pip install requests pandas openpyxl mysql-connector-python
```

### 2. Database Setup

**Step 1: Create Database**
```sql
CREATE DATABASE hydrodata CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'hydrodata_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON hydrodata.* TO 'hydrodata_user'@'localhost';
FLUSH PRIVILEGES;
```

**Step 2: Import Schema**
```bash
mysql -u hydrodata_user -p hydrodata < hydrodata_schema.sql
```

### 3. Data Collection

**Basic extraction (current values):**
```bash
python hydrodata_extractor.py
```

**Detailed extraction (last 20 measurements):**
```bash
python hydrodata_extractor_detail.py
```

**Output files:**
- `hydrodata_bern_TIMESTAMP.csv`
- `hydrodata_bern_TIMESTAMP.json`
- `hydrodata_detail_TIMESTAMP.xlsx`

### 4. Import to Database

```bash
python db_import.py --csv hydrodata_bern_TIMESTAMP.csv
python db_import.py --aggregate
python db_import.py --verify
```

---

## Project Components

### 1. Data Extraction Scripts

#### hydrodata_extractor.py
- Fetches current measurements from all stations
- Exports to CSV and JSON
- ~1-2 minutes runtime

**Usage:**
```python
python hydrodata_extractor.py
```

#### hydrodata_extractor_detail.py
- Fetches last 20 measurements per station
- Creates detailed reports
- Exports to CSV and Excel with multiple sheets
- ~2-3 minutes runtime

**Usage:**
```python
python hydrodata_extractor_detail.py
```

### 2. Database Schema

#### Tables:

**stations** - Master data for measuring stations
- 16 pre-configured stations in Canton Bern
- Geolocation data (latitude, longitude, elevation)
- Waterbody and location information

**measurements** - Time-series data (10-minute intervals)
- Discharge (m³/s)
- Water level (m)
- Temperature (°C)
- Precipitation (mm)
- Data quality flag

**daily_values** - Aggregated daily statistics
- Min/Max/Average values
- Automatically calculated via stored procedure
- Optimized for reporting queries

**events** - Recorded events
- Floods, low water, ice conditions
- Severity levels (info, warning, alarm)
- Start/end timestamps

#### Views:

**current_measurements** - Latest value per station
**daily_statistics** - Daily aggregates by waterbody

### 3. Database Import Tool

#### db_import.py
Multi-purpose database utility:

```bash
# Import CSV data
python db_import.py --csv data.csv

# Calculate daily aggregates
python db_import.py --aggregate

# Verify database contents
python db_import.py --verify

# Show recent measurements
python db_import.py --show --station 2135 --limit 20
```

---

## Data Sources & APIs

### Primary Source: BAFU (Federal Office for the Environment)

**Official Portal:**
- https://www.hydrodaten.admin.ch
- Open Government Data
- 10-minute measurement interval

**API Endpoint (via Existenz.ch):**
```
https://api.existenz.ch/apiv1/hydro/latest?loc={STATION_ID}
https://api.existenz.ch/apiv1/hydro/archive?loc={STATION_ID}&from={START}&to={END}
```

### Station IDs Canton Bern

| ID   | Waterbody    | Location          | Type  |
|------|--------------|-------------------|-------|
| 2135 | Aare         | Bern              | River |
| 2070 | Emme         | Emmenmatt         | River |
| 2179 | Sense        | Thörishaus        | River |
| 2215 | Saane        | Laupen            | River |
| 2208 | Lake Biel    | Ligerz            | Lake  |
| 2004 | Lake Murten  | Murten            | Lake  |

*Full list: see schema or scripts*

---

## Database Queries Examples

### Current Status All Stations
```sql
SELECT * FROM current_measurements
ORDER BY waterbody, location;
```

### Time Series (Last 24h)
```sql
SELECT timestamp, discharge_m3s, temperature_c
FROM measurements
WHERE station_id = '2135'
  AND timestamp >= NOW() - INTERVAL 24 HOUR
ORDER BY timestamp;
```

### Daily Statistics (Last Week)
```sql
SELECT date, waterbody, 
       avg_discharge, avg_temperature
FROM daily_statistics
WHERE date >= CURDATE() - INTERVAL 7 DAY
ORDER BY date DESC, waterbody;
```

### Peak Discharges (Last Month)
```sql
SELECT s.station_name, s.waterbody, 
       MAX(m.discharge_m3s) AS peak_discharge,
       MAX(m.timestamp) AS peak_time
FROM measurements m
JOIN stations s ON m.station_id = s.station_id
WHERE m.timestamp >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
GROUP BY s.station_id
ORDER BY peak_discharge DESC
LIMIT 10;
```

---

## Automation & Scheduling

### Linux/Mac (Cron)

```bash
# Edit crontab
crontab -e

# Add hourly data collection
0 * * * * cd /path/to/project && python hydrodata_extractor.py >> /var/log/hydrodata.log 2>&1

# Daily aggregate calculation
0 1 * * * cd /path/to/project && python db_import.py --aggregate >> /var/log/hydrodata.log 2>&1
```

### Windows (Task Scheduler)

1. Open Task Scheduler
2. Create Basic Task
3. Trigger: Daily at 01:00
4. Action: Start Program
5. Program: `python.exe`
6. Arguments: `C:\path\to\hydrodata_extractor.py`

---

## Visualization Options

### 1. Grafana Dashboard

**Setup:**
1. Install Grafana
2. Add MySQL data source
3. Create dashboard using views
4. Use time-series panels for hydrographs

**Example Panel Query:**
```sql
SELECT 
  timestamp as time,
  discharge_m3s as "Discharge (m³/s)",
  temperature_c as "Temperature (°C)"
FROM measurements
WHERE station_id = '2135'
  AND $__timeFilter(timestamp)
ORDER BY timestamp
```

### 2. Python Plotting

```python
import pandas as pd
import matplotlib.pyplot as plt

# Load data
df = pd.read_csv('hydrodata_bern_20231021.csv', sep=';')

# Plot
plt.figure(figsize=(12, 6))
plt.plot(df['timestamp'], df['discharge_m3s'])
plt.xlabel('Time')
plt.ylabel('Discharge (m³/s)')
plt.title('Aare River - Bern')
plt.xticks(rotation=45)
plt.tight_layout()
plt.show()
```

### 3. Excel Pivot Tables

1. Open Excel file from extractor
2. Insert > PivotTable
3. Rows: timestamp (grouped by hour/day)
4. Values: Average discharge, temperature
5. Create charts

---

## Data Quality & Validation

### Quality Levels

**provisional** - Raw API data (real-time)
- Available within 10 minutes
- Not quality checked
- May contain errors

**validated** - Quality checked
- Manual review completed
- Outliers corrected
- Available after ~2-4 months

**verified** - Officially released
- Published in yearbooks
- Legally binding
- Available after 6-12 months

### Validation Rules

```python
# Implemented in config_template.py
QUALITY_CONFIG = {
    'discharge_min': 0,
    'discharge_max': 5000,      # m³/s
    'temperature_min': -10,
    'temperature_max': 40,       # °C
    'water_level_min': 0,
    'water_level_max': 1000,    # m
}
```

---

## Troubleshooting

### Common Issues

**1. API returns no data**
- Check internet connection
- Verify station ID exists
- Try alternative stations
- Check BAFU portal manually

**2. Database connection failed**
- Verify MySQL is running
- Check credentials in config
- Ensure database exists
- Check firewall settings

**3. Import errors**
- Check CSV file format (semicolon separator)
- Verify column names match schema
- Check date/time format
- Look for NULL values

**4. Slow queries**
- Add indexes on filtered columns
- Use daily_values for reporting
- Partition large tables by year
- Archive old data

### Debug Mode

```python
# Add to script
import logging
logging.basicConfig(level=logging.DEBUG)
```

---

## Performance Optimization

### For Large Datasets (>1M records)

**1. Partitioning**
```sql
ALTER TABLE measurements
PARTITION BY RANGE (YEAR(timestamp)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026)
);
```

**2. Archiving**
```sql
-- Archive data older than 2 years
CREATE TABLE measurements_archive LIKE measurements;
INSERT INTO measurements_archive 
  SELECT * FROM measurements 
  WHERE timestamp < DATE_SUB(NOW(), INTERVAL 2 YEAR);
DELETE FROM measurements 
  WHERE timestamp < DATE_SUB(NOW(), INTERVAL 2 YEAR);
```

**3. Indexing**
```sql
-- Composite index for common queries
CREATE INDEX idx_station_time_discharge 
ON measurements(station_id, timestamp, discharge_m3s);
```

---

## Legal & Attribution

### Data License
- BAFU data: Open Government Data (OGD)
- Free for non-commercial use
- Attribution required: "Source: BAFU"

### API Usage
- Existenz.ch API: Unofficial, free
- No official rate limits
- Use parameter: `&app=your_app_name`

### Project License
- Scripts & Schema: MIT License
- Free to use and modify
- No warranty provided

---

## Support & Resources

### Official Documentation
- BAFU Hydrodata: https://www.hydrodaten.admin.ch
- API Docs: https://api.existenz.ch
- MySQL Docs: https://dev.mysql.com/doc/

### Contact
- BAFU Hydrology: hydrologie@bafu.admin.ch
- Canton Bern AWA: info.awa@be.ch

### Alternative Tools
- Mobile App: "Meine Pegel" (iOS/Android)
- SMS Service: Text "Q 2135" to 237
- LINDAS API: https://lindas.admin.ch

---

## Project Maintenance

### Daily Tasks
- Monitor data collection scripts
- Check for API errors
- Verify data quality

### Weekly Tasks
- Calculate daily aggregates
- Review database growth
- Check for data gaps

### Monthly Tasks
- Archive old data
- Optimize database tables
- Update documentation
- Backup database

### Yearly Tasks
- Review station list
- Update API endpoints
- Clean up old logs
- Performance tuning

---

## Future Enhancements

1. **Real-time Alerts**
   - Email notifications for flood warnings
   - SMS alerts for critical levels
   - Webhook integration

2. **Web Dashboard**
   - Live station map
   - Interactive charts
   - Historical comparisons

3. **Machine Learning**
   - Flood prediction models
   - Anomaly detection
   - Seasonal trend analysis

4. **Extended Coverage**
   - Add more cantons
   - Include groundwater data
   - Integrate weather forecasts

---

## Version History

**v1.0 (October 2025)**
- Initial release
- 16 stations Canton Bern
- Basic extraction and import
- MySQL schema with views

---

**End of Documentation**

For questions or contributions, contact the HFTM faculty.

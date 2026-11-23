# Hydrodata Extractor - Canton Bern

Tools for extracting and storing hydrological measurement data from Canton Bern.

## Data Sources

The data primarily comes from BAFU (Federal Office for the Environment) and is obtained via the following APIs:

1. **BAFU Hydrodata Portal**: https://www.hydrodaten.admin.ch
2. **Existenz.ch API** (unofficial): https://api.existenz.ch
3. **Canton Bern AWA**: https://www.naturgefahren.sites.be.ch

## Available Measuring Stations (Selection Canton Bern)

| Station ID | Waterbody | Location | Measurement Parameters |
|------------|-----------|----------|------------------------|
| 2135 | Aare | Bern | Discharge, Temperature, Water Level |
| 2070 | Emme | Emmenmatt | Discharge, Temperature |
| 2179 | Sense | Thörishaus | Discharge, Water Level |
| 2215 | Saane | Laupen | Discharge, Water Level |
| 2603 | Ilfis | Langnau | Discharge |
| 2208 | Lake Biel | Ligerz | Lake Level |
| 2004 | Lake Murten | Murten | Lake Level |

*Complete list: see `hydrodata_extractor.py`*

## Installation

```bash
# Install dependencies
pip install requests pandas openpyxl

# Optional: MySQL/PostgreSQL client for database import
pip install mysql-connector-python  # for MySQL
# or
pip install psycopg2-binary  # for PostgreSQL
```

## Usage

### 1. Fetch Data

```bash
python hydrodata_extractor.py
```

The script:
- Retrieves current measurements from all configured stations
- Displays a summary table
- Saves data in CSV and JSON format

### 2. Set Up Database

```bash
# MySQL/MariaDB
mysql -u root -p < hydrodata_schema.sql

# PostgreSQL
psql -U postgres -d hydrodata < hydrodata_schema.sql
```

### 3. Import Data

```bash
# Import CSV into MySQL
mysql -u root -p hydrodata << EOF
LOAD DATA LOCAL INFILE 'hydrodata_bern_YYYYMMDD_HHMMSS.csv'
INTO TABLE measurements
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(station_id, @dummy, waterbody, location, timestamp, 
 discharge_m3s, water_level_m, temperature_c);
EOF
```

## API Access Details

### Current Measurements

The BAFU APIs provide data at 10-minute intervals:

```python
import requests

# Existenz.ch API (recommended)
response = requests.get("https://api.existenz.ch/apiv1/hydro/latest?loc=2135")
data = response.json()

print(f"Temperature: {data['temperature']}°C")
print(f"Discharge: {data['flow']} m³/s")
```

### Historical Data

For historical data (up to 32 days back):

```python
from datetime import datetime, timedelta

start = (datetime.now() - timedelta(hours=48)).strftime("%Y-%m-%dT%H:%M:%S")
end = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")

url = f"https://api.existenz.ch/apiv1/hydro/archive?loc=2135&from={start}&to={end}"
response = requests.get(url)
data = response.json()
```

## Database Schema

The schema contains:

- **stations**: Master data of measuring stations
- **measurements**: Individual measurements (10-minute interval)
- **daily_values**: Aggregated daily values (Min/Max/Avg)
- **events**: Special events (floods, etc.)

### Important Views

```sql
-- Current values of all stations
SELECT * FROM current_measurements;

-- Daily statistics per waterbody
SELECT * FROM daily_statistics WHERE date >= CURDATE() - INTERVAL 7 DAY;
```

## Advanced Features

### Automatic Data Import (Cron)

```bash
# Crontab for hourly import
0 * * * * cd /path/to/project && python hydrodata_extractor.py >> /var/log/hydrodata.log 2>&1
```

### Integration with Grafana

The database can be used directly as a data source in Grafana:

1. Add MySQL/PostgreSQL as data source
2. Create dashboards with the views `current_measurements` and `daily_statistics`
3. Time series visualization for hydrographs

## Known Limitations

1. **API Availability**: The Existenz.ch API is unofficial and may fail
2. **Rate Limiting**: No official rate limit documentation available
3. **Historical Data**: Only 32 days available via API
4. **Canton Website**: The wada.sites.be.ch page has bot protection

## Alternative Data Sources

If APIs are unavailable:

1. **Directly from BAFU**: 
   - Web: https://www.hydrodaten.admin.ch
   - Mobile App: "Meine Pegel"
   - SMS Service: Send "Q 2135" to 237

2. **Canton Bern**:
   - Order form for historical data
   - Contact: hydrologie@be.ch

3. **LINDAS Linked Data Service**:
   - https://lindas.admin.ch (official Semantic Web API)

## Data Quality

- **provisional**: Raw data without quality check
- **validated**: Manually controlled
- **verified**: Officially released (in yearbooks)

Most real-time data is "provisional". Validated data is published approximately 6-12 months after collection.

## Legal Information

- BAFU data is Open Government Data
- Source attribution required: "Source: BAFU"
- Non-commercial use only for Existenz.ch API

## Support

For questions about official data sources:
- BAFU Hydrology: hydrologie@bafu.admin.ch
- Canton Bern AWA: info.awa@be.ch

## Example Queries

### Top 10 Highest Discharges in Last Month

```sql
SELECT s.station_name, s.waterbody, 
       MAX(m.discharge_m3s) AS max_discharge,
       DATE_FORMAT(MAX(m.timestamp), '%d.%m.%Y %H:%i') AS time
FROM measurements m
INNER JOIN stations s ON m.station_id = s.station_id
WHERE m.timestamp >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
GROUP BY m.station_id
ORDER BY max_discharge DESC
LIMIT 10;
```

### Temperature Development Last 7 Days

```sql
SELECT DATE(timestamp) AS date,
       AVG(temperature_c) AS average,
       MIN(temperature_c) AS minimum,
       MAX(temperature_c) AS maximum
FROM measurements
WHERE station_id = '2135'  -- Aare Bern
  AND timestamp >= DATE_SUB(NOW(), INTERVAL 7 DAY)
GROUP BY DATE(timestamp)
ORDER BY date;
```

## Database Design Best Practices

### Normalization
The schema follows 3NF (Third Normal Form):
- Station master data separated from measurements
- No redundant data storage
- Clear foreign key relationships

### Indexing Strategy
```sql
-- Optimized for time-series queries
INDEX idx_station_time (station_id, timestamp)

-- Optimized for filtering by waterbody
INDEX idx_waterbody (waterbody)

-- Unique constraint to prevent duplicates
UNIQUE KEY unique_measurement (station_id, timestamp, data_source)
```

### Performance Optimization

For large datasets (>1 million records), consider:

1. **Partitioning by time**:
```sql
ALTER TABLE measurements
PARTITION BY RANGE (YEAR(timestamp)) (
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);
```

2. **Archive old data**:
```sql
-- Move data older than 5 years to archive table
CREATE TABLE measurements_archive LIKE measurements;
INSERT INTO measurements_archive 
SELECT * FROM measurements WHERE timestamp < DATE_SUB(NOW(), INTERVAL 5 YEAR);
DELETE FROM measurements WHERE timestamp < DATE_SUB(NOW(), INTERVAL 5 YEAR);
```

3. **Use daily_values for analytics**:
```sql
-- Pre-aggregate data for faster reporting
CALL calculate_daily_values(CURDATE());
```

### Data Integrity

Implement triggers for data validation:

```sql
DELIMITER $$

CREATE TRIGGER validate_measurement BEFORE INSERT ON measurements
FOR EACH ROW
BEGIN
    -- Validate discharge range (0-5000 m³/s)
    IF NEW.discharge_m3s < 0 OR NEW.discharge_m3s > 5000 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Discharge value out of valid range';
    END IF;
    
    -- Validate temperature range (-10 to 40°C)
    IF NEW.temperature_c < -10 OR NEW.temperature_c > 40 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Temperature value out of valid range';
    END IF;
END$$

DELIMITER ;
```

## Data Pipeline Architecture

```
┌─────────────────┐
│  BAFU API       │
│  (10-min data)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Python Script  │
│  (ETL Process)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  MySQL Database │
│  • Raw data     │
│  • Aggregates   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Visualization  │
│  • Grafana      │
│  • Custom Apps  │
└─────────────────┘
```

## License

The scripts and database schema are under MIT License.
The data itself is subject to the license terms of the respective data source.

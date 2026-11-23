# Database ERD (Entity Relationship Diagram)

## Hydrodata Database Schema - Canton Bern

```
┌─────────────────────────────────────────────┐
│              STATIONS                        │
├─────────────────────────────────────────────┤
│ PK  station_id        VARCHAR(10)           │
│     station_name      VARCHAR(255)          │
│     waterbody         VARCHAR(100)          │
│     location          VARCHAR(100)          │
│     latitude          DECIMAL(10,7)         │
│     longitude         DECIMAL(10,7)         │
│     elevation_masl    INT                   │
│     operator          VARCHAR(100)          │
│     active            BOOLEAN               │
│     created_at        TIMESTAMP             │
│     updated_at        TIMESTAMP             │
└──────────────┬──────────────────────────────┘
               │
               │ 1:N
               │
┌──────────────▼──────────────────────────────┐
│           MEASUREMENTS                       │
├─────────────────────────────────────────────┤
│ PK  id               BIGINT AUTO_INCREMENT  │
│ FK  station_id       VARCHAR(10)            │
│     timestamp        DATETIME               │
│     discharge_m3s    DECIMAL(10,3)          │
│     water_level_m    DECIMAL(8,3)           │
│     temperature_c    DECIMAL(5,2)           │
│     precipitation_mm DECIMAL(6,2)           │
│     data_source      VARCHAR(50)            │
│     quality          ENUM                   │
│     remarks          TEXT                   │
│     created_at       TIMESTAMP              │
├─────────────────────────────────────────────┤
│ UQ  (station_id, timestamp, data_source)    │
│ IX  (station_id, timestamp)                 │
│ IX  (timestamp)                             │
└──────────────┬──────────────────────────────┘
               │
               │
               │
┌──────────────┴──────────────────────────────┐
│                                              │
│                                              │
┌──────────────▼──────────────────────────────┐
│           DAILY_VALUES                       │
├─────────────────────────────────────────────┤
│ PK  id               BIGINT AUTO_INCREMENT  │
│ FK  station_id       VARCHAR(10)            │
│     date             DATE                   │
│     discharge_min    DECIMAL(10,3)          │
│     discharge_max    DECIMAL(10,3)          │
│     discharge_avg    DECIMAL(10,3)          │
│     temperature_min  DECIMAL(5,2)           │
│     temperature_max  DECIMAL(5,2)           │
│     temperature_avg  DECIMAL(5,2)           │
│     precipitation_sum DECIMAL(8,2)          │
│     measurement_count INT                   │
│     created_at       TIMESTAMP              │
│     updated_at       TIMESTAMP              │
├─────────────────────────────────────────────┤
│ UQ  (station_id, date)                      │
│ IX  (station_id, date)                      │
└─────────────────────────────────────────────┘

┌──────────────┬──────────────────────────────┐
│              │                              │
│              │                              │
┌──────────────▼──────────────────────────────┐
│             EVENTS                           │
├─────────────────────────────────────────────┤
│ PK  id               BIGINT AUTO_INCREMENT  │
│ FK  station_id       VARCHAR(10)            │
│     event_type       ENUM                   │
│     start_time       DATETIME               │
│     end_time         DATETIME               │
│     peak_value       DECIMAL(10,3)          │
│     description      TEXT                   │
│     severity         ENUM                   │
│     created_at       TIMESTAMP              │
├─────────────────────────────────────────────┤
│ IX  (station_id, event_type)                │
│ IX  (start_time)                            │
└─────────────────────────────────────────────┘
```

## Views

### current_measurements
Displays the latest measurement for each active station.

**Columns:**
- station_id, station_name, waterbody, location
- timestamp, discharge_m3s, water_level_m, temperature_c
- precipitation_mm, quality, minutes_old

**Usage:**
```sql
SELECT * FROM current_measurements 
WHERE waterbody = 'Aare' 
ORDER BY location;
```

### daily_statistics
Aggregates daily statistics grouped by waterbody.

**Columns:**
- date, waterbody, station_count
- avg_discharge, max_discharge, min_discharge
- avg_temperature, total_precipitation

**Usage:**
```sql
SELECT * FROM daily_statistics 
WHERE date >= CURDATE() - INTERVAL 30 DAY
ORDER BY date DESC;
```

## Relationships

| Parent Table | Child Table    | Relationship | Constraint       |
|--------------|----------------|--------------|------------------|
| stations     | measurements   | 1:N          | CASCADE DELETE   |
| stations     | daily_values   | 1:N          | CASCADE DELETE   |
| stations     | events         | 1:N          | CASCADE DELETE   |

## Indexes Strategy

### Performance Indexes
- `idx_station_time` on measurements(station_id, timestamp) - Time series queries
- `idx_timestamp` on measurements(timestamp) - Date range filters
- `idx_waterbody` on stations(waterbody) - Filter by river/lake
- `idx_location` on stations(location) - Filter by location

### Unique Constraints
- `unique_measurement` on measurements(station_id, timestamp, data_source) - Prevent duplicates
- `unique_daily` on daily_values(station_id, date) - One record per day per station

## Data Types Explanation

| Column           | Type            | Precision | Range              | Notes                    |
|------------------|-----------------|-----------|--------------------|--------------------------|
| discharge_m3s    | DECIMAL(10,3)   | 3 digits  | 0 - 9,999,999.999  | Cubic meters per second  |
| water_level_m    | DECIMAL(8,3)    | 3 digits  | 0 - 99,999.999     | Meters above sea level   |
| temperature_c    | DECIMAL(5,2)    | 2 digits  | -999.99 - 999.99   | Celsius                  |
| precipitation_mm | DECIMAL(6,2)    | 2 digits  | 0 - 9,999.99       | Millimeters              |
| latitude         | DECIMAL(10,7)   | 7 digits  | -90.0000000 - 90.0 | WGS84 coordinates        |
| longitude        | DECIMAL(10,7)   | 7 digits  | -180.0 - 180.0     | WGS84 coordinates        |

## Enum Values

### quality
- `provisional` - Raw data, not quality checked
- `validated` - Manually verified
- `verified` - Officially released

### event_type
- `flood` - High water event
- `low_water` - Low water event
- `ice` - Ice formation
- `other` - Other events

### severity
- `info` - Informational
- `warning` - Warning level
- `alarm` - Critical level

## Storage Estimates

Based on 16 stations with 10-minute interval (144 measurements/day):

| Table         | Records/Day | Records/Year | Size/Year (est.) |
|---------------|-------------|--------------|------------------|
| measurements  | 2,304       | 841,000      | ~150 MB          |
| daily_values  | 16          | 5,840        | ~1 MB            |
| events        | 1-5         | 365-1,825    | <1 MB            |

**Total estimated storage:** ~150 MB per year for raw data

## Maintenance Procedures

### Daily
```sql
-- Calculate daily aggregates
CALL calculate_daily_values(CURDATE() - INTERVAL 1 DAY);
```

### Weekly
```sql
-- Check for data gaps
SELECT station_id, DATE(timestamp) as date, COUNT(*) as count
FROM measurements
WHERE timestamp >= CURDATE() - INTERVAL 7 DAY
GROUP BY station_id, DATE(timestamp)
HAVING count < 140;  -- Less than expected ~144 measurements/day
```

### Monthly
```sql
-- Archive old data
-- Move measurements older than 2 years to archive table
```

### Yearly
```sql
-- Optimize tables
OPTIMIZE TABLE measurements;
OPTIMIZE TABLE daily_values;
```

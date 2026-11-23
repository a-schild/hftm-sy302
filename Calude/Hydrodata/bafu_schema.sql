-- ===============================================================================
-- BAFU Hydrodaten - Datenbankschema
-- Für relationale Datenbanken (MySQL, PostgreSQL, SQLite, etc.)
-- ===============================================================================

-- Tabelle: Messstationen
CREATE TABLE IF NOT EXISTS stations (
    station_id VARCHAR(10) PRIMARY KEY,
    station_name VARCHAR(255) NOT NULL,
    gewässer VARCHAR(100) NOT NULL,
    gewässer_type ENUM('Fluss', 'See', 'Bach') NOT NULL,
    region VARCHAR(100),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    elevation_m INT,
    area_km2 DECIMAL(12, 2),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_gewässer (gewässer),
    INDEX idx_region (region),
    INDEX idx_status (status)
);

-- Tabelle: Parameter/Messgrössen
CREATE TABLE IF NOT EXISTS parameters (
    parameter_id INT PRIMARY KEY AUTO_INCREMENT,
    parameter_name VARCHAR(100) NOT NULL UNIQUE,
    unit VARCHAR(20) NOT NULL,
    description TEXT,
    min_value DECIMAL(15, 4),
    max_value DECIMAL(15, 4),
    measurement_type ENUM('discharge', 'temperature', 'water_level', 'precipitation', 'other'),
    
    INDEX idx_parameter_name (parameter_name)
);

-- Tabelle: Messwerte/Messungen
CREATE TABLE IF NOT EXISTS measurements (
    measurement_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    station_id VARCHAR(10) NOT NULL,
    parameter_id INT NOT NULL,
    measurement_time DATETIME NOT NULL,
    value DECIMAL(15, 4) NOT NULL,
    quality_code VARCHAR(20) DEFAULT 'validated',
    data_source VARCHAR(50) DEFAULT 'BAFU',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (station_id) REFERENCES stations(station_id),
    FOREIGN KEY (parameter_id) REFERENCES parameters(parameter_id),
    
    INDEX idx_station_time (station_id, measurement_time),
    INDEX idx_parameter_time (parameter_id, measurement_time),
    INDEX idx_measurement_time (measurement_time),
    INDEX idx_quality (quality_code)
);

-- Tabelle: Gewässer/Gewässernetz
CREATE TABLE IF NOT EXISTS water_bodies (
    water_body_id INT PRIMARY KEY AUTO_INCREMENT,
    water_body_name VARCHAR(100) NOT NULL UNIQUE,
    water_body_type VARCHAR(20) NOT NULL,
    region VARCHAR(100),
    country VARCHAR(50) DEFAULT 'Switzerland',
    catchment_area_km2 DECIMAL(12, 2),
    average_discharge_m3s DECIMAL(10, 2),
    description TEXT,
    
    INDEX idx_name (water_body_name),
    INDEX idx_type (water_body_type),
    INDEX idx_region (region)
);

-- Tabelle: Tägliche Aggregate
CREATE TABLE IF NOT EXISTS daily_aggregates (
    aggregate_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    station_id VARCHAR(10) NOT NULL,
    parameter_id INT NOT NULL,
    measurement_date DATE NOT NULL,
    min_value DECIMAL(15, 4),
    max_value DECIMAL(15, 4),
    avg_value DECIMAL(15, 4),
    count_measurements INT,
    sum_value DECIMAL(18, 4),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (station_id) REFERENCES stations(station_id),
    FOREIGN KEY (parameter_id) REFERENCES parameters(parameter_id),
    
    UNIQUE KEY unique_daily (station_id, parameter_id, measurement_date),
    INDEX idx_station_date (station_id, measurement_date),
    INDEX idx_parameter_date (parameter_id, measurement_date)
);

-- Tabelle: Qualitätskontrolle
CREATE TABLE IF NOT EXISTS quality_checks (
    check_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    station_id VARCHAR(10),
    parameter_id INT,
    check_date DATETIME,
    check_type VARCHAR(50),
    result VARCHAR(20),
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (station_id) REFERENCES stations(station_id),
    FOREIGN KEY (parameter_id) REFERENCES parameters(parameter_id),
    
    INDEX idx_station_check (station_id, check_date),
    INDEX idx_check_type (check_type)
);

-- Tabelle: Audit Log
CREATE TABLE IF NOT EXISTS audit_log (
    log_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    record_id VARCHAR(100),
    action VARCHAR(10),
    old_values JSON,
    new_values JSON,
    user VARCHAR(100),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_table_action (table_name, action),
    INDEX idx_timestamp (timestamp)
);

-- ===============================================================================
-- VIEWS für einfachen Datenzugriff
-- ===============================================================================

-- View: Aktuelle Messwerte (letzte 24h)
CREATE VIEW v_latest_measurements AS
SELECT 
    s.station_id,
    s.station_name,
    s.gewässer,
    p.parameter_name,
    p.unit,
    m.measurement_time,
    m.value,
    m.quality_code,
    HOUR(NOW()) - HOUR(m.measurement_time) AS hours_since_measurement
FROM measurements m
    JOIN stations s ON m.station_id = s.station_id
    JOIN parameters p ON m.parameter_id = p.parameter_id
WHERE m.measurement_time > NOW() - INTERVAL 24 HOUR
ORDER BY m.station_id, m.parameter_id, m.measurement_time DESC;

-- View: Stationen mit Koordinaten und letzten Messwerten
CREATE VIEW v_station_summary AS
SELECT 
    s.station_id,
    s.station_name,
    s.gewässer,
    s.region,
    s.latitude,
    s.longitude,
    COUNT(DISTINCT m.parameter_id) AS active_parameters,
    MAX(m.measurement_time) AS last_measurement_time,
    DATEDIFF(NOW(), MAX(m.measurement_time)) AS days_since_last_measurement
FROM stations s
    LEFT JOIN measurements m ON s.station_id = m.station_id
        AND m.measurement_time > NOW() - INTERVAL 30 DAY
WHERE s.status = 'active'
GROUP BY s.station_id, s.station_name, s.gewässer, s.region, s.latitude, s.longitude;

-- ===============================================================================
-- Beispiel INSERT Statements
-- ===============================================================================

-- Einfügen von Parametern
INSERT INTO parameters (parameter_name, unit, measurement_type, description)
VALUES
    ('Durchfluss', 'm³/s', 'discharge', 'Abflussmenge des Gewässers'),
    ('Temperatur', '°C', 'temperature', 'Wassertemperatur'),
    ('Wasserstand', 'm ü.M.', 'water_level', 'Wasserstand über Meereshöhe'),
    ('Niederschlag', 'mm', 'precipitation', 'Niederschlagsmenge');

-- Einfügen von Stationen (Beispiele für Nord-Bern)
INSERT INTO stations (station_id, station_name, gewässer, gewässer_type, region, latitude, longitude)
VALUES
    ('2002', 'Thunersee - Interlaken', 'Thunersee', 'See', 'Nord-Bern', 46.6365, 8.1598),
    ('2003', 'Bielersee', 'Bielersee', 'See', 'Nord-Bern', 47.1500, 7.2000),
    ('2030', 'Aare - Brigg', 'Aare', 'Fluss', 'Nord-Bern', 46.7500, 8.3500),
    ('2135', 'Aare - Mellingen', 'Aare', 'Fluss', 'Nord-Bern', 47.3500, 8.1800),
    ('2091', 'Reuss - Mellingen', 'Reuss', 'Fluss', 'Nord-Bern', 47.3700, 8.2000),
    ('2051', 'Emme - Eggiwil', 'Emme', 'Fluss', 'Nord-Bern', 46.9800, 8.0800);

-- ===============================================================================
-- Beispiel QUERIES
-- ===============================================================================

-- 1. Letzten 20 Messwerte für eine Station und Parameter
-- SELECT * FROM measurements 
-- WHERE station_id = '2030' AND parameter_id = 1
-- ORDER BY measurement_time DESC 
-- LIMIT 20;

-- 2. Durchschnittliche Temperatur pro Gewässer in den letzten 7 Tagen
-- SELECT 
--     s.gewässer,
--     p.parameter_name,
--     COUNT(*) as count,
--     AVG(m.value) as avg_value,
--     MIN(m.value) as min_value,
--     MAX(m.value) as max_value
-- FROM measurements m
--     JOIN stations s ON m.station_id = s.station_id
--     JOIN parameters p ON m.parameter_id = p.parameter_id
-- WHERE m.measurement_time > NOW() - INTERVAL 7 DAY
--   AND p.parameter_id = 2 -- Temperatur
-- GROUP BY s.gewässer, p.parameter_name;

-- 3. Stationen mit neuesten Messwerten
-- SELECT * FROM v_station_summary ORDER BY last_measurement_time DESC;

-- 4. Zeitreihe für Datenanalyse
-- SELECT 
--     DATE(m.measurement_time) as date,
--     p.parameter_name,
--     AVG(m.value) as daily_avg,
--     MIN(m.value) as daily_min,
--     MAX(m.value) as daily_max
-- FROM measurements m
--     JOIN parameters p ON m.parameter_id = p.parameter_id
-- WHERE m.station_id = '2030'
-- GROUP BY DATE(m.measurement_time), p.parameter_id
-- ORDER BY date, p.parameter_id;
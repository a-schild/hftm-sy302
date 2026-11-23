-- Database schema for hydrodata Canton Bern
-- Compatible with MySQL/MariaDB and PostgreSQL

-- Table for measuring stations
CREATE TABLE IF NOT EXISTS stations (
    station_id VARCHAR(10) PRIMARY KEY,
    station_name VARCHAR(255) NOT NULL,
    waterbody VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    elevation_masl INT,
    operator VARCHAR(100) DEFAULT 'BAFU',
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_waterbody (waterbody),
    INDEX idx_location (location)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for measurements
CREATE TABLE IF NOT EXISTS measurements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(10) NOT NULL,
    timestamp DATETIME NOT NULL,
    discharge_m3s DECIMAL(10, 3),
    water_level_m DECIMAL(8, 3),
    temperature_c DECIMAL(5, 2),
    precipitation_mm DECIMAL(6, 2),
    data_source VARCHAR(50) DEFAULT 'BAFU',
    quality ENUM('provisional', 'validated', 'verified') DEFAULT 'provisional',
    remarks TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE,
    INDEX idx_station_time (station_id, timestamp),
    INDEX idx_timestamp (timestamp),
    UNIQUE KEY unique_measurement (station_id, timestamp, data_source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for aggregated daily values
CREATE TABLE IF NOT EXISTS daily_values (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(10) NOT NULL,
    date DATE NOT NULL,
    discharge_min DECIMAL(10, 3),
    discharge_max DECIMAL(10, 3),
    discharge_avg DECIMAL(10, 3),
    temperature_min DECIMAL(5, 2),
    temperature_max DECIMAL(5, 2),
    temperature_avg DECIMAL(5, 2),
    precipitation_sum DECIMAL(8, 2),
    measurement_count INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE,
    INDEX idx_station_date (station_id, date),
    UNIQUE KEY unique_daily (station_id, date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table for events (floods, low water, etc.)
CREATE TABLE IF NOT EXISTS events (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    station_id VARCHAR(10) NOT NULL,
    event_type ENUM('flood', 'low_water', 'ice', 'other') NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME,
    peak_value DECIMAL(10, 3),
    description TEXT,
    severity ENUM('info', 'warning', 'alarm') DEFAULT 'info',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (station_id) REFERENCES stations(station_id) ON DELETE CASCADE,
    INDEX idx_station_event (station_id, event_type),
    INDEX idx_start (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- View for current measurements (last measurement per station)
CREATE OR REPLACE VIEW current_measurements AS
SELECT 
    m.station_id,
    s.station_name,
    s.waterbody,
    s.location,
    m.timestamp,
    m.discharge_m3s,
    m.water_level_m,
    m.temperature_c,
    m.precipitation_mm,
    m.quality,
    TIMESTAMPDIFF(MINUTE, m.timestamp, NOW()) AS minutes_old
FROM measurements m
INNER JOIN stations s ON m.station_id = s.station_id
INNER JOIN (
    SELECT station_id, MAX(timestamp) AS max_time
    FROM measurements
    GROUP BY station_id
) latest ON m.station_id = latest.station_id AND m.timestamp = latest.max_time
WHERE s.active = TRUE
ORDER BY s.waterbody, s.location;

-- View for daily statistics
CREATE OR REPLACE VIEW daily_statistics AS
SELECT 
    d.date,
    s.waterbody,
    COUNT(DISTINCT d.station_id) AS station_count,
    ROUND(AVG(d.discharge_avg), 2) AS avg_discharge,
    ROUND(MAX(d.discharge_max), 2) AS max_discharge,
    ROUND(MIN(d.discharge_min), 2) AS min_discharge,
    ROUND(AVG(d.temperature_avg), 2) AS avg_temperature,
    ROUND(SUM(d.precipitation_sum), 2) AS total_precipitation
FROM daily_values d
INNER JOIN stations s ON d.station_id = s.station_id
WHERE s.active = TRUE
GROUP BY d.date, s.waterbody
ORDER BY d.date DESC, s.waterbody;

-- Stored procedure to calculate daily values
DELIMITER $$

CREATE PROCEDURE calculate_daily_values(IN p_date DATE)
BEGIN
    DELETE FROM daily_values WHERE date = p_date;
    
    INSERT INTO daily_values (
        station_id, date,
        discharge_min, discharge_max, discharge_avg,
        temperature_min, temperature_max, temperature_avg,
        precipitation_sum, measurement_count
    )
    SELECT 
        station_id,
        DATE(timestamp) AS date,
        MIN(discharge_m3s) AS discharge_min,
        MAX(discharge_m3s) AS discharge_max,
        AVG(discharge_m3s) AS discharge_avg,
        MIN(temperature_c) AS temperature_min,
        MAX(temperature_c) AS temperature_max,
        AVG(temperature_c) AS temperature_avg,
        SUM(precipitation_mm) AS precipitation_sum,
        COUNT(*) AS measurement_count
    FROM measurements
    WHERE DATE(timestamp) = p_date
    GROUP BY station_id, DATE(timestamp);
END$$

DELIMITER ;

-- Example queries

-- 1. Current measurements of all stations
-- SELECT * FROM current_measurements;

-- 2. Time series for a station (last 24 hours)
-- SELECT timestamp, discharge_m3s, temperature_c 
-- FROM measurements 
-- WHERE station_id = '2135' 
--   AND timestamp >= NOW() - INTERVAL 24 HOUR
-- ORDER BY timestamp;

-- 3. Highest discharges of the last month
-- SELECT s.station_name, s.waterbody, MAX(m.discharge_m3s) AS max_discharge
-- FROM measurements m
-- INNER JOIN stations s ON m.station_id = s.station_id
-- WHERE m.timestamp >= DATE_SUB(NOW(), INTERVAL 1 MONTH)
-- GROUP BY m.station_id, s.station_name, s.waterbody
-- ORDER BY max_discharge DESC
-- LIMIT 10;

-- 4. Average daily temperatures per waterbody
-- SELECT waterbody, date, avg_temperature
-- FROM daily_statistics
-- WHERE date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
-- ORDER BY date DESC, waterbody;

-- 5. Events of the last 30 days
-- SELECT e.event_type, s.station_name, s.waterbody, 
--        e.start_time, e.end_time, e.peak_value, e.description
-- FROM events e
-- INNER JOIN stations s ON e.station_id = s.station_id
-- WHERE e.start_time >= DATE_SUB(NOW(), INTERVAL 30 DAY)
-- ORDER BY e.start_time DESC;

-- Initial data for measuring stations (examples from Canton Bern)
INSERT INTO stations (station_id, station_name, waterbody, location) VALUES
('2135', 'Aare - Bern', 'Aare', 'Bern'),
('2179', 'Sense - Thörishaus', 'Sense', 'Thörishaus'),
('2215', 'Saane - Laupen', 'Saane', 'Laupen'),
('2070', 'Emme - Emmenmatt', 'Emme', 'Emmenmatt'),
('2409', 'Emme - Eggiwil', 'Emme', 'Eggiwil'),
('2155', 'Emme - Wiler + Werkkanal', 'Emme', 'Wiler'),
('2603', 'Ilfis - Langnau', 'Ilfis', 'Langnau'),
('2343', 'Langete - Huttwil', 'Langete', 'Huttwil'),
('2307', 'Suze - Sonceboz', 'Suze', 'Sonceboz'),
('2122', 'Birse - Moutier', 'Birse', 'Moutier'),
('2063', 'Aare - Murgenthal', 'Aare', 'Murgenthal'),
('2085', 'Aare - Hagneck', 'Aare', 'Hagneck'),
('2029', 'Aare - Brügg Aegerten', 'Aare', 'Brügg Aegerten'),
('2208', 'Lake Biel - Ligerz', 'Lake Biel', 'Ligerz'),
('2004', 'Lake Murten - Murten', 'Lake Murten', 'Murten'),
('2480', 'Areuse - Boudry', 'Areuse', 'Boudry')
ON DUPLICATE KEY UPDATE station_name = VALUES(station_name);

# Configuration File for Hydrodata Extractor
# Copy this file to config.py and adjust the settings

# Database Configuration
DATABASE_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'hydrodata_user',
    'password': 'your_password_here',
    'database': 'hydrodata',
    'charset': 'utf8mb4',
    'autocommit': True
}

# PostgreSQL alternative
# DATABASE_CONFIG = {
#     'host': 'localhost',
#     'port': 5432,
#     'user': 'hydrodata_user',
#     'password': 'your_password_here',
#     'database': 'hydrodata'
# }

# API Configuration
API_CONFIG = {
    'base_url': 'https://api.existenz.ch/apiv1',
    'timeout': 15,  # seconds
    'retry_attempts': 3,
    'retry_delay': 2,  # seconds
    'app_name': 'hydrodata_extractor_hftm'
}

# Data Collection Settings
COLLECTION_CONFIG = {
    'interval_minutes': 60,  # How often to collect data
    'history_hours': 4,      # Hours of history to fetch
    'max_measurements': 20,   # Maximum measurements per station
}

# Stations Configuration
# You can enable/disable specific stations
ENABLED_STATIONS = [
    '2135',  # Aare - Bern
    '2179',  # Sense - Thörishaus
    '2215',  # Saane - Laupen
    '2070',  # Emme - Emmenmatt
    '2409',  # Emme - Eggiwil
    '2155',  # Emme - Wiler
    '2603',  # Ilfis - Langnau
    '2343',  # Langete - Huttwil
    '2307',  # Suze - Sonceboz
    '2122',  # Birse - Moutier
    '2063',  # Aare - Murgenthal
    '2085',  # Aare - Hagneck
    '2029',  # Aare - Brügg Aegerten
    '2208',  # Lake Biel - Ligerz
    '2004',  # Lake Murten - Murten
]

# Logging Configuration
LOGGING_CONFIG = {
    'level': 'INFO',  # DEBUG, INFO, WARNING, ERROR, CRITICAL
    'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    'file': 'hydrodata.log',
    'console': True,
    'max_bytes': 10485760,  # 10 MB
    'backup_count': 5
}

# Export Configuration
EXPORT_CONFIG = {
    'csv_separator': ';',
    'csv_decimal': '.',
    'date_format': '%Y-%m-%d %H:%M:%S',
    'output_directory': './output',
    'filename_prefix': 'hydrodata_bern'
}

# Alert Configuration (for future use)
ALERT_CONFIG = {
    'enable_alerts': False,
    'email_smtp_server': 'smtp.example.com',
    'email_smtp_port': 587,
    'email_sender': 'alerts@example.com',
    'email_recipients': ['admin@example.com'],
    'alert_thresholds': {
        'flood_warning_m3s': 500,
        'flood_alarm_m3s': 1000,
        'low_water_warning_m3s': 10,
        'temperature_alarm_c': 25
    }
}

# Data Quality Rules
QUALITY_CONFIG = {
    'discharge_min': 0,
    'discharge_max': 5000,      # m³/s
    'temperature_min': -10,
    'temperature_max': 40,       # °C
    'water_level_min': 0,
    'water_level_max': 1000,    # m
    'precipitation_max': 500,    # mm
}

# Backup Configuration
BACKUP_CONFIG = {
    'enable_backup': True,
    'backup_directory': './backups',
    'backup_interval_days': 7,
    'keep_backups': 4  # Number of backups to keep
}

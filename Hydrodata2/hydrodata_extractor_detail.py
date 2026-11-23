#!/usr/bin/env python3
"""
Extended version: Fetches the last 20 measurements per station.
"""

import requests
import json
import pandas as pd
from datetime import datetime, timedelta
from typing import List, Dict, Optional

# Measuring stations Canton Bern
STATIONS_BERN = {
    "2135": {"name": "Aare - Bern", "waterbody": "Aare", "location": "Bern"},
    "2179": {"name": "Sense - Thörishaus", "waterbody": "Sense", "location": "Thörishaus"},
    "2215": {"name": "Saane - Laupen", "waterbody": "Saane", "location": "Laupen"},
    "2070": {"name": "Emme - Emmenmatt", "waterbody": "Emme", "location": "Emmenmatt"},
    "2409": {"name": "Emme - Eggiwil", "waterbody": "Emme", "location": "Eggiwil"},
    "2155": {"name": "Emme - Wiler", "waterbody": "Emme", "location": "Wiler"},
    "2603": {"name": "Ilfis - Langnau", "waterbody": "Ilfis", "location": "Langnau"},
    "2343": {"name": "Langete - Huttwil", "waterbody": "Langete", "location": "Huttwil"},
    "2307": {"name": "Suze - Sonceboz", "waterbody": "Suze", "location": "Sonceboz"},
    "2122": {"name": "Birse - Moutier", "waterbody": "Birse", "location": "Moutier"},
    "2063": {"name": "Aare - Murgenthal", "waterbody": "Aare", "location": "Murgenthal"},
    "2085": {"name": "Aare - Hagneck", "waterbody": "Aare", "location": "Hagneck"},
    "2029": {"name": "Aare - Brügg", "waterbody": "Aare", "location": "Brügg Aegerten"},
    "2208": {"name": "Lake Biel - Ligerz", "waterbody": "Lake Biel", "location": "Ligerz"},
    "2004": {"name": "Lake Murten - Murten", "waterbody": "Lake Murten", "location": "Murten"},
}

def fetch_historical_data(station_id: str, hours: int = 4) -> Optional[List[Dict]]:
    """
    Fetches historical data for the last N hours (approx. 20-24 measurements with 10-min interval).
    """
    end_time = datetime.now()
    start_time = end_time - timedelta(hours=hours)
    
    start_str = start_time.strftime("%Y-%m-%dT%H:%M:%S")
    end_str = end_time.strftime("%Y-%m-%dT%H:%M:%S")
    
    # Try multiple API endpoints
    api_urls = [
        f"https://api.existenz.ch/apiv1/hydro/archive?loc={station_id}&from={start_str}&to={end_str}",
    ]
    
    for api_url in api_urls:
        try:
            response = requests.get(api_url, timeout=15)
            if response.status_code == 200:
                data = response.json()
                return parse_historical_response(data, station_id)
        except Exception as e:
            continue
    
    return None

def parse_historical_response(data: Dict, station_id: str) -> List[Dict]:
    """
    Parses the API response and extracts measurements.
    """
    results = []
    
    if not data or 'data' not in data:
        return results
    
    data_dict = data['data']
    dataformat = data.get('dataformat', [])
    
    # Extract timestamps
    if 'datetime' not in data_dict:
        return results
    
    timestamps = data_dict['datetime']
    num_values = len(timestamps)
    
    # Take last 20 values
    start_idx = max(0, num_values - 20)
    
    for i in range(start_idx, num_values):
        record = {
            'station_id': station_id,
            'timestamp': timestamps[i],
            'discharge_m3s': None,
            'temperature_c': None,
            'water_level_m': None
        }
        
        # Extract available parameters
        if 'flow' in data_dict and i < len(data_dict['flow']):
            record['discharge_m3s'] = data_dict['flow'][i]
        
        if 'temperature' in data_dict and i < len(data_dict['temperature']):
            record['temperature_c'] = data_dict['temperature'][i]
        
        if 'height' in data_dict and i < len(data_dict['height']):
            record['water_level_m'] = data_dict['height'][i]
        
        results.append(record)
    
    return results

def create_detailed_report(station_id: str, station_info: Dict, measurements: List[Dict]) -> str:
    """
    Creates a detailed report for a station.
    """
    if not measurements:
        return f"\nNo data for {station_info['name']}\n"
    
    report = []
    report.append("\n" + "="*80)
    report.append(f"STATION: {station_info['name']}")
    report.append(f"Waterbody: {station_info['waterbody']}")
    report.append(f"Location: {station_info['location']}")
    report.append(f"Station ID: {station_id}")
    report.append("="*80)
    
    # Create table
    df = pd.DataFrame(measurements)
    
    # Only relevant columns
    cols_to_show = ['timestamp', 'discharge_m3s', 'temperature_c', 'water_level_m']
    df_display = df[cols_to_show].copy()
    
    # Formatting
    df_display['timestamp'] = pd.to_datetime(df_display['timestamp']).dt.strftime('%d.%m.%Y %H:%M')
    
    # Rounding
    for col in ['discharge_m3s', 'temperature_c', 'water_level_m']:
        if col in df_display.columns:
            df_display[col] = df_display[col].round(2)
    
    # Rename column headers
    df_display.columns = ['Timestamp', 'Discharge (m³/s)', 'Temp. (°C)', 'Water Level (m)']
    
    report.append("\nLast 20 measurements:")
    report.append(df_display.to_string(index=False))
    
    # Statistics
    if 'discharge_m3s' in df.columns and df['discharge_m3s'].notna().any():
        report.append(f"\nDischarge - Min: {df['discharge_m3s'].min():.2f} | " +
                     f"Max: {df['discharge_m3s'].max():.2f} | " +
                     f"Avg: {df['discharge_m3s'].mean():.2f} m³/s")
    
    if 'temperature_c' in df.columns and df['temperature_c'].notna().any():
        report.append(f"Temperature - Min: {df['temperature_c'].min():.2f} | " +
                     f"Max: {df['temperature_c'].max():.2f} | " +
                     f"Avg: {df['temperature_c'].mean():.2f} °C")
    
    report.append("")
    
    return "\n".join(report)

def export_to_csv(all_data: List[Dict], filename: str = "hydrodata_detail"):
    """
    Exports all data to CSV.
    """
    if not all_data:
        return
    
    df = pd.DataFrame(all_data)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename_full = f"{filename}_{timestamp}.csv"
    
    df.to_csv(filename_full, index=False, encoding='utf-8', sep=';')
    print(f"\nData exported to: {filename_full}")

def export_to_excel(station_data: Dict[str, List[Dict]], filename: str = "hydrodata_detail"):
    """
    Exports data to Excel with one sheet per station.
    """
    if not station_data:
        return
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename_full = f"{filename}_{timestamp}.xlsx"
    
    with pd.ExcelWriter(filename_full, engine='openpyxl') as writer:
        for station_id, measurements in station_data.items():
            if measurements:
                df = pd.DataFrame(measurements)
                # Sheet name from first 31 characters of station name
                sheet_name = STATIONS_BERN.get(station_id, {}).get('name', station_id)[:31]
                df.to_excel(writer, sheet_name=sheet_name, index=False)
    
    print(f"Excel exported to: {filename_full}")

def main():
    print("="*80)
    print("HYDRODATA CANTON BERN - LAST 20 MEASUREMENTS PER STATION")
    print("="*80)
    
    all_data = []
    station_data = {}
    successful = 0
    
    # Iterate through all stations
    for station_id, info in STATIONS_BERN.items():
        print(f"\nFetching data for: {info['name']} (ID: {station_id})...", end=" ")
        
        measurements = fetch_historical_data(station_id, hours=4)
        
        if measurements and len(measurements) > 0:
            print(f"✓ ({len(measurements)} measurements)")
            
            # Add station information
            for measurement in measurements:
                measurement.update({
                    'station_name': info['name'],
                    'waterbody': info['waterbody'],
                    'location': info['location']
                })
                all_data.append(measurement)
            
            station_data[station_id] = measurements
            successful += 1
            
            # Show detailed report
            report = create_detailed_report(station_id, info, measurements)
            print(report)
        else:
            print("✗ (No data available)")
    
    print("\n" + "="*80)
    print(f"SUMMARY: {successful}/{len(STATIONS_BERN)} stations successfully retrieved")
    print("="*80)
    
    if all_data:
        # Export data
        export_to_csv(all_data)
        
        try:
            export_to_excel(station_data)
        except Exception as e:
            print(f"Excel export failed: {e}")
        
        print(f"\nTotal {len(all_data)} measurements captured.")
    else:
        print("\nNO DATA AVAILABLE")
        print("\nAlternative data sources:")
        print("1. BAFU Hydrodata: https://www.hydrodaten.admin.ch")
        print("2. Canton Bern: https://www.naturgefahren.sites.be.ch")
        print("3. Mobile app 'Meine Pegel'")

if __name__ == "__main__":
    main()

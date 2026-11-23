#!/usr/bin/env python3
"""
Script for extracting water data (discharge, temperature, water levels) 
from the BAFU Hydrology API for Canton Bern.

Data is saved as CSV/JSON and can be imported into a database.
"""

import requests
import json
import csv
from datetime import datetime, timedelta
import pandas as pd

# Known measuring stations in Canton Bern (extracted from map)
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
    "2029": {"name": "Aare - Brügg Aegerten", "waterbody": "Aare", "location": "Brügg Aegerten"},
    "2208": {"name": "Lake Biel - Ligerz", "waterbody": "Lake Biel", "location": "Ligerz"},
    "2004": {"name": "Lake Murten - Murten", "waterbody": "Lake Murten", "location": "Murten"},
    "2480": {"name": "Areuse - Boudry", "waterbody": "Areuse", "location": "Boudry"},
}

def fetch_station_current(station_id):
    """
    Fetches the latest measurements for a station from the BAFU API.
    The API is publicly accessible via hydrodaten.admin.ch
    """
    # Alternative API endpoints
    apis = [
        f"https://api.existenz.ch/apiv1/hydro/latest?loc={station_id}",
        f"https://www.hydrodaten.admin.ch/lhg/sdi/ogc_schmrz/smr_{station_id}.json"
    ]
    
    for api_url in apis:
        try:
            response = requests.get(api_url, timeout=10)
            if response.status_code == 200:
                return response.json()
        except:
            continue
    
    return None

def fetch_station_history(station_id, hours=48):
    """
    Fetches historical measurements for the last N hours.
    """
    # Calculate time range
    end_time = datetime.now()
    start_time = end_time - timedelta(hours=hours)
    
    # Format for API
    start_str = start_time.strftime("%Y-%m-%dT%H:%M:%S")
    end_str = end_time.strftime("%Y-%m-%dT%H:%M:%S")
    
    try:
        # Use existenz.ch API for historical data
        api_url = f"https://api.existenz.ch/apiv1/hydro/archive?loc={station_id}&from={start_str}&to={end_str}"
        response = requests.get(api_url, timeout=15)
        
        if response.status_code == 200:
            return response.json()
    except Exception as e:
        print(f"Error fetching history for station {station_id}: {e}")
    
    return None

def extract_data_from_response(station_id, data, station_info):
    """
    Extracts relevant data from the API response.
    """
    if not data:
        return None
    
    result = {
        "station_id": station_id,
        "station_name": station_info["name"],
        "waterbody": station_info["waterbody"],
        "location": station_info["location"],
        "timestamp": None,
        "discharge_m3s": None,
        "water_level_m": None,
        "temperature_c": None,
    }
    
    # Parsing depending on API format
    if "data" in data:
        # existenz.ch format
        result["timestamp"] = data.get("datetime", "")
        result["discharge_m3s"] = data.get("flow")
        result["temperature_c"] = data.get("temperature")
        result["water_level_m"] = data.get("height")
    elif "properties" in data:
        # hydrodaten.admin.ch format
        props = data.get("properties", {})
        result["timestamp"] = props.get("time", "")
        result["discharge_m3s"] = props.get("discharge")
        result["temperature_c"] = props.get("temperature")
        result["water_level_m"] = props.get("level")
    
    return result

def create_summary_table(all_data):
    """
    Creates a summary table from all station data.
    """
    if not all_data:
        return None
    
    # Convert to DataFrame for better presentation
    df = pd.DataFrame(all_data)
    
    # Sort by waterbody and location
    df = df.sort_values(by=["waterbody", "location"])
    
    return df

def save_data(data, format="csv", filename="hydrodata"):
    """
    Saves data in various formats.
    """
    if not data:
        print("No data available to save.")
        return
    
    df = pd.DataFrame(data)
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    if format == "csv":
        filename_full = f"{filename}_{timestamp}.csv"
        df.to_csv(filename_full, index=False, encoding='utf-8')
        print(f"Data saved to: {filename_full}")
    
    elif format == "json":
        filename_full = f"{filename}_{timestamp}.json"
        df.to_json(filename_full, orient='records', indent=2, force_ascii=False)
        print(f"Data saved to: {filename_full}")
    
    elif format == "excel":
        filename_full = f"{filename}_{timestamp}.xlsx"
        df.to_excel(filename_full, index=False, engine='openpyxl')
        print(f"Data saved to: {filename_full}")

def main():
    """
    Main function to fetch and display water data.
    """
    print("=" * 80)
    print("HYDRODATA CANTON BERN - CURRENT MEASUREMENTS")
    print("=" * 80)
    print()
    
    all_data = []
    
    # Iterate through all stations
    for station_id, info in STATIONS_BERN.items():
        print(f"Fetching data for: {info['name']} (ID: {station_id})...", end=" ")
        
        # Fetch current data
        current_data = fetch_station_current(station_id)
        
        if current_data:
            extracted = extract_data_from_response(station_id, current_data, info)
            if extracted:
                all_data.append(extracted)
                print("✓")
            else:
                print("✗ (No data extractable)")
        else:
            print("✗ (API not reachable)")
    
    print()
    print("=" * 80)
    print("SUMMARY")
    print("=" * 80)
    print()
    
    if all_data:
        # Create table
        df = create_summary_table(all_data)
        
        # Display table
        print(df.to_string(index=False))
        print()
        
        # Save data
        save_data(all_data, format="csv", filename="hydrodata_bern")
        save_data(all_data, format="json", filename="hydrodata_bern")
        
        print()
        print(f"Successfully retrieved {len(all_data)} out of {len(STATIONS_BERN)} stations.")
    else:
        print("ERROR: No data could be retrieved.")
        print()
        print("Possible causes:")
        print("- API not reachable")
        print("- Network problems")
        print("- Changed API endpoints")
        print()
        print("Alternative: Use BAFU Hydrodata website directly:")
        print("https://www.hydrodaten.admin.ch/en/lakes-and-rivers.html")

if __name__ == "__main__":
    main()

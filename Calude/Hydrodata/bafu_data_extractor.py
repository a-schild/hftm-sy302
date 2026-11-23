#!/usr/bin/env python3
"""
BAFU Hydrodaten Extractor
Extrahiert Durchflussmengen, Temperaturen, Stationen und Gewässernamen
mit den letzten 20 Messwerten pro Station
"""

import requests
import json
import pandas as pd
from datetime import datetime, timedelta
import sys

class BAFUExtractor:
    def __init__(self):
        self.base_url = "https://api.existenz.ch/bafu/v1"
        self.app_name = "bafu-data-extractor"
        self.all_data = []
        
    def get_locations(self):
        """Holt alle verfügbaren Messstationen"""
        try:
            url = f"{self.base_url}/locations?app={self.app_name}"
            print(f"Fetching locations from: {url}")
            response = requests.get(url, timeout=10)
            response.raise_for_status()
            return response.json()
        except Exception as e:
            print(f"Fehler beim Abrufen der Stationen: {e}")
            return []
    
    def get_latest_measurements(self, location_id):
        """Holt die letzten Messwerte für eine Station"""
        try:
            url = f"{self.base_url}/latest?location={location_id}&app={self.app_name}"
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                return response.json()
            return None
        except Exception as e:
            print(f"Fehler beim Abrufen von Messwerten für Station {location_id}: {e}")
            return None
    
    def get_measurements_history(self, location_id, parameter, days=1):
        """Holt historische Messwerte der letzten N Tage"""
        try:
            url = f"{self.base_url}/measurements?location={location_id}&parameter={parameter}&limit=100&app={self.app_name}"
            response = requests.get(url, timeout=10)
            if response.status_code == 200:
                data = response.json()
                if isinstance(data, list):
                    return data[-20:] if len(data) > 20 else data
                return []
            return []
        except Exception as e:
            print(f"Fehler beim Abrufen der Historie für Station {location_id}: {e}")
            return []
    
    def extract_bern_north_stations(self):
        """
        Extrahiert Daten für Stationen in Nord-Bern
        Bekannte Stationen im Norden: 2002, 2003, 2006, 2008, 2030, 2135, etc.
        """
        nord_stations = {
            '2002': 'Thunersee - Interlaken',
            '2003': 'Bielersee',
            '2030': 'Aare - Brigg',
            '2135': 'Aare - Mellingen',
            '2091': 'Reuss - Mellingen',
            '2051': 'Emme - Eggiwil',
        }
        
        print(f"\nExtraktion der Messstationen für Nord-Bern...")
        print(f"Anzahl Stationen: {len(nord_stations)}")
        print("-" * 80)
        
        for station_id, station_name in nord_stations.items():
            print(f"\nVerarbeite: {station_name} (ID: {station_id})")
            
            latest = self.get_latest_measurements(station_id)
            if latest:
                print(f"  ✓ Aktuelle Daten erhalten")
            
            parameters = ['discharge', 'temperature', 'water_level']
            for param in parameters:
                measurements = self.get_measurements_history(station_id, param)
                if measurements:
                    print(f"  ✓ {len(measurements)} Messwerte für Parameter '{param}'")
                    
                    for idx, measurement in enumerate(measurements[-20:], 1):
                        record = {
                            'Station_ID': station_id,
                            'Station_Name': station_name,
                            'Parameter': param,
                            'Messung_Nummer': idx,
                        }
                        
                        if isinstance(measurement, dict):
                            record.update(measurement)
                        elif isinstance(measurement, (list, tuple)) and len(measurement) >= 2:
                            record['Timestamp'] = measurement[0]
                            record['Value'] = measurement[1]
                        
                        self.all_data.append(record)
        
        return self.all_data
    
    def extract_all_stations(self):
        """
        Alternative: Extrahiert alle verfügbaren Stationen
        """
        locations = self.get_locations()
        
        if not locations:
            print("Hinweis: Konnte Stationen nicht über API abrufen.")
            print("Verwende stattdessen bekannte Nord-Bern Stationen...")
            return self.extract_bern_north_stations()
        
        print(f"\nGefundene Stationen: {len(locations)}")
        
        for location in locations:
            if isinstance(location, dict):
                station_id = location.get('id') or location.get('loc')
                station_name = location.get('name') or location.get('location_name', 'Unknown')
                
                if station_id:
                    print(f"Verarbeite: {station_name} (ID: {station_id})")
                    
                    for param in ['discharge', 'temperature', 'water_level']:
                        measurements = self.get_measurements_history(station_id, param)
                        
                        for idx, measurement in enumerate(measurements[-20:], 1):
                            record = {
                                'Station_ID': station_id,
                                'Station_Name': station_name,
                                'Parameter': param,
                                'Messung_Nummer': idx,
                            }
                            
                            if isinstance(measurement, dict):
                                record.update(measurement)
                            
                            self.all_data.append(record)
        
        return self.all_data
    
    def to_dataframe(self):
        """Konvertiert die gesammelten Daten zu DataFrame"""
        if not self.all_data:
            return pd.DataFrame()
        
        df = pd.DataFrame(self.all_data)
        
        sort_cols = [col for col in ['Station_ID', 'Parameter', 'Messung_Nummer'] if col in df.columns]
        if sort_cols:
            df = df.sort_values(by=sort_cols)
        
        return df
    
    def to_excel(self, filename='bafu_messdaten.xlsx'):
        """Speichert die Daten als Excel-Datei"""
        df = self.to_dataframe()
        
        if df.empty:
            print("Keine Daten zum Speichern.")
            return False
        
        try:
            with pd.ExcelWriter(filename, engine='openpyxl') as writer:
                df.to_excel(writer, sheet_name='Messdaten', index=False)
                
                worksheet = writer.sheets['Messdaten']
                for column in worksheet.columns:
                    max_length = 0
                    column = [cell for cell in column]
                    for cell in column:
                        try:
                            if len(str(cell.value)) > max_length:
                                max_length = len(cell.value)
                        except:
                            pass
                    adjusted_width = (max_length + 2)
                    worksheet.column_dimensions[column[0].column_letter].width = adjusted_width
            
            print(f"\n✓ Daten erfolgreich gespeichert: {filename}")
            print(f"  Anzahl Einträge: {len(df)}")
            return True
        except Exception as e:
            print(f"Fehler beim Speichern der Excel-Datei: {e}")
            return False
    
    def to_csv(self, filename='bafu_messdaten.csv'):
        """Speichert die Daten als CSV-Datei"""
        df = self.to_dataframe()
        
        if df.empty:
            print("Keine Daten zum Speichern.")
            return False
        
        try:
            df.to_csv(filename, index=False, encoding='utf-8-sig')
            print(f"\n✓ Daten erfolgreich gespeichert: {filename}")
            print(f"  Anzahl Einträge: {len(df)}")
            return True
        except Exception as e:
            print(f"Fehler beim Speichern der CSV-Datei: {e}")
            return False
    
    def print_summary(self):
        """Gibt eine Zusammenfassung der extrahierten Daten aus"""
        df = self.to_dataframe()
        
        if df.empty:
            print("Keine Daten vorhanden.")
            return
        
        print("\n" + "="*80)
        print("ZUSAMMENFASSUNG DER EXTRAHIERTEN DATEN")
        print("="*80)
        
        print(f"\nGesamt Messwerte: {len(df)}")
        
        if 'Station_ID' in df.columns:
            print(f"Unique Stationen: {df['Station_ID'].nunique()}")
        
        if 'Parameter' in df.columns:
            print(f"\nParameter pro Station:")
            print(df['Parameter'].value_counts())
        
        print("\nPrimary Columns:")
        print(df.head(20).to_string())
        
        print("\n" + "="*80)


def main():
    print("BAFU Hydrodaten Extractor")
    print("=" * 80)
    
    extractor = BAFUExtractor()
    
    print("\nStarte Datenextraktion...")
    data = extractor.extract_all_stations()
    
    extractor.print_summary()
    
    extractor.to_excel('bafu_messdaten.xlsx')
    extractor.to_csv('bafu_messdaten.csv')
    
    print("\nFertig!")


if __name__ == '__main__':
    main()

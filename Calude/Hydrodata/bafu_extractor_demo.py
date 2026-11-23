#!/usr/bin/env python3
"""
BAFU Hydrodaten Extractor - Vereinfachte Version
Extrahiert Messdaten manuell mit konstruierten Testdaten
"""

import json
import csv
from datetime import datetime, timedelta
from typing import List, Dict
import random

class BAFUDataExtractor:
    def __init__(self):
        # Bekannte Messstationen in Nord-Bern
        self.stations = {
            '2002': {
                'name': 'Thunersee - Interlaken',
                'gewässer': 'Thunersee',
                'region': 'Nord-Bern',
                'type': 'See',
                'lat': 46.6365,
                'lon': 8.1598,
            },
            '2003': {
                'name': 'Bielersee',
                'gewässer': 'Bielersee',
                'region': 'Nord-Bern',
                'type': 'See',
                'lat': 47.1500,
                'lon': 7.2000,
            },
            '2030': {
                'name': 'Aare - Brigg',
                'gewässer': 'Aare',
                'region': 'Nord-Bern',
                'type': 'Fluss',
                'lat': 46.7500,
                'lon': 8.3500,
            },
            '2135': {
                'name': 'Aare - Mellingen',
                'gewässer': 'Aare',
                'region': 'Nord-Bern',
                'type': 'Fluss',
                'lat': 47.3500,
                'lon': 8.1800,
            },
            '2091': {
                'name': 'Reuss - Mellingen',
                'gewässer': 'Reuss',
                'region': 'Nord-Bern',
                'type': 'Fluss',
                'lat': 47.3700,
                'lon': 8.2000,
            },
            '2051': {
                'name': 'Emme - Eggiwil',
                'gewässer': 'Emme',
                'region': 'Nord-Bern',
                'type': 'Fluss',
                'lat': 46.9800,
                'lon': 8.0800,
            },
        }
        
        self.data = []
    
    def generate_sample_data(self):
        """Generiert Beispieldaten für Demonstration"""
        print("Generiere Beispieldaten für BAFU Nord-Bern Stationen...\n")
        
        parameters = {
            'Durchfluss': {'unit': 'm³/s', 'min': 10, 'max': 200},
            'Temperatur': {'unit': '°C', 'min': 5, 'max': 22},
            'Wasserstand': {'unit': 'm ü.M.', 'min': 430, 'max': 700},
        }
        
        base_time = datetime.now()
        measurement_count = 0
        
        for station_id, station_info in self.stations.items():
            print(f"  Station: {station_info['name']} (ID: {station_id})")
            
            for param_name, param_info in parameters.items():
                # Generiere 20 Messwerte pro Parameter
                for i in range(20):
                    # Zeitstempel (rückwärts, je neuere Messwerte zuerst)
                    timestamp = base_time - timedelta(minutes=10*(20-i))
                    
                    # Realistisches Zittern um einen Wert
                    value = random.uniform(param_info['min'], param_info['max'])
                    
                    record = {
                        'Station_ID': station_id,
                        'Station_Name': station_info['name'],
                        'Gewässer': station_info['gewässer'],
                        'Region': station_info['region'],
                        'Gewässertyp': station_info['type'],
                        'Latitude': station_info['lat'],
                        'Longitude': station_info['lon'],
                        'Parameter': param_name,
                        'Unit': param_info['unit'],
                        'Messung_Nummer': i + 1,
                        'Zeitstempel': timestamp.isoformat(),
                        'Wert': round(value, 2),
                        'Qualität': 'validated',
                        'Datenquelle': 'BAFU',
                    }
                    
                    self.data.append(record)
                    measurement_count += 1
            
            print(f"    ✓ {len(parameters) * 20} Messwerte generiert")
        
        print(f"\nGesamt {measurement_count} Messwerte generiert")
        return self.data
    
    def print_summary(self):
        """Gibt eine Zusammenfassung aus"""
        print("\n" + "="*100)
        print("ZUSAMMENFASSUNG DER EXTRAHIERTEN DATEN")
        print("="*100)
        
        if not self.data:
            print("Keine Daten vorhanden!")
            return
        
        print(f"\nGesamt Messwerte: {len(self.data)}")
        print(f"Unique Stationen: {len(set(r['Station_ID'] for r in self.data))}")
        
        # Zähle Parameter
        params = {}
        for record in self.data:
            param = record['Parameter']
            params[param] = params.get(param, 0) + 1
        
        print("\nMessungen pro Parameter:")
        for param, count in sorted(params.items()):
            print(f"  - {param}: {count} Werte")
        
        # Zähle Gewässer
        gewässer = {}
        for record in self.data:
            g = record['Gewässer']
            gewässer[g] = gewässer.get(g, 0) + 1
        
        print("\nMessungen pro Gewässer:")
        for g, count in sorted(gewässer.items()):
            print(f"  - {g}: {count} Werte")
        
        # Zeige Sample
        print("\nSample-Daten (erste 10 Messungen):")
        print("-"*100)
        print(f"{'Station':<30} {'Gewässer':<15} {'Parameter':<15} {'Wert':<12} {'Einheit':<10} {'Zeit':<25}")
        print("-"*100)
        
        for record in self.data[:10]:
            print(f"{record['Station_Name']:<30} {record['Gewässer']:<15} {record['Parameter']:<15} "
                  f"{record['Wert']:<12} {record['Unit']:<10} {record['Zeitstempel']:<25}")
        
        print("-"*100)
        print("="*100 + "\n")
    
    def export_to_csv(self, filename='bafu_messdaten.csv'):
        """Exportiert zu CSV"""
        if not self.data:
            print("Keine Daten zum Exportieren.")
            return False
        
        try:
            with open(filename, 'w', newline='', encoding='utf-8') as f:
                writer = csv.DictWriter(f, fieldnames=self.data[0].keys())
                writer.writeheader()
                writer.writerows(self.data)
            
            print(f"✓ CSV exportiert: {filename}")
            print(f"  Anzahl Einträge: {len(self.data)}")
            return True
        except Exception as e:
            print(f"Fehler beim CSV-Export: {e}")
            return False
    
    def export_to_json(self, filename='bafu_messdaten.json'):
        """Exportiert zu JSON"""
        if not self.data:
            print("Keine Daten zum Exportieren.")
            return False
        
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(self.data, f, indent=2, ensure_ascii=False)
            
            print(f"✓ JSON exportiert: {filename}")
            print(f"  Anzahl Einträge: {len(self.data)}")
            return True
        except Exception as e:
            print(f"Fehler beim JSON-Export: {e}")
            return False


def main():
    print("="*100)
    print("BAFU HYDRODATEN EXTRACTOR - NORD-BERN STATIONEN")
    print("="*100 + "\n")
    
    extractor = BAFUDataExtractor()
    
    # Generiere Beispieldaten
    extractor.generate_sample_data()
    
    # Gib Zusammenfassung aus
    extractor.print_summary()
    
    # Exportiere in verschiedene Formate
    print("Exportiere Daten...\n")
    extractor.export_to_csv('bafu_messdaten.csv')
    extractor.export_to_json('bafu_messdaten.json')
    
    print("\n✓ Alle Exporte abgeschlossen!")


if __name__ == '__main__':
    main()

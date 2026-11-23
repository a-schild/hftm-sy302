#!/usr/bin/env python3
"""
Database Import Script for Hydrodata
Imports CSV/JSON data into the MySQL database
"""

import mysql.connector
from mysql.connector import Error
import pandas as pd
import json
import sys
from datetime import datetime
import argparse

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  # Set your password
    'database': 'hydrodata'
}

def create_connection():
    """Create database connection"""
    try:
        connection = mysql.connector.connect(**DB_CONFIG)
        if connection.is_connected():
            print(f"Successfully connected to database: {DB_CONFIG['database']}")
            return connection
    except Error as e:
        print(f"Error connecting to database: {e}")
        sys.exit(1)

def import_csv_to_measurements(connection, csv_file):
    """
    Import CSV file into measurements table
    """
    try:
        # Read CSV
        df = pd.read_csv(csv_file, sep=';')
        
        cursor = connection.cursor()
        
        # Insert data
        insert_query = """
        INSERT INTO measurements 
        (station_id, timestamp, discharge_m3s, water_level_m, temperature_c, quality)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            discharge_m3s = VALUES(discharge_m3s),
            water_level_m = VALUES(water_level_m),
            temperature_c = VALUES(temperature_c)
        """
        
        records_inserted = 0
        records_updated = 0
        
        for index, row in df.iterrows():
            try:
                values = (
                    row.get('station_id'),
                    row.get('timestamp'),
                    row.get('discharge_m3s') if pd.notna(row.get('discharge_m3s')) else None,
                    row.get('water_level_m') if pd.notna(row.get('water_level_m')) else None,
                    row.get('temperature_c') if pd.notna(row.get('temperature_c')) else None,
                    'provisional'
                )
                
                cursor.execute(insert_query, values)
                
                if cursor.rowcount == 1:
                    records_inserted += 1
                elif cursor.rowcount == 2:
                    records_updated += 1
                    
            except Error as e:
                print(f"Error inserting row {index}: {e}")
                continue
        
        connection.commit()
        cursor.close()
        
        print(f"Import completed:")
        print(f"  - Records inserted: {records_inserted}")
        print(f"  - Records updated: {records_updated}")
        print(f"  - Total processed: {len(df)}")
        
        return True
        
    except Exception as e:
        print(f"Error importing CSV: {e}")
        return False

def calculate_daily_aggregates(connection, date=None):
    """
    Calculate and store daily aggregate values
    """
    try:
        cursor = connection.cursor()
        
        if date is None:
            date = datetime.now().strftime('%Y-%m-%d')
        
        # Call stored procedure
        cursor.callproc('calculate_daily_values', [date])
        connection.commit()
        
        # Get number of records created
        cursor.execute("SELECT ROW_COUNT()")
        count = cursor.fetchone()[0]
        
        cursor.close()
        
        print(f"Daily aggregates calculated for {date}: {count} records")
        return True
        
    except Error as e:
        print(f"Error calculating daily aggregates: {e}")
        return False

def verify_import(connection):
    """
    Verify imported data
    """
    try:
        cursor = connection.cursor()
        
        # Count records
        cursor.execute("SELECT COUNT(*) FROM measurements")
        total_measurements = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM daily_values")
        total_daily = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(DISTINCT station_id) FROM measurements")
        total_stations = cursor.fetchone()[0]
        
        # Get latest timestamp
        cursor.execute("SELECT MAX(timestamp) FROM measurements")
        latest = cursor.fetchone()[0]
        
        # Get date range
        cursor.execute("SELECT MIN(DATE(timestamp)), MAX(DATE(timestamp)) FROM measurements")
        date_range = cursor.fetchone()
        
        cursor.close()
        
        print("\n" + "="*60)
        print("DATABASE STATISTICS")
        print("="*60)
        print(f"Total measurements:     {total_measurements:,}")
        print(f"Total daily aggregates: {total_daily:,}")
        print(f"Active stations:        {total_stations}")
        print(f"Latest measurement:     {latest}")
        print(f"Date range:             {date_range[0]} to {date_range[1]}")
        print("="*60)
        
        return True
        
    except Error as e:
        print(f"Error verifying import: {e}")
        return False

def show_recent_data(connection, station_id=None, limit=10):
    """
    Display recent measurements
    """
    try:
        cursor = connection.cursor()
        
        if station_id:
            query = """
            SELECT m.timestamp, s.station_name, s.waterbody, 
                   m.discharge_m3s, m.temperature_c, m.water_level_m
            FROM measurements m
            JOIN stations s ON m.station_id = s.station_id
            WHERE m.station_id = %s
            ORDER BY m.timestamp DESC
            LIMIT %s
            """
            cursor.execute(query, (station_id, limit))
        else:
            query = """
            SELECT m.timestamp, s.station_name, s.waterbody, 
                   m.discharge_m3s, m.temperature_c, m.water_level_m
            FROM measurements m
            JOIN stations s ON m.station_id = s.station_id
            ORDER BY m.timestamp DESC
            LIMIT %s
            """
            cursor.execute(query, (limit,))
        
        results = cursor.fetchall()
        
        if results:
            print("\n" + "="*80)
            print("RECENT MEASUREMENTS")
            print("="*80)
            print(f"{'Timestamp':<20} {'Station':<25} {'Waterbody':<15} {'Discharge':<12} {'Temp':<8} {'Level':<8}")
            print("-"*80)
            
            for row in results:
                discharge = f"{row[3]:.2f}" if row[3] is not None else "N/A"
                temp = f"{row[4]:.2f}" if row[4] is not None else "N/A"
                level = f"{row[5]:.2f}" if row[5] is not None else "N/A"
                
                print(f"{str(row[0]):<20} {row[1]:<25} {row[2]:<15} {discharge:<12} {temp:<8} {level:<8}")
            
            print("="*80)
        else:
            print("No data found.")
        
        cursor.close()
        return True
        
    except Error as e:
        print(f"Error displaying data: {e}")
        return False

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Import hydrodata into MySQL database')
    parser.add_argument('--csv', help='CSV file to import')
    parser.add_argument('--aggregate', action='store_true', help='Calculate daily aggregates')
    parser.add_argument('--verify', action='store_true', help='Verify database contents')
    parser.add_argument('--show', action='store_true', help='Show recent data')
    parser.add_argument('--station', help='Filter by station ID')
    parser.add_argument('--limit', type=int, default=10, help='Number of records to show')
    
    args = parser.parse_args()
    
    # Create connection
    connection = create_connection()
    
    try:
        # Import CSV
        if args.csv:
            print(f"\nImporting CSV file: {args.csv}")
            import_csv_to_measurements(connection, args.csv)
        
        # Calculate aggregates
        if args.aggregate:
            print("\nCalculating daily aggregates...")
            calculate_daily_aggregates(connection)
        
        # Verify database
        if args.verify:
            verify_import(connection)
        
        # Show recent data
        if args.show:
            show_recent_data(connection, args.station, args.limit)
        
        # If no arguments, show help
        if not any([args.csv, args.aggregate, args.verify, args.show]):
            parser.print_help()
            print("\n\nExample usage:")
            print("  python db_import.py --csv hydrodata_bern_20231021_120000.csv")
            print("  python db_import.py --aggregate")
            print("  python db_import.py --verify")
            print("  python db_import.py --show --station 2135 --limit 20")
        
    finally:
        if connection.is_connected():
            connection.close()
            print("\nDatabase connection closed.")

if __name__ == "__main__":
    main()

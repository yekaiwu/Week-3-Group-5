#!/usr/bin/env python3
"""
Generate extended sensor data from Jan 1, 2026 to Feb 6, 2026
Extends existing CSV files with realistic sensor readings
"""

import csv
import math
import random
from datetime import datetime, timedelta

# Room configurations with temperature, humidity, and light characteristics
ROOM_CONFIGS = {
    "synthetic_living_room_20260204_153610.csv": {
        "name": "Living Room",
        "temp_base": 21.5,
        "temp_variation": 3.0,
        "humidity_base": 45.0,
        "humidity_variation": 15.0,
        "light_day_max": 850,
        "light_night_min": 50
    },
    "synthetic_kitchen_20260204_160156.csv": {
        "name": "Kitchen",
        "temp_base": 22.0,
        "temp_variation": 4.0,  # Higher variation due to cooking
        "humidity_base": 55.0,
        "humidity_variation": 20.0,  # Higher variation due to cooking/washing
        "light_day_max": 900,
        "light_night_min": 30
    },
    "synthetic_bathroom_20260204_160204.csv": {
        "name": "Bathroom",
        "temp_base": 23.0,
        "temp_variation": 2.5,
        "humidity_base": 65.0,  # Higher base humidity
        "humidity_variation": 25.0,  # High variation due to showers
        "light_day_max": 700,
        "light_night_min": 20
    },
    "synthetic_bedroom_20260204_160253.csv": {
        "name": "Bedroom",
        "temp_base": 20.0,  # Cooler for sleeping
        "temp_variation": 2.0,
        "humidity_base": 50.0,
        "humidity_variation": 12.0,
        "light_day_max": 600,
        "light_night_min": 10  # Very dark at night
    }
}

def read_last_timestamp(filepath):
    """Read the last timestamp from existing CSV"""
    try:
        with open(filepath, 'r') as f:
            lines = f.readlines()
            if len(lines) > 1:
                last_line = lines[-1].strip()
                timestamp_str = last_line.split(',')[0]
                return datetime.fromisoformat(timestamp_str)
    except FileNotFoundError:
        print(f"Warning: {filepath} not found, will start from 2026-01-01")
    return datetime(2025, 12, 31, 23, 30, 0)

def generate_temperature(hour, config, day_offset):
    """Generate realistic temperature with daily cycle"""
    base = config["temp_base"]
    variation = config["temp_variation"]

    # Daily cycle: cooler at night, warmer during day
    daily_cycle = math.sin((hour - 6) * math.pi / 12) * (variation / 2)

    # Random noise
    noise = random.gauss(0, variation / 4)

    # Seasonal variation (winter = cooler)
    seasonal = -1.0 * math.sin(day_offset * math.pi / 180)

    temp = base + daily_cycle + noise + seasonal
    return round(max(15.0, min(35.0, temp)), 2)

def generate_humidity(hour, config, day_offset):
    """Generate realistic humidity with daily cycle"""
    base = config["humidity_base"]
    variation = config["humidity_variation"]

    # Daily cycle: higher at night, lower during day
    daily_cycle = -math.sin((hour - 6) * math.pi / 12) * (variation / 3)

    # Random noise
    noise = random.gauss(0, variation / 3)

    # Random spikes (e.g., shower in bathroom, cooking in kitchen)
    spike = 0
    if random.random() < 0.05:  # 5% chance of spike
        spike = random.uniform(5, 15)

    humidity = base + daily_cycle + noise + spike
    return round(max(20.0, min(95.0, humidity)), 2)

def generate_light(hour, minute, config):
    """Generate realistic light levels with day/night cycle"""
    day_max = config["light_day_max"]
    night_min = config["light_night_min"]

    # Time as decimal hour
    time_decimal = hour + minute / 60.0

    # Sunrise around 7:00, sunset around 19:00 (winter)
    sunrise = 7.0
    sunset = 19.0

    if time_decimal < sunrise or time_decimal > sunset:
        # Night time - very low light
        light = night_min + random.uniform(-5, 10)
    elif time_decimal < sunrise + 1:
        # Sunrise transition
        progress = (time_decimal - sunrise)
        light = night_min + (day_max - night_min) * progress + random.uniform(-50, 50)
    elif time_decimal > sunset - 1:
        # Sunset transition
        progress = (sunset - time_decimal)
        light = night_min + (day_max - night_min) * progress + random.uniform(-50, 50)
    else:
        # Daytime - high light with cloud variations
        cloud_factor = random.uniform(0.7, 1.0)
        light = day_max * cloud_factor + random.uniform(-100, 100)

    return round(max(0, light), 0)

def extend_csv_file(filepath, config, start_date, end_date):
    """Extend a CSV file with new data"""
    print(f"\nProcessing {config['name']}...")

    # Read last timestamp from existing file
    last_timestamp = read_last_timestamp(filepath)
    print(f"  Last timestamp in file: {last_timestamp}")

    # Start from next 30-minute interval
    current_time = last_timestamp + timedelta(minutes=30)

    # Generate data until end_date
    new_rows = []
    day_offset = 0

    while current_time <= end_date:
        hour = current_time.hour
        minute = current_time.minute

        # Calculate day offset for seasonal effects
        day_offset = (current_time - start_date).days

        # Generate sensor values
        temperature = generate_temperature(hour, config, day_offset)
        humidity = generate_humidity(hour, config, day_offset)
        light = generate_light(hour, minute, config)

        # Format row
        timestamp_str = current_time.strftime("%Y-%m-%dT%H:%M:%S")
        new_rows.append(f"{timestamp_str},{temperature},{humidity},{int(light)}")

        # Next reading (30 minutes later)
        current_time += timedelta(minutes=30)

    # Append to existing file
    print(f"  Generated {len(new_rows)} new readings")
    with open(filepath, 'a') as f:
        for row in new_rows:
            f.write(row + '\n')

    print(f"  ✓ Extended {config['name']} to {end_date}")

def main():
    base_path = "/Users/jay/Documents/Processing/PlantHealthDashboard/sensor_data"

    # Date range for new data
    start_date = datetime(2026, 1, 1, 0, 0, 0)
    end_date = datetime(2026, 2, 6, 23, 30, 0)

    print("=" * 60)
    print("Sensor Data Extension Tool")
    print("=" * 60)
    print(f"Extending data from {start_date.date()} to {end_date.date()}")
    print(f"Total days: {(end_date - start_date).days + 1}")
    print()

    # Process each room
    for filename, config in ROOM_CONFIGS.items():
        filepath = f"{base_path}/{filename}"
        try:
            extend_csv_file(filepath, config, start_date, end_date)
        except Exception as e:
            print(f"  ✗ Error processing {filename}: {e}")

    print("\n" + "=" * 60)
    print("Data extension complete!")
    print("=" * 60)

if __name__ == "__main__":
    main()

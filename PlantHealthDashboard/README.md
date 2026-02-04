# Plant Health Monitoring Dashboard

An interactive dashboard for monitoring plant health across different rooms in a house. Features real-time sensor data visualization, historical analysis, and AI-powered plant health predictions.

## Features

### 🏠 House Map View
- **Interactive House Layout**: Click on different rooms to view detailed sensor data
- **5 Monitored Locations**:
  - Living Room (Peace Lily)
  - Kitchen (Herb Garden)
  - Balcony (Tomato Plants)
  - Bedroom (Snake Plant)
  - Bathroom (Water Lily)

### 📊 Growing Squares Visualization
- Real-time sensor data displayed as growing/shrinking squares
- Three sensors per location:
  - **Humidity** (blue squares, 0-100%)
  - **Temperature** (orange squares, 15-35°C)
  - **Light** (yellow squares, 0-1000 lux)
- Square size represents the magnitude of the sensor reading

### ⏱️ Time Travel Slider
- View historical data from the last 24 hours
- Drag the slider to see how conditions changed over time
- Hour markers for easy navigation
- Shows "Now" for current time (hour 0)

### 🌿 Plant Health Prediction
- AI-powered health assessment for each plant
- Health score (0-100%) based on:
  - Humidity levels
  - Temperature conditions
  - Light availability
- **Health Status Levels**:
  - Excellent (80-100%): Green
  - Good (60-79%): Light green
  - Fair (40-59%): Yellow
  - Poor (20-39%): Orange
  - Critical (0-19%): Red
- Detailed explanation of issues with recommendations

### 📈 Analytics Dashboard
- 24-hour historical graphs for each sensor type
- Beautiful line charts with data points
- **Statistical Analysis**:
  - Average value
  - Standard deviation
  - Minimum value
  - Maximum value
- Separate graphs for humidity, temperature, and light

## Plant-Specific Optimal Conditions

Each plant type has specific optimal ranges:

| Plant Type | Humidity | Temperature | Light |
|------------|----------|-------------|-------|
| Peace Lily | 50-70% | 18-27°C | 100-300 lux |
| Herb Garden | 40-60% | 15-25°C | 400-800 lux |
| Tomato Plants | 60-80% | 20-30°C | 600-1000 lux |
| Snake Plant | 30-50% | 15-29°C | 50-500 lux |
| Water Lily | 70-90% | 20-28°C | 300-700 lux |

## How to Use

### Setup
1. Open `PlantHealthDashboard.pde` in Processing
2. (Optional) Add a house layout image as `data/house_layout.png` for a custom background
3. Run the sketch

### Navigation
- **House Map Tab**: Click on any room to view its detailed sensor data
- **Analytics Tab**: View comprehensive graphs and statistics for the selected room
- **Time Slider**: Drag to explore historical data from the last 24 hours

### Understanding the Visualizations

#### Growing Squares
- Larger squares = Higher values
- Each square is color-coded by sensor type
- Current values displayed below each square

#### Health Prediction
- Color-coded health bar shows overall plant condition
- Explanation text provides actionable insights
- Based on plant-specific optimal ranges

#### Analytics Graphs
- X-axis: Time (0-23 hours ago)
- Y-axis: Sensor value with appropriate units
- Blue line: Humidity
- Orange line: Temperature
- Yellow line: Light
- Statistics panel on the right side

## Data Generation

The dashboard currently uses **mock data** for demonstration:
- Generated using Perlin noise for realistic variations
- Includes day/night cycles for temperature and light
- Randomly fluctuates within reasonable ranges
- 24 hours of historical data per location

To use real sensor data, modify the `generateHistoricalData()` method in `HouseRegion.pde` to read from your actual sensors.

## Technical Details

### Files
- `PlantHealthDashboard.pde` - Main sketch with UI and tab system
- `HouseRegion.pde` - Region class with data, visualization, and health prediction

### Requirements
- Processing 3.x or 4.x
- No external libraries required

### Customization
You can easily customize:
- Number and names of rooms (modify `regions` array in setup())
- Plant types and optimal conditions (edit `setPlantOptimalConditions()`)
- Color schemes (modify color values in draw functions)
- Graph ranges and appearance (edit `drawSensorGraph()`)
- House layout image (place custom image in `data/` folder)

## Future Enhancements

Potential features to add:
- Connect to real IoT sensors (Arduino, ESP32, etc.)
- Database integration for long-term data storage
- Alert system for critical conditions
- Export data to CSV
- Multiple house layouts
- User-defined plant types and optimal ranges
- Machine learning for predictive analytics
- Mobile-responsive web version

## Credits

Created as part of the Plant Monitoring Dashboard project for interactive data visualization and plant health monitoring.

## License

Free to use and modify for educational and personal projects.

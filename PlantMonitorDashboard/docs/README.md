# Plant Monitoring Dashboard - 3D Visualization

A 3D visualization for plant conditions monitoring using Processing (Java). This application displays sensor data from 4 different rooms, each containing 3 sensors (Humidity, Temperature, and Light Level).

## Features

- **4 Room Types**: Living Room, Attic, Balcony, and Toilet
- **Room Images**: Each room displays a background image (customizable)
- **3 Sensors per Room**:
  - Humidity (0-100%)
  - Temperature (15-35°C)
  - Light Level (0-1000 lux)
- **3D Bar Visualization**: Sensor readings displayed as 3D bars that grow/shrink based on values
- **Overall Dashboard**: Right-side panel showing all rooms and their sensor data in real-time
- **Color Coding**:
  - **Green**: Healthy range
  - **Yellow**: Warning range
  - **Red**: Critical range
  - **Grey**: Rooms not being hovered over
- **Interactive Hover**: Hovered room shows colored bars with detailed sensor information
- **Multiple Camera Views**: Arrow keys for rotation, preset views (top-down, front, side, perspective)
- **Billboard Text**: Room names and sensor readings always face the camera for easy reading
- **Smooth Zoom**: Works with mouse wheel and 2-finger trackpad gestures
- **Realistic Simulation**: Uses Perlin noise to generate smooth, realistic sensor data
- **Auto-Update**: Sensor data refreshes every 5 seconds

## Installation

### Prerequisites

1. **Processing IDE**: Download and install from [processing.org](https://processing.org/download)
   - Version 3.x or 4.x recommended

### Setup

1. Locate the `PlantMonitorDashboard` folder
2. Open the main sketch file `PlantMonitorDashboard.pde` in Processing IDE
3. The IDE will automatically load all associated files:
   - `PlantMonitorDashboard.pde` (main sketch)
   - `Sensor.pde` (sensor class)
   - `Quadrant.pde` (quadrant class)

### Adding Room Images (Optional but Recommended)

To add custom images for each room:

1. Download 4 images (one for each room type) from free stock photo sites:
   - **Unsplash**: [unsplash.com](https://unsplash.com) (recommended)
   - **Pexels**: [pexels.com](https://pexels.com)
   - **Pixabay**: [pixabay.com](https://pixabay.com)

2. Download the following image types:
   - Living room interior
   - Attic room
   - Balcony view
   - Modern bathroom/toilet

3. Rename the images to:
   - `living_room.jpg`
   - `attic.jpg`
   - `balcony.jpg`
   - `toilet.jpg`

4. Place them in the `PlantMonitorDashboard/data/` folder

5. See `data/IMAGES_GUIDE.txt` for direct links to free image sources

**Note**: The visualization works without images but looks better with them!

## How to Run

1. Open `PlantMonitorDashboard.pde` in Processing IDE
2. Click the **Run** button (or press `Ctrl+R` / `Cmd+R`)
3. The visualization window will open

## Controls

### Mouse Controls
- **Hover**: Move mouse over a room to see sensor details and colors
- **Click & Drag**: Rotate the 3D view
- **Scroll Wheel / 2-Finger Trackpad**: Zoom in/out (smooth zooming from very close to far away)

### Keyboard Controls

**Camera Navigation:**
- **Arrow Keys**: Rotate camera view (Up/Down/Left/Right)
- **1**: Top-down view
- **2**: Front view
- **3**: Side view (left)
- **4**: Side view (right)
- **5**: Perspective view

**Other Controls:**
- **R**: Reset camera view to default
- **H**: Toggle help panel on/off
- **U**: Force immediate sensor update (for testing)

## Understanding the Visualization

### Room Layout
```
┌──────────────┬──────────────┐
│ Living Room  │    Attic     │
│              │              │
├──────────────┼──────────────┤
│   Balcony    │   Toilet     │
│              │              │
└──────────────┴──────────────┘
```

### Dashboard Layout
- **Left Side**: Help panel (toggle with 'H')
- **Center**: 3D visualization of 4 rooms
- **Right Side**: Overall dashboard showing all sensor data

### Each Room Contains 3 Bars (from left to right):
1. **Humidity** (0-100%)
   - Healthy: 40-70%
   - Warning: 30-40% or 70-80%
   - Critical: <30% or >80%

2. **Temperature** (15-35°C)
   - Healthy: 18-28°C
   - Warning: 15-18°C or 28-30°C
   - Critical: <15°C or >30°C

3. **Light Level** (0-1000 lux)
   - Healthy: 200-800 lux
   - Warning: 100-200 or 800-900 lux
   - Critical: <100 or >900 lux

### Visual Feedback

- **Bar Height**: Taller bars = higher sensor values
- **Bar Color**:
  - Shows health status when hovering over the room
  - Grey when not hovering
- **Room Images**: Background images for each room (dims when not hovered)
- **Billboard Text**: All text (room names, sensor values, status) automatically rotates to face you regardless of camera angle, making it easy to read from any view
- **Overall Dashboard** (Right Side):
  - Shows all 4 rooms simultaneously
  - Real-time sensor values for each room
  - Color-coded status indicators
  - Highlights the currently hovered room
  - Color legend at the bottom

## Data Simulation

The sketch uses **Perlin noise** to simulate realistic sensor data:
- Smooth, natural-looking variations
- Each sensor has unique noise patterns
- Values update every 5 seconds
- Countdown timer shows time until next update

## Customization

### Adjusting Sensor Ranges

Edit the sensor initialization in `Quadrant.pde`:

```java
// Humidity sensor
sensors[0] = new Sensor(
  "Humidity",
  0, 100,           // min, max values
  40, 70,           // healthy range
  30, 80,           // warning range
  quadrantIndex * 100 + 0
);
```

### Changing Update Interval

In `PlantMonitorDashboard.pde`, modify:

```java
int updateInterval = 5000; // milliseconds (5000 = 5 seconds)
```

### Adjusting Colors

In `Sensor.pde`, modify the `updateColor()` method:

```java
barColor = color(50, 200, 50);  // Green (R, G, B)
barColor = color(255, 200, 0);  // Yellow
barColor = color(255, 50, 50);  // Red
```

## Integration with Arduino/Server

To integrate with real Arduino sensor data:

1. Add network/serial communication code to receive data
2. Modify the `update()` method in `Sensor.pde` to accept external values
3. Replace Perlin noise simulation with actual sensor readings
4. Example integration point:

```java
// In Sensor.pde, add method to set value from external source
void setValue(float newValue) {
  value = constrain(newValue, minValue, maxValue);
  updateColor(true);
}
```

## File Structure

```
PlantMonitorDashboard/
├── PlantMonitorDashboard.pde  # Main sketch
├── Sensor.pde                  # Sensor class
├── Quadrant.pde                # Quadrant class
└── README.md                   # This file
```

## Troubleshooting

### Sketch won't run
- Ensure all three `.pde` files are in the same folder
- Check that Processing IDE is up to date
- Try File → Quit and restart Processing

### Graphics issues
- Update your graphics drivers
- Try switching renderer (change `P3D` to `P2D` for 2D mode)

### Performance issues
- Lower the frame rate: Add `frameRate(30);` in `setup()`
- Reduce window size in `size()` function

## Credits

Created for Plant Health Monitoring System
- Simulates Arduino Nano 33 Sense Rev2 sensor data
- Part of Week 3 IoT development project

## License

This visualization is part of an educational project for IoT and plant monitoring systems.

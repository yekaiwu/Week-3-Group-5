# Integration Guide: Connecting Real Arduino Data

This guide explains how to integrate the Processing visualization with your Arduino Nano 33 Sense Rev2 and server setup to display real sensor data instead of simulated data.

## Architecture Overview

```
Arduino Nano 33 → Serial/USB → Python Server → HTTP/WebSocket → Processing
                                                                      ↓
                                                              3D Visualization
```

## Option 1: HTTP Polling (Simplest)

### Step 1: Modify Processing to Fetch Data via HTTP

Add HTTP client capabilities to `PlantMonitorDashboard.pde`:

```java
import http.*;

// Add at top of sketch
HTTPClient httpClient;
String serverURL = "http://localhost:8000/api/sensors"; // Adjust to your server

// In setup()
void setup() {
  // ... existing code ...
  httpClient = new HTTPClient(this);
}

// Replace updateAllSensors() with:
void updateAllSensors() {
  String response = httpClient.GET(serverURL);

  if (response != null) {
    parseAndUpdateSensors(response);
  }
}

// Add JSON parsing function
void parseAndUpdateSensors(String jsonString) {
  JSONObject json = parseJSONObject(jsonString);

  if (json != null) {
    // Example: expecting data for each quadrant
    for (int i = 0; i < 4; i++) {
      String quadrantKey = "quadrant" + i;
      if (json.hasKey(quadrantKey)) {
        JSONObject quadrantData = json.getJSONObject(quadrantKey);

        // Update humidity
        if (quadrantData.hasKey("humidity")) {
          quadrants[i].sensors[0].setValue(quadrantData.getFloat("humidity"));
        }

        // Update temperature
        if (quadrantData.hasKey("temperature")) {
          quadrants[i].sensors[1].setValue(quadrantData.getFloat("temperature"));
        }

        // Update light
        if (quadrantData.hasKey("light")) {
          quadrants[i].sensors[2].setValue(quadrantData.getFloat("light"));
        }
      }
    }
  }
}
```

### Step 2: Update Sensor.pde

Add a method to set values from external sources:

```java
/**
 * Set sensor value from external source (Arduino)
 */
void setValue(float newValue) {
  value = constrain(newValue, minValue, maxValue);
  // Don't increment noise offset when using real data
}

/**
 * Toggle between simulated and real data
 */
void setSimulationMode(boolean useSimulation) {
  if (useSimulation) {
    update(); // Use Perlin noise
  }
  // If not simulating, values are set via setValue()
}
```

### Step 3: Create Server Endpoint

Add to your Python server (in `Server/` directory):

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import random

app = FastAPI()

# Enable CORS for Processing to access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/sensors")
def get_sensor_data():
    # Replace with actual Arduino sensor readings
    return {
        "quadrant0": {
            "humidity": get_arduino_humidity(0),
            "temperature": get_arduino_temperature(0),
            "light": get_arduino_light(0)
        },
        "quadrant1": {
            "humidity": get_arduino_humidity(1),
            "temperature": get_arduino_temperature(1),
            "light": get_arduino_light(1)
        },
        "quadrant2": {
            "humidity": get_arduino_humidity(2),
            "temperature": get_arduino_temperature(2),
            "light": get_arduino_light(2)
        },
        "quadrant3": {
            "humidity": get_arduino_humidity(3),
            "temperature": get_arduino_temperature(3),
            "light": get_arduino_light(3)
        }
    }

# Helper functions to get Arduino data
def get_arduino_humidity(quadrant_id):
    # TODO: Replace with actual Arduino reading
    return random.uniform(30, 80)

def get_arduino_temperature(quadrant_id):
    # TODO: Replace with actual Arduino reading
    return random.uniform(18, 28)

def get_arduino_light(quadrant_id):
    # TODO: Replace with actual Arduino reading
    return random.uniform(200, 800)
```

## Option 2: WebSocket (Real-time)

For real-time updates without polling:

### Processing Side

```java
import websockets.*;

WebsocketClient ws;

void setup() {
  // ... existing code ...
  ws = new WebsocketClient(this, "ws://localhost:8000/ws");
}

void webSocketEvent(String msg) {
  parseAndUpdateSensors(msg);
}
```

### Python Server Side

```python
from fastapi import WebSocket
import asyncio
import json

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    while True:
        # Read Arduino data
        sensor_data = {
            "quadrant0": {...},
            "quadrant1": {...},
            "quadrant2": {...},
            "quadrant3": {...}
        }

        await websocket.send_text(json.dumps(sensor_data))
        await asyncio.sleep(5)  # Send every 5 seconds
```

## Option 3: Serial Direct (No Server)

Connect Processing directly to Arduino:

```java
import processing.serial.*;

Serial arduinoPort;

void setup() {
  // ... existing code ...

  // List available serial ports
  printArray(Serial.list());

  // Connect to Arduino (adjust port index)
  arduinoPort = new Serial(this, Serial.list()[0], 9600);
  arduinoPort.bufferUntil('\n');
}

void serialEvent(Serial port) {
  String data = port.readStringUntil('\n');

  if (data != null) {
    data = trim(data);
    parseSerialData(data);
  }
}

void parseSerialData(String data) {
  // Expected format: "Q0,H:45.2,T:23.5,L:450|Q1,H:52.1,T:24.2,L:380|..."
  String[] quadrants = split(data, '|');

  for (String quadData : quadrants) {
    String[] parts = split(quadData, ',');

    if (parts.length == 4) {
      int quadId = int(parts[0].substring(1)); // Extract quadrant ID
      float humidity = parseValue(parts[1]);
      float temp = parseValue(parts[2]);
      float light = parseValue(parts[3]);

      quadrants[quadId].sensors[0].setValue(humidity);
      quadrants[quadId].sensors[1].setValue(temp);
      quadrants[quadId].sensors[2].setValue(light);
    }
  }
}

float parseValue(String input) {
  // Extract number from "H:45.2" format
  String[] parts = split(input, ':');
  return float(parts[1]);
}
```

### Arduino Side

Modify Arduino sketch to output data in expected format:

```cpp
void loop() {
  // Read sensors for all 4 quadrants
  // Format: Q0,H:45.2,T:23.5,L:450|Q1,H:52.1,T:24.2,L:380|...

  String output = "";

  for (int q = 0; q < 4; q++) {
    float humidity = readHumidity(q);
    float temp = readTemperature(q);
    float light = readLight(q);

    output += "Q" + String(q) + ",";
    output += "H:" + String(humidity, 1) + ",";
    output += "T:" + String(temp, 1) + ",";
    output += "L:" + String(light, 0);

    if (q < 3) output += "|";
  }

  Serial.println(output);
  delay(5000); // Send every 5 seconds
}
```

## Expected Data Format

### JSON Format (HTTP/WebSocket)
```json
{
  "quadrant0": {
    "humidity": 45.2,
    "temperature": 23.5,
    "light": 450
  },
  "quadrant1": {
    "humidity": 52.1,
    "temperature": 24.2,
    "light": 380
  },
  "quadrant2": {
    "humidity": 48.7,
    "temperature": 22.8,
    "light": 520
  },
  "quadrant3": {
    "humidity": 55.3,
    "temperature": 25.1,
    "light": 410
  }
}
```

### Serial Format
```
Q0,H:45.2,T:23.5,L:450|Q1,H:52.1,T:24.2,L:380|Q2,H:48.7,T:22.8,L:520|Q3,H:55.3,T:25.1,L:410
```

## Toggle Between Simulated and Real Data

Add a mode switch in the main sketch:

```java
boolean useSimulatedData = true; // Set to false for real data

void keyPressed() {
  // ... existing key handlers ...

  // Toggle simulation mode
  if (key == 's' || key == 'S') {
    useSimulatedData = !useSimulatedData;
    println("Simulation mode: " + (useSimulatedData ? "ON" : "OFF"));
  }
}

void updateAllSensors() {
  if (useSimulatedData) {
    // Use Perlin noise
    for (Quadrant quadrant : quadrants) {
      for (Sensor sensor : quadrant.sensors) {
        sensor.update();
      }
    }
  } else {
    // Fetch real data from Arduino/Server
    fetchRealData();
  }
}
```

## Testing the Integration

1. Start with simulated data to verify visualization works
2. Set up your server endpoint to return mock data
3. Test HTTP connection from Processing
4. Replace mock data with actual Arduino readings
5. Monitor data flow in console: `println()` statements

## Troubleshooting

### No data received
- Check server is running: `curl http://localhost:8000/api/sensors`
- Verify CORS is enabled on server
- Check Processing console for error messages

### Wrong values displayed
- Verify sensor ranges match in both Arduino and Processing
- Check data parsing logic
- Add debug prints to see raw received data

### Connection issues
- Ensure server URL/port is correct
- Check firewall settings
- Try ping/curl to test connectivity

## Recommended Approach

Start with **Option 1 (HTTP Polling)** as it's:
- Easiest to implement
- Works with your existing server
- Easy to debug
- Matches your 5-second update interval

Once that works, you can optimize with WebSockets if needed for real-time updates.

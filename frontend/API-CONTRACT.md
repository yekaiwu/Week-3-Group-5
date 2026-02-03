# Frontend-Backend API Contract

This document defines the exact API contract between the frontend and backend teams for the Plant Health Monitor application.

## Overview

The frontend consumes two REST API endpoints:
1. `GET /api/plant-data` - Fetches complete plant monitoring data
2. `POST /api/plant-config` - Updates plant configuration

## Endpoint 1: Get Plant Data

### Request
```
GET /api/plant-data
```

### Response
Status: `200 OK`
Content-Type: `application/json`

### Response Body Structure

See `mock-data.json` for the complete reference implementation.

Key fields the frontend requires:

```json
{
  "device": {
    "id": "arduino-nano-001",
    "status": "online|offline",
    "lastReading": "ISO 8601 timestamp"
  },
  "plant": {
    "name": "string",
    "nickname": "string|null",
    "type": "tropical|desert|fern|custom",
    "age": "number|null",
    "ageUnit": "months|years",
    "photoUrl": "URL string",
    "photoAlt": "string"
  },
  "sensorReadings": {
    "soilMoisture": {
      "percentage": "number (0-100)",
      "unit": "%",
      "llmReference": "string"
    },
    "airTemperature": {
      "value": "number",
      "unit": "°C",
      "llmReference": "string"
    },
    "airHumidity": {
      "percentage": "number (0-100)",
      "unit": "%",
      "llmReference": "string"
    },
    "lightLevel": {
      "percentage": "number (0-100)",
      "unit": "%",
      "llmReference": "string"
    }
  },
  "llmInsights": {
    "evaporationRate": "number",
    "evaporationUnit": "string",
    "nextWateringTime": "ISO 8601 timestamp",
    "wateringAmount": "string (e.g., '200ml')",
    "contextNote": "string"
  },
  "recommendation": {
    "statusEmoticon": "😊|🥺|🚨|🍂",
    "action": "DO_NOT_WATER|NEED_WATER|SOON_TO_WATER|ROOT_ROT_RISK",
    "humanFriendly": "string",
    "warning": "string|null"
  },
  "llmCareSheet": {
    "title": "string",
    "content": "string (supports newlines)"
  },
  "historicalData": {
    "timeFilterOptions": ["7d", "30d", "all"],
    "sensorLogs": {
      "soilMoisture": [
        {"timestamp": "ISO 8601", "value": "number"}
      ],
      "airTemperature": [
        {"timestamp": "ISO 8601", "value": "number"}
      ],
      "airHumidity": [
        {"timestamp": "ISO 8601", "value": "number"}
      ],
      "lightLevel": [
        {"timestamp": "ISO 8601", "value": "number"}
      ]
    },
    "wateringLogs": [
      {
        "timestamp": "ISO 8601",
        "amount": "string (e.g., '200ml')",
        "notes": "string|null",
        "sensorDataAtWatering": {
          "soilMoisture": "number",
          "airTemp": "number"
        }
      }
    ]
  }
}
```

### Error Response
Status: `500 Internal Server Error` or `503 Service Unavailable`
```json
{
  "error": "Error message string"
}
```

## Endpoint 2: Update Plant Configuration

### Request
```
POST /api/plant-config
Content-Type: application/json
```

### Request Body
```json
{
  "name": "string (required)",
  "nickname": "string|null (optional)",
  "type": "string (required, e.g., 'tropical', 'desert', 'fern')",
  "age": "number|null (optional)",
  "ageUnit": "months|years (optional)",
  "photo": "File object (optional, JPG/PNG max 5MB)"
}
```

### Response - Success
Status: `200 OK`
```json
{
  "message": "Plant configuration updated successfully",
  "photoUrl": "URL to uploaded photo (if photo was provided)"
}
```

### Response - Validation Error
Status: `400 Bad Request`
```json
{
  "error": "Validation error message",
  "field": "field name that failed validation"
}
```

### Response - Server Error
Status: `500 Internal Server Error`
```json
{
  "error": "Internal server error message"
}
```

## Backend Responsibilities

### 1. Arduino Data Collection
- Read raw sensor data from Arduino (analog/digital values)
- Calibrate to human-readable units:
  - Soil moisture: 0-100% (0=dry, 100=saturated)
  - Air temperature: Celsius (°C)
  - Air humidity: 0-100%
  - Light level: 0-100% (0=dark, 100=bright)

### 2. LLM Integration
- Send plant type, sensor data to LLM
- Generate:
  - `llmReference` for each sensor (plant-specific context)
  - `evaporationRate` calculation
  - `nextWateringTime` prediction
  - `wateringAmount` recommendation
  - `contextNote` explanation
  - Complete care sheet (`llmCareSheet`)

### 3. Status Mapping
- Map LLM logic to plant emoticons:
  - 😊 = DO_NOT_WATER (healthy, no action needed)
  - 🥺 = NEED_WATER (soil dry, water soon)
  - 🚨 = ROOT_ROT_RISK (soil oversaturated)
  - 🍂 = SOON_TO_WATER (approaching water time)
- Generate human-friendly recommendation text
- Detect warning conditions (e.g., root rot risk)

### 4. Data Persistence
- Store all sensor readings with timestamps
- Store watering events (manual or automatic)
- Maintain plant configuration
- Handle photo uploads:
  - Validate file type (JPG/PNG) and size (max 5MB)
  - Store photo securely
  - Return public URL in `photoUrl` field

### 5. Historical Data
- Provide time-series data for all 4 sensors
- Support filtering by time range (7d, 30d, all)
- Include complete watering log history

## Data Types & Formats

### Timestamps
All timestamps must be ISO 8601 format:
```
"2026-02-03T14:30:00Z"
```

Frontend will format these for display.

### Percentages
All percentage values are numbers between 0-100 (inclusive):
```json
"percentage": 30
```

### Temperature
Temperature values are numbers in Celsius:
```json
"value": 24
```

### Watering Amount
String with unit (e.g., "200ml", "1 cup"):
```json
"wateringAmount": "200ml"
```

### Plant Emoticons
Exactly one of these Unicode characters:
- 😊 (Happy)
- 🥺 (Thirsty)
- 🚨 (Danger)
- 🍂 (Other)

## Frontend Behavior

### Polling Interval
The frontend polls `GET /api/plant-data` every **1 second**.

Backend should be optimized for frequent requests:
- Consider caching sensor data
- Return cached LLM results when sensor values unchanged
- Use efficient database queries for historical data

### Error Handling
If the API call fails:
- Frontend displays last successfully loaded data (cached)
- User sees "Offline" status
- Auto-retry on next polling interval

### Form Submission
When user saves plant config:
- Frontend validates required fields client-side
- Sends POST request to `/api/plant-config`
- Shows success message on 200 OK
- Refreshes plant data automatically
- Returns to home screen

## CORS Configuration

If frontend and backend run on different ports/domains during development, backend must enable CORS:

```python
# Example for Flask
from flask_cors import CORS
app = Flask(__name__)
CORS(app)
```

```javascript
// Example for Express
const cors = require('cors');
app.use(cors());
```

## Testing the Integration

### 1. Mock Backend
During frontend development, the app uses `mock-data.json` (located in frontend directory).

### 2. Integration Testing
When backend is ready:
1. Start backend server (e.g., `http://localhost:5000`)
2. Update `js/app.js`:
   ```javascript
   const API_BASE_URL = 'http://localhost:5000/api';
   const USE_MOCK_DATA = false;
   ```
3. Frontend will now call real backend endpoints

### 3. Validation Checklist
- [ ] GET /api/plant-data returns valid JSON matching structure
- [ ] All required fields present in response
- [ ] Timestamps are valid ISO 8601 format
- [ ] Sensor values within valid ranges (0-100 for percentages)
- [ ] Plant emoticon is one of: 😊🥺🚨🍂
- [ ] Historical data arrays have timestamp + value objects
- [ ] POST /api/plant-config accepts JSON and returns success
- [ ] Photo upload works (if provided)
- [ ] Error responses return proper HTTP status codes

## Questions?

For frontend-related API questions, refer to:
- `mock-data.json` - Reference implementation
- `js/app.js` - Frontend data handling code
- This document - API contract specification

For backend implementation:
- Backend team owns Arduino, LLM, and data persistence
- Frontend only consumes JSON payloads
- No frontend changes needed for backend updates (as long as API contract is maintained)

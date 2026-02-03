# Plant Health Monitor - Frontend Application

A responsive, mobile-first web application for monitoring plant health using Arduino sensors and LLM-generated care recommendations.

## Features

### Home Screen (Dashboard)
- **Device Status**: Real-time Arduino connection status with visual indicators
- **Plant Profile**: Photo, name, nickname, type, and age display
- **LLM Recommendations**: Plant emoticon status (😊/🥺/🚨/🍂) with human-friendly watering advice
- **Watering Predictions**: Next watering time with countdown timer and recommended amount
- **Sensor Readings**: 4 sensor cards showing:
  - Soil Moisture (%)
  - Air Temperature (°C)
  - Air Humidity (%)
  - Light Level (%)
- **Historical Data**: Individual line charts for each sensor metric with time filters (7d/30d/all)
- **Watering Log**: Complete history of watering events with sensor snapshots

### Plant Configuration Screen
- **Plant Details Form**: Edit plant name, nickname, type, age, and upload photo
- **LLM Care Sheet**: Auto-generated care instructions based on plant type
- **Form Validation**: Client-side validation with helpful error messages

## Directory Structure

```
frontend/
├── index.html              # Main HTML file with both screens
├── mock-data.json          # Simulated backend data for testing
├── css/
│   └── styles.css          # Mobile-first responsive CSS
├── js/
│   └── app.js              # Main JavaScript application logic
└── README.md               # This file
```

## Getting Started

### Prerequisites
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Local web server (for loading the mock JSON data)

### Running the Application

1. **Navigate to the frontend directory**:
   ```bash
   cd frontend
   ```

2. **Start a local web server**:

   **Option 1: Using Python 3**
   ```bash
   python3 -m http.server 8000
   ```

   **Option 2: Using Node.js (if you have npx)**
   ```bash
   npx http-server -p 8000
   ```

   **Option 3: Using PHP**
   ```bash
   php -S localhost:8000
   ```

3. **Open the application**:
   - Navigate to `http://localhost:8000` in your web browser

4. **The app will load with mock data automatically**

## Configuration

### Switching from Mock Data to Real Backend

When your backend API is ready:

1. Open `js/app.js`
2. Find the API configuration section at the top:
   ```javascript
   const API_BASE_URL = '/api'; // Change this to your backend URL
   const USE_MOCK_DATA = true; // Set to false when backend is ready
   ```
3. Update `API_BASE_URL` to your backend endpoint (e.g., `'http://localhost:5000/api'`)
4. Set `USE_MOCK_DATA` to `false`

### Backend API Contract

The frontend expects the backend to provide the following endpoints:

- `GET /api/plant-data` - Returns the complete plant data JSON payload (see mock-data.json for structure)
- `POST /api/plant-config` - Accepts plant configuration updates

The exact JSON structure is defined in `mock-data.json`.

## Key Features Explained

### Auto-Refresh
- Data automatically refreshes every 1 second from the backend
- Countdown timer updates every second
- Loading spinner shows during data fetch

### Responsive Design
- **Mobile**: Single-column layout with stacked components
- **Tablet (768px+)**: 2-column sensor grid and optimized spacing
- **Desktop (1024px+)**: 4-column sensor grid, 2-column charts, horizontal plant profile

### Plant Emoticon Status
The app uses emoticons to indicate plant health:
- 😊 = Happy Plant (no water needed)
- 🥺 = Thirsty Plant (water soon)
- 🚨 = Plant in Danger (root rot risk)
- 🍂 = Other status

### Time Filters
Historical charts support 3 time ranges:
- Last 7 Days
- Last 30 Days
- All Time

### Chart Library
Uses Chart.js 4.4.1 (loaded from CDN) for sensor trend visualization.

## Customization

### Updating Mock Data

To test different scenarios, edit `mock-data.json`:

1. **Change device status**: Set `device.status` to `"online"` or `"offline"`
2. **Update sensor values**: Modify values in `sensorReadings`
3. **Change plant emoticon**: Update `recommendation.statusEmoticon` to 😊/🥺/🚨/🍂
4. **Add historical data**: Append entries to `historicalData.sensorLogs`
5. **Add watering logs**: Append entries to `historicalData.wateringLogs`

### Styling

All styles are in `css/styles.css`:
- Colors, fonts, and spacing can be adjusted
- Mobile-first approach with `@media` queries for larger screens
- Utility classes for common patterns

## Browser Compatibility

- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Accessibility Features

- Semantic HTML structure
- Alt text for images
- ARIA labels for interactive elements
- Keyboard navigation support
- Responsive text sizing

## Performance

- Minimal dependencies (only Chart.js)
- Optimized CSS with mobile-first approach
- Efficient data rendering with vanilla JavaScript
- Auto-refresh with 1-second interval (configurable in app.js)

## Troubleshooting

### Charts not displaying
- Ensure Chart.js CDN is accessible
- Check browser console for JavaScript errors
- Verify historical data exists in mock-data.json

### Photos not loading
- Check that photoUrl in mock-data.json is a valid URL
- For local testing, use online image URLs (e.g., Unsplash)

### Form submission not working
- Verify form validation passes
- Check browser console for errors
- Ensure mock data mode is enabled for testing

## Future Enhancements

When connecting to the real backend:
- Real-time WebSocket updates (replace polling)
- User authentication
- Multiple plant profiles
- Push notifications for watering reminders
- Export historical data (CSV/PDF)
- Advanced analytics and trends

## Support

For questions or issues related to the frontend:
1. Check browser console for errors
2. Verify mock-data.json structure
3. Ensure local web server is running
4. Test in a different browser

## License

This project is part of the Plant Health Monitor system.

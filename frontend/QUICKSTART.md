# Quick Start Guide

Get your Plant Health Monitor frontend running in 30 seconds!

## Steps

1. **Open Terminal** and navigate to the frontend directory:
   ```bash
   cd /Users/jay/Downloads/Week-3-Group-5/frontend
   ```

2. **Start a local web server**:
   ```bash
   python3 -m http.server 8000
   ```

3. **Open your browser** and go to:
   ```
   http://localhost:8000
   ```

4. **You should see**:
   - Plant Health Monitor dashboard
   - Peace Lily plant profile with photo
   - Happy plant emoticon (😊)
   - Sensor readings (soil moisture, temperature, humidity, light)
   - Watering prediction and countdown
   - Historical charts
   - Watering history log

## Test the Features

### View Dashboard
- The home screen loads automatically with mock data
- All sensor readings update every 1 second
- Countdown timer counts down to next watering

### Edit Plant Details
1. Click "Edit Plant Details" button
2. Change plant name, nickname, type, or age
3. Upload a new photo (optional)
4. Click "Save Plant Details"
5. You'll see a success message and return to home

### View Historical Charts
- Scroll down to see 4 separate sensor charts
- Click time filter buttons: "Last 7 Days", "Last 30 Days", "All Time"
- Charts update based on selected filter

### View Watering History
- Scroll to the bottom of the page
- See past watering events with timestamps and sensor data

## Customizing Mock Data

Edit `mock-data.json` to test different scenarios:

### Test Offline Status
```json
"device": {
  "status": "offline"
}
```

### Test Thirsty Plant
```json
"recommendation": {
  "statusEmoticon": "🥺",
  "action": "NEED_WATER"
}
```

### Test Root Rot Warning
```json
"recommendation": {
  "statusEmoticon": "🚨",
  "action": "ROOT_ROT_RISK",
  "warning": "Root rot risk! Soil is oversaturated at 85% — stop watering immediately."
}
```

## Connect to Real Backend

When your backend team is ready:

1. Open `js/app.js`
2. Change line 5:
   ```javascript
   const USE_MOCK_DATA = false;
   ```
3. Change line 4 to your backend URL:
   ```javascript
   const API_BASE_URL = 'http://your-backend-url:5000/api';
   ```
4. Reload the page

## Troubleshooting

**Problem**: Page shows "This site can't be reached"
**Solution**: Make sure the web server is running (step 2)

**Problem**: Charts not showing
**Solution**: Check internet connection (Chart.js loads from CDN)

**Problem**: Mock data not loading
**Solution**: Ensure you're using a web server (not opening index.html directly)

**Problem**: Photos not displaying
**Solution**: Check that the photoUrl in mock-data.json is accessible

## Next Steps

- Read the full README.md for detailed documentation
- Customize the mock data to test different scenarios
- Connect to your backend API when ready
- Share feedback with your team

Enjoy monitoring your plants! 🌱

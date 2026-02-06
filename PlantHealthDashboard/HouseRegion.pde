/**
 * HouseRegion class
 * Represents a clickable region in the house with sensor data
 * Data points: 48 (30-minute intervals for 24 hours)
 * Index 0 = current time, Index 47 = 24 hours ago
 */
class HouseRegion {
  String name;
  float x, y, width, height;
  boolean isHovered = false;
  String csvFilePath;

  // Raw sensor data from CSV (all 30-minute intervals)
  ArrayList<Float> rawHumidity;
  ArrayList<Float> rawTemperature;
  ArrayList<Float> rawLight;
  ArrayList<String> rawTimestamps;

  // Current timeframe data (changes based on timeframe mode)
  float[] humidityHistory;
  float[] temperatureHistory;
  float[] lightHistory;
  String[] timestampHistory;  // Timestamps for current timeframe

  /**
   * Constructor
   */
  HouseRegion(String name, float x, float y, float width, float height, String csvFilePath) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.csvFilePath = csvFilePath;

    // Initialize raw data storage
    rawHumidity = new ArrayList<Float>();
    rawTemperature = new ArrayList<Float>();
    rawLight = new ArrayList<Float>();
    rawTimestamps = new ArrayList<String>();

    // Initialize with hourly view (48 data points)
    humidityHistory = new float[48];
    temperatureHistory = new float[48];
    lightHistory = new float[48];
    timestampHistory = new String[48];
  }

  /**
   * Load sensor data from CSV file
   */
  void loadSensorData() {
    try {
      // Use sketchPath() to get the full path to the CSV file
      String fullPath = sketchPath(csvFilePath);
      println("Loading data for " + name + " from " + fullPath);
      String[] lines = loadStrings(fullPath);

      // Skip header line
      for (int i = 1; i < lines.length; i++) {
        String[] parts = split(lines[i], ',');
        if (parts.length >= 4) {
          rawTimestamps.add(parts[0]);
          rawTemperature.add(Float.parseFloat(parts[1]));
          rawHumidity.add(Float.parseFloat(parts[2]));
          rawLight.add(Float.parseFloat(parts[3]));
        }
      }

      println("Loaded " + rawHumidity.size() + " data points for " + name);

      // Initialize with hourly view (last 48 points)
      updateTimeframeData(0);

    } catch (Exception e) {
      println("Error loading CSV for " + name + ": " + e.getMessage());
      // Generate fallback data
      generateHistoricalData();
    }
  }

  /**
   * Find index of timestamp closest to current system time
   */
  int findCurrentTimeIndex() {
    if (rawTimestamps.size() == 0) return rawTimestamps.size() - 1;

    // Get current system time
    String currentTime = String.format("%04d-%02d-%02dT%02d:%02d:00",
                                       year(), month(), day(), hour(), minute());

    // Binary search or linear search for closest timestamp
    int closestIndex = rawTimestamps.size() - 1;
    long minDiff = Long.MAX_VALUE;

    for (int i = rawTimestamps.size() - 1; i >= 0; i--) {
      String timestamp = rawTimestamps.get(i);
      // Compare timestamps (they're in ISO format so lexicographic comparison works)
      int cmp = currentTime.compareTo(timestamp);

      if (cmp >= 0) {
        // Current time is after or equal to this timestamp
        closestIndex = i;
        break;
      }
    }

    return closestIndex;
  }

  /**
   * Update data arrays based on timeframe mode
   * 0 = Hourly (last 48 points, 30-min intervals = 24 hours)
   * 1 = Daily (last 30 days, aggregated)
   * 2 = Monthly (last 12 months, aggregated)
   */
  void updateTimeframeData(int mode) {
    if (rawHumidity.size() == 0) {
      generateHistoricalData();
      return;
    }

    if (mode == 0) {
      // Hourly: 48 data points (24 hours) leading up to current system time
      // Each reading is 30 minutes apart
      // Shows the past 24 hours from now
      // Example: If current time is Feb 6 15:30, shows Feb 5 15:30 - Feb 6 15:30

      // Find the index closest to current time
      int currentIndex = findCurrentTimeIndex();

      int dataSize = min(48, currentIndex + 1);
      humidityHistory = new float[dataSize];
      temperatureHistory = new float[dataSize];
      lightHistory = new float[dataSize];
      timestampHistory = new String[dataSize];

      int startIndex = max(0, currentIndex - 47);  // Go back 47 readings (23.5 hours)
      for (int i = 0; i < dataSize; i++) {
        // i=0 = current time (most recent), i=47 = 24 hours ago
        int sourceIndex = currentIndex - i;  // Reverse order from current time
        if (sourceIndex >= 0 && sourceIndex < rawHumidity.size()) {
          humidityHistory[i] = rawHumidity.get(sourceIndex);
          temperatureHistory[i] = rawTemperature.get(sourceIndex);
          lightHistory[i] = rawLight.get(sourceIndex);
          timestampHistory[i] = rawTimestamps.get(sourceIndex);
        }
      }
    } else if (mode == 1) {
      // Daily: last 30 days from the most recent data in CSV
      // Each day has 48 readings (30-minute intervals)
      // Shows the most recent 30 days available in the CSV
      // Example: If CSV ends on Dec 31, 2025, shows Dec 2 - Dec 31, 2025
      int numDays = min(30, rawHumidity.size() / 48);
      humidityHistory = new float[numDays];
      temperatureHistory = new float[numDays];
      lightHistory = new float[numDays];
      timestampHistory = new String[numDays];

      // Start from the most recent data and work backwards day by day
      for (int day = 0; day < numDays; day++) {
        // day 0 = most recent day (last 48 readings)
        // day 1 = previous day (readings 49-96 from end)
        // day 29 = 30 days ago (readings 1393-1440 from end)
        int dayStartIndex = rawHumidity.size() - ((day + 1) * 48);

        if (dayStartIndex < 0) break;

        float humSum = 0, tempSum = 0, lightSum = 0;
        int count = 0;

        for (int i = 0; i < 48 && dayStartIndex + i < rawHumidity.size(); i++) {
          humSum += rawHumidity.get(dayStartIndex + i);
          tempSum += rawTemperature.get(dayStartIndex + i);
          lightSum += rawLight.get(dayStartIndex + i);
          count++;
        }

        if (count > 0) {
          // Store in order (index 0 = most recent day)
          humidityHistory[day] = humSum / count;
          temperatureHistory[day] = tempSum / count;
          lightHistory[day] = lightSum / count;
          // Store the first timestamp of the day (at noon for better representation)
          int noonIndex = dayStartIndex + 24;  // 24 half-hours = noon
          if (noonIndex >= 0 && noonIndex < rawTimestamps.size()) {
            timestampHistory[day] = rawTimestamps.get(noonIndex);
          } else if (dayStartIndex >= 0 && dayStartIndex < rawTimestamps.size()) {
            timestampHistory[day] = rawTimestamps.get(dayStartIndex);
          }
        }
      }
    } else if (mode == 2) {
      // Monthly: Show all 12 months from the most recent data in CSV
      // CSV has 365 days = 12 months (17,520 readings at 30-min intervals)
      // Shows the most recent 12 months available in the CSV
      // Example: If CSV ends on Dec 31, 2025, shows Jan 2025 - Dec 2025
      int totalDays = rawHumidity.size() / 48;  // Total days of data available
      int numMonths = min(12, max(1, totalDays / 30));  // Calculate months (at least 1)

      humidityHistory = new float[numMonths];
      temperatureHistory = new float[numMonths];
      lightHistory = new float[numMonths];
      timestampHistory = new String[numMonths];

      // Average days per month (accounting for actual data)
      float daysPerMonth = (float)totalDays / numMonths;
      int readingsPerMonth = (int)(daysPerMonth * 48);  // 48 readings per day

      // Start from the most recent data and work backwards month by month
      for (int month = 0; month < numMonths; month++) {
        // month 0 = most recent month (e.g., December 2025)
        // month 1 = previous month (e.g., November 2025)
        // month 11 = 12 months ago (e.g., January 2025)
        int monthEndIndex = rawHumidity.size() - (month * readingsPerMonth);
        int monthStartIndex = max(0, monthEndIndex - readingsPerMonth);

        if (monthStartIndex >= rawHumidity.size()) break;

        float humSum = 0, tempSum = 0, lightSum = 0;
        int count = 0;

        for (int i = monthStartIndex; i < monthEndIndex && i < rawHumidity.size(); i++) {
          humSum += rawHumidity.get(i);
          tempSum += rawTemperature.get(i);
          lightSum += rawLight.get(i);
          count++;
        }

        if (count > 0) {
          // Store in order (index 0 = most recent month)
          humidityHistory[month] = humSum / count;
          temperatureHistory[month] = tempSum / count;
          lightHistory[month] = lightSum / count;
          // Store timestamp from the middle of the month for better representation
          int midMonthIndex = (monthStartIndex + monthEndIndex) / 2;
          if (midMonthIndex >= 0 && midMonthIndex < rawTimestamps.size()) {
            timestampHistory[month] = rawTimestamps.get(midMonthIndex);
          } else if (monthStartIndex >= 0 && monthStartIndex < rawTimestamps.size()) {
            timestampHistory[month] = rawTimestamps.get(monthStartIndex);
          }
        }
      }
    }
  }

  /**
   * Get maximum time index for current timeframe
   */
  int getMaxTimeIndex(int mode) {
    return humidityHistory.length - 1;
  }

  /**
   * Get time label for slider based on timeframe mode
   * Now uses actual CSV timestamps for better accuracy
   */
  String getTimeLabel(int index, int mode) {
    if (index < 0 || index >= timestampHistory.length || timestampHistory[index] == null) {
      return "Unknown";
    }

    String timestamp = timestampHistory[index];

    if (mode == 0) {
      // Hourly - show date and time
      if (index == 0) return "Now: " + extractTime(timestamp);
      return extractDate(timestamp) + " at " + extractTime(timestamp);
    } else if (mode == 1) {
      // Daily - show date
      if (index == 0) return "Today: " + extractDate(timestamp);
      return extractDate(timestamp);
    } else {
      // Monthly - show month and year
      if (index == 0) return "Current: " + extractMonthYear(timestamp);
      return extractMonthYear(timestamp);
    }
  }

  /**
   * Generate 24 hours of mock historical data (fallback)
   */
  void generateHistoricalData() {
    float timeOffset = random(1000);
    timestampHistory = new String[48];

    for (int i = 0; i < 48; i++) {
      float t = timeOffset + (47 - i) * 0.05f;
      humidityHistory[i] = map(noise(t), 0, 1, 30, 90);
      float tempBase = map(noise(t + 100), 0, 1, 15, 32);
      float hoursAgo = i * 0.5f;
      float hourOfDay = (hour() - hoursAgo + 24) % 24;
      float dayNightEffect = sin(map(hourOfDay, 0, 24, 0, TWO_PI)) * 3.0f;
      temperatureHistory[i] = constrain(tempBase + dayNightEffect, 15, 35);
      float lightBase = map(noise(t + 200), 0, 1, 0, 1000);
      float lightDayNight;
      if (hourOfDay >= 6 && hourOfDay <= 20) {
        lightDayNight = 1.0f;
      } else {
        lightDayNight = 0.2f;
      }
      lightHistory[i] = lightBase * lightDayNight;

      // Generate fallback timestamp
      int h = int(hourOfDay);
      int m = int((hourOfDay - h) * 60);
      timestampHistory[i] = "2025-01-01T" + nf(h, 2) + ":" + nf(m, 2) + ":00";
    }
  }

  /**
   * Check if mouse is hovering over this region
   */
  void checkHover(float mx, float my) {
    isHovered = contains(mx, my);
  }

  /**
   * Check if point is inside this region
   */
  boolean contains(float mx, float my) {
    return mx >= x && mx <= x + width && my >= y && my <= y + height;
  }

  /**
   * Draw 3D growing cubes visualization (vertical bar chart style)
   */
  void draw3DGrowingSquares(float x, float y, float w, float h, int timeIndex, float camRotX, float camRotY, float camRotZ) {
    pushStyle();

    // Get current values at this time index
    float humidityValue = humidityHistory[timeIndex];
    float tempValue = temperatureHistory[timeIndex];
    float lightValue = lightHistory[timeIndex];

    // Background panel
    fill(30, 35, 45, 200);
    stroke(80);
    strokeWeight(1);
    rect(x, y, w, h, 8);

    // Title
    fill(200);
    textAlign(LEFT, TOP);
    textSize(14);
    text("Sensor Readings", x + 15, y + 10);

    // Calculate value-based brightness (0.0 to 1.0, where 1.0 is brightest)
    // Using wider range (0.15 to 1.0) for more dramatic color variation
    float humidityBrightness = map(humidityValue, 0, 100, 0.15, 1.0);
    float tempBrightness = map(tempValue, 15, 35, 0.15, 1.0);
    float lightBrightness = map(lightValue, 0, 1000, 0.15, 1.0);

    // Legend - show color meanings
    float legendX = x + 15;
    float legendY = y + 32;
    float legendBoxSize = 12;
    float legendSpacing = 100;

    textSize(10);
    textAlign(LEFT, CENTER);

    // Humidity legend (blue) - use medium brightness
    fill(80 * 0.65, 150 * 0.65, 220 * 0.65);
    noStroke();
    rect(legendX, legendY, legendBoxSize, legendBoxSize, 2);
    fill(200);
    text("Humidity", legendX + legendBoxSize + 5, legendY + legendBoxSize/2);

    // Temperature legend (orange) - use medium brightness
    fill(255 * 0.65, 100 * 0.65, 50 * 0.65);
    rect(legendX + legendSpacing, legendY, legendBoxSize, legendBoxSize, 2);
    fill(200);
    text("Temperature", legendX + legendSpacing + legendBoxSize + 5, legendY + legendBoxSize/2);

    // Light legend (yellow) - use medium brightness
    fill(255 * 0.65, 220 * 0.65, 80 * 0.65);
    rect(legendX + legendSpacing * 2, legendY, legendBoxSize, legendBoxSize, 2);
    fill(200);
    text("Light", legendX + legendSpacing * 2 + legendBoxSize + 5, legendY + legendBoxSize/2);

    // Layout calculations - move labels to bottom (more space for cubes)
    float labelY = y + h - 35;
    float labelSpacing = (w - 140) / 3;  // Reduce width to make space for value scale on right

    // Position labels evenly across width - shifted left to make room for legend
    float humidityLabelX = x + labelSpacing * 0.5f;
    float tempLabelX = x + labelSpacing * 1.5f;
    float lightLabelX = x + labelSpacing * 2.5f;

    // 3D visualization area (above labels, with more space for taller cubes)
    float viz3DAreaTop = y + 65;  // More space at top for legend
    float viz3DAreaBottom = labelY - 10;  // Less gap above labels to maximize cube space
    float viz3DHeight = viz3DAreaBottom - viz3DAreaTop;

    float cubeWidth = min(50.0f, w / 8.0f);  // Cube width/depth
    float maxCubeHeight = viz3DHeight;  // Use full available height for taller cubes

    // Calculate cube heights based on values (grow upwards)
    float humidityHeight = map(humidityValue, 0, 100, maxCubeHeight * 0.15f, maxCubeHeight);
    float tempHeight = map(tempValue, 15, 35, maxCubeHeight * 0.15f, maxCubeHeight);
    float lightHeight = map(lightValue, 0, 1000, maxCubeHeight * 0.15f, maxCubeHeight);

    // Enable 3D lighting for better depth perception (simplified for performance)
    hint(ENABLE_DEPTH_TEST);
    lights();
    ambientLight(100, 100, 100);  // Single ambient light for better performance

    // Fixed camera angle for all cubes (identical orientation)
    // For perfectly horizontal bottom edges and vertical side edges:
    // fixedRotX = 0 (no tilt - keeps edges horizontal and vertical)
    // fixedRotY = rotation for 3D perspective
    //   0.0 = face forward, -0.5 = show left side, +0.5 = show right side, PI/4 = 45° angle
    float fixedRotX = 0.0f;  // No tilt - bottom edges are perfectly horizontal, sides are perfectly vertical
    float fixedRotY = PI/4;  // 45-degree angle to show corner perspective (all cubes face same way)

    // Baseline Y position (where all cubes sit - perfectly horizontal)
    float baselineY = viz3DAreaBottom;

    // Draw each cube aligned above its label with same viewing angle
    // All cubes share the same baseline - bottom edges are perfectly horizontal
    // Strategy: Translate to position bottom at baseline, THEN rotate

    // Humidity cube (blue) - aligned above "Humidity" label - brightness varies with value
    pushMatrix();
    translate(humidityLabelX, baselineY - humidityHeight/2, 0);  // Position center so bottom is at baseline
    rotateX(fixedRotX);
    rotateY(fixedRotY);
    fill(80 * humidityBrightness, 150 * humidityBrightness, 220 * humidityBrightness);
    stroke(60 * humidityBrightness, 100 * humidityBrightness, 160 * humidityBrightness);
    strokeWeight(1);  // Reduced stroke weight for better performance
    box(cubeWidth, humidityHeight, cubeWidth);
    popMatrix();

    // Temperature cube (orange) - aligned above "Temperature" label - brightness varies with value
    pushMatrix();
    translate(tempLabelX, baselineY - tempHeight/2, 0);  // Position center so bottom is at baseline
    rotateX(fixedRotX);
    rotateY(fixedRotY);
    fill(255 * tempBrightness, 100 * tempBrightness, 50 * tempBrightness);
    stroke(180 * tempBrightness, 60 * tempBrightness, 20 * tempBrightness);
    strokeWeight(1);  // Reduced stroke weight for better performance
    box(cubeWidth, tempHeight, cubeWidth);
    popMatrix();

    // Light cube (yellow) - aligned above "Light" label - brightness varies with value
    pushMatrix();
    translate(lightLabelX, baselineY - lightHeight/2, 0);  // Position center so bottom is at baseline
    rotateX(fixedRotX);
    rotateY(fixedRotY);
    fill(255 * lightBrightness, 220 * lightBrightness, 80 * lightBrightness);
    stroke(200 * lightBrightness, 160 * lightBrightness, 40 * lightBrightness);
    strokeWeight(1);  // Reduced stroke weight for better performance
    box(cubeWidth, lightHeight, cubeWidth);
    popMatrix();

    // Draw 3D text labels below cubes (rotated to be readable from top view)
    // Keep depth test enabled so text is part of 3D scene
    textAlign(CENTER, CENTER);

    // Humidity label and value - drawn in 3D space
    pushMatrix();
    translate(humidityLabelX, baselineY + 25, 0);  // Position below cube
    rotateX(-HALF_PI);  // Rotate to lie flat (readable from top)
    rotateZ(fixedRotY);  // Counter-rotate to face forward
    fill(200);
    textSize(11);
    text("Humidity", 0, -7);
    fill(100, 200, 255);
    textSize(13);
    text(nf(humidityValue, 0, 1) + "%", 0, 7);
    popMatrix();

    // Temperature label and value - drawn in 3D space
    pushMatrix();
    translate(tempLabelX, baselineY + 25, 0);  // Position below cube
    rotateX(-HALF_PI);  // Rotate to lie flat (readable from top)
    rotateZ(fixedRotY);  // Counter-rotate to face forward
    fill(200);
    textSize(11);
    text("Temperature", 0, -7);
    fill(255, 150, 100);
    textSize(13);
    text(nf(tempValue, 0, 1) + "°C", 0, 7);
    popMatrix();

    // Light label and value - drawn in 3D space
    pushMatrix();
    translate(lightLabelX, baselineY + 25, 0);  // Position below cube
    rotateX(-HALF_PI);  // Rotate to lie flat (readable from top)
    rotateZ(fixedRotY);  // Counter-rotate to face forward
    fill(200);
    textSize(11);
    text("Light", 0, -7);
    fill(255, 240, 150);
    textSize(13);
    text(nf(lightValue, 0, 0) + " lux", 0, 7);
    popMatrix();

    // Disable lights and depth test for 2D UI elements (legend)
    noLights();
    hint(DISABLE_DEPTH_TEST);

    // ========================================
    // HEATMAP LEGEND (Right side)
    // ========================================
    float heatmapX = x + w - 120;
    float heatmapY = y + 65;
    float heatmapWidth = 100;
    float heatmapHeight = 180;

    // Heatmap background panel
    fill(25, 30, 40, 200);
    stroke(80);
    strokeWeight(1);
    rect(heatmapX, heatmapY, heatmapWidth, heatmapHeight, 5);

    // Title
    fill(200);
    textAlign(CENTER, TOP);
    textSize(11);
    text("Value Scale", heatmapX + heatmapWidth/2, heatmapY + 8);

    // Draw gradient bars for each sensor type
    float barStartY = heatmapY + 30;
    float barWidth = 25;
    float barHeight = 120;
    float barSpacing = 8;

    // Calculate positions for 3 bars centered in the panel
    float totalBarWidth = (barWidth * 3) + (barSpacing * 2);
    float barStartX = heatmapX + (heatmapWidth - totalBarWidth) / 2;

    // Humidity gradient bar (blue)
    float humBarX = barStartX;
    int gradientSteps = 40;  // More steps for smoother gradient
    float stepHeight = barHeight / gradientSteps;
    for (int i = 0; i < gradientSteps; i++) {
      // Bottom = dark (low value), Top = bright (high value)
      // Using wider brightness range (0.15 to 1.0) for more dramatic variation
      float brightness = map(i, 0, gradientSteps - 1, 0.15, 1.0);
      fill(80 * brightness, 150 * brightness, 220 * brightness);
      noStroke();
      rect(humBarX, barStartY + barHeight - (i + 1) * stepHeight, barWidth, stepHeight);
    }
    // Label
    fill(200);
    textAlign(CENTER, TOP);
    textSize(9);
    text("Hum", humBarX + barWidth/2, barStartY + barHeight + 3);

    // Temperature gradient bar (orange)
    float tempBarX = humBarX + barWidth + barSpacing;
    for (int i = 0; i < gradientSteps; i++) {
      float brightness = map(i, 0, gradientSteps - 1, 0.15, 1.0);
      fill(255 * brightness, 100 * brightness, 50 * brightness);
      noStroke();
      rect(tempBarX, barStartY + barHeight - (i + 1) * stepHeight, barWidth, stepHeight);
    }
    // Label
    fill(200);
    text("Temp", tempBarX + barWidth/2, barStartY + barHeight + 3);

    // Light gradient bar (yellow)
    float lightBarX = tempBarX + barWidth + barSpacing;
    for (int i = 0; i < gradientSteps; i++) {
      float brightness = map(i, 0, gradientSteps - 1, 0.15, 1.0);
      fill(255 * brightness, 220 * brightness, 80 * brightness);
      noStroke();
      rect(lightBarX, barStartY + barHeight - (i + 1) * stepHeight, barWidth, stepHeight);
    }
    // Label
    fill(200);
    text("Light", lightBarX + barWidth/2, barStartY + barHeight + 3);

    // Add "High" and "Low" labels
    fill(180);
    textSize(9);
    textAlign(RIGHT, CENTER);
    text("High", heatmapX + 15, barStartY);
    text("Low", heatmapX + 15, barStartY + barHeight);

    popStyle();
  }

  /**
   * Draw sensor graph for analytics view with timeframe support
   */
  public void drawSensorGraph(String sensorType, float x, float y, float w, float h, int timeframeMode) {
    pushStyle();

    // Background
    fill(30, 35, 45, 200);
    stroke(80);
    strokeWeight(1);
    rect(x, y, w, h, 8);

    // Title with timeframe label
    String timeframeLabel;
    if (timeframeMode == 0) {
      timeframeLabel = "Last 24 Hours (30-min intervals)";
    } else if (timeframeMode == 1) {
      timeframeLabel = "Last 30 Days (daily averages)";
    } else {
      timeframeLabel = "Last 12 Months (monthly averages)";
    }

    fill(200);
    textAlign(LEFT, TOP);
    textSize(16);
    text(sensorType + " (" + timeframeLabel + ")", x + 15, y + 10);

    // Graph area
    float graphX = x + 80;
    float graphY = y + 50;
    float graphW = w - 180;
    float graphH = h - 100;

    // Graph background
    fill(25, 30, 40);
    noStroke();
    rect(graphX, graphY, graphW, graphH);

    // Grid lines
    stroke(50, 55, 65);
    strokeWeight(1);
    for (int i = 0; i <= 4; i++) {
      float lineY = graphY + (graphH / 4) * i;
      line(graphX, lineY, graphX + graphW, lineY);
    }

    // Get data array
    float[] data;
    float minVal, maxVal;
    int lineColor;

    if (sensorType.equals("Humidity")) {
      data = humidityHistory;
      minVal = 0;
      maxVal = 100;
      lineColor = color(100, 180, 255);
    } else if (sensorType.equals("Temperature")) {
      data = temperatureHistory;
      minVal = 15;
      maxVal = 35;
      lineColor = color(255, 120, 50);
    } else {  // Light
      data = lightHistory;
      minVal = 0;
      maxVal = 1000;
      lineColor = color(255, 240, 150);
    }

    // Draw line graph
    // Timeline: index 0 = most recent (RIGHT), index dataLength-1 = oldest (LEFT)
    int dataLength = data.length;
    noFill();
    stroke(lineColor);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < dataLength; i++) {
      // Correct mapping: i=0 → RIGHT (graphW), i=max → LEFT (0)
      float px = graphX + map(i, 0, dataLength - 1, graphW, 0);
      float py = graphY + graphH - map(data[i], minVal, maxVal, 0, graphH);
      vertex(px, py);
    }
    endShape();

    // Draw data points (skip some for readability on larger datasets)
    fill(lineColor);
    noStroke();
    int pointInterval = dataLength > 48 ? max(1, dataLength / 24) : 2;
    for (int i = 0; i < dataLength; i += pointInterval) {
      float px = graphX + map(i, 0, dataLength - 1, graphW, 0);
      float py = graphY + graphH - map(data[i], minVal, maxVal, 0, graphH);
      circle(px, py, 6);
    }

    // Y-axis labels
    fill(150);
    textAlign(RIGHT, CENTER);
    textSize(11);
    for (int i = 0; i <= 4; i++) {
      float value = map(i, 0, 4, minVal, maxVal);
      float labelY = graphY + graphH - (graphH / 4) * i;
      String unit = sensorType.equals("Temperature") ? "°C" :
                    sensorType.equals("Humidity") ? "%" : " lux";
      text(nf(value, 0, 0) + unit, graphX - 10, labelY);
    }

    // X-axis labels (adapt to timeframe) - using actual CSV timestamps
    // Timeline: RIGHT = index 0 (most recent), LEFT = index max (oldest)
    textAlign(CENTER, TOP);
    textSize(13);  // Increased x-axis label size
    if (timeframeMode == 0) {
      // Hourly: show actual times (every 4 hours in 24-hour format)
      for (int hoursAgo = 0; hoursAgo <= 24; hoursAgo += 4) {
        int index = min(hoursAgo * 2, dataLength - 1);  // 2 readings per hour
        if (index < timestampHistory.length && timestampHistory[index] != null) {
          float labelX = graphX + map(index, 0, dataLength - 1, graphW, 0);  // i=0 right, i=max left
          String timeLabel = extractTime(timestampHistory[index]);
          text(timeLabel, labelX, graphY + graphH + 5);
        }
      }
    } else if (timeframeMode == 1) {
      // Daily: show actual dates (every ~5 days)
      int step = max(1, dataLength / 6);  // Show ~6 labels
      for (int i = 0; i < dataLength; i += step) {
        if (i < timestampHistory.length && timestampHistory[i] != null) {
          float labelX = graphX + map(i, 0, dataLength - 1, graphW, 0);  // i=0 right, i=max left
          String dateLabel = extractDate(timestampHistory[i]);
          text(dateLabel, labelX, graphY + graphH + 5);
        }
      }
    } else {
      // Monthly: show actual month names
      int step = max(1, dataLength / 6);  // Show ~6 labels
      for (int i = 0; i < dataLength; i += step) {
        if (i < timestampHistory.length && timestampHistory[i] != null) {
          float labelX = graphX + map(i, 0, dataLength - 1, graphW, 0);  // i=0 right, i=max left
          String monthLabel = extractMonth(timestampHistory[i]);
          text(monthLabel, labelX, graphY + graphH + 5);
        }
      }
    }

    // Statistics
    float statsX = graphX + graphW + 20;
    float statsY = graphY;

    fill(180);
    textAlign(LEFT, TOP);
    textSize(12);
    text("Statistics:", statsX, statsY);

    float avg = calculateAverage(data);
    float stdDev = calculateStdDev(data, avg);
    float minValue = min(data);
    float maxValue = max(data);

    fill(150);
    textSize(10);
    int lineHeight = 18;
    String unit = sensorType.equals("Temperature") ? "°C" :
                  sensorType.equals("Humidity") ? "%" : " lux";

    text("Avg: " + nf(avg, 0, 1) + unit, statsX, statsY + lineHeight);
    text("Std: " + nf(stdDev, 0, 1) + unit, statsX, statsY + lineHeight * 2);
    text("Min: " + nf(minValue, 0, 1) + unit, statsX, statsY + lineHeight * 3);
    text("Max: " + nf(maxValue, 0, 1) + unit, statsX, statsY + lineHeight * 4);

    popStyle();
  }

  /**
   * Calculate average of array
   */
  public float calculateAverage(float[] data) {
    float sum = 0;
    for (float val : data) {
      sum += val;
    }
    return sum / data.length;
  }

  /**
   * Calculate standard deviation
   */
  public float calculateStdDev(float[] data, float avg) {
    float sumSquaredDiff = 0;
    for (float val : data) {
      float diff = val - avg;
      sumSquaredDiff += diff * diff;
    }
    return sqrt(sumSquaredDiff / data.length);
  }

  // Note: Timestamp helper functions (extractTime, extractDate, extractMonth, extractMonthYear)
  // are now defined globally in the main sketch file for easier access and debugging
}

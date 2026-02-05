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
  String plantType;
  PImage plantImage;
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

  // Plant health thresholds (specific to plant type)
  float optimalHumidityMin, optimalHumidityMax;
  float optimalTempMin, optimalTempMax;
  float optimalLightMin, optimalLightMax;

  /**
   * Constructor
   */
  HouseRegion(String name, float x, float y, float width, float height, String plantType, String csvFilePath) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.plantType = plantType;
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

    // Load plant image
    loadPlantImage();

    // Set plant-specific optimal conditions
    setPlantOptimalConditions();
  }

  /**
   * Load plant image
   */
  void loadPlantImage() {
    try {
      String filename = plantType.toLowerCase().replace(" ", "_") + ".png";
      plantImage = loadImage(filename);
      println("Loaded plant image: " + filename);
    } catch (Exception e) {
      println("Could not load image for " + plantType);
      plantImage = null;
    }
  }

  /**
   * Set optimal conditions based on plant type
   */
  void setPlantOptimalConditions() {
    switch (plantType) {
      case "Rose":
        optimalHumidityMin = 50;
        optimalHumidityMax = 70;
        optimalTempMin = 15;
        optimalTempMax = 25;
        optimalLightMin = 400;
        optimalLightMax = 800;
        break;
      case "Banana":
        optimalHumidityMin = 60;
        optimalHumidityMax = 80;
        optimalTempMin = 20;
        optimalTempMax = 30;
        optimalLightMin = 600;
        optimalLightMax = 1000;
        break;
      case "Tomato Plant":
        optimalHumidityMin = 60;
        optimalHumidityMax = 80;
        optimalTempMin = 20;
        optimalTempMax = 30;
        optimalLightMin = 600;
        optimalLightMax = 1000;
        break;
      case "Water Lily":
        optimalHumidityMin = 70;
        optimalHumidityMax = 90;
        optimalTempMin = 20;
        optimalTempMax = 28;
        optimalLightMin = 300;
        optimalLightMax = 700;
        break;
      default:
        optimalHumidityMin = 40;
        optimalHumidityMax = 70;
        optimalTempMin = 18;
        optimalTempMax = 28;
        optimalLightMin = 200;
        optimalLightMax = 800;
    }
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
      // Hourly: last 48 data points from the most recent data in CSV (24 hours)
      // Each reading is 30 minutes apart
      // Shows the most recent 24 hours available in the CSV
      // Example: If CSV ends at Dec 31 23:30, shows Dec 31 00:00 - Dec 31 23:30
      int dataSize = min(48, rawHumidity.size());
      humidityHistory = new float[dataSize];
      temperatureHistory = new float[dataSize];
      lightHistory = new float[dataSize];
      timestampHistory = new String[dataSize];

      int startIndex = max(0, rawHumidity.size() - 48);
      for (int i = 0; i < dataSize; i++) {
        // i=0 = most recent reading, i=47 = 24 hours ago
        int sourceIndex = startIndex + (dataSize - 1 - i);  // Reverse order
        humidityHistory[i] = rawHumidity.get(sourceIndex);
        temperatureHistory[i] = rawTemperature.get(sourceIndex);
        lightHistory[i] = rawLight.get(sourceIndex);
        timestampHistory[i] = rawTimestamps.get(sourceIndex);
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

    // Layout calculations - move labels to bottom
    float labelY = y + h - 40;
    float labelSpacing = w / 3;

    // Position labels evenly across width
    float humidityLabelX = x + labelSpacing * 0.5f;
    float tempLabelX = x + labelSpacing * 1.5f;
    float lightLabelX = x + labelSpacing * 2.5f;

    // 3D visualization area (above labels, with more space at top)
    float viz3DAreaTop = y + 35;
    float viz3DAreaBottom = labelY - 50;  // More space above labels
    float viz3DHeight = viz3DAreaBottom - viz3DAreaTop;

    float cubeWidth = min(50.0f, w / 8.0f);  // Cube width/depth
    float maxCubeHeight = viz3DHeight * 0.85f;

    // Calculate cube heights based on values (grow upwards)
    float humidityHeight = map(humidityValue, 0, 100, maxCubeHeight * 0.15f, maxCubeHeight);
    float tempHeight = map(tempValue, 15, 35, maxCubeHeight * 0.15f, maxCubeHeight);
    float lightHeight = map(lightValue, 0, 1000, maxCubeHeight * 0.15f, maxCubeHeight);

    // Enable 3D lighting for better depth perception
    hint(ENABLE_DEPTH_TEST);
    lights();
    ambientLight(80, 80, 80);
    directionalLight(200, 200, 200, -0.5f, 0.5f, -1);

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

    // Humidity cube (blue) - aligned above "Humidity" label
    pushMatrix();
    translate(humidityLabelX, baselineY - humidityHeight/2, 0);  // Position center so bottom is at baseline
    rotateX(fixedRotX);
    rotateY(fixedRotY);
    fill(80, 150, 220);
    stroke(60, 100, 160);  // Darker blue edges
    strokeWeight(2);
    box(cubeWidth, humidityHeight, cubeWidth);
    popMatrix();

    // Temperature cube (orange) - aligned above "Temperature" label
    pushMatrix();
    translate(tempLabelX, baselineY - tempHeight/2, 0);  // Position center so bottom is at baseline
    rotateX(fixedRotX);
    rotateY(fixedRotY);
    fill(255, 100, 50);
    stroke(180, 60, 20);  // Darker orange edges for visibility
    strokeWeight(2);
    box(cubeWidth, tempHeight, cubeWidth);
    popMatrix();

    // Light cube (yellow) - aligned above "Light" label
    pushMatrix();
    translate(lightLabelX, baselineY - lightHeight/2, 0);  // Position center so bottom is at baseline
    rotateX(fixedRotX);
    rotateY(fixedRotY);
    fill(255, 220, 80);
    stroke(200, 160, 40);  // Darker yellow edges for visibility
    strokeWeight(2);
    box(cubeWidth, lightHeight, cubeWidth);
    popMatrix();

    // Disable lights for 2D text rendering
    noLights();
    hint(DISABLE_DEPTH_TEST);

    // Draw labels and values below cubes (2D overlay)
    // Humidity label and value
    fill(200);
    textAlign(CENTER, TOP);
    textSize(11);
    text("Humidity", humidityLabelX, labelY);
    fill(100, 200, 255);
    textSize(13);
    text(nf(humidityValue, 0, 1) + "%", humidityLabelX, labelY + 14);

    // Temperature label and value
    fill(200);
    textSize(11);
    text("Temperature", tempLabelX, labelY);
    fill(255, 150, 100);
    textSize(13);
    text(nf(tempValue, 0, 1) + "°C", tempLabelX, labelY + 14);

    // Light label and value
    fill(200);
    textSize(11);
    text("Light", lightLabelX, labelY);
    fill(255, 240, 150);
    textSize(13);
    text(nf(lightValue, 0, 0) + " lux", lightLabelX, labelY + 14);

    popStyle();
  }

  /**
   * Draw plant health with gauges combined
   */
  void drawPlantHealthWithGauges(float x, float y, float w, int timeIndex) {
    pushStyle();

    // Background panel - adjusted height to fit all content
    fill(35, 40, 50, 200);
    stroke(80);
    strokeWeight(1);
    rect(x, y, w, 270, 8);

    float padding = 15;

    // === TOP SECTION: Plant Info & Health Status ===
    // Plant image section
    float imgSize = 65;
    float imgX = x + padding;
    float imgY = y + padding;

    if (plantImage != null) {
      image(plantImage, imgX, imgY, imgSize, imgSize);
    }

    // Health info section - dynamically positioned
    float healthInfoX = plantImage != null ? imgX + imgSize + 20 : imgX;
    float healthInfoY = imgY;
    float healthInfoWidth = w - (healthInfoX - x) - padding;

    // Plant type title
    fill(150, 255, 150);
    textAlign(LEFT, TOP);
    textSize(15);
    text("🌿 " + plantType, healthInfoX, healthInfoY);

    // Get current values
    float humidity = humidityHistory[timeIndex];
    float temp = temperatureHistory[timeIndex];
    float light = lightHistory[timeIndex];

    // Calculate health score
    float humidityScore = calculateParameterScore(humidity, optimalHumidityMin, optimalHumidityMax, 0, 100);
    float tempScore = calculateParameterScore(temp, optimalTempMin, optimalTempMax, 15, 35);
    float lightScore = calculateParameterScore(light, optimalLightMin, optimalLightMax, 0, 1000);
    float overallHealth = (humidityScore + tempScore + lightScore) / 3;

    // Health status
    String healthStatus;
    int healthColor;
    if (overallHealth >= 80) {
      healthStatus = "Excellent";
      healthColor = color(50, 255, 50);
    } else if (overallHealth >= 60) {
      healthStatus = "Good";
      healthColor = color(150, 255, 50);
    } else if (overallHealth >= 40) {
      healthStatus = "Fair";
      healthColor = color(255, 200, 50);
    } else if (overallHealth >= 20) {
      healthStatus = "Poor";
      healthColor = color(255, 150, 50);
    } else {
      healthStatus = "Critical";
      healthColor = color(255, 50, 50);
    }

    // Health text - dynamically positioned below plant type
    float currentY = healthInfoY + 23;  // Below plant type
    fill(healthColor);
    textSize(12);
    text("Health: " + nf(overallHealth, 0, 1) + "% - " + healthStatus, healthInfoX, currentY);

    // Health bar - dynamically positioned directly below health text
    currentY += 14;  // Move down from health text
    float barWidth = healthInfoWidth;
    float barHeight = 12;

    fill(40, 45, 55);
    noStroke();
    rect(healthInfoX, currentY, barWidth, barHeight, 6);

    fill(healthColor);
    rect(healthInfoX, currentY, barWidth * (overallHealth / 100), barHeight, 6);

    // Explanation text - grouped with health status above
    currentY += barHeight + 8;  // Move down from health bar
    String explanation = generateHealthExplanation(humidityScore, tempScore, lightScore, humidity, temp, light);
    fill(200);
    textAlign(LEFT, TOP);
    textSize(11);
    text(explanation, healthInfoX, currentY, healthInfoWidth, 40);

    // === BOTTOM SECTION: Sensor Gauges ===
    // Grouped gauges with labels and values - positioned below health section
    float gaugesStartY = y + 110;  // Fixed position for gauge section
    float gaugeWidth = (w - padding * 4) / 3;
    float gaugeHeight = 120;  // Slightly bigger
    float gaugeSpacing = (w - padding * 2 - gaugeWidth * 3) / 2;

    // Humidity gauge
    drawSmallGauge(x + padding, gaugesStartY, gaugeWidth, gaugeHeight, "Humidity", "%",
                   humidity, 0.0f, 100.0f,
                   optimalHumidityMin, optimalHumidityMax);

    // Temperature gauge
    drawSmallGauge(x + padding + gaugeWidth + gaugeSpacing, gaugesStartY, gaugeWidth, gaugeHeight, "Temperature", "°C",
                   temp, 15.0f, 35.0f,
                   optimalTempMin, optimalTempMax);

    // Light gauge
    drawSmallGauge(x + padding + (gaugeWidth + gaugeSpacing) * 2, gaugesStartY, gaugeWidth, gaugeHeight, "Light", "lux",
                   light, 0.0f, 1000.0f,
                   optimalLightMin, optimalLightMax);

    popStyle();
  }

  /**
   * Draw a smaller gauge
   */
  public void drawSmallGauge(float x, float y, float w, float h, String label, String unit,
                             float value, float minVal, float maxVal,
                             float optimalMin, float optimalMax) {
    pushStyle();

    // Arc parameters - positioned at top of gauge area
    float centerX = x + w/2;
    float radius = min(w/2 - 10, 38);  // Slightly bigger radius
    float centerY = y + radius + 15;  // Position arc near top
    float startAngle = PI * 0.75f;
    float endAngle = PI * 2.25f;

    // Draw background arc
    noFill();
    stroke(60, 65, 75);
    strokeWeight(7);  // Slightly thicker
    strokeCap(SQUARE);
    arc(centerX, centerY, radius * 2, radius * 2, startAngle, endAngle);

    // Draw optimal range arc
    float optimalStartAngle = map(optimalMin, minVal, maxVal, startAngle, endAngle);
    float optimalEndAngle = map(optimalMax, minVal, maxVal, startAngle, endAngle);
    stroke(50, 200, 50, 120);
    strokeWeight(7);  // Slightly thicker
    arc(centerX, centerY, radius * 2, radius * 2, optimalStartAngle, optimalEndAngle);

    // Draw value arc
    float valueAngle = map(value, minVal, maxVal, startAngle, endAngle);
    valueAngle = constrain(valueAngle, startAngle, endAngle);

    boolean inRange = (value >= optimalMin && value <= optimalMax);
    int valueColor = inRange ? color(50, 255, 50) : color(255, 50, 50);

    stroke(valueColor);
    strokeWeight(4);  // Slightly thicker
    arc(centerX, centerY, radius * 2, radius * 2, startAngle, valueAngle);

    // Draw needle
    pushMatrix();
    translate(centerX, centerY);
    rotate(valueAngle);
    fill(255, 50, 50);
    noStroke();
    triangle(0, -2.5f, 0, 2.5f, radius - 5, 0);
    popMatrix();

    // Center dot
    fill(200);
    noStroke();
    circle(centerX, centerY, 6);

    // === GROUPED: Label and Value together ===
    // Label text BELOW the arc
    fill(200);
    textAlign(CENTER, TOP);
    textSize(11);
    text(label, centerX, centerY + 12);

    // Value text BELOW the label (grouped)
    fill(valueColor);
    textAlign(CENTER, TOP);
    textSize(13);
    text(nf(value, 0, 1) + unit, centerX, centerY + 28);

    popStyle();
  }

  /**
   * Draw a single gauge (like car speedometer)
   */
  void drawGauge(float x, float y, float w, float h, String label, String unit,
                 float value, float minVal, float maxVal,
                 float optimalMin, float optimalMax) {
    pushStyle();

    // Background
    fill(35, 40, 50, 200);
    stroke(80);
    strokeWeight(1);
    rect(x, y, w, h, 8);

    // Title
    fill(200);
    textAlign(CENTER, TOP);
    textSize(12);
    text(label, x + w/2, y + 10);

    // Arc parameters
    float centerX = x + w/2;
    float centerY = y + h - 30;
    float radius = w/2 - 20;
    float startAngle = PI * 0.75f;
    float endAngle = PI * 2.25f;

    // Draw background arc
    noFill();
    stroke(60, 65, 75);
    strokeWeight(12);
    strokeCap(SQUARE);
    arc(centerX, centerY, radius * 2, radius * 2, startAngle, endAngle);

    // Draw optimal range arc (green)
    float optimalStartAngle = map(optimalMin, minVal, maxVal, startAngle, endAngle);
    float optimalEndAngle = map(optimalMax, minVal, maxVal, startAngle, endAngle);
    stroke(50, 200, 50, 150);
    strokeWeight(12);
    arc(centerX, centerY, radius * 2, radius * 2, optimalStartAngle, optimalEndAngle);

    // Draw value arc
    float valueAngle = map(value, minVal, maxVal, startAngle, endAngle);
    valueAngle = constrain(valueAngle, startAngle, endAngle);

    // Color based on whether in optimal range
    boolean inRange = (value >= optimalMin && value <= optimalMax);
    int valueColor = inRange ? color(50, 255, 50) : color(255, 50, 50);

    stroke(valueColor);
    strokeWeight(6);
    arc(centerX, centerY, radius * 2, radius * 2, startAngle, valueAngle);

    // Draw needle/pointer
    pushMatrix();
    translate(centerX, centerY);
    rotate(valueAngle);
    fill(255, 50, 50);
    noStroke();
    triangle(0, -5, 0, 5, radius - 10, 0);
    popMatrix();

    // Center dot
    fill(200);
    noStroke();
    circle(centerX, centerY, 10);

    // Value text
    fill(valueColor);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(nf(value, 0, 1) + unit, centerX, centerY + radius + 5);

    // Min/max labels
    fill(150);
    textSize(9);
    textAlign(LEFT, CENTER);
    text(nf(minVal, 0, 0), x + 10, centerY + 10);
    textAlign(RIGHT, CENTER);
    text(nf(maxVal, 0, 0), x + w - 10, centerY + 10);

    // Optimal range text
    fill(100, 200, 100);
    textAlign(CENTER, BOTTOM);
    textSize(8);
    text("Optimal: " + nf(optimalMin, 0, 0) + "-" + nf(optimalMax, 0, 0) + unit,
         centerX, y + h - 5);

    popStyle();
  }

  /**
   * Draw plant health prediction
   */
  void drawPlantHealth(float x, float y, float w, int timeIndex) {
    pushStyle();

    // Background panel (reduced height)
    fill(35, 40, 50, 200);
    stroke(80);
    strokeWeight(1);
    rect(x, y, w, 140, 8);

    // Plant image (if available) - smaller
    if (plantImage != null) {
      float imgSize = 50;
      image(plantImage, x + 15, y + 12, imgSize, imgSize);
    }

    // Title
    float textX = plantImage != null ? x + 75 : x + 15;
    fill(150, 255, 150);
    textAlign(LEFT, TOP);
    textSize(14);
    text("🌿 " + plantType + " Health", textX, y + 12);

    // Get current values
    float humidity = humidityHistory[timeIndex];
    float temp = temperatureHistory[timeIndex];
    float light = lightHistory[timeIndex];

    // Calculate health score (0-100)
    float humidityScore = calculateParameterScore(humidity, optimalHumidityMin, optimalHumidityMax, 0, 100);
    float tempScore = calculateParameterScore(temp, optimalTempMin, optimalTempMax, 15, 35);
    float lightScore = calculateParameterScore(light, optimalLightMin, optimalLightMax, 0, 1000);

    float overallHealth = (humidityScore + tempScore + lightScore) / 3;

    // Health status and color
    String healthStatus;
    int healthColor;
    if (overallHealth >= 80) {
      healthStatus = "Excellent";
      healthColor = color(50, 255, 50);
    } else if (overallHealth >= 60) {
      healthStatus = "Good";
      healthColor = color(150, 255, 50);
    } else if (overallHealth >= 40) {
      healthStatus = "Fair";
      healthColor = color(255, 200, 50);
    } else if (overallHealth >= 20) {
      healthStatus = "Poor";
      healthColor = color(255, 150, 50);
    } else {
      healthStatus = "Critical";
      healthColor = color(255, 50, 50);
    }

    // Health score display
    fill(healthColor);
    textSize(12);
    text("Score: " + nf(overallHealth, 0, 1) + "% - " + healthStatus, textX, y + 32);

    // Health bar
    float barWidth = w - 30;
    float barHeight = 16;
    float barX = x + 15;
    float barY = y + 55;

    // Background bar
    fill(40, 45, 55);
    noStroke();
    rect(barX, barY, barWidth, barHeight, 8);

    // Health bar fill
    fill(healthColor);
    rect(barX, barY, barWidth * (overallHealth / 100), barHeight, 8);

    // Explanation
    String explanation = generateHealthExplanation(humidityScore, tempScore, lightScore, humidity, temp, light);

    fill(200);
    textAlign(LEFT, TOP);
    textSize(10);
    text(explanation, x + 15, y + 80, w - 30, 50);

    popStyle();
  }

  /**
   * Calculate score for a parameter (0-100)
   */
  float calculateParameterScore(float value, float optimalMin, float optimalMax, float absoluteMin, float absoluteMax) {
    if (value >= optimalMin && value <= optimalMax) {
      return 100;
    } else if (value < optimalMin) {
      // Below optimal
      float range = optimalMin - absoluteMin;
      float distance = optimalMin - value;
      return max(0, 100 - (distance / range) * 100);
    } else {
      // Above optimal
      float range = absoluteMax - optimalMax;
      float distance = value - optimalMax;
      return max(0, 100 - (distance / range) * 100);
    }
  }

  /**
   * Generate health explanation based on conditions
   */
  public String generateHealthExplanation(float humidityScore, float tempScore, float lightScore,
                                     float humidity, float temp, float light) {
    String explanation = plantType + " is currently ";

    ArrayList<String> issues = new ArrayList<String>();

    if (humidityScore < 60) {
      if (humidity < optimalHumidityMin) {
        issues.add("humidity is too low (needs " + nf(optimalHumidityMin, 0, 0) + "-" +
                   nf(optimalHumidityMax, 0, 0) + "%)");
      } else {
        issues.add("humidity is too high (needs " + nf(optimalHumidityMin, 0, 0) + "-" +
                   nf(optimalHumidityMax, 0, 0) + "%)");
      }
    }

    if (tempScore < 60) {
      if (temp < optimalTempMin) {
        issues.add("temperature is too cold (needs " + nf(optimalTempMin, 0, 1) + "-" +
                   nf(optimalTempMax, 0, 1) + "°C)");
      } else {
        issues.add("temperature is too warm (needs " + nf(optimalTempMin, 0, 1) + "-" +
                   nf(optimalTempMax, 0, 1) + "°C)");
      }
    }

    if (lightScore < 60) {
      if (light < optimalLightMin) {
        issues.add("light level is too low (needs " + nf(optimalLightMin, 0, 0) + "-" +
                   nf(optimalLightMax, 0, 0) + " lux)");
      } else {
        issues.add("light level is too high (needs " + nf(optimalLightMin, 0, 0) + "-" +
                   nf(optimalLightMax, 0, 0) + " lux)");
      }
    }

    if (issues.size() == 0) {
      explanation += "thriving in ideal conditions. All environmental parameters are within optimal range.";
    } else {
      explanation += "experiencing suboptimal conditions: ";
      for (int i = 0; i < issues.size(); i++) {
        explanation += issues.get(i);
        if (i < issues.size() - 1) {
          explanation += ", ";
        }
      }
      explanation += ". Consider adjusting these factors for better plant health.";
    }

    return explanation;
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

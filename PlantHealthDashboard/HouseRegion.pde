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

  // 24-hour historical data with 30-minute intervals (48 data points)
  // Index 0 = now, Index 47 = 24 hours ago
  float[] humidityHistory;
  float[] temperatureHistory;
  float[] lightHistory;

  // Plant health thresholds (specific to plant type)
  float optimalHumidityMin, optimalHumidityMax;
  float optimalTempMin, optimalTempMax;
  float optimalLightMin, optimalLightMax;

  /**
   * Constructor
   */
  HouseRegion(String name, float x, float y, float width, float height, String plantType) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.plantType = plantType;

    humidityHistory = new float[48];
    temperatureHistory = new float[48];
    lightHistory = new float[48];

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
   * Generate 24 hours of mock historical data (48 data points at 30-minute intervals)
   */
  void generateHistoricalData() {
    float timeOffset = random(1000);

    for (int i = 0; i < 48; i++) {
      // Use Perlin noise for realistic variations
      // i=0 is current, i=47 is 24 hours ago
      float t = timeOffset + (47 - i) * 0.05;

      // Humidity: 30-90%
      humidityHistory[i] = map(noise(t), 0, 1, 30, 90);

      // Temperature: 15-32°C (varies more during day)
      float tempBase = map(noise(t + 100), 0, 1, 15, 32);
      // Add day/night cycle
      float hoursAgo = i * 0.5;
      float hourOfDay = (hour() - hoursAgo + 24) % 24;
      float dayNightEffect = sin(map(hourOfDay, 0, 24, 0, TWO_PI)) * 3;
      temperatureHistory[i] = constrain(tempBase + dayNightEffect, 15, 35);

      // Light: 0-1000 lux (day/night cycle)
      float lightBase = map(noise(t + 200), 0, 1, 0, 1000);
      // Strong day/night effect
      float lightDayNight = (hourOfDay >= 6 && hourOfDay <= 20) ? 1.0 : 0.2;
      lightHistory[i] = lightBase * lightDayNight;
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
   * Draw simple 2D bar chart visualization
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

    // Bar chart area
    float chartX = x + 40;
    float chartY = y + 50;
    float chartW = w - 80;
    float chartH = h - 100;

    // Calculate bar heights
    float maxBarHeight = chartH;
    float humidityHeight = map(humidityValue, 0, 100, 0, maxBarHeight);
    float tempHeight = map(tempValue, 15, 35, 0, maxBarHeight);
    float lightHeight = map(lightValue, 0, 1000, 0, maxBarHeight);

    // Bar dimensions
    float barWidth = chartW / 4;
    float spacing = chartW / 3;

    // Draw grid lines
    stroke(50, 55, 65);
    strokeWeight(1);
    for (int i = 0; i <= 4; i++) {
      float lineY = chartY + chartH - (chartH / 4) * i;
      line(chartX, lineY, chartX + chartW, lineY);
    }

    // Humidity bar (left)
    float bar1X = chartX;
    fill(80, 150, 220);
    stroke(100, 180, 255);
    strokeWeight(2);
    rect(bar1X, chartY + chartH - humidityHeight, barWidth, humidityHeight, 5, 5, 0, 0);

    // Temperature bar (center)
    float bar2X = chartX + spacing;
    fill(255, 100, 50);
    stroke(255, 150, 100);
    strokeWeight(2);
    rect(bar2X, chartY + chartH - tempHeight, barWidth, tempHeight, 5, 5, 0, 0);

    // Light bar (right)
    float bar3X = chartX + spacing * 2;
    fill(255, 220, 80);
    stroke(255, 240, 150);
    strokeWeight(2);
    rect(bar3X, chartY + chartH - lightHeight, barWidth, lightHeight, 5, 5, 0, 0);

    // Draw labels and values below bars
    float labelY = y + h - 40;

    // Humidity label and value
    fill(200);
    textAlign(CENTER, TOP);
    textSize(11);
    text("Humidity", bar1X + barWidth/2, labelY);
    fill(100, 200, 255);
    textSize(14);
    text(nf(humidityValue, 0, 1) + "%", bar1X + barWidth/2, labelY + 16);

    // Temperature label and value
    fill(200);
    textSize(11);
    text("Temperature", bar2X + barWidth/2, labelY);
    fill(255, 150, 100);
    textSize(14);
    text(nf(tempValue, 0, 1) + "°C", bar2X + barWidth/2, labelY + 16);

    // Light label and value
    fill(200);
    textSize(11);
    text("Light", bar3X + barWidth/2, labelY);
    fill(255, 240, 150);
    textSize(14);
    text(nf(lightValue, 0, 0) + " lux", bar3X + barWidth/2, labelY + 16);

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
    color healthColor;
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
    textSize(9);
    text(explanation, healthInfoX, currentY, healthInfoWidth, 40);

    // === BOTTOM SECTION: Sensor Gauges ===
    // Grouped gauges with labels and values - positioned below health section
    float gaugesStartY = y + 110;  // Fixed position for gauge section
    float gaugeWidth = (w - padding * 4) / 3;
    float gaugeHeight = 120;  // Slightly bigger
    float gaugeSpacing = (w - padding * 2 - gaugeWidth * 3) / 2;

    // Humidity gauge
    drawSmallGauge(x + padding, gaugesStartY, gaugeWidth, gaugeHeight, "Humidity", "%",
                   humidity, 0, 100,
                   optimalHumidityMin, optimalHumidityMax);

    // Temperature gauge
    drawSmallGauge(x + padding + gaugeWidth + gaugeSpacing, gaugesStartY, gaugeWidth, gaugeHeight, "Temperature", "°C",
                   temp, 15, 35,
                   optimalTempMin, optimalTempMax);

    // Light gauge
    drawSmallGauge(x + padding + (gaugeWidth + gaugeSpacing) * 2, gaugesStartY, gaugeWidth, gaugeHeight, "Light", "lux",
                   light, 0, 1000,
                   optimalLightMin, optimalLightMax);

    popStyle();
  }

  /**
   * Draw a smaller gauge
   */
  void drawSmallGauge(float x, float y, float w, float h, String label, String unit,
                      float value, float minVal, float maxVal,
                      float optimalMin, float optimalMax) {
    pushStyle();

    // Arc parameters - positioned at top of gauge area
    float centerX = x + w/2;
    float radius = min(w/2 - 10, 38);  // Slightly bigger radius
    float centerY = y + radius + 15;  // Position arc near top
    float startAngle = PI * 0.75;
    float endAngle = PI * 2.25;

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
    color valueColor = inRange ? color(50, 255, 50) : color(255, 50, 50);

    stroke(valueColor);
    strokeWeight(4);  // Slightly thicker
    arc(centerX, centerY, radius * 2, radius * 2, startAngle, valueAngle);

    // Draw needle
    pushMatrix();
    translate(centerX, centerY);
    rotate(valueAngle);
    fill(255, 50, 50);
    noStroke();
    triangle(0, -2.5, 0, 2.5, radius - 5, 0);
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
    float startAngle = PI * 0.75;
    float endAngle = PI * 2.25;

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
    color valueColor = inRange ? color(50, 255, 50) : color(255, 50, 50);

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
    color healthColor;
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
  String generateHealthExplanation(float humidityScore, float tempScore, float lightScore,
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
   * Draw sensor graph for analytics view (48 data points)
   */
  void drawSensorGraph(String sensorType, float x, float y, float w, float h) {
    pushStyle();

    // Background
    fill(30, 35, 45, 200);
    stroke(80);
    strokeWeight(1);
    rect(x, y, w, h, 8);

    // Title
    fill(200);
    textAlign(LEFT, TOP);
    textSize(16);
    text(sensorType + " (Last 24 Hours, 30-min intervals)", x + 15, y + 10);

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
    color lineColor;

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

    // Draw line graph (remember: index 0 = now, 47 = 24h ago)
    noFill();
    stroke(lineColor);
    strokeWeight(2);
    beginShape();
    for (int i = 0; i < 48; i++) {
      float px = graphX + map(i, 0, 47, graphW, 0);  // Right to left
      float py = graphY + graphH - map(data[i], minVal, maxVal, 0, graphH);
      vertex(px, py);
    }
    endShape();

    // Draw data points
    fill(lineColor);
    noStroke();
    for (int i = 0; i < 48; i += 2) {  // Every hour
      float px = graphX + map(i, 0, 47, graphW, 0);
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

    // X-axis labels (hours ago)
    textAlign(CENTER, TOP);
    for (int i = 0; i <= 24; i += 4) {
      int index = i * 2;  // Convert to 30-min intervals
      float labelX = graphX + map(index, 0, 47, graphW, 0);
      text(i + "h", labelX, graphY + graphH + 5);
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
  float calculateAverage(float[] data) {
    float sum = 0;
    for (float val : data) {
      sum += val;
    }
    return sum / data.length;
  }

  /**
   * Calculate standard deviation
   */
  float calculateStdDev(float[] data, float avg) {
    float sumSquaredDiff = 0;
    for (float val : data) {
      float diff = val - avg;
      sumSquaredDiff += diff * diff;
    }
    return sqrt(sumSquaredDiff / data.length);
  }
}

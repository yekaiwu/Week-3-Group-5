/**
 * Plant Health Monitoring Dashboard
 * Interactive house layout with clickable regions
 * Features:
 * - Click on different rooms to view sensor data
 * - 24-hour historical data with time slider
 * - Growing squares visualization
 * - Plant health prediction
 * - Statistical analysis and graphs
 */

// House regions
HouseRegion[] regions;
HouseRegion selectedRegion = null;

// Analytics view - selected location (can be different from selectedRegion in house map)
int analyticsLocationIndex = 0;  // Index into regions array for analytics view

// Tab system
int currentTab = 0;  // 0 = House Map, 1 = Analytics, 2 = Recommendations
float tabY = 60;
float tabHeight = 35;
float tab1X = 20;
float tab2X = 220;
float tab3X = 420;
float tabWidth = 180;

// Timeframe selection (grouped together)
int timeframeMode = 0;  // 0 = Hourly (48 points), 1 = Daily (30 days), 2 = Monthly (12 months)
String[] timeframeLabels = {"Hourly", "Daily", "Monthly"};
float timeframeButtonY = 0;  // Will be set in setup
float timeframeButtonHeight = 30;
float timeframeButtonWidth = 100;

// Time slider (position adjusted based on timeframe)
float sliderX = 200;
float sliderY = 0;  // Will be set in setup
float sliderWidth = 600;
float sliderHeight = 20;
int selectedTimeIndex = 0;  // Index into current data array
boolean draggingSlider = false;

// 3D visualization rotation controls
float rotationX = -0.6;  // Vertical rotation
float rotationY = 0.4;   // Horizontal rotation
float rotationZ = 0;     // Roll rotation
boolean dragging3D = false;
float prevMouseX3D = 0;
float prevMouseY3D = 0;
float viz3DX, viz3DY, viz3DWidth, viz3DHeight;  // 3D visualization area bounds

// House layout image
PImage houseLayoutImage;
float houseImageX = 50;
float houseImageY = 120;
float houseImageWidth = 700;
float houseImageHeight = 500;

/**
 * Setup function - runs once at start
 */
public void setup() {
  size(1400, 900, P3D);
  smooth(8);

  sliderY = height - 80;
  timeframeButtonY = 105;  // Position below tabs

  // Try to load house layout image
  try {
    houseLayoutImage = loadImage("house_layout.png");
    println("Loaded house layout image");
  } catch (Exception e) {
    println("Could not load house_layout.png - will use rectangles");
    houseLayoutImage = null;
  }

  // Initialize house regions with positions, names, plant types, and CSV file paths
  // Coordinates are mapped to the floor plan image
  regions = new HouseRegion[4];

  // Define regions with their clickable areas (mapped to floor plan)
  // Living Room - large brown wooden floor area on the left side
  regions[0] = new HouseRegion("Living Room", houseImageX + 20, houseImageY + 20, 300.0f, 460.0f, "Rose",
                                "sensor_data/synthetic_living_room_20260204_153610.csv");

  // Kitchen - top center-right area with blue tiles
  regions[1] = new HouseRegion("Kitchen", houseImageX + 320, houseImageY + 20, 170.0f, 240.0f, "Banana",
                                "sensor_data/synthetic_kitchen_20260204_160156.csv");

  // Bathroom - lower center-right area with blue tiles
  regions[2] = new HouseRegion("Bathroom", houseImageX + 320, houseImageY + 260, 170.0f, 220.0f, "Water Lily",
                                "sensor_data/synthetic_bathroom_20260204_160204.csv");

  // Balcony - far right side with gray/blue tiles
  regions[3] = new HouseRegion("Balcony", houseImageX + 490, houseImageY + 20, 180.0f, 460.0f, "Tomato Plant",
                                "sensor_data/synthetic_balcony_20260204_160253.csv");

  // Load sensor data from CSV files for all regions
  println("Loading sensor data from CSV files...");
  for (HouseRegion region : regions) {
    region.loadSensorData();
  }

  // Load recommendation data for recommendations tab
  loadRecommendationData();

  println("Plant Health Dashboard initialized");
  println("Click on different rooms to view sensor data");
}

// ============================================
// TIMESTAMP HELPER FUNCTIONS
// ============================================

/**
 * Extract time from timestamp string (24-hour format)
 * Example: "2025-01-01T14:30:00" -> "14:30"
 */
String extractTime(String timestamp) {
  if (timestamp == null || timestamp.length() < 16) return "00:00";
  return timestamp.substring(11, 16);
}

/**
 * Extract date from timestamp string
 * Example: "2025-01-15T14:30:00" -> "Jan 15"
 */
String extractDate(String timestamp) {
  if (timestamp == null || timestamp.length() < 10) return "???";
  String datePart = timestamp.substring(0, 10);
  String[] parts = datePart.split("-");
  if (parts.length < 3) return "???";

  int month = Integer.parseInt(parts[1]);
  int day = Integer.parseInt(parts[2]);

  String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
  String monthName = (month >= 1 && month <= 12) ? monthNames[month - 1] : "???";

  return monthName + " " + day;
}

/**
 * Extract month from timestamp string
 * Example: "2025-01-15T14:30:00" -> "Jan"
 */
String extractMonth(String timestamp) {
  if (timestamp == null || timestamp.length() < 7) return "???";
  String monthStr = timestamp.substring(5, 7);
  int month = Integer.parseInt(monthStr);

  String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
  return (month >= 1 && month <= 12) ? monthNames[month - 1] : "???";
}

/**
 * Extract month and year from timestamp string
 * Example: "2025-01-15T14:30:00" -> "Jan 2025"
 */
String extractMonthYear(String timestamp) {
  if (timestamp == null || timestamp.length() < 10) return "???";
  String year = timestamp.substring(0, 4);
  String monthStr = timestamp.substring(5, 7);
  int month = Integer.parseInt(monthStr);

  String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                         "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
  String monthName = (month >= 1 && month <= 12) ? monthNames[month - 1] : "???";

  return monthName + " " + year;
}

/**
 * Draw function - runs every frame
 */
public void draw() {
  background(20, 25, 35);

  // Draw title bar
  drawTitleBar();

  // Draw tabs
  drawTabs();

  // Draw content based on current tab
  if (currentTab == 0) {
    drawHouseMapView();
  } else if (currentTab == 1) {
    drawAnalyticsView();
  } else if (currentTab == 2) {
    drawRecommendationsView();
  }
}

/**
 * Draw title bar
 */
public void drawTitleBar() {
  pushStyle();
  fill(255);
  textAlign(LEFT, TOP);
  textSize(28);
  text("🌱 Plant Health Monitoring Dashboard", 20, 15);
  popStyle();
}

/**
 * Draw tabs for switching views
 */
public void drawTabs() {
  pushStyle();

  // Tab 1: House Map
  boolean tab1Hover = (mouseX >= tab1X && mouseX <= tab1X + tabWidth &&
                       mouseY >= tabY && mouseY <= tabY + tabHeight);

  if (currentTab == 0) {
    fill(60, 120, 180);
    stroke(100, 200, 255);
    strokeWeight(2);
  } else if (tab1Hover) {
    fill(50, 80, 120);
    stroke(100, 150, 200);
    strokeWeight(1);
  } else {
    fill(30, 40, 60);
    stroke(60);
    strokeWeight(1);
  }
  rect(tab1X, tabY, tabWidth, tabHeight, 8, 8, 0, 0);

  fill(currentTab == 0 ? 255 : 180);
  textAlign(CENTER, CENTER);
  textSize(15);
  text("House Map", tab1X + tabWidth/2, tabY + tabHeight/2 + 1);

  // Tab 2: Analytics
  boolean tab2Hover = (mouseX >= tab2X && mouseX <= tab2X + tabWidth &&
                       mouseY >= tabY && mouseY <= tabY + tabHeight);

  if (currentTab == 1) {
    fill(60, 120, 180);
    stroke(100, 200, 255);
    strokeWeight(2);
  } else if (tab2Hover) {
    fill(50, 80, 120);
    stroke(100, 150, 200);
    strokeWeight(1);
  } else {
    fill(30, 40, 60);
    stroke(60);
    strokeWeight(1);
  }
  rect(tab2X, tabY, tabWidth, tabHeight, 8, 8, 0, 0);

  fill(currentTab == 1 ? 255 : 180);
  textAlign(CENTER, CENTER);
  textSize(15);
  text("Analytics", tab2X + tabWidth/2, tabY + tabHeight/2 + 1);

  // Tab 3: Recommendations
  boolean tab3Hover = (mouseX >= tab3X && mouseX <= tab3X + tabWidth &&
                       mouseY >= tabY && mouseY <= tabY + tabHeight);

  if (currentTab == 2) {
    fill(60, 120, 180);
    stroke(100, 200, 255);
    strokeWeight(2);
  } else if (tab3Hover) {
    fill(50, 80, 120);
    stroke(100, 150, 200);
    strokeWeight(1);
  } else {
    fill(30, 40, 60);
    stroke(60);
    strokeWeight(1);
  }
  rect(tab3X, tabY, tabWidth, tabHeight, 8, 8, 0, 0);

  fill(currentTab == 2 ? 255 : 180);
  textAlign(CENTER, CENTER);
  textSize(15);
  text("Recommendations", tab3X + tabWidth/2, tabY + tabHeight/2 + 1);

  popStyle();
}

/**
 * Draw timeframe selector buttons (grouped together)
 */
public void drawTimeframeSelector(float x, float y) {
  pushStyle();

  // Label
  fill(180);
  textAlign(LEFT, CENTER);
  textSize(12);
  text("View:", x, y + timeframeButtonHeight/2);

  // Buttons - align with location buttons
  float buttonStartX = x + 75;  // Changed from 45 to 75 to align with Location buttons
  for (int i = 0; i < 3; i++) {
    float btnX = buttonStartX + i * (timeframeButtonWidth + 10);
    boolean isHovered = (mouseX >= btnX && mouseX <= btnX + timeframeButtonWidth &&
                         mouseY >= y && mouseY <= y + timeframeButtonHeight);

    // Button styling
    if (timeframeMode == i) {
      fill(60, 120, 180);
      stroke(100, 200, 255);
      strokeWeight(2);
    } else if (isHovered) {
      fill(50, 80, 120);
      stroke(100, 150, 200);
      strokeWeight(1);
    } else {
      fill(40, 50, 70);
      stroke(80);
      strokeWeight(1);
    }
    rect(btnX, y, timeframeButtonWidth, timeframeButtonHeight, 5);

    // Button text
    fill(timeframeMode == i ? 255 : 180);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(timeframeLabels[i], btnX + timeframeButtonWidth/2, y + timeframeButtonHeight/2);
  }

  popStyle();
}

/**
 * Draw house map view with clickable regions
 */
public void drawHouseMapView() {
  pushStyle();

  // Draw house layout
  if (houseLayoutImage != null) {
    image(houseLayoutImage, houseImageX, houseImageY, houseImageWidth, houseImageHeight);
  } else {
    // Draw placeholder rectangles for regions
    fill(40, 45, 55);
    stroke(80);
    strokeWeight(1);
    rect(houseImageX, houseImageY, houseImageWidth, houseImageHeight, 10);

    // Draw each region as a rectangle
    for (HouseRegion region : regions) {
      if (region.isHovered || region == selectedRegion) {
        fill(70, 100, 140, 150);
        stroke(100, 200, 255);
        strokeWeight(2);
      } else {
        fill(50, 60, 80, 100);
        stroke(100);
        strokeWeight(1);
      }
      rect(region.x, region.y, region.width, region.height, 8);

      // Draw region label
      fill(200);
      textAlign(CENTER, CENTER);
      textSize(14);
      text(region.name, region.x + region.width/2, region.y + region.height/2);
    }
  }

  // Draw instruction text
  fill(180);
  textAlign(LEFT, TOP);
  textSize(16);
  text("Click on a room to view detailed sensor data and plant health", houseImageX, houseImageY + houseImageHeight + 20);

  // If a region is selected, show its detailed view
  if (selectedRegion != null) {
    drawRegionDetailView();
  }

  popStyle();
}

/**
 * Draw detailed view for selected region
 */
public void drawRegionDetailView() {
  pushStyle();

  float detailX = houseImageX + houseImageWidth + 30;
  float detailY = houseImageY;
  float detailWidth = width - detailX - 30;
  float detailHeight = height - detailY - 30;  // Use full available height

  // Background panel
  fill(30, 35, 45, 240);
  stroke(80);
  strokeWeight(1);
  rect(detailX, detailY, detailWidth, detailHeight, 10);

  // Title
  fill(100, 200, 255);
  textAlign(LEFT, TOP);
  textSize(20);
  text(selectedRegion.name, detailX + 20, detailY + 15);

  // Plant type
  fill(150, 200, 150);
  textSize(14);
  text("Plant: " + selectedRegion.plantType, detailX + 20, detailY + 45);

  // Timeframe selector (grouped above time slider)
  float timeframeSelectorY = detailY + 70;
  drawTimeframeSelector(detailX + 20, timeframeSelectorY);

  // Time slider with appropriate label based on timeframe
  float sliderStartY = timeframeSelectorY + timeframeButtonHeight + 15;
  fill(180);
  textSize(12);
  String timeText = selectedRegion.getTimeLabel(selectedTimeIndex, timeframeMode);
  text("Time: " + timeText, detailX + 20, sliderStartY);

  drawTimeSlider(detailX + 20, sliderStartY + 20, detailWidth - 40);

  // 3D Growing squares visualization with base platform
  // Position below slider with enough space for labels (slider height + label height + padding)
  float squaresY = sliderStartY + 20 + sliderHeight + 25;  // Extra space for labels
  float squaresHeight = 250;

  // Store 3D visualization bounds for mouse interaction
  viz3DX = detailX + 20;
  viz3DY = squaresY;
  viz3DWidth = detailWidth - 40;
  viz3DHeight = squaresHeight;

  selectedRegion.draw3DGrowingSquares(viz3DX, viz3DY, viz3DWidth, viz3DHeight, selectedTimeIndex, rotationX, rotationY, rotationZ);

  // Plant health prediction with gauges
  float healthY = squaresY + squaresHeight + 15;
  selectedRegion.drawPlantHealthWithGauges(detailX + 20, healthY, detailWidth - 40, selectedTimeIndex);

  popStyle();
}

/**
 * Draw location selector for analytics view
 */
public void drawLocationSelector(float x, float y) {
  pushStyle();

  // Label
  fill(180);
  textAlign(LEFT, CENTER);
  textSize(12);
  text("Location:", x, y + timeframeButtonHeight/2);

  // Buttons for each location
  float buttonStartX = x + 75;
  float buttonWidth = 140;

  for (int i = 0; i < regions.length; i++) {
    float btnX = buttonStartX + i * (buttonWidth + 10);
    boolean isHovered = (mouseX >= btnX && mouseX <= btnX + buttonWidth &&
                         mouseY >= y && mouseY <= y + timeframeButtonHeight);

    // Button styling
    if (analyticsLocationIndex == i) {
      fill(60, 120, 180);
      stroke(100, 200, 255);
      strokeWeight(2);
    } else if (isHovered) {
      fill(50, 80, 120);
      stroke(100, 150, 200);
      strokeWeight(1);
    } else {
      fill(40, 50, 70);
      stroke(80);
      strokeWeight(1);
    }
    rect(btnX, y, buttonWidth, timeframeButtonHeight, 5);

    // Button text
    fill(analyticsLocationIndex == i ? 255 : 180);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(regions[i].name, btnX + buttonWidth/2, y + timeframeButtonHeight/2);
  }

  popStyle();
}

/**
 * Draw analytics view with graphs and statistics
 */
public void drawAnalyticsView() {
  pushStyle();

  // ========================================
  // SECTION 1: CONTROL PANEL (Location + Timeframe)
  // ========================================
  float controlPanelY = timeframeButtonY;

  // Location selector
  drawLocationSelector(40, controlPanelY);

  // Timeframe selector (below location selector)
  float timeframeSelectorY = controlPanelY + timeframeButtonHeight + 15;
  drawTimeframeSelector(40, timeframeSelectorY);

  // ========================================
  // SECTION 2: TITLE AND INFO
  // ========================================
  HouseRegion analyticsRegion = regions[analyticsLocationIndex];

  float titleY = timeframeSelectorY + timeframeButtonHeight + 25;
  fill(100, 200, 255);
  textAlign(LEFT, TOP);
  textSize(20);
  String timeframeLabel = timeframeMode == 0 ? "24-Hour" : (timeframeMode == 1 ? "30-Day" : "12-Month");
  text(timeframeLabel + " Sensor Data: " + analyticsRegion.name, 40, titleY);

  // Plant info
  fill(150, 200, 150);
  textSize(14);
  text("Plant: " + analyticsRegion.plantType, 40, titleY + 28);

  // ========================================
  // SECTION 3: SENSOR GRAPHS (Properly Spaced)
  // ========================================
  float graphsStartY = titleY + 65;
  float chartX = 40;
  float chartWidth = width - 80;
  float chartHeight = 200;  // Slightly smaller for better fit
  float graphSpacing = 30;  // Space between graphs

  // Humidity graph
  analyticsRegion.drawSensorGraph("Humidity", chartX, graphsStartY, chartWidth, chartHeight, timeframeMode);

  // Temperature graph
  float tempGraphY = graphsStartY + chartHeight + graphSpacing;
  analyticsRegion.drawSensorGraph("Temperature", chartX, tempGraphY, chartWidth, chartHeight, timeframeMode);

  // Light graph
  float lightGraphY = tempGraphY + chartHeight + graphSpacing;
  analyticsRegion.drawSensorGraph("Light", chartX, lightGraphY, chartWidth, chartHeight, timeframeMode);

  popStyle();
}

/**
 * Draw time slider (adapts to timeframe mode)
 */
public void drawTimeSlider(float x, float y, float w) {
  pushStyle();

  // Slider background
  fill(40, 45, 55);
  stroke(80);
  strokeWeight(1);
  rect(x, y, w, sliderHeight, 5);

  int maxIndex = selectedRegion.getMaxTimeIndex(timeframeMode);

  // Draw markers based on timeframe mode - using actual CSV timestamps
  // Timeline: RIGHT = index 0 (most recent), LEFT = index max (oldest)
  textAlign(CENTER, TOP);
  textSize(11);  // Increased time slider label size
  if (timeframeMode == 0) {  // Hourly - show actual times
    // Show labels every 4 hours
    for (int hoursAgo = 0; hoursAgo <= 24; hoursAgo += 4) {
      int index = min(hoursAgo * 2, maxIndex);  // 2 readings per hour
      if (index < selectedRegion.timestampHistory.length && selectedRegion.timestampHistory[index] != null) {
        float markerX = x + map(index, 0, maxIndex, w, 0);  // i=0 right, i=max left
        stroke(100);
        line(markerX, y, markerX, y + sliderHeight);
        fill(150);
        String timeLabel = extractTime(selectedRegion.timestampHistory[index]);
        text(timeLabel, markerX, y + sliderHeight + 3);
      }
    }
  } else if (timeframeMode == 1) {  // Daily - show actual dates
    // Show ~6 date labels across 30 days
    int dataLength = selectedRegion.timestampHistory.length;
    int step = max(1, dataLength / 6);
    for (int i = 0; i < dataLength; i += step) {
      if (i < selectedRegion.timestampHistory.length && selectedRegion.timestampHistory[i] != null) {
        float markerX = x + map(i, 0, maxIndex, w, 0);  // i=0 right, i=max left
        stroke(100);
        line(markerX, y, markerX, y + sliderHeight);
        fill(150);
        String dateLabel = extractDate(selectedRegion.timestampHistory[i]);
        text(dateLabel, markerX, y + sliderHeight + 3);
      }
    }
  } else {  // Monthly - show actual month names
    // Show ~6 month labels across the year
    int dataLength = selectedRegion.timestampHistory.length;
    int step = max(1, dataLength / 6);
    for (int i = 0; i < dataLength; i += step) {
      if (i < selectedRegion.timestampHistory.length && selectedRegion.timestampHistory[i] != null) {
        float markerX = x + map(i, 0, maxIndex, w, 0);  // i=0 right, i=max left
        stroke(100);
        line(markerX, y, markerX, y + sliderHeight);
        fill(150);
        String monthLabel = extractMonth(selectedRegion.timestampHistory[i]);
        text(monthLabel, markerX, y + sliderHeight + 3);
      }
    }
  }

  // Selected time indicator
  // Timeline: RIGHT = index 0 (most recent), LEFT = index max (oldest)
  float handleX = x + map(selectedTimeIndex, 0, maxIndex, w, 0);  // i=0 right, i=max left
  fill(100, 200, 255);
  noStroke();
  circle(handleX, y + sliderHeight/2, 16);

  // Hover effect
  if (dist(mouseX, mouseY, handleX, y + sliderHeight/2) < 10) {
    stroke(150, 220, 255);
    strokeWeight(2);
    noFill();
    circle(handleX, y + sliderHeight/2, 20);
  }

  popStyle();
}

/**
 * Mouse pressed event
 */
public void mousePressed() {
  // Check tab clicks
  if (mouseY >= tabY && mouseY <= tabY + tabHeight) {
    if (mouseX >= tab1X && mouseX <= tab1X + tabWidth) {
      currentTab = 0;
    } else if (mouseX >= tab2X && mouseX <= tab2X + tabWidth) {
      currentTab = 1;
    } else if (mouseX >= tab3X && mouseX <= tab3X + tabWidth) {
      currentTab = 2;
    }
  }

  // Check timeframe selector clicks
  // In house map view with selected region, check detail panel timeframe buttons
  if (currentTab == 0 && selectedRegion != null) {
    float detailX = houseImageX + houseImageWidth + 30;
    float detailY = houseImageY;
    float timeframeSelectorY = detailY + 70;
    float buttonStartX = detailX + 20 + 75;  // Aligned with Location buttons

    if (mouseY >= timeframeSelectorY && mouseY <= timeframeSelectorY + timeframeButtonHeight) {
      for (int i = 0; i < 3; i++) {
        float btnX = buttonStartX + i * (timeframeButtonWidth + 10);
        if (mouseX >= btnX && mouseX <= btnX + timeframeButtonWidth) {
          timeframeMode = i;
          selectedTimeIndex = 0;
          selectedRegion.updateTimeframeData(timeframeMode);
          break;
        }
      }
    }
  }

  // Check location selector in analytics view
  if (currentTab == 1) {
    float locationButtonStartX = 40 + 75;
    float locationButtonWidth = 140;
    if (mouseY >= timeframeButtonY && mouseY <= timeframeButtonY + timeframeButtonHeight) {
      for (int i = 0; i < regions.length; i++) {
        float btnX = locationButtonStartX + i * (locationButtonWidth + 10);
        if (mouseX >= btnX && mouseX <= btnX + locationButtonWidth) {
          analyticsLocationIndex = i;
          selectedTimeIndex = 0;
          regions[analyticsLocationIndex].updateTimeframeData(timeframeMode);
          break;
        }
      }
    }
  }

  // Check timeframe selector in analytics view
  if (currentTab == 1) {
    float timeframeSelectorY = timeframeButtonY + timeframeButtonHeight + 15;
    float buttonStartX = 40 + 75;  // Aligned with Location buttons
    if (mouseY >= timeframeSelectorY && mouseY <= timeframeSelectorY + timeframeButtonHeight) {
      for (int i = 0; i < 3; i++) {
        float btnX = buttonStartX + i * (timeframeButtonWidth + 10);
        if (mouseX >= btnX && mouseX <= btnX + timeframeButtonWidth) {
          timeframeMode = i;
          selectedTimeIndex = 0;
          regions[analyticsLocationIndex].updateTimeframeData(timeframeMode);
          break;
        }
      }
    }
  }

  // Check zone clicks in recommendations tab
  if (currentTab == 2) {
    handleRecommendationZoneClick(mouseX, mouseY);

    // Check if clicking on recommendation slider
    if (handleRecommendationSliderDrag(mouseX, mouseY)) {
      draggingSlider = true;
    }
  }

  // Check region clicks (only in house map view)
  if (currentTab == 0) {
    for (HouseRegion region : regions) {
      if (region.contains(mouseX, mouseY)) {
        selectedRegion = region;
        selectedTimeIndex = 0;  // Reset to current time
        break;
      }
    }

    // Check slider click
    if (selectedRegion != null) {
      float detailX = houseImageX + houseImageWidth + 30;
      float detailY = houseImageY;
      float detailWidth = width - detailX - 30;
      float timeframeSelectorY = detailY + 70;
      float sliderStartY = timeframeSelectorY + timeframeButtonHeight + 15;
      float sliderXPos = detailX + 20;
      float sliderYPos = sliderStartY + 20;
      float sliderW = detailWidth - 40;

      if (mouseX >= sliderXPos && mouseX <= sliderXPos + sliderW &&
          mouseY >= sliderYPos && mouseY <= sliderYPos + sliderHeight) {
        draggingSlider = true;
        updateSliderValue(sliderXPos, sliderW);
      }
      // Check 3D visualization area click for rotation
      else if (mouseX >= viz3DX && mouseX <= viz3DX + viz3DWidth &&
               mouseY >= viz3DY && mouseY <= viz3DY + viz3DHeight) {
        dragging3D = true;
        prevMouseX3D = mouseX;
        prevMouseY3D = mouseY;
      }
    }
  }
}

/**
 * Mouse dragged event
 */
public void mouseDragged() {
  // Handle recommendation slider dragging
  if (draggingSlider && currentTab == 2) {
    handleRecommendationSliderDrag(mouseX, mouseY);
  }
  // Handle house map slider dragging
  else if (draggingSlider && selectedRegion != null) {
    float detailX = houseImageX + houseImageWidth + 30;
    float detailWidth = width - detailX - 30;
    float sliderXPos = detailX + 20;
    float sliderW = detailWidth - 40;

    updateSliderValue(sliderXPos, sliderW);
  }
  // Handle 3D rotation dragging
  else if (dragging3D && selectedRegion != null) {
    float dx = mouseX - prevMouseX3D;
    float dy = mouseY - prevMouseY3D;

    // Update rotation based on mouse movement
    rotationY += dx * 0.01f;  // Horizontal rotation
    rotationX += dy * 0.01f;  // Vertical rotation

    // Constrain vertical rotation to prevent flipping
    rotationX = constrain(rotationX, -PI/2, PI/2);

    prevMouseX3D = mouseX;
    prevMouseY3D = mouseY;
  }
}

/**
 * Mouse released event
 */
public void mouseReleased() {
  draggingSlider = false;
  dragging3D = false;
}

/**
 * Mouse moved event - update hover states
 */
public void mouseMoved() {
  if (currentTab == 0) {
    for (HouseRegion region : regions) {
      region.checkHover(mouseX, mouseY);
    }
  } else if (currentTab == 2) {
    checkRecommendationZoneHover(mouseX, mouseY);
  }
}

/**
 * Update slider value based on mouse position
 */
public void updateSliderValue(float sliderX, float sliderW) {
  float relativeX = constrain(mouseX - sliderX, 0, sliderW);
  int maxIndex = selectedRegion.getMaxTimeIndex(timeframeMode);
  // Reversed mapping: right = index 0 (most recent), left = maxIndex (oldest)
  selectedTimeIndex = round(map(relativeX, 0, sliderW, maxIndex, 0));
}

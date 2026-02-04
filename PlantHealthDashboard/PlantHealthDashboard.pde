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

// Tab system
int currentTab = 0;  // 0 = House Map, 1 = Analytics
float tabY = 60;
float tabHeight = 35;
float tab1X = 20;
float tab2X = 220;
float tabWidth = 180;

// Time slider for 24-hour view (30-minute intervals = 48 data points)
float sliderX = 200;
float sliderY = 0;  // Will be set in setup
float sliderWidth = 600;
float sliderHeight = 20;
int selectedTimeIndex = 0;  // 0-47 (0 = now, 47 = 24 hours ago)
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
void setup() {
  size(1400, 900, P3D);
  smooth(8);

  sliderY = height - 80;

  // Try to load house layout image
  try {
    houseLayoutImage = loadImage("house_layout.png");
    println("Loaded house layout image");
  } catch (Exception e) {
    println("Could not load house_layout.png - will use rectangles");
    houseLayoutImage = null;
  }

  // Initialize house regions with positions, names, and plant types
  // Coordinates are mapped to the floor plan image
  regions = new HouseRegion[4];

  // Define regions with their clickable areas (mapped to floor plan)
  // Living Room - large brown wooden floor area on the left side
  regions[0] = new HouseRegion("Living Room", houseImageX + 20, houseImageY + 20, 360, 460, "Rose");

  // Kitchen - top center-right area with blue tiles
  regions[1] = new HouseRegion("Kitchen", houseImageX + 390, houseImageY + 20, 170, 190, "Banana");

  // Bathroom - lower center-right area with blue tiles
  regions[2] = new HouseRegion("Bathroom", houseImageX + 390, houseImageY + 320, 220, 160, "Water Lily");

  // Balcony - far right side with gray/blue tiles
  regions[3] = new HouseRegion("Balcony", houseImageX + 570, houseImageY + 140, 180, 340, "Tomato Plant");

  // Generate 24-hour mock data for all regions
  for (HouseRegion region : regions) {
    region.generateHistoricalData();
  }

  println("Plant Health Dashboard initialized");
  println("Click on different rooms to view sensor data");
}

/**
 * Draw function - runs every frame
 */
void draw() {
  background(20, 25, 35);

  // Draw title bar
  drawTitleBar();

  // Draw tabs
  drawTabs();

  // Draw content based on current tab
  if (currentTab == 0) {
    drawHouseMapView();
  } else {
    drawAnalyticsView();
  }
}

/**
 * Draw title bar
 */
void drawTitleBar() {
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
void drawTabs() {
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
  textSize(14);
  text("🏠 House Map", tab1X + tabWidth/2, tabY + tabHeight/2);

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
  textSize(14);
  text("📊 Analytics", tab2X + tabWidth/2, tabY + tabHeight/2);

  popStyle();
}

/**
 * Draw house map view with clickable regions
 */
void drawHouseMapView() {
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
  textSize(13);
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
void drawRegionDetailView() {
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

  // Time slider
  fill(180);
  textSize(12);
  float hoursAgo = selectedTimeIndex * 0.5;
  int hours = int(hoursAgo);
  int minutes = int((hoursAgo - hours) * 60);
  String timeText = selectedTimeIndex == 0 ? "Now" : hours + "h " + minutes + "m ago";
  text("Time: " + timeText, detailX + 20, detailY + 75);

  drawTimeSlider(detailX + 20, detailY + 95, detailWidth - 40);

  // 3D Growing squares visualization with base platform
  float squaresY = detailY + 130;
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
 * Draw analytics view with graphs and statistics
 */
void drawAnalyticsView() {
  pushStyle();

  if (selectedRegion == null) {
    // No region selected message
    fill(180);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("Please select a room from the House Map tab to view analytics", width/2, height/2);
    popStyle();
    return;
  }

  float chartX = 40;
  float chartY = 120;
  float chartWidth = width - 80;
  float chartHeight = 220;

  // Title
  fill(100, 200, 255);
  textAlign(LEFT, TOP);
  textSize(20);
  text("24-Hour Sensor Data: " + selectedRegion.name, chartX, chartY - 30);

  // Draw three separate graphs
  selectedRegion.drawSensorGraph("Humidity", chartX, chartY, chartWidth, chartHeight);
  selectedRegion.drawSensorGraph("Temperature", chartX, chartY + chartHeight + 50, chartWidth, chartHeight);
  selectedRegion.drawSensorGraph("Light", chartX, chartY + (chartHeight + 50) * 2, chartWidth, chartHeight);

  popStyle();
}

/**
 * Draw time slider
 */
void drawTimeSlider(float x, float y, float w) {
  pushStyle();

  // Slider background
  fill(40, 45, 55);
  stroke(80);
  strokeWeight(1);
  rect(x, y, w, sliderHeight, 5);

  // Hour markers (every 6 hours = 12 intervals)
  for (int i = 0; i <= 24; i += 6) {
    int index = i * 2;  // Convert hours to 30-min intervals
    float markerX = x + map(index, 0, 47, 0, w);
    stroke(100);
    line(markerX, y, markerX, y + sliderHeight);

    fill(150);
    textAlign(CENTER, TOP);
    textSize(10);
    text(i + "h", markerX, y + sliderHeight + 3);
  }

  // Selected time indicator
  float handleX = x + map(selectedTimeIndex, 0, 47, 0, w);
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
void mousePressed() {
  // Check tab clicks
  if (mouseY >= tabY && mouseY <= tabY + tabHeight) {
    if (mouseX >= tab1X && mouseX <= tab1X + tabWidth) {
      currentTab = 0;
    } else if (mouseX >= tab2X && mouseX <= tab2X + tabWidth) {
      currentTab = 1;
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
      float sliderXPos = detailX + 20;
      float sliderYPos = detailY + 95;
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
void mouseDragged() {
  if (draggingSlider && selectedRegion != null) {
    float detailX = houseImageX + houseImageWidth + 30;
    float detailY = houseImageY;
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
    rotationY += dx * 0.01;  // Horizontal rotation
    rotationX += dy * 0.01;  // Vertical rotation

    // Constrain vertical rotation to prevent flipping
    rotationX = constrain(rotationX, -PI/2, PI/2);

    prevMouseX3D = mouseX;
    prevMouseY3D = mouseY;
  }
}

/**
 * Mouse released event
 */
void mouseReleased() {
  draggingSlider = false;
  dragging3D = false;
}

/**
 * Mouse moved event - update hover states
 */
void mouseMoved() {
  if (currentTab == 0) {
    for (HouseRegion region : regions) {
      region.checkHover(mouseX, mouseY);
    }
  }
}

/**
 * Update slider value based on mouse position
 */
void updateSliderValue(float sliderX, float sliderW) {
  float relativeX = constrain(mouseX - sliderX, 0, sliderW);
  selectedTimeIndex = round(map(relativeX, 0, sliderW, 0, 47));
}

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

// Time slider for 24-hour view
float sliderX = 200;
float sliderY = 0;  // Will be set in setup
float sliderWidth = 600;
float sliderHeight = 20;
int selectedHour = 0;  // 0-23 hours
boolean draggingSlider = false;

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
  size(1400, 900);
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
  regions = new HouseRegion[5];

  // Define regions with their clickable areas (relative to house image position)
  regions[0] = new HouseRegion("Living Room", 100, 150, 200, 180, "Peace Lily");
  regions[1] = new HouseRegion("Kitchen", 320, 150, 180, 180, "Herb Garden");
  regions[2] = new HouseRegion("Balcony", 520, 150, 200, 180, "Tomato Plants");
  regions[3] = new HouseRegion("Bedroom", 100, 350, 200, 200, "Snake Plant");
  regions[4] = new HouseRegion("Bathroom", 320, 350, 180, 200, "Water Lily");

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
  float detailHeight = houseImageHeight + 120;

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
  text("Time: " + selectedHour + ":00 (" + (selectedHour == 0 ? "Now" : selectedHour + " hours ago") + ")",
       detailX + 20, detailY + 75);

  drawTimeSlider(detailX + 20, detailY + 95, detailWidth - 40);

  // Growing squares visualization
  float squaresY = detailY + 140;
  selectedRegion.drawGrowingSquares(detailX + 20, squaresY, detailWidth - 40, selectedHour);

  // Plant health prediction
  float healthY = squaresY + 250;
  selectedRegion.drawPlantHealth(detailX + 20, healthY, detailWidth - 40, selectedHour);

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

  // Hour markers
  for (int i = 0; i <= 24; i += 6) {
    float markerX = x + map(i, 0, 23, 0, w);
    stroke(100);
    line(markerX, y, markerX, y + sliderHeight);

    fill(150);
    textAlign(CENTER, TOP);
    textSize(10);
    text(i + "h", markerX, y + sliderHeight + 3);
  }

  // Selected hour indicator
  float handleX = x + map(selectedHour, 0, 23, 0, w);
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
        selectedHour = 0;  // Reset to current time
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
}

/**
 * Mouse released event
 */
void mouseReleased() {
  draggingSlider = false;
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
  selectedHour = round(map(relativeX, 0, sliderW, 0, 23));
}

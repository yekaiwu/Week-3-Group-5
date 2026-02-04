/**
 * Plant Conditions Monitoring Dashboard
 * 3D Visualization with 4 Quadrants
 * Each quadrant contains 3 sensors: Humidity, Temperature, Light Level
 * Data is simulated using Perlin noise and updated every 5 seconds
 */

// Quadrants array (4 quadrants)
Quadrant[] quadrants;

// Camera control variables
float rotationX = -0.6;  // Viewing angle X
float rotationY = 0;     // Viewing angle Y
float rotationZ = 0;     // Viewing angle Z
float cameraDistance = 600; // Distance from center

// Camera preset positions
int cameraPreset = 0;  // 0=top-down, 1=front, 2=side, 3=perspective
float targetRotationX = -0.6;
float targetRotationY = 0;
float targetRotationZ = 0;

// Arrow key camera movement
float rotationSpeed = 0.05;

// Mouse interaction
float prevMouseX = 0;
float prevMouseY = 0;
boolean isDragging = false;

// Timing for data updates
int lastUpdateTime = 0;
int updateInterval = 5000; // 5 seconds in milliseconds

// UI state
boolean showHelp = false;  // Hidden by default
int lastKeyPressTime = 0;

// Tab/View system
int currentView = 0;  // 0 = Quadrants View, 1 = System Overview
float tabY = 70;
float tabHeight = 35;
float tab1X = 20;
float tab2X = 220;
float tabWidth = 180;

/**
 * Setup function - runs once at start
 */
void setup() {
  size(1200, 900, P3D);
  smooth(8);

  // Initialize quadrants in a 2x2 grid
  float quadrantSize = 300;
  float spacing = 50;
  float offsetX = quadrantSize / 2 + spacing / 2;
  float offsetY = quadrantSize / 2 + spacing / 2;

  quadrants = new Quadrant[4];

  // Top-left quadrant - Living Room
  quadrants[0] = new Quadrant("Living Room", -offsetX, -offsetY, quadrantSize, 0, "living_room.jpg");

  // Top-right quadrant - Attic
  quadrants[1] = new Quadrant("Attic", offsetX, -offsetY, quadrantSize, 1, "attic.jpg");

  // Bottom-left quadrant - Balcony
  quadrants[2] = new Quadrant("Balcony", -offsetX, offsetY, quadrantSize, 2, "balcony.jpg");

  // Bottom-right quadrant - Toilet
  quadrants[3] = new Quadrant("Toilet", offsetX, offsetY, quadrantSize, 3, "toilet.jpg");

  lastUpdateTime = millis();
}

/**
 * Draw function - runs every frame
 */
void draw() {
  background(20, 20, 30);

  // Update sensor data every 5 seconds
  if (millis() - lastUpdateTime >= updateInterval) {
    updateAllSensors();
    lastUpdateTime = millis();
  }

  // Show different content based on current view
  if (currentView == 0) {
    // QUADRANTS VIEW - Show 3D visualization
    // Set up 3D camera
    setupCamera();

    // Enable lighting for better 3D effect
    lights();
    ambientLight(80, 80, 80);
    directionalLight(200, 200, 200, -1, 1, -1);

    // Draw ground plane
    drawGroundPlane();

    // Check hover state for each quadrant
    checkQuadrantHover();

    // Update and display all quadrants (pass camera rotation for billboarding)
    for (Quadrant quadrant : quadrants) {
      quadrant.display(rotationX, rotationY, rotationZ);
    }

    // Draw UI overlay (2D)
    drawUI();
  } else {
    // SYSTEM OVERVIEW VIEW - Show dashboard only (2D mode)
    pushStyle();
    fill(255);
    textAlign(LEFT, TOP);
    textSize(24);
    text("Plant Monitoring Dashboard", 20, 20);

    // Draw instructions
    textSize(12);
    fill(180);
    text("Switch views with tabs", 20, 55);

    // Draw tabs for switching views
    drawTabs();

    // Draw help panel if needed
    if (showHelp) {
      drawHelpPanel();
    }

    popStyle();

    // Draw the full-screen system overview
    drawSystemOverviewFullScreen();
  }
}

/**
 * Set up 3D camera with rotation and zoom
 */
void setupCamera() {
  pushMatrix();
  translate(width / 2, height / 2, -cameraDistance);
  rotateX(rotationX);
  rotateY(rotationY);
  rotateZ(rotationZ);
}

/**
 * Draw a ground plane for reference
 */
void drawGroundPlane() {
  pushStyle();
  noStroke();
  fill(30, 30, 40, 150);
  pushMatrix();
  translate(0, 0, -10);
  rectMode(CENTER);
  rect(0, 0, 800, 800);
  popMatrix();
  popStyle();
}

/**
 * Check which quadrant the mouse is hovering over
 * This is done by projecting mouse position into 3D space
 */
void checkQuadrantHover() {
  // Calculate mouse position relative to center
  float mx = mouseX - width / 2;
  float my = mouseY - height / 2;

  // Simple 2D hover detection (approximate)
  // In a full implementation, this would use proper 3D picking
  for (Quadrant quadrant : quadrants) {
    // Transform quadrant position by current rotation (simplified)
    float qx = quadrant.x;
    float qy = quadrant.y;

    // Apply rotation transformations (simplified for top-down view)
    float transformedX = qx * cos(rotationY) - qy * sin(rotationX);
    float transformedY = qy * cos(rotationX) + qx * sin(rotationY);

    quadrant.checkHover(mx, my);
  }

  // Ensure at least the update happens
  for (Quadrant quadrant : quadrants) {
    quadrant.update();
  }
}

/**
 * Update all sensor readings
 */
void updateAllSensors() {
  for (Quadrant quadrant : quadrants) {
    for (Sensor sensor : quadrant.sensors) {
      sensor.update();
    }
  }
}

/**
 * Draw 2D UI overlay
 */
void drawUI() {
  popMatrix(); // Exit 3D mode

  // Draw title
  pushStyle();
  fill(255);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Plant Monitoring Dashboard", 20, 20);

  // Draw instructions
  textSize(12);
  fill(180);
  text("Arrow keys/Drag to rotate | 2-finger zoom | Click tabs to switch views", 20, 55);

  // Draw tabs for switching views
  drawTabs();

  // Draw help panel
  if (showHelp) {
    drawHelpPanel();
  }

  popStyle();
}

/**
 * Draw help panel
 */
void drawHelpPanel() {
  pushStyle();
  fill(0, 0, 0, 200);
  rect(20, 110, 320, 360, 10);

  fill(255, 255, 100);
  textSize(16);
  textAlign(LEFT, TOP);
  text("How to Use:", 30, 125);

  fill(220);
  textSize(12);
  int yPos = 150;
  int lineHeight = 20;

  text("• Hover over a room to see", 30, yPos);
  yPos += lineHeight;
  text("  sensor details and colors", 30, yPos);
  yPos += lineHeight;
  text("• Text always faces you!", 30, yPos);
  yPos += lineHeight + 5;

  text("• Green bars = Healthy range", 30, yPos);
  yPos += lineHeight;
  text("• Yellow bars = Warning range", 30, yPos);
  yPos += lineHeight;
  text("• Red bars = Critical range", 30, yPos);
  yPos += lineHeight + 5;

  text("• Grey bars = Not hovered", 30, yPos);
  yPos += lineHeight + 5;

  fill(100, 200, 255);
  text("Camera Controls:", 30, yPos);
  yPos += lineHeight;
  fill(220);

  text("• Arrow keys: Rotate camera", 30, yPos);
  yPos += lineHeight;
  text("• Click and drag to rotate", 30, yPos);
  yPos += lineHeight;
  text("• Scroll/2-finger to zoom", 30, yPos);
  yPos += lineHeight + 5;

  fill(100, 200, 255);
  text("Preset Views:", 30, yPos);
  yPos += lineHeight;
  fill(220);

  text("• Press '1' for Top-down view", 30, yPos);
  yPos += lineHeight;
  text("• Press '2' for Front view", 30, yPos);
  yPos += lineHeight;
  text("• Press '3' for Side view (left)", 30, yPos);
  yPos += lineHeight;
  text("• Press '4' for Side view (right)", 30, yPos);
  yPos += lineHeight;
  text("• Press '5' for Perspective", 30, yPos);
  yPos += lineHeight + 5;

  text("• Press 'R' to reset view", 30, yPos);
  yPos += lineHeight;
  text("• Press 'H' to hide this panel", 30, yPos);

  popStyle();
}

/**
 * Draw overall dashboard on the right side showing all rooms and sensor data
 */
void drawOverallDashboard() {
  pushStyle();

  // Dashboard dimensions
  float dashboardWidth = 380;
  float dashboardX = width - dashboardWidth - 10;
  float dashboardY = 110;
  float dashboardHeight = height - 120;

  // Background panel
  fill(0, 0, 0, 220);
  stroke(80);
  strokeWeight(1);
  rect(dashboardX, dashboardY, dashboardWidth, dashboardHeight, 10);

  // Title
  fill(255, 200, 50);
  textSize(18);
  textAlign(LEFT, TOP);
  text("📊 System Overview", dashboardX + 15, dashboardY + 15);

  // Draw line separator
  stroke(100);
  line(dashboardX + 15, dashboardY + 45, dashboardX + dashboardWidth - 15, dashboardY + 45);

  // Starting position for room cards
  float cardY = dashboardY + 60;
  float cardHeight = (dashboardHeight - 80) / 4 - 10;  // Divide space for 4 rooms
  float cardSpacing = 10;

  // Draw each room's sensor data
  for (int i = 0; i < quadrants.length; i++) {
    Quadrant quadrant = quadrants[i];
    float currentCardY = cardY + (i * (cardHeight + cardSpacing));

    // Room card background (highlight if hovered)
    if (quadrant.isHovered) {
      fill(40, 80, 120, 200);
      strokeWeight(2);
      stroke(100, 200, 255);
    } else {
      fill(20, 20, 30, 180);
      strokeWeight(1);
      stroke(60);
    }
    rect(dashboardX + 10, currentCardY, dashboardWidth - 20, cardHeight, 8);

    // Room name
    fill(quadrant.isHovered ? color(100, 200, 255) : color(180, 180, 180));
    textSize(14);
    textAlign(LEFT, TOP);
    text(quadrant.name, dashboardX + 20, currentCardY + 8);

    // Sensor data
    float sensorX = dashboardX + 20;
    float sensorY = currentCardY + 30;
    float sensorSpacing = (cardHeight - 40) / 3;

    for (int j = 0; j < quadrant.sensors.length; j++) {
      Sensor sensor = quadrant.sensors[j];
      float currentSensorY = sensorY + (j * sensorSpacing);

      // Sensor name
      fill(200);
      textSize(11);
      textAlign(LEFT, TOP);
      text(sensor.name + ":", sensorX, currentSensorY);

      // Sensor value with color indicator
      color statusColor = sensor.getStatusColor();
      fill(statusColor);
      textSize(12);
      text(sensor.getValueString(), sensorX + 90, currentSensorY);

      // Color indicator box
      noStroke();
      fill(statusColor);
      rect(sensorX + 180, currentSensorY + 2, 12, 12, 2);

      // Status text
      fill(150);
      textSize(10);
      text(sensor.getStatus(), sensorX + 200, currentSensorY + 2);
    }
  }

  // Legend at the bottom
  float legendY = dashboardY + dashboardHeight - 55;
  fill(180);
  textSize(11);
  textAlign(LEFT, TOP);
  text("Status Legend:", dashboardX + 15, legendY);

  // Green indicator
  fill(50, 200, 50);
  noStroke();
  rect(dashboardX + 15, legendY + 20, 15, 15, 3);
  fill(200);
  textSize(10);
  text("Healthy", dashboardX + 35, legendY + 22);

  // Yellow indicator
  fill(255, 200, 0);
  rect(dashboardX + 110, legendY + 20, 15, 15, 3);
  fill(200);
  text("Warning", dashboardX + 130, legendY + 22);

  // Red indicator
  fill(255, 50, 50);
  rect(dashboardX + 210, legendY + 20, 15, 15, 3);
  fill(200);
  text("Critical", dashboardX + 230, legendY + 22);

  popStyle();
}

/**
 * Draw tabs for switching between views
 */
void drawTabs() {
  pushStyle();

  // Tab 1: Quadrants View
  boolean tab1Hover = (mouseX >= tab1X && mouseX <= tab1X + tabWidth &&
                       mouseY >= tabY && mouseY <= tabY + tabHeight);

  if (currentView == 0) {
    // Active tab
    fill(60, 120, 180);
    stroke(100, 200, 255);
    strokeWeight(2);
  } else if (tab1Hover) {
    // Hover state
    fill(50, 80, 120);
    stroke(100, 150, 200);
    strokeWeight(1);
  } else {
    // Inactive tab
    fill(30, 40, 60);
    stroke(60);
    strokeWeight(1);
  }
  rect(tab1X, tabY, tabWidth, tabHeight, 8, 8, 0, 0);

  fill(currentView == 0 ? 255 : 180);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("🏠 Quadrants View", tab1X + tabWidth/2, tabY + tabHeight/2);

  // Tab 2: System Overview
  boolean tab2Hover = (mouseX >= tab2X && mouseX <= tab2X + tabWidth &&
                       mouseY >= tabY && mouseY <= tabY + tabHeight);

  if (currentView == 1) {
    // Active tab
    fill(60, 120, 180);
    stroke(100, 200, 255);
    strokeWeight(2);
  } else if (tab2Hover) {
    // Hover state
    fill(50, 80, 120);
    stroke(100, 150, 200);
    strokeWeight(1);
  } else {
    // Inactive tab
    fill(30, 40, 60);
    stroke(60);
    strokeWeight(1);
  }
  rect(tab2X, tabY, tabWidth, tabHeight, 8, 8, 0, 0);

  fill(currentView == 1 ? 255 : 180);
  textAlign(CENTER, CENTER);
  textSize(14);
  text("📊 System Overview", tab2X + tabWidth/2, tabY + tabHeight/2);

  popStyle();
}

/**
 * Draw full-screen system overview (for tab view)
 */
void drawSystemOverviewFullScreen() {
  pushStyle();

  // Full screen dashboard dimensions
  float dashboardWidth = width - 40;
  float dashboardX = 20;
  float dashboardY = 120;
  float dashboardHeight = height - 140;

  // Background panel
  fill(0, 0, 0, 220);
  stroke(80);
  strokeWeight(1);
  rect(dashboardX, dashboardY, dashboardWidth, dashboardHeight, 10);

  // Title
  fill(255, 200, 50);
  textSize(24);
  textAlign(LEFT, TOP);
  text("📊 System Overview", dashboardX + 20, dashboardY + 20);

  // Draw line separator
  stroke(100);
  line(dashboardX + 20, dashboardY + 60, dashboardX + dashboardWidth - 20, dashboardY + 60);

  // Starting position for room cards
  float cardY = dashboardY + 80;
  float cardHeight = (dashboardHeight - 110) / 4 - 15;  // Divide space for 4 rooms
  float cardSpacing = 15;

  // Draw each room's sensor data
  for (int i = 0; i < quadrants.length; i++) {
    Quadrant quadrant = quadrants[i];
    float currentCardY = cardY + (i * (cardHeight + cardSpacing));

    // Room card background
    fill(20, 20, 30, 180);
    strokeWeight(1);
    stroke(60);
    rect(dashboardX + 15, currentCardY, dashboardWidth - 30, cardHeight, 8);

    // Room name
    fill(180, 180, 200);
    textSize(18);
    textAlign(LEFT, TOP);
    text(quadrant.name, dashboardX + 30, currentCardY + 15);

    // Sensor data in columns
    float sensorX = dashboardX + 30;
    float sensorY = currentCardY + 50;
    float columnWidth = (dashboardWidth - 80) / 3;

    for (int j = 0; j < quadrant.sensors.length; j++) {
      Sensor sensor = quadrant.sensors[j];
      float currentSensorX = sensorX + (j * columnWidth);

      // Get status-based color
      color statusColor = sensor.getStatusColor();

      // Sensor card
      fill(30, 30, 40, 150);
      stroke(statusColor);
      strokeWeight(2);
      rect(currentSensorX, sensorY, columnWidth - 20, cardHeight - 70, 6);

      // Sensor name
      fill(200);
      textSize(14);
      textAlign(LEFT, TOP);
      text(sensor.name, currentSensorX + 10, sensorY + 10);

      // Sensor value
      fill(statusColor);
      textSize(24);
      text(sensor.getValueString(), currentSensorX + 10, sensorY + 35);

      // Status text
      fill(150);
      textSize(12);
      text(sensor.getStatus(), currentSensorX + 10, sensorY + 70);

      // Bar indicator
      float barWidth = columnWidth - 40;
      float barHeight = 8;
      float barX = currentSensorX + 10;
      float barY = sensorY + cardHeight - 85;

      // Background bar
      noStroke();
      fill(40, 40, 50);
      rect(barX, barY, barWidth, barHeight, 4);

      // Value bar
      float percentage = (sensor.value - sensor.minValue) / (sensor.maxValue - sensor.minValue);
      fill(statusColor);
      rect(barX, barY, barWidth * percentage, barHeight, 4);
    }
  }

  // Legend at the bottom
  float legendY = dashboardY + dashboardHeight - 40;
  fill(180);
  textSize(14);
  textAlign(LEFT, TOP);
  text("Status Legend:", dashboardX + 20, legendY);

  // Green indicator
  fill(50, 200, 50);
  noStroke();
  rect(dashboardX + 150, legendY + 2, 20, 20, 3);
  fill(200);
  textSize(12);
  text("Healthy", dashboardX + 180, legendY + 3);

  // Yellow indicator
  fill(255, 200, 0);
  rect(dashboardX + 280, legendY + 2, 20, 20, 3);
  fill(200);
  text("Warning", dashboardX + 310, legendY + 3);

  // Red indicator
  fill(255, 50, 50);
  rect(dashboardX + 420, legendY + 2, 20, 20, 3);
  fill(200);
  text("Critical", dashboardX + 450, legendY + 3);

  popStyle();
}

/**
 * Mouse pressed event
 */
void mousePressed() {
  isDragging = true;
  prevMouseX = mouseX;
  prevMouseY = mouseY;
}

/**
 * Mouse released event
 */
void mouseReleased() {
  isDragging = false;
}

/**
 * Mouse dragged event - rotate view (full 360-degree rotation)
 * Only works in Quadrants View
 */
void mouseDragged() {
  if (isDragging && currentView == 0) {
    float dx = mouseX - prevMouseX;
    float dy = mouseY - prevMouseY;

    rotationY += dx * 0.01;  // Full horizontal rotation (no limit)
    rotationX += dy * 0.01;  // Vertical rotation

    // Constrain rotation X to prevent extreme flipping (same as arrow keys)
    rotationX = constrain(rotationX, -PI/2, PI/2);

    prevMouseX = mouseX;
    prevMouseY = mouseY;
  }
}

/**
 * Mouse wheel event - zoom in/out (works with 2-finger trackpad gestures)
 * Only works in Quadrants View
 */
void mouseWheel(MouseEvent event) {
  if (currentView == 0) {
    float delta = event.getCount();

    // Smooth zoom with better sensitivity for trackpad
    float zoomSpeed = 25;
    cameraDistance += delta * zoomSpeed;

    // Constrain zoom levels (closer = smaller value, farther = larger value)
    // Min: 100 (very close), Max: 1500 (far away)
    cameraDistance = constrain(cameraDistance, 100, 1500);
  }
}

/**
 * Key pressed event
 */
void keyPressed() {
  // Arrow key controls for camera rotation (only in Quadrants View)
  if (currentView == 0) {
    if (keyCode == UP) {
      rotationX -= rotationSpeed;
      rotationX = constrain(rotationX, -PI/2, PI/2);
    }
    else if (keyCode == DOWN) {
      rotationX += rotationSpeed;
      rotationX = constrain(rotationX, -PI/2, PI/2);
    }
    else if (keyCode == LEFT) {
      rotationY -= rotationSpeed;
    }
    else if (keyCode == RIGHT) {
      rotationY += rotationSpeed;
    }
  }

  // Number keys for preset camera views (only in Quadrants View)
  if (currentView == 0) {
    if (key == '1') {
      // Top-down view
      rotationX = -PI/2;
      rotationY = 0;
      rotationZ = 0;
      cameraPreset = 0;
    }
    else if (key == '2') {
      // Front view
      rotationX = 0;
      rotationY = 0;
      rotationZ = 0;
      cameraPreset = 1;
    }
    else if (key == '3') {
      // Side view (left)
      rotationX = 0;
      rotationY = -PI/2;
      rotationZ = 0;
      cameraPreset = 2;
    }
    else if (key == '4') {
      // Side view (right)
      rotationX = 0;
      rotationY = PI/2;
      rotationZ = 0;
      cameraPreset = 3;
    }
    else if (key == '5') {
      // Perspective view
      rotationX = -0.6;
      rotationY = 0.5;
      rotationZ = 0;
      cameraPreset = 4;
    }
  }

  // Reset view
  if (key == 'r' || key == 'R') {
    rotationX = -0.6;
    rotationY = 0;
    rotationZ = 0;
    cameraDistance = 600;
  }

  // Toggle help
  if (key == 'h' || key == 'H') {
    showHelp = !showHelp;
  }

  // Force update sensors (for testing)
  if (key == 'u' || key == 'U') {
    updateAllSensors();
    lastUpdateTime = millis();
  }
}

/**
 * Mouse clicked event - handle tab switching
 */
void mouseClicked() {
  // Check if Tab 1 (Quadrants View) was clicked
  if (mouseX >= tab1X && mouseX <= tab1X + tabWidth &&
      mouseY >= tabY && mouseY <= tabY + tabHeight) {
    currentView = 0;
  }

  // Check if Tab 2 (System Overview) was clicked
  if (mouseX >= tab2X && mouseX <= tab2X + tabWidth &&
      mouseY >= tabY && mouseY <= tabY + tabHeight) {
    currentView = 1;
  }
}

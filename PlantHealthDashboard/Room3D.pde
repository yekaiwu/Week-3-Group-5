/**
 * 3D Room Visualization Tab
 * Displays a 3D model of the house layout that can be rotated
 *
 * Note: Variables like rotationX, rotationY, rotationZ, dragging3D, etc.
 * are declared in the main PlantHealthDashboard.pde file and shared across all tabs.
 */

/**
 * Draw the 3D Room view - called from main draw() when currentTab == 4
 */
void drawRoom3DView() {
  pushStyle();

  // Title
  fill(100, 200, 255);
  textAlign(LEFT, TOP);
  textSize(20);
  text("3D House Layout", 40, 120);

  // Instructions
  fill(180);
  textSize(14);
  text("Click and drag to rotate the 3D house model", 40, 155);

  // 3D visualization area
  float viz3DStartY = 190;
  float viz3DAreaHeight = height - viz3DStartY - 40;

  // Store bounds for mouse interaction
  viz3DX = 40;
  viz3DY = viz3DStartY;
  viz3DWidth = width - 80;
  viz3DHeight = viz3DAreaHeight;

  // Draw 3D house model
  draw3DHouseModel(viz3DX, viz3DY, viz3DWidth, viz3DHeight);

  popStyle();
}

/**
 * Draw the 3D house model with rooms
 */
void draw3DHouseModel(float x, float y, float w, float h) {
  pushMatrix();
  pushStyle();

  // Set up 3D viewport
  translate(x + w/2, y + h/2, 0);

  // Apply rotation
  rotateX(rotationX);
  rotateY(rotationY);
  rotateZ(rotationZ);

  // Scale for better view
  float scaleSize = min(w, h) / 800.0;
  scale(scaleSize);

  // Draw floor
  pushMatrix();
  translate(0, 200, 0);
  fill(60, 50, 45);
  stroke(40);
  strokeWeight(2);
  box(700, 5, 500);
  popMatrix();

  // Wall thickness
  float wallThickness = 20;
  float wallHeight = 300;

  // LIVING ROOM - Left side (large area)
  pushMatrix();
  translate(-175, 0, 0);

  // Living room floor
  fill(139, 90, 60); // Brown wood
  stroke(80, 50, 30);
  strokeWeight(1);
  pushMatrix();
  translate(0, 200, 0);
  box(300, 1, 460);
  popMatrix();

  // Living room label
  fill(255, 200, 100);
  textAlign(CENTER, CENTER);
  textSize(24);
  pushMatrix();
  translate(0, 50, 0);
  rotateX(HALF_PI);
  text("Living Room", 0, 0);
  popMatrix();

  // Walls for living room
  fill(200, 200, 200);
  stroke(100);
  strokeWeight(2);

  // Left wall
  pushMatrix();
  translate(-150 - wallThickness/2, 0, 0);
  box(wallThickness, wallHeight, 460);
  popMatrix();

  // Back wall
  pushMatrix();
  translate(0, 0, -230 - wallThickness/2);
  box(300, wallHeight, wallThickness);
  popMatrix();

  popMatrix();

  // KITCHEN - Top center-right
  pushMatrix();
  translate(70, 0, -110);

  // Kitchen floor (blue tiles)
  fill(120, 150, 180);
  stroke(80, 100, 120);
  strokeWeight(1);
  pushMatrix();
  translate(0, 200, 0);
  box(170, 1, 240);
  popMatrix();

  // Kitchen label
  fill(255, 200, 100);
  textAlign(CENTER, CENTER);
  textSize(24);
  pushMatrix();
  translate(0, 50, 0);
  rotateX(HALF_PI);
  text("Kitchen", 0, 0);
  popMatrix();

  // Kitchen walls
  fill(220, 220, 220);
  stroke(100);
  strokeWeight(2);

  // Top wall
  pushMatrix();
  translate(0, 0, -120 - wallThickness/2);
  box(170, wallHeight, wallThickness);
  popMatrix();

  popMatrix();

  // BATHROOM - Lower center-right
  pushMatrix();
  translate(70, 0, 120);

  // Bathroom floor (blue tiles)
  fill(140, 160, 190);
  stroke(90, 110, 130);
  strokeWeight(1);
  pushMatrix();
  translate(0, 200, 0);
  box(170, 1, 220);
  popMatrix();

  // Bathroom label
  fill(255, 200, 100);
  textAlign(CENTER, CENTER);
  textSize(24);
  pushMatrix();
  translate(0, 50, 0);
  rotateX(HALF_PI);
  text("Bathroom", 0, 0);
  popMatrix();

  popMatrix();

  // BEDROOM - Right side
  pushMatrix();
  translate(245, 0, 0);

  // Bedroom floor (gray/blue tiles)
  fill(160, 165, 175);
  stroke(100, 105, 115);
  strokeWeight(1);
  pushMatrix();
  translate(0, 200, 0);
  box(180, 1, 460);
  popMatrix();

  // Bedroom label
  fill(255, 200, 100);
  textAlign(CENTER, CENTER);
  textSize(24);
  pushMatrix();
  translate(0, 50, 0);
  rotateX(HALF_PI);
  text("Bedroom", 0, 0);
  popMatrix();

  // Bedroom walls
  fill(200, 200, 200);
  stroke(100);
  strokeWeight(2);

  // Right wall
  pushMatrix();
  translate(90 + wallThickness/2, 0, 0);
  box(wallThickness, wallHeight, 460);
  popMatrix();

  // Back wall
  pushMatrix();
  translate(0, 0, -230 - wallThickness/2);
  box(180, wallHeight, wallThickness);
  popMatrix();

  popMatrix();

  // OUTER WALLS
  fill(220, 220, 220);
  stroke(100);
  strokeWeight(2);

  // Front wall
  pushMatrix();
  translate(0, 0, 250);
  box(700, wallHeight, wallThickness);
  popMatrix();

  // Add dividing walls between rooms
  fill(200, 200, 200);

  // Wall between living room and kitchen/bathroom/bedroom
  pushMatrix();
  translate(-25, 0, 0);
  box(wallThickness, wallHeight, 500);
  popMatrix();

  // Wall between kitchen and bathroom
  pushMatrix();
  translate(70, 0, 10);
  box(170, wallHeight, wallThickness);
  popMatrix();

  // Wall between kitchen/bathroom and bedroom
  pushMatrix();
  translate(155, 0, 0);
  box(wallThickness, wallHeight, 500);
  popMatrix();

  popStyle();
  popMatrix();
}

/**
 * Handle mouse press events for 3D room view
 */
boolean handleRoom3DMousePressed(int mx, int my) {
  // Check if clicking in 3D visualization area for rotation
  if (mx >= viz3DX && mx <= viz3DX + viz3DWidth &&
      my >= viz3DY && my <= viz3DY + viz3DHeight) {
    dragging3D = true;
    prevMouseX3D = mx;
    prevMouseY3D = my;
    return true;
  }

  return false;
}

/**
 * Handle mouse drag for 3D room view
 */
void handleRoom3DDrag(int mx, int my) {
  if (dragging3D) {
    float dx = mx - prevMouseX3D;
    float dy = my - prevMouseY3D;

    // Update rotation based on mouse movement
    rotationY += dx * 0.01;  // Horizontal rotation
    rotationX += dy * 0.01;  // Vertical rotation

    // Constrain vertical rotation to prevent flipping
    rotationX = constrain(rotationX, -PI/2, PI/2);

    prevMouseX3D = mx;
    prevMouseY3D = my;
  }
}

/**
 * Quadrant class - Represents one of the 4 quadrants in the room
 * Each quadrant contains 3 sensors: Humidity, Temperature, and Light
 */
class Quadrant {
  String name;           // Quadrant name (e.g., "Living Room", "Attic", etc.)
  float x, y;            // 2D position of quadrant center
  float size;            // Size of the quadrant
  Sensor[] sensors;      // Array of 3 sensors
  boolean isHovered;     // Whether mouse is hovering over this quadrant
  int quadrantIndex;     // Index (0-3) for identification
  PImage roomImage;      // Image representing the room
  String imageName;      // Name of image file

  /**
   * Constructor for Quadrant
   */
  Quadrant(String name, float x, float y, float size, int quadrantIndex, String imageName) {
    this.name = name;
    this.x = x;
    this.y = y;
    this.size = size;
    this.quadrantIndex = quadrantIndex;
    this.isHovered = false;
    this.imageName = imageName;

    // Try to load the room image
    loadRoomImage();


    // Initialize 3 sensors with different noise offsets for variety
    sensors = new Sensor[3];

    // Humidity sensor: 0-100%, healthy: 40-70%, warning: 30-80%
    sensors[0] = new Sensor(
      "Humidity",
      0, 100,           // min, max
      40, 70,           // healthy range
      30, 80,           // warning range
      quadrantIndex * 100 + 0  // unique noise offset
    );

    // Temperature sensor: 15-35°C, healthy: 18-28°C, warning: 15-30°C
    sensors[1] = new Sensor(
      "Temperature",
      15, 35,           // min, max
      18, 28,           // healthy range
      15, 30,           // warning range
      quadrantIndex * 100 + 50  // unique noise offset
    );

    // Light sensor: 0-1000 lux, healthy: 200-800, warning: 100-900
    sensors[2] = new Sensor(
      "Light",
      0, 1000,          // min, max
      200, 800,         // healthy range
      100, 900,         // warning range
      quadrantIndex * 100 + 100  // unique noise offset
    );
  }

  /**
   * Load the room image from data folder
   */
  void loadRoomImage() {
    try {
      roomImage = loadImage(imageName);
      println("Loaded image: " + imageName);
    } catch (Exception e) {
      println("Could not load image: " + imageName);
      println("Using default appearance. Please add image to data folder.");
      roomImage = null;
    }
  }

  /**
   * Update all sensors in this quadrant
   */
  void update() {
    for (Sensor sensor : sensors) {
      sensor.update();
      sensor.updateColor(isHovered);
    }
  }

  /**
   * Check if mouse is hovering over this quadrant
   */
  void checkHover(float mouseXPos, float mouseYPos) {
    // Calculate quadrant boundaries
    float left = x - size / 2;
    float right = x + size / 2;
    float top = y - size / 2;
    float bottom = y + size / 2;

    // Check if mouse is within quadrant bounds
    isHovered = (mouseXPos >= left && mouseXPos <= right &&
                 mouseYPos >= top && mouseYPos <= bottom);
  }

  /**
   * Display the quadrant in 3D
   */
  void display(float camRotX, float camRotY, float camRotZ) {
    pushMatrix();

    // Move to quadrant position
    translate(x, y, 0);

    // Draw room image as textured floor if available
    if (roomImage != null) {
      pushStyle();
      pushMatrix();
      translate(0, 0, -5);  // Slightly below ground

      // Enable texture - keep brightness constant
      noStroke();
      tint(120);  // Same dimmed brightness always

      // Draw textured rectangle
      beginShape();
      texture(roomImage);
      vertex(-size/2, -size/2, 0, 0);
      vertex(size/2, -size/2, roomImage.width, 0);
      vertex(size/2, size/2, roomImage.width, roomImage.height);
      vertex(-size/2, size/2, 0, roomImage.height);
      endShape(CLOSE);

      noTint();
      popMatrix();
      popStyle();
    }

    // Draw quadrant boundary with glowing blue border when hovered
    pushStyle();
    noFill();
    if (isHovered) {
      // Glowing blue border effect
      stroke(100, 180, 255);  // Bright blue
      strokeWeight(3);
    } else {
      stroke(80);  // Subtle gray
      strokeWeight(1);
    }
    rectMode(CENTER);
    rect(0, 0, size, size);
    popStyle();

    // Calculate spacing for 3 sensors
    float spacing = size / 4;
    float startX = -spacing;

    // Draw quadrant label with background box - BILLBOARD effect (always faces camera)
    // Fixed height position - stays constant regardless of bar heights
    pushStyle();
    pushMatrix();

    // Position label at a fixed height above all bars (max bar height is 200, so use 270)
    translate(0, 0, 270);

    // Billboard transformation - counteract camera rotations
    rotateZ(-camRotZ);
    rotateY(-camRotY);
    rotateX(-camRotX);

    fill(isHovered ? color(0, 0, 0, 200) : color(0, 0, 0, 150));
    noStroke();
    rectMode(CENTER);
    float labelWidth = textWidth(name) + 20;
    rect(0, 0, labelWidth, 20, 5);

    fill(isHovered ? color(100, 200, 255) : 150);
    textAlign(CENTER, CENTER);
    textSize(14);
    text(name, 0, 0);

    popMatrix();
    popStyle();

    // Draw each sensor as a 3D bar
    for (int i = 0; i < sensors.length; i++) {
      Sensor sensor = sensors[i];
      float barX = startX + (i * spacing);
      float barHeight = sensor.getBarHeight();
      float barWidth = size / 6;

      pushMatrix();
      translate(barX, 0, barHeight / 2);

      // Draw 3D box
      pushStyle();
      fill(sensor.barColor);
      stroke(isHovered ? 50 : 30);
      strokeWeight(1);
      box(barWidth, barWidth, barHeight);
      popStyle();

      popMatrix();

      // Draw sensor label and value if hovered - BILLBOARD effect
      if (isHovered) {
        pushStyle();

        // Position sensor labels above the bars
        float labelZ = barHeight + 20;

        // Sensor name
        pushMatrix();
        translate(barX, 0, labelZ);
        // Billboard transformation - counteract camera rotations
        rotateZ(-camRotZ);
        rotateY(-camRotY);
        rotateX(-camRotX);

        fill(255);
        textAlign(CENTER, CENTER);
        textSize(10);
        text(sensor.name, 0, 0);
        popMatrix();

        // Sensor value
        pushMatrix();
        translate(barX, 0, labelZ + 15);
        rotateZ(-camRotZ);
        rotateY(-camRotY);
        rotateX(-camRotX);

        fill(255, 255, 100);
        textAlign(CENTER, CENTER);
        textSize(11);
        text(sensor.getValueString(), 0, 0);
        popMatrix();

        // Sensor status
        pushMatrix();
        translate(barX, 0, labelZ + 30);
        rotateZ(-camRotZ);
        rotateY(-camRotY);
        rotateX(-camRotX);

        fill(sensor.barColor);
        textAlign(CENTER, CENTER);
        textSize(9);
        text(sensor.getStatus(), 0, 0);
        popMatrix();

        popStyle();
      }
    }

    popMatrix();
  }

  /**
   * Get sensor data as a formatted string
   */
  String getSensorData() {
    String data = name + ":\n";
    for (Sensor sensor : sensors) {
      data += "  " + sensor.name + ": " + sensor.getValueString() + " (" + sensor.getStatus() + ")\n";
    }
    return data;
  }
}

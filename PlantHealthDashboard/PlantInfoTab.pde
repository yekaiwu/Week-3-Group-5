/**
 * Plant Information Tab
 * Displays all plants with their optimal environmental conditions
 */

// Plant data structure
class PlantInfo {
  String name;
  String sunlightNeeds;
  int wateringDays;
  float minTemp, maxTemp, avgTemp;
  float minHumidity, maxHumidity, avgHumidity;
  float minLux, maxLux, avgLux;
  int occurrences;

  PlantInfo(String name, String sunlight, int watering) {
    this.name = name;
    this.sunlightNeeds = sunlight;
    this.wateringDays = watering;
    this.minTemp = Float.MAX_VALUE;
    this.maxTemp = Float.MIN_VALUE;
    this.minHumidity = Float.MAX_VALUE;
    this.maxHumidity = Float.MIN_VALUE;
    this.minLux = Float.MAX_VALUE;
    this.maxLux = Float.MIN_VALUE;
    this.occurrences = 0;
    this.avgTemp = 0;
    this.avgHumidity = 0;
    this.avgLux = 0;
  }

  void addConditions(float temp, float humidity, float lux) {
    minTemp = min(minTemp, temp);
    maxTemp = max(maxTemp, temp);
    minHumidity = min(minHumidity, humidity);
    maxHumidity = max(maxHumidity, humidity);
    minLux = min(minLux, lux);
    maxLux = max(maxLux, lux);

    // Update running average
    avgTemp = (avgTemp * occurrences + temp) / (occurrences + 1);
    avgHumidity = (avgHumidity * occurrences + humidity) / (occurrences + 1);
    avgLux = (avgLux * occurrences + lux) / (occurrences + 1);

    occurrences++;
  }
}

// Storage for all unique plants
HashMap<String, PlantInfo> allPlants = new HashMap<String, PlantInfo>();
boolean plantDataLoaded = false;

// Scroll position for plant list
float plantScrollOffset = 0;
float maxPlantScroll = 0;
boolean isDraggingPlantScroll = false;
float plantScrollbarHeight = 0;

/**
 * Load and parse plant data from recommendations JSON
 */
void loadPlantData() {
  if (plantDataLoaded) return;

  println("Loading plant information from recommendations data...");

  try {
    JSONObject json = loadJSONObject("sensor_data/zones_export_20260205_135503.json");
    JSONArray zones = json.getJSONArray("zones");

    // Iterate through all zones
    for (int z = 0; z < zones.size(); z++) {
      JSONObject zone = zones.getJSONObject(z);
      JSONArray timeline = zone.getJSONArray("timeline");

      // Iterate through all hours in the timeline
      for (int h = 0; h < timeline.size(); h++) {
        JSONObject hour = timeline.getJSONObject(h);
        float temp = hour.getFloat("temp");
        float humidity = hour.getFloat("humidity");
        float lux = hour.getFloat("lux");
        JSONArray recommendations = hour.getJSONArray("recommendations");

        // Iterate through all plant recommendations
        for (int p = 0; p < recommendations.size(); p++) {
          JSONObject plant = recommendations.getJSONObject(p);
          String plantName = plant.getString("plant");
          String sunlight = plant.getString("sunlight_needs");
          int watering = plant.getInt("watering_days");

          // Create unique key combining name and watering schedule
          String key = plantName + "_" + watering;

          // Add or update plant info
          if (!allPlants.containsKey(key)) {
            allPlants.put(key, new PlantInfo(plantName, sunlight, watering));
          }
          allPlants.get(key).addConditions(temp, humidity, lux);
        }
      }
    }

    plantDataLoaded = true;
    println("Loaded " + allPlants.size() + " unique plant configurations");

  } catch (Exception e) {
    println("Error loading plant data: " + e.getMessage());
    e.printStackTrace();
  }
}

/**
 * Draw the Plant Information view
 */
void drawPlantInfoView() {
  pushStyle();

  // Load data if not already loaded
  if (!plantDataLoaded) {
    loadPlantData();
  }

  // Title section
  float titleY = 120;
  fill(100, 200, 255);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Plant Encyclopedia", 40, titleY);

  fill(180);
  textSize(14);
  text("All plants with their optimal environmental conditions", 40, titleY + 35);

  // Stats badge
  fill(60, 120, 180);
  stroke(100, 200, 255);
  strokeWeight(1);
  rect(40, titleY + 60, 250, 40, 8);

  fill(255);
  textSize(16);
  textAlign(LEFT, CENTER);
  text("Total Plant Varieties: " + allPlants.size(), 55, titleY + 80);

  // Scrollable plant list
  float listY = titleY + 120;
  float listHeight = height - listY - 40;

  drawPlantList(40, listY, width - 80, listHeight);

  popStyle();
}

/**
 * Draw scrollable list of plants
 */
void drawPlantList(float x, float y, float w, float h) {
  pushStyle();

  // Background panel
  fill(30, 35, 45, 240);
  stroke(80);
  strokeWeight(1);
  rect(x, y, w, h, 10);

  // Enable clipping for scrolling
  clip(x + 10, y + 10, w - 40, h - 20);

  // Calculate card dimensions
  float cardWidth = 380;
  float cardHeight = 180;
  float cardPadding = 20;
  float contentX = x + 20;
  float contentY = y + 20 - plantScrollOffset;

  // Calculate grid layout
  int columns = floor((w - 40) / (cardWidth + cardPadding));
  if (columns < 1) columns = 1;

  float actualCardSpacing = (w - 40 - columns * cardWidth) / max(1, columns - 1);
  if (columns == 1) actualCardSpacing = 0;

  // Draw each plant card
  int cardIndex = 0;
  for (PlantInfo plant : allPlants.values()) {
    int row = cardIndex / columns;
    int col = cardIndex % columns;

    float cardX = contentX + col * (cardWidth + actualCardSpacing);
    float cardY = contentY + row * (cardHeight + cardPadding);

    // Only draw if visible
    if (cardY + cardHeight >= y && cardY <= y + h) {
      drawPlantCard(plant, cardX, cardY, cardWidth, cardHeight);
    }

    cardIndex++;
  }

  // Calculate total content height for scrollbar
  int rows = ceil((float)allPlants.size() / columns);
  float totalContentHeight = rows * (cardHeight + cardPadding);
  maxPlantScroll = max(0, totalContentHeight - h + 40);

  noClip();

  // Draw scrollbar if needed
  if (maxPlantScroll > 0) {
    drawScrollbar(x + w - 25, y + 10, 15, h - 20);
  }

  popStyle();
}

/**
 * Draw individual plant information card
 */
void drawPlantCard(PlantInfo plant, float x, float y, float w, float h) {
  pushStyle();

  // Card background
  fill(40, 50, 70);
  stroke(80, 100, 140);
  strokeWeight(1);
  rect(x, y, w, h, 8);

  // Plant name header
  fill(60, 120, 180);
  noStroke();
  rect(x, y, w, 35, 8, 8, 0, 0);

  fill(255);
  textAlign(LEFT, CENTER);
  textSize(15);
  text(plant.name, x + 12, y + 17);

  // Content area
  float contentY = y + 45;
  float lineHeight = 22;

  // Temperature
  fill(255, 180, 100);
  textSize(12);
  text("Temperature:", x + 12, contentY);
  fill(200);
  text(nf(plant.avgTemp, 0, 1) + "°C (range: " + nf(plant.minTemp, 0, 1) + "-" + nf(plant.maxTemp, 0, 1) + "°C)",
       x + 120, contentY);

  // Humidity
  contentY += lineHeight;
  fill(100, 180, 255);
  text("Humidity:", x + 12, contentY);
  fill(200);
  text(nf(plant.avgHumidity, 0, 1) + "% (range: " + nf(plant.minHumidity, 0, 1) + "-" + nf(plant.maxHumidity, 0, 1) + "%)",
       x + 120, contentY);

  // Light
  contentY += lineHeight;
  fill(255, 230, 100);
  text("Light:", x + 12, contentY);
  fill(200);
  text(nf(plant.avgLux, 0, 1) + " lux (range: " + nf(plant.minLux, 0, 1) + "-" + nf(plant.maxLux, 0, 1) + " lux)",
       x + 120, contentY);

  // Sunlight needs
  contentY += lineHeight;
  fill(150, 255, 150);
  text("Sunlight:", x + 12, contentY);
  fill(200);
  text(plant.sunlightNeeds, x + 120, contentY);

  // Watering schedule
  contentY += lineHeight;
  fill(100, 200, 255);
  text("Watering:", x + 12, contentY);
  fill(200);
  String wateringText = "Every " + plant.wateringDays + " day" + (plant.wateringDays != 1 ? "s" : "");
  text(wateringText, x + 120, contentY);

  // Occurrences badge
  fill(60, 80, 100);
  noStroke();
  float badgeW = 80;
  float badgeH = 24;
  rect(x + w - badgeW - 10, y + h - badgeH - 10, badgeW, badgeH, 5);

  fill(180);
  textAlign(CENTER, CENTER);
  textSize(11);
  text(plant.occurrences + " refs", x + w - badgeW/2 - 10, y + h - badgeH/2 - 10);

  popStyle();
}

/**
 * Draw scrollbar
 */
void drawScrollbar(float x, float y, float w, float h) {
  pushStyle();

  // Scrollbar track
  fill(25, 30, 40);
  stroke(60);
  strokeWeight(1);
  rect(x, y, w, h, 5);

  // Scrollbar thumb
  if (maxPlantScroll > 0) {
    float scrollableHeight = h - 20;
    float contentHeight = h + maxPlantScroll;
    plantScrollbarHeight = max(30, (h / contentHeight) * scrollableHeight);

    float thumbY = y + 10 + (plantScrollOffset / maxPlantScroll) * (scrollableHeight - plantScrollbarHeight);

    fill(80, 100, 140);
    stroke(100, 150, 200);
    strokeWeight(1);
    rect(x + 2, thumbY, w - 4, plantScrollbarHeight, 4);
  }

  popStyle();
}

/**
 * Handle mouse wheel scrolling for plant list
 */
void handlePlantScroll(float amount) {
  plantScrollOffset += amount;
  plantScrollOffset = constrain(plantScrollOffset, 0, maxPlantScroll);
}

/**
 * Handle scrollbar dragging
 */
boolean handlePlantScrollbarClick(float mouseX, float mouseY, float scrollbarX, float scrollbarY, float scrollbarW, float scrollbarH) {
  if (maxPlantScroll <= 0) return false;

  float scrollableHeight = scrollbarH - 20;
  float thumbY = scrollbarY + 10 + (plantScrollOffset / maxPlantScroll) * (scrollableHeight - plantScrollbarHeight);

  // Check if clicking on scrollbar thumb
  if (mouseX >= scrollbarX && mouseX <= scrollbarX + scrollbarW &&
      mouseY >= thumbY && mouseY <= thumbY + plantScrollbarHeight) {
    return true;
  }

  // Check if clicking on track (jump to position)
  if (mouseX >= scrollbarX && mouseX <= scrollbarX + scrollbarW &&
      mouseY >= scrollbarY && mouseY <= scrollbarY + scrollbarH) {
    float clickRatio = (mouseY - scrollbarY - 10) / scrollableHeight;
    plantScrollOffset = clickRatio * maxPlantScroll;
    plantScrollOffset = constrain(plantScrollOffset, 0, maxPlantScroll);
    return true;
  }

  return false;
}

/**
 * Update scrollbar position while dragging
 */
void updatePlantScrollbarDrag(float mouseY, float scrollbarY, float scrollbarH) {
  if (maxPlantScroll <= 0) return;

  float scrollableHeight = scrollbarH - 20;
  float mouseRatio = (mouseY - scrollbarY - 10 - plantScrollbarHeight/2) / (scrollableHeight - plantScrollbarHeight);
  plantScrollOffset = mouseRatio * maxPlantScroll;
  plantScrollOffset = constrain(plantScrollOffset, 0, maxPlantScroll);
}

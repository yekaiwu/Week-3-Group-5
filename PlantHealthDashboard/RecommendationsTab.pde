/**
 * RecommendationsTab.pde
 * Handles the plant recommendations tab
 * Shows recommended plants for each zone based on sensor conditions
 */

// Recommendation data structures
class PlantRecommendation {
  String plantName;
  float score;
  String sunlightNeeds;
  int wateringDays;

  PlantRecommendation(String plantName, float score, String sunlightNeeds, int wateringDays) {
    this.plantName = plantName;
    this.score = score;
    this.sunlightNeeds = sunlightNeeds;
    this.wateringDays = wateringDays;
  }
}

class HourlyRecommendations {
  int hour;
  float temp;
  float humidity;
  float lux;
  ArrayList<PlantRecommendation> recommendations;

  HourlyRecommendations(int hour, float temp, float humidity, float lux) {
    this.hour = hour;
    this.temp = temp;
    this.humidity = humidity;
    this.lux = lux;
    this.recommendations = new ArrayList<PlantRecommendation>();
  }
}

class ZoneRecommendations {
  String name;
  float x, y, width, height;  // For display positioning
  ArrayList<HourlyRecommendations> timeline;
  boolean isHovered = false;

  ZoneRecommendations(String name) {
    this.name = name;
    this.timeline = new ArrayList<HourlyRecommendations>();
  }

  HourlyRecommendations getRecommendationsAtHour(int hour) {
    for (HourlyRecommendations hr : timeline) {
      if (hr.hour == hour) {
        return hr;
      }
    }
    return timeline.size() > 0 ? timeline.get(0) : null;
  }
}

// Global variables for recommendations tab
ArrayList<ZoneRecommendations> zoneRecommendations;
int selectedRecommendationHour = 12;  // Default to noon
ZoneRecommendations selectedZone = null;

/**
 * Load recommendation data from JSON file
 */
void loadRecommendationData() {
  try {
    String jsonPath = sketchPath("sensor_data/zones_export_20260205_135503.json");
    println("Loading recommendation data from: " + jsonPath);

    JSONObject json = loadJSONObject(jsonPath);
    JSONArray zones = json.getJSONArray("zones");

    zoneRecommendations = new ArrayList<ZoneRecommendations>();

    for (int i = 0; i < zones.size(); i++) {
      JSONObject zone = zones.getJSONObject(i);
      String zoneName = zone.getString("name");

      ZoneRecommendations zoneRec = new ZoneRecommendations(zoneName);

      // Parse timeline
      JSONArray timeline = zone.getJSONArray("timeline");
      for (int j = 0; j < timeline.size(); j++) {
        JSONObject timeEntry = timeline.getJSONObject(j);
        int hour = timeEntry.getInt("hour");
        float temp = timeEntry.getFloat("temp");
        float humidity = timeEntry.getFloat("humidity");
        float lux = timeEntry.getFloat("lux");

        HourlyRecommendations hourlyRec = new HourlyRecommendations(hour, temp, humidity, lux);

        // Parse recommendations
        JSONArray recommendations = timeEntry.getJSONArray("recommendations");
        for (int k = 0; k < min(5, recommendations.size()); k++) {  // Only top 5
          JSONObject rec = recommendations.getJSONObject(k);
          String plantName = rec.getString("plant");
          float score = rec.getFloat("score");
          String sunlightNeeds = rec.getString("sunlight_needs");
          int wateringDays = rec.getInt("watering_days");

          PlantRecommendation plantRec = new PlantRecommendation(plantName, score, sunlightNeeds, wateringDays);
          hourlyRec.recommendations.add(plantRec);
        }

        zoneRec.timeline.add(hourlyRec);
      }

      zoneRecommendations.add(zoneRec);
    }

    // Set positions for zones (similar to house regions)
    // JSON zones: 0=Living Room, 1=Bed Room, 2=Bath Room, 3=Kitchen Room
    // Map visual: 0=Living Room, 1=Kitchen (uses Bed Room data), 2=Bathroom (uses Bath Room data), 3=Balcony (uses Kitchen Room data)
    if (zoneRecommendations.size() >= 4) {
      // Zone 0: Living Room (left side)
      zoneRecommendations.get(0).x = houseImageX + 20;
      zoneRecommendations.get(0).y = houseImageY + 20;
      zoneRecommendations.get(0).width = 300;
      zoneRecommendations.get(0).height = 460;

      // Zone 1: Bed Room data → Display as "Kitchen" (top center-right)
      zoneRecommendations.get(1).x = houseImageX + 320;
      zoneRecommendations.get(1).y = houseImageY + 20;
      zoneRecommendations.get(1).width = 170;
      zoneRecommendations.get(1).height = 240;
      zoneRecommendations.get(1).name = "Kitchen";  // Override display name

      // Zone 2: Bath Room data → Display as "Bathroom" (lower center-right)
      zoneRecommendations.get(2).x = houseImageX + 320;
      zoneRecommendations.get(2).y = houseImageY + 260;
      zoneRecommendations.get(2).width = 170;
      zoneRecommendations.get(2).height = 220;
      zoneRecommendations.get(2).name = "Bathroom";  // Override display name

      // Zone 3: Kitchen Room data → Display as "Balcony" (far right)
      zoneRecommendations.get(3).x = houseImageX + 490;
      zoneRecommendations.get(3).y = houseImageY + 20;
      zoneRecommendations.get(3).width = 180;
      zoneRecommendations.get(3).height = 460;
      zoneRecommendations.get(3).name = "Balcony";  // Override display name
    }

    println("Loaded recommendations for " + zoneRecommendations.size() + " zones");
  } catch (Exception e) {
    println("Error loading recommendation data: " + e.getMessage());
    e.printStackTrace();
    zoneRecommendations = new ArrayList<ZoneRecommendations>();
  }
}

/**
 * Draw the recommendations tab
 */
void drawRecommendationsView() {
  pushStyle();

  // Draw house layout background
  if (houseLayoutImage != null) {
    image(houseLayoutImage, houseImageX, houseImageY, houseImageWidth, houseImageHeight);
  } else {
    fill(40, 45, 55);
    stroke(80);
    strokeWeight(1);
    rect(houseImageX, houseImageY, houseImageWidth, houseImageHeight, 10);
  }

  // Zones are clickable but invisible (no visual indicators drawn)
  // The hover detection still works in the background for click handling

  // Draw instruction text
  fill(180);
  textAlign(LEFT, TOP);
  textSize(16);  // Increased instruction text size
  text("Click on a room to view recommended plants based on environmental conditions", houseImageX, houseImageY + houseImageHeight + 20);

  // If a zone is selected, show recommendations
  if (selectedZone != null) {
    drawZoneRecommendations();
  }

  popStyle();
}

/**
 * Draw detailed recommendations for selected zone
 */
void drawZoneRecommendations() {
  pushStyle();

  float detailX = houseImageX + houseImageWidth + 30;
  float detailY = houseImageY;
  float detailWidth = width - detailX - 30;
  float detailHeight = height - detailY - 30;

  // Background panel
  fill(30, 35, 45, 240);
  stroke(80);
  strokeWeight(1);
  rect(detailX, detailY, detailWidth, detailHeight, 10);

  // Title
  fill(100, 200, 255);
  textAlign(LEFT, TOP);
  textSize(20);
  text("Plant Recommendations", detailX + 20, detailY + 15);

  // Zone name (use the mapped display name)
  fill(150, 200, 150);
  textSize(14);
  String zoneName = selectedZone.name;
  // Clean up the display name
  zoneName = zoneName.replace("Zone 1: ", "").replace("Zone 2: ", "")
                     .replace("Zone 3: ", "").replace("Zone 4: ", "")
                     .replace("Bed Room", "").replace("Bath Room", "")
                     .replace("Kitchen Room", "");
  if (zoneName.trim().isEmpty()) {
    zoneName = selectedZone.name.replace("Zone 1: ", "").replace("Zone 2: ", "")
                                  .replace("Zone 3: ", "").replace("Zone 4: ", "");
  }
  text("Location: " + zoneName.trim(), detailX + 20, detailY + 45);

  // Hour slider
  float sliderY = detailY + 75;
  fill(180);
  textSize(12);
  text("Time of Day: " + selectedRecommendationHour + ":00", detailX + 20, sliderY);

  drawRecommendationTimeSlider(detailX + 20, sliderY + 20, detailWidth - 40);

  // Get recommendations for selected hour
  HourlyRecommendations hourlyData = selectedZone.getRecommendationsAtHour(selectedRecommendationHour);

  if (hourlyData != null) {
    // Display environmental conditions
    float conditionsY = sliderY + 60;
    fill(200);
    textSize(16);  // Increased title size
    text("Environmental Conditions at " + selectedRecommendationHour + ":00", detailX + 20, conditionsY);

    fill(150);
    textSize(14);  // Increased conditions text size
    text("Temperature: " + nf(hourlyData.temp, 0, 1) + "°C  |  " +
         "Humidity: " + nf(hourlyData.humidity, 0, 1) + "%  |  " +
         "Light: " + nf(hourlyData.lux, 0, 0) + " lux",
         detailX + 20, conditionsY + 20);

    // Display top 5 recommended plants
    float cardsStartY = conditionsY + 50;
    float cardHeight = 95;
    float cardSpacing = 8;

    fill(200);
    textSize(14);
    text("Top 5 Recommended Plants:", detailX + 20, cardsStartY);

    cardsStartY += 25;

    for (int i = 0; i < min(5, hourlyData.recommendations.size()); i++) {
      PlantRecommendation rec = hourlyData.recommendations.get(i);
      float cardY = cardsStartY + i * (cardHeight + cardSpacing);
      drawPlantRecommendationCard(detailX + 20, cardY, detailWidth - 40, cardHeight, rec, i + 1);
    }
  } else {
    fill(200, 100, 100);
    textSize(12);
    text("No recommendation data available for this hour", detailX + 20, sliderY + 60);
  }

  popStyle();
}

/**
 * Draw a plant recommendation card
 */
void drawPlantRecommendationCard(float x, float y, float w, float h, PlantRecommendation rec, int rank) {
  pushStyle();

  // Card background
  fill(40, 45, 55, 200);
  stroke(100, 150, 200);
  strokeWeight(1);
  rect(x, y, w, h, 8);

  // Rank badge
  fill(60, 120, 180);
  noStroke();
  circle(x + 20, y + 20, 28);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(14);
  text(str(rank), x + 20, y + 20);

  // Plant name
  fill(150, 255, 150);
  textAlign(LEFT, TOP);
  textSize(15);
  text(rec.plantName, x + 40, y + 10);

  // Score bar
  float scoreBarX = x + 40;
  float scoreBarY = y + 32;
  float scoreBarWidth = w - 60;
  float scoreBarHeight = 8;

  // Background bar
  fill(50, 55, 65);
  noStroke();
  rect(scoreBarX, scoreBarY, scoreBarWidth, scoreBarHeight, 4);

  // Score fill
  float scoreColor = map(rec.score, 0, 100, 0, 120);
  fill(120 - scoreColor, 120 + scoreColor, 50);
  rect(scoreBarX, scoreBarY, scoreBarWidth * (rec.score / 100), scoreBarHeight, 4);

  // Score text
  fill(200);
  textSize(11);
  text("Compatibility: " + nf(rec.score, 0, 1) + "%", scoreBarX, scoreBarY + 12);

  // Sunlight needs
  fill(255, 220, 100);
  textSize(11);
  text("☀ Light: " + rec.sunlightNeeds, x + 10, y + h - 35);

  // Watering needs
  fill(100, 180, 255);
  text("💧 Water every " + rec.wateringDays + " day" + (rec.wateringDays > 1 ? "s" : ""), x + 10, y + h - 18);

  popStyle();
}

/**
 * Draw time slider for recommendations (0-23 hours)
 */
void drawRecommendationTimeSlider(float x, float y, float w) {
  pushStyle();

  float h = sliderHeight;

  // Slider background
  fill(40, 45, 55);
  stroke(80);
  strokeWeight(1);
  rect(x, y, w, h, 5);

  // Draw hour markers
  textAlign(CENTER, TOP);
  textSize(11);  // Increased time slider label size
  for (int hour = 0; hour <= 23; hour += 3) {
    float markerX = x + map(hour, 0, 23, 0, w);
    stroke(100);
    line(markerX, y, markerX, y + h);
    fill(150);
    text(hour + ":00", markerX, y + h + 3);
  }

  // Selected hour indicator
  float handleX = x + map(selectedRecommendationHour, 0, 23, 0, w);
  fill(100, 200, 255);
  noStroke();
  circle(handleX, y + h/2, 16);

  // Hover effect
  if (dist(mouseX, mouseY, handleX, y + h/2) < 10) {
    stroke(150, 220, 255);
    strokeWeight(2);
    noFill();
    circle(handleX, y + h/2, 20);
  }

  popStyle();
}

/**
 * Check if mouse is hovering over recommendation zones
 */
void checkRecommendationZoneHover(float mx, float my) {
  if (zoneRecommendations == null) return;

  for (ZoneRecommendations zone : zoneRecommendations) {
    zone.isHovered = (mx >= zone.x && mx <= zone.x + zone.width &&
                      my >= zone.y && my <= zone.y + zone.height);
  }
}

/**
 * Handle clicks on recommendation zones
 */
void handleRecommendationZoneClick(float mx, float my) {
  if (zoneRecommendations == null) return;

  for (ZoneRecommendations zone : zoneRecommendations) {
    if (mx >= zone.x && mx <= zone.x + zone.width &&
        my >= zone.y && my <= zone.y + zone.height) {
      selectedZone = zone;
      return;
    }
  }
}

/**
 * Handle slider drag for recommendations
 */
boolean handleRecommendationSliderDrag(float mx, float my) {
  if (selectedZone == null) return false;

  float detailX = houseImageX + houseImageWidth + 30;
  float detailY = houseImageY;
  float detailWidth = width - detailX - 30;
  float sliderY = detailY + 75 + 20;
  float sliderX = detailX + 20;
  float sliderW = detailWidth - 40;

  if (mx >= sliderX && mx <= sliderX + sliderW &&
      my >= sliderY && my <= sliderY + sliderHeight) {
    float relativeX = constrain(mx - sliderX, 0, sliderW);
    selectedRecommendationHour = round(map(relativeX, 0, sliderW, 0, 23));
    return true;
  }

  return false;
}

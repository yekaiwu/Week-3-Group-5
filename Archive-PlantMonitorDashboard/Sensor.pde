/**
 * Sensor class - Represents a single sensor (humidity, temperature, or light)
 * Uses Perlin noise to simulate realistic sensor readings
 */
class Sensor {
  String name;           // Sensor name (e.g., "Humidity", "Temperature", "Light")
  float value;           // Current sensor value
  float minValue;        // Minimum possible value
  float maxValue;        // Maximum possible value
  float noiseOffset;     // Offset for Perlin noise
  float noiseIncrement;  // How fast the noise changes

  // Threshold ranges for color coding
  float healthyMin;      // Minimum healthy value
  float healthyMax;      // Maximum healthy value
  float warningMin;      // Minimum warning value
  float warningMax;      // Maximum warning value

  color barColor;        // Current color of the bar

  /**
   * Constructor for Sensor
   */
  Sensor(String name, float minValue, float maxValue, float healthyMin, float healthyMax, float warningMin, float warningMax, float noiseOffset) {
    this.name = name;
    this.minValue = minValue;
    this.maxValue = maxValue;
    this.healthyMin = healthyMin;
    this.healthyMax = healthyMax;
    this.warningMin = warningMin;
    this.warningMax = warningMax;
    this.noiseOffset = noiseOffset;
    this.noiseIncrement = 0.01; // Slow smooth changes
    this.value = (minValue + maxValue) / 2; // Start at middle value
    this.barColor = color(150); // Default grey
  }

  /**
   * Update sensor value using Perlin noise for realistic simulation
   */
  void update() {
    // Use Perlin noise to generate smooth, natural-looking changes
    float noiseValue = noise(noiseOffset);
    value = map(noiseValue, 0, 1, minValue, maxValue);
    noiseOffset += noiseIncrement;

    // Update color based on value
    updateColor(true);
  }

  /**
   * Update the color based on current value and whether quadrant is hovered
   * Each sensor type has a unique color gradient based on its value
   */
  void updateColor(boolean isHovered) {
    if (!isHovered) {
      barColor = color(100, 100, 100); // Dull grey when not hovered
      return;
    }

    // Map value from min-max to 0-1 for gradient calculation
    float normalizedValue = map(value, minValue, maxValue, 0, 1);

    // Different color gradients for each sensor type
    if (name.equals("Humidity")) {
      // Blue gradient: Light blue (low) -> Deep blue (high)
      // RGB: (100, 200, 255) -> (0, 80, 200)
      float r = map(normalizedValue, 0, 1, 100, 0);
      float g = map(normalizedValue, 0, 1, 200, 80);
      float b = map(normalizedValue, 0, 1, 255, 200);
      barColor = color(r, g, b);
    }
    else if (name.equals("Temperature")) {
      // Orange to Red gradient: Deep orange (low) -> Hot red (high)
      // RGB: (255, 100, 0) -> (255, 30, 30)
      // Avoids yellow tones that overlap with Light sensor
      float r = 255;
      float g = map(normalizedValue, 0, 1, 100, 30);
      float b = map(normalizedValue, 0, 1, 0, 30);
      barColor = color(r, g, b);
    }
    else if (name.equals("Light")) {
      // Yellow/Amber gradient: Dim yellow (low) -> Bright yellow (high)
      // RGB: (180, 150, 0) -> (255, 255, 100)
      float r = map(normalizedValue, 0, 1, 180, 255);
      float g = map(normalizedValue, 0, 1, 150, 255);
      float b = map(normalizedValue, 0, 1, 0, 100);
      barColor = color(r, g, b);
    }
    else {
      // Default gradient (shouldn't happen)
      barColor = color(150, 150, 150);
    }
  }

  /**
   * Get the height of the bar based on sensor value (for 3D visualization)
   */
  float getBarHeight() {
    // Map sensor value to a height between 20 and 200
    return map(value, minValue, maxValue, 20, 200);
  }

  /**
   * Get formatted value string for display
   */
  String getValueString() {
    if (name.equals("Humidity")) {
      return nf(value, 0, 1) + "%";
    } else if (name.equals("Temperature")) {
      return nf(value, 0, 1) + "°C";
    } else if (name.equals("Light")) {
      return nf(value, 0, 0) + " lux";
    }
    return nf(value, 0, 1);
  }

  /**
   * Get status string (Healthy, Warning, Critical)
   */
  String getStatus() {
    if (value >= healthyMin && value <= healthyMax) {
      return "Healthy";
    } else if ((value >= warningMin && value < healthyMin) || (value > healthyMax && value <= warningMax)) {
      return "Warning";
    } else {
      return "Critical";
    }
  }

  /**
   * Get status-based color (Green for Healthy, Yellow for Warning, Red for Critical)
   */
  color getStatusColor() {
    if (value >= healthyMin && value <= healthyMax) {
      return color(50, 200, 50); // Green - Healthy
    } else if ((value >= warningMin && value < healthyMin) || (value > healthyMax && value <= warningMax)) {
      return color(255, 200, 0); // Yellow - Warning
    } else {
      return color(255, 50, 50); // Red - Critical
    }
  }
}

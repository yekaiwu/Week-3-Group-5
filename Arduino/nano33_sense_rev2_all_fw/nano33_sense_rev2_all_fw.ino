#include <Arduino_HS300x.h>
#include <Arduino_LPS22HB.h>
#include <Arduino_APDS9960.h>
#include <Arduino_BMI270_BMM150.h>
#include <Arduino_JSON.h>

const int LED_PIN = LED_BUILTIN;

// Do not use names LEDR/LEDG/LEDB (these are macros)!
const int RGB_R = LEDR;  // (22u) 
const int RGB_G = LEDG;  // (23u)
const int RGB_B = LEDB;  // (24u)

String cmd;

static inline void setRgb(uint8_t r, uint8_t g, uint8_t b) {
  // active-low PWM: analogWrite(pin, 255-r)
  analogWrite(RGB_R, 255 - r);
  analogWrite(RGB_G, 255 - g);
  analogWrite(RGB_B, 255 - b);
}

static inline void rgbOff() { setRgb(0, 0, 0); }

void handleCommand(const String& s) {
  if (s == "LED=ON") {
    digitalWrite(LED_PIN, HIGH);
    Serial.println("ACK=LED_ON");
    return;
  }
  if (s == "LED=OFF") {
    digitalWrite(LED_PIN, LOW);
    Serial.println("ACK=LED_OFF");
    return;
  }

  if (s.startsWith("RGB=")) {
    int r = -1, g = -1, b = -1;
    if (sscanf(s.c_str(), "RGB=%d,%d,%d", &r, &g, &b) == 3) {
      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);
      setRgb((uint8_t)r, (uint8_t)g, (uint8_t)b);
      Serial.print("ACK=RGB,");
      Serial.print(r); Serial.print(",");
      Serial.print(g); Serial.print(",");
      Serial.println(b);
      return;
    }
    Serial.print("ERR=BAD_RGB,VAL=");
    Serial.println(s);
    return;
  }

  Serial.print("ERR=UNKNOWN_CMD,VAL=");
  Serial.println(s);
}

void setup() {
  Serial.begin(115200);
  while (!Serial) {}

  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  pinMode(RGB_R, OUTPUT);
  pinMode(RGB_G, OUTPUT);
  pinMode(RGB_B, OUTPUT);
  rgbOff();

  bool ok = true;
  if (!HS300x.begin()) { Serial.println("ERR=HS300x_INIT"); ok = false; }
  if (!BARO.begin())   { Serial.println("ERR=LPS22HB_INIT"); ok = false; }
  if (!APDS.begin())   { Serial.println("ERR=APDS9960_INIT"); ok = false; }
  if (!IMU.begin())    { Serial.println("ERR=IMU_INIT"); ok = false; }

  if (!ok) {
    Serial.println("ERR=INIT_FAILED");
    while (1) {}
  }

  Serial.println("READY");
  Serial.println("Commands: LED=ON|OFF, RGB=R,G,B (0-255)");
}

void loop() {
  // read commands
  while (Serial.available()) {
    char c = (char)Serial.read();
    if (c == '\n' || c == '\r') {
      if (cmd.length() > 0) {
        cmd.trim();
        handleCommand(cmd);
        cmd = "";
      }
    } else {
      cmd += c;
      if (cmd.length() > 96) { cmd = ""; Serial.println("ERR=CMD_TOO_LONG"); }
    }
  }

  // publish JSON @ 1Hz
  static unsigned long last = 0;
  unsigned long now = millis();
  if (now - last < 1000) return;
  last = now;

  JSONVar root;

  root["hs3003_t_c"]  = (double)HS300x.readTemperature();
  root["hs3003_h_rh"] = (double)HS300x.readHumidity();

  root["lps22hb_p_kpa"] = (double)BARO.readPressure();
  root["lps22hb_t_c"]   = (double)BARO.readTemperature();

  if (APDS.proximityAvailable()) {
    root["apds_prox"] = APDS.readProximity();
  }
  if (APDS.colorAvailable()) {
    int r, g, b, c;
    APDS.readColor(r, g, b, c);
    JSONVar col;
    col["r"] = r; col["g"] = g; col["b"] = b; col["c"] = c;
    root["apds_color"] = col;
  }
  if (APDS.gestureAvailable()) {
    root["apds_gesture"] = APDS.readGesture();
  }

  if (IMU.accelerationAvailable()) {
    float x, y, z;
    IMU.readAcceleration(x, y, z);
    JSONVar a; a["x"]=x; a["y"]=y; a["z"]=z;
    root["acc_g"] = a;
  }
  if (IMU.gyroscopeAvailable()) {
    float x, y, z;
    IMU.readGyroscope(x, y, z);
    JSONVar g; g["x"]=x; g["y"]=y; g["z"]=z;
    root["gyro_dps"] = g;
  }
  if (IMU.magneticFieldAvailable()) {
    float x, y, z;
    IMU.readMagneticField(x, y, z);
    JSONVar m; m["x"]=x; m["y"]=y; m["z"]=z;
    root["mag_uT"] = m;
  }

  Serial.println(JSON.stringify(root));
}

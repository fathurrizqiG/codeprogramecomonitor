#include <WiFi.h>
#include <WiFiManager.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <HTTPClient.h>
#include <WiFiClientSecure.h>
#include <time.h>

// === KREDENSIAL FIREBASE ===
#define API_KEY "AIzaSyDiYpuUPQUvK-1fOztrblPKKn3cMTDrlXU"
#define DATABASE_URL "https://ecomoni-dc5fd-default-rtdb.firebaseio.com/"
#define LEGACY_TOKEN "Sd9aMsdVYzEV7QkvaJh79j4kd3vaCClvBAC78yjn"

// === PIN SENSOR DAN KOMPONEN ===
#define DHTPIN 4
#define DHTTYPE DHT22
#define RAIN_SENSOR_PIN 5
#define LDR_PIN 34
#define LED_STATUS 26
#define BUTTON_PIN 27

// === OBJEK & VARIABEL GLOBAL ===
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
DHT dht(DHTPIN, DHTTYPE);
LiquidCrystal_I2C lcd(0x27, 16, 2);

unsigned long lastUpdate = 0;
unsigned long interval = 5000;
unsigned long lastHistorySend = 0;
unsigned long intervalHistory = 300000;
int displayPage = 0;
bool isOfflineMode = false;

void setupNTP() {
  configTime(7 * 3600, 0, "pool.ntp.org", "time.nist.gov");
  struct tm timeinfo;
  Serial.print("Sinkronisasi waktu NTP...");
  while (!getLocalTime(&timeinfo)) {
    Serial.print(".");
    delay(500);
  }
  Serial.println(" [BERHASIL]");
  Serial.print("Waktu sekarang: ");
  Serial.println(&timeinfo, "%Y-%m-%d %H:%M:%S");
}

void updateIntervalHistoryFromFirebase() {
  if (Firebase.RTDB.getInt(&fbdo, "/threshold/interval_history")) {
    if (fbdo.dataType() == "int") {
      int interval_minutes = fbdo.intData();
      intervalHistory = interval_minutes * 60000UL;
      Serial.print("Interval diperbarui: ");
      Serial.println(intervalHistory);
    }
  } else {
    Serial.print("Gagal mengambil interval_history: ");
    Serial.println(fbdo.errorReason());
  }
}

void setup() {
  Serial.begin(115200);
  dht.begin();
  Wire.begin(22, 21);
  lcd.init();
  lcd.backlight();

  pinMode(RAIN_SENSOR_PIN, INPUT);
  pinMode(LED_STATUS, OUTPUT);
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  digitalWrite(LED_STATUS, LOW);

  lcd.setCursor(0, 0);
  lcd.print("Menghubungkan...");

  WiFiManager wm;
  wm.setTimeout(60); // 1 menit

  if (!wm.autoConnect("EcoMonitor-Setup")) {
    Serial.println("Gagal konek WiFi. Mode offline.");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Mode Offline");
    isOfflineMode = true;
    delay(2000);
  } else {
    Serial.println("WiFi Terhubung!");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("WiFi Terhubung");
    digitalWrite(LED_STATUS, HIGH);
    delay(2000);

    setupNTP();

    config.api_key = API_KEY;
    config.database_url = DATABASE_URL;
    config.signer.tokens.legacy_token = LEGACY_TOKEN;
    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);
    updateIntervalHistoryFromFirebase();

    lcd.clear();
  }
}

void loop() {
  // === Tombol untuk masuk mode konfigurasi WiFi (bisa online/offline) ===
  if (digitalRead(BUTTON_PIN) == LOW) {
    Serial.println("Tombol ditekan. Masuk konfigurasi WiFi...");
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Config WiFi...");
    delay(1000);

    WiFiManager wm;
    wm.resetSettings();           // Reset kredensial WiFi
    wm.setTimeout(120);           // Timeout 2 menit
    wm.startConfigPortal("EcoMonitor-Setup");
    ESP.restart();                // Restart setelah config
  }

  // === Mode Offline ===
  if (isOfflineMode) {
    float suhu = dht.readTemperature();
    float kelembaban = dht.readHumidity();
    int hujan_status = digitalRead(RAIN_SENSOR_PIN);
    int ldr_raw = analogRead(LDR_PIN);
    int lux = map(ldr_raw, 0, 4095, 1000, 1);
    lux = constrain(lux, 1, 1000);
    String kondisi_hujan = (hujan_status == 1) ? "Cerah" : "Hujan";

    lcd.clear();
    switch (displayPage) {
      case 0:
        lcd.setCursor(0, 0);
        lcd.print("    Ecomonitor");
        break;
      case 1:
        lcd.setCursor(0, 0);
        lcd.print("Suhu:");
        lcd.print(suhu, 0);
        lcd.print((char)223);
        lcd.print("C");
        lcd.setCursor(0, 1);
        lcd.print("Kelembaban:");
        lcd.print(kelembaban, 0);
        lcd.print("%");
        break;
      case 2:
        lcd.setCursor(0, 0);
        lcd.print("Cahaya:");
        lcd.print(lux);
        lcd.print(" Lux");
        lcd.setCursor(0, 1);
        lcd.print("Cuaca:");
        lcd.print(kondisi_hujan);
        break;
    }
    displayPage = (displayPage + 1) % 3;
    delay(3000);
    return;
  }

  // === Mode Online ===
  if (millis() - lastUpdate >= interval && Firebase.ready()) {
    lastUpdate = millis();

    float suhu = dht.readTemperature();
    float kelembabanMentah = dht.readHumidity();
    float kelembaban = kelembabanMentah * 0.51;
    kelembaban = constrain(kelembaban, 0, 100);
    int hujan_status = digitalRead(RAIN_SENSOR_PIN);
    int ldr_raw = analogRead(LDR_PIN);
    int lux = map(ldr_raw, 0, 4095, 1000, 1);
    lux = constrain(lux, 1, 1000);
    String kondisi_hujan = (hujan_status == 1) ? "Cerah" : "Hujan";

    Serial.printf("Suhu: %.2f °C\n", suhu);
    Serial.printf("Kelembaban: %.2f %%\n", kelembaban);
    Serial.printf("Cuaca: %s\n", kondisi_hujan.c_str());
    Serial.printf("Cahaya: %d lux\n", lux);

    lcd.clear();
    switch (displayPage) {
      case 0:
        lcd.setCursor(0, 0);
        lcd.print("    Ecomonitor");
        break;
      case 1:
        lcd.setCursor(0, 0);
        lcd.print("Suhu:");
        lcd.print(suhu, 0);
        lcd.print((char)223);
        lcd.print("C");
        lcd.setCursor(0, 1);
        lcd.print("Kelembaban:");
        lcd.print(kelembaban, 0);
        lcd.print("%");
        break;
      case 2:
        lcd.setCursor(0, 0);
        lcd.print("Cahaya:");
        lcd.print(lux);
        lcd.print(" Lux");
        lcd.setCursor(0, 1);
        lcd.print("Cuaca:");
        lcd.print(kondisi_hujan);
        break;
    }
    displayPage = (displayPage + 1) % 3;
    delay(3000);

    Firebase.RTDB.setFloat(&fbdo, "/sensor/suhu", suhu);
    Firebase.RTDB.setFloat(&fbdo, "/sensor/kelembaban", kelembaban);
    Firebase.RTDB.setString(&fbdo, "/sensor/sensor_hujan", kondisi_hujan);
    Firebase.RTDB.setInt(&fbdo, "/sensor/intensitas_cahaya", lux);

    if (millis() - lastHistorySend >= intervalHistory) {
      lastHistorySend = millis();
      updateIntervalHistoryFromFirebase();

      time_t now;
      struct tm timeinfo;
      if (!getLocalTime(&timeinfo)) {
        Serial.println("Gagal mendapatkan waktu!");
        return;
      }

      char isoTime[30];
      strftime(isoTime, sizeof(isoTime), "%Y-%m-%dT%H:%M:%S+07:00", &timeinfo);

      String jsonPayload = "{";
      jsonPayload += "\"intensitas_cahaya\":" + String(lux) + ",";
      jsonPayload += "\"kelembaban\":" + String(kelembaban) + ",";
      jsonPayload += "\"sensor_hujan\":" + String((hujan_status == 0) ? "true" : "false") + ",";
      jsonPayload += "\"suhu\":" + String(suhu) + ",";
      jsonPayload += "\"timestamp\":\"" + String(isoTime) + "\"}";

      WiFiClientSecure client;
      client.setInsecure();

      HTTPClient http;
      http.begin(client, "https://ecomonitor-api.vercel.app/api/kirimdata");
      http.addHeader("Content-Type", "application/json");
      int httpResponseCode = http.POST(jsonPayload);

      if (httpResponseCode > 0) {
        Serial.printf("Data history terkirim (%d): %s\n", httpResponseCode, http.getString().c_str());
      } else {
        Serial.printf("Gagal kirim data history: %s\n", http.errorToString(httpResponseCode).c_str());
      }
      http.end();
    }
  }
}
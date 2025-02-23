#include "ESP_I2S.h"
#include "FS.h"
#include "SD.h"
#include <WiFi.h>
#include <HTTPClient.h>

// WiFi credentials
const char* ssid = "Pixel_6581";
const char* password = "ronny123";

// Server details (if sending to a server)
const char* serverUrl = "http://10.88.141.142:8080/upload";

void setup() {
  // Create an instance of the I2SClass
  I2SClass i2s;

  // Create variables to store the audio data
  uint8_t *wav_buffer;
  size_t wav_size;

  // Initialize the serial port
  Serial.begin(115200);
  while (!Serial) {
    delay(10);
  }

  // Connect to WiFi
  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");

  Serial.println("Initializing I2S bus...");
  
  // Set up the pins used for audio input
  i2s.setPinsPdmRx(42, 41);

  // start I2S at 16 kHz with 16-bits per sample
  if (!i2s.begin(I2S_MODE_PDM_RX, 16000, I2S_DATA_BIT_WIDTH_16BIT, I2S_SLOT_MODE_MONO)) {
    Serial.println("Failed to initialize I2S!");
    while (1);
  }

  Serial.println("I2S bus initialized.");
  Serial.println("Initializing SD card...");

  // Set up the pins used for SD card access
  if(!SD.begin(21)){
    Serial.println("Failed to mount SD Card!");
    while (1);
  }
  Serial.println("SD card initialized.");
  Serial.println("Recording 20 seconds of audio data...");

  // Record 20 seconds of audio data
  wav_buffer = i2s.recordWAV(20, &wav_size);

  // Create a file on the SD card
  File file = SD.open("/arduino_rec.wav", FILE_WRITE);
  if (!file) {
    Serial.println("Failed to open file for writing!");
    return;
  }

  Serial.println("Writing audio data to file...");

  // Write the audio data to the file
  if (file.write(wav_buffer, wav_size) != wav_size) {
    Serial.println("Failed to write audio data to file!");
    return;
  }

  // Close the file
  file.close();

  // Send the file over WiFi
  sendFileOverWiFi("/arduino_rec.wav");

  Serial.println("Application complete.");
}

void sendFileOverWiFi(const char* filename) {
  Serial.println("Starting file transfer...");
  
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi not connected!");
    return;
  }

  File file = SD.open(filename, FILE_READ);
  if (!file) {
    Serial.println("Failed to open file for reading!");
    return;
  }

  HTTPClient http;
  Serial.println("Connecting to server...");
  http.begin(serverUrl);
  http.addHeader("Content-Type", "audio/wav");
  
  // Get file size
  size_t fileSize = file.size();
  Serial.printf("File size: %d bytes\n", fileSize);
  
  // Create buffer for reading chunks
  const size_t bufferSize = 1024;
  uint8_t *buffer = (uint8_t *)malloc(bufferSize);
  
  // Start multipart upload
  http.addHeader("Content-Length", String(fileSize));
  Serial.println("Sending file...");
  
  int httpResponseCode = http.sendRequest("POST", &file, fileSize);

  if (httpResponseCode > 0) {
    Serial.printf("HTTP Response code: %d\n", httpResponseCode);
    String response = http.getString();
    Serial.println("Server response: " + response);
    
    // Check specific response codes
    switch(httpResponseCode) {
      case 200:
        Serial.println("Transfer successful!");
        // Optional: Blink LED or make sound to indicate success
        // Add in setup():
        pinMode(LED_BUILTIN, OUTPUT);

        // In sendFileOverWiFi(), for success:
        digitalWrite(LED_BUILTIN, HIGH);
        delay(1000);
        digitalWrite(LED_BUILTIN, LOW);

        break;
      case 404:
        Serial.println("Server endpoint not found!");
        break;
      case 500:
        Serial.println("Server error!");
        break;
      default:
        Serial.printf("Unexpected response code: %d\n", httpResponseCode);
    }
  } else {
    Serial.printf("Error occurred during transfer. Error: %d\n", httpResponseCode);
    Serial.println(http.errorToString(httpResponseCode));
  }

  // Clean up
  free(buffer);
  file.close();
  http.end();

  Serial.println("Transfer complete!");
}
void loop() {
  delay(1000);
  Serial.print(".");
}

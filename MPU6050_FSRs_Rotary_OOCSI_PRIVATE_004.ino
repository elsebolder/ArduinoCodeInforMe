// Basic demo for accelerometer readings from Adafruit MPU6050
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>
#include <WiFi.h>
#include <AsyncMqttClient.h>

#include <Keypad.h>

// put the adress of your OOCSI server here, can be URL or IP address string
//const char* hostserver = "10.13.38.8";//Take the IPv4 address of your computer. This is the localhost in processing sketch. (this changes when you connect to different wifi network).
//  192.168.239.177    192.168.178.17   10.13.38.8  192.168.226.177
#define MQTT_HOST IPAddress(192, 168, 178, 17)//10, 13, 38, 8             192, 168, 178, 17
#define MQTT_PORT 1883

Adafruit_MPU6050 mpu;

//keypad
const byte ROWS = 4; //four rows
const byte COLS = 3; //three columns
char keys[ROWS][COLS] = {
  {'1', '2', '3'},
  {'4', '5', '6'},
  {'7', '8', '9'},
  {'*', '0', '#'}
};

byte rowPins[ROWS] = {33, 25, 26, 27}; //byte rowPins[ROWS] = {8, 7, 6, 5}; //connect to the row pinouts of the keypad
byte colPins[COLS] = {14, 19, 13}; // byte colPins[COLS] = {4, 3, 2}; //connect to the column pinouts of the keypad

Keypad keypad = Keypad( makeKeymap(keys), rowPins, colPins, ROWS, COLS );

int buttonPressed = 0;

//FSRs
const int fsrPin1 = 35; // Pin connected to FSR left
const int fsrPin2 = 32; // Pin connected to FSR right
const int fsrPinSq = 34; // Pin connected to FSR square

int fsrVal1 = 0;
int fsrVal2 = 0;
int fsrValSq = 0;
int potVal = 0;

/* Read Quadrature Encoder
   Connect Encoder to Pins encoder0PinA, encoder0PinB, and +5V.

   Sketch by max wolf / www.meso.net
   v. 0.1 - very basic functions - mw 20061220

*/

int val;
int encoder0PinA = 18;
int encoder0PinB = 23;
int counter = 0;
int encoder0PinALast = LOW;
int n = LOW;


//Accelerometer and gyroscope

int aXVal = 0;
int aYVal = 0;
int aZVal = 0;

int gXVal = 0;
int gYVal = 0;
int gZVal = 0;

// Delay
// Generally, you should use "unsigned long" for variables that hold time
// The value will quickly become too large for an int to store
unsigned long previousMillis = 0;        // will store last time it was updated

// constants won't change:
const long interval = 20;           // interval (milliseconds)

// use this if you want the OOCSI-ESP library to manage the connection to the Wifi
// SSID of your Wifi network, the library currently does not support WPA2 Enterprise networks
const char* ssid = "ZiggoF69587B_2.4";//HotspotElse   ZiggoF69587B_2.4  BMD-DEV  ZiggoF69587B_2.4  Bureau Moeilijke Dingen
// Password of your Wifi network.
const char* password = "HHpeu54eauax";//wbhi2617   HHpeu54eauax  utveckling  >[gpCxp^$]wRq/3>k7]Bn&xA.iBx9T

AsyncMqttClient mqttClient;
bool mqttConnected = false;

void setup() {
  Serial.begin(115200);
  Serial.println("Booting...");

  Serial.println("Connecting to Wi-Fi...");
  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("Connecting to MQTT...");
  mqttClient.onConnect(onMqttConnect);
  mqttClient.onDisconnect(onMqttDisconnect);
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);
  mqttClient.connect();

  //Rotary-----------------------
  pinMode (encoder0PinA, INPUT);
  pinMode (encoder0PinB, INPUT);

  pinMode(fsrPin1, INPUT);
  pinMode(fsrPin2, INPUT);

  Serial.println("Adafruit MPU6050 test!");

  // Try to initialize!
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
    while (1) {
      delay(10);
    }
  }
  Serial.println("MPU6050 Found!");

  mpu.setAccelerometerRange(MPU6050_RANGE_8_G);
  Serial.print("Accelerometer range set to: ");
  switch (mpu.getAccelerometerRange()) {
    case MPU6050_RANGE_2_G:
      Serial.println("+-2G");
      break;
    case MPU6050_RANGE_4_G:
      Serial.println("+-4G");
      break;
    case MPU6050_RANGE_8_G:
      Serial.println("+-8G");
      break;
    case MPU6050_RANGE_16_G:
      Serial.println("+-16G");
      break;
  }
  mpu.setGyroRange(MPU6050_RANGE_500_DEG);
  Serial.print("Gyro range set to: ");
  switch (mpu.getGyroRange()) {
    case MPU6050_RANGE_250_DEG:
      Serial.println("+- 250 deg/s");
      break;
    case MPU6050_RANGE_500_DEG:
      Serial.println("+- 500 deg/s");
      break;
    case MPU6050_RANGE_1000_DEG:
      Serial.println("+- 1000 deg/s");
      break;
    case MPU6050_RANGE_2000_DEG:
      Serial.println("+- 2000 deg/s");
      break;
  }

  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);
  Serial.print("Filter bandwidth set to: ");
  switch (mpu.getFilterBandwidth()) {
    case MPU6050_BAND_260_HZ:
      Serial.println("260 Hz");
      break;
    case MPU6050_BAND_184_HZ:
      Serial.println("184 Hz");
      break;
    case MPU6050_BAND_94_HZ:
      Serial.println("94 Hz");
      break;
    case MPU6050_BAND_44_HZ:
      Serial.println("44 Hz");
      break;
    case MPU6050_BAND_21_HZ:
      Serial.println("21 Hz");
      break;
    case MPU6050_BAND_10_HZ:
      Serial.println("10 Hz");
      break;
    case MPU6050_BAND_5_HZ:
      Serial.println("5 Hz");
      break;
  }

  Serial.println("");
  delay(100);
}

void onMqttConnect(bool sessionPresent)
{
  Serial.println("Connected to MQTT!");
  Serial.print("Session present: ");
  Serial.println(sessionPresent);
  mqttConnected = true;
}

void onMqttDisconnect(AsyncMqttClientDisconnectReason reason) {
  Serial.println("Disconnected from MQTT.");

  if (WiFi.isConnected()) {
    Serial.println("Connecting to MQTT...");
    mqttClient.connect();
  }
}

void loop() {
  unsigned long currentMillis = millis();

  keypad1();
  rotaryEncoder();

  if (currentMillis - previousMillis >= interval) {
    previousMillis = currentMillis;
    fsr();
    MPU6050();
    oocsiPackage();
    buttonPressed = 0;
  }
}

void oocsiPackage() {
  if (!mqttConnected) {
    return;
  }

  long currentMillis = millis();

  //This order of the index in the array should be the same as in the processing sketch.
  String payload = String(currentMillis) + "," +
   String(fsrVal1) + "," +
   String(fsrVal2) + "," +
   String(fsrValSq) + "," +
   String(counter) + "," +
   String(aXVal) + "," +
   String(aYVal) + "," +
   String(aZVal) + "," +
   String(gXVal) + "," +
   String(gYVal) + "," +
   String(gZVal);
   
  mqttClient.publish("informe-package", 2, true, payload.c_str());//The " 2 " here is for the Quality of Service (qos). 2 is the most strict (0, 1 or 2) which basically means none of the data packages may be skipped to prioritize other things.
  Serial.print("currentMillis is: ");
  Serial.println(currentMillis);
  
  if (buttonPressed != 0) {
    Serial.print("Button is pressed and sent: ");
    Serial.println(buttonPressed);
    mqttClient.publish("button-pressed", 2, true, String(buttonPressed).c_str());
  }
}

void keypad1() {
  char key = keypad.getKey();
  if (key != NO_KEY) {
    //Serial.println(key);
    buttonPressed = key - 48;//The buttonPressed in arduino is a char put in an int. This gives 49 which is 1 in ASCII
  }

}

void fsr() {
  fsrVal1 = analogRead(fsrPin1);
  //  Serial.print("fsr1 = ");
  //  Serial.println (fsrVal1);
  fsrVal2 = analogRead(fsrPin2);
  //  Serial.print("fsr2 = ");
  //  Serial.println (fsrVal2);
  fsrValSq = analogRead(fsrPinSq);
  //  Serial.print("fsrSq = ");
  //  Serial.println (fsrValSq);
}

void rotaryEncoder() {
  n = digitalRead(encoder0PinA);
  if ((encoder0PinALast == LOW) && (n == HIGH)) {
    if (digitalRead(encoder0PinB) == LOW) {
      counter--;
    } else {
      counter++;
    }
    Serial.print (counter);
    Serial.println ("/");
  }
  encoder0PinALast = n;
}

void MPU6050() {
  /* Get new sensor events with the readings */
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  aXVal = (a.acceleration.x) * 100;
  aYVal = (a.acceleration.y) * 100;
  aZVal = (a.acceleration.z) * 100;

  gXVal = (g.gyro.x) * 100;
  gYVal = (g.gyro.y) * 100;
  gZVal = (g.gyro.z) * 100;

  /* Print out the values */
  //  Serial.print("Acceleration X: ");
  //  Serial.print(aXVal);
  //  Serial.print(", Y: ");
  //  Serial.print(aYVal);
  //  Serial.print(", Z: ");
  //  Serial.print(aZVal);
  //  Serial.println(" m/s^2");
  //
  //  Serial.print("Rotation X: ");
  //  Serial.print(gXVal);
  //  Serial.print(", Y: ");
  //  Serial.print(gYVal);
  //  Serial.print(", Z: ");
  //  Serial.print(gZVal);
  //  Serial.println(" rad/s");
  //
  //  Serial.print("Temperature: ");
  //  Serial.print(temp.temperature);
  //  Serial.println(" degC");
  //
  //  Serial.println("");
  //delay(500);
}

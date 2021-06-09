import java.util.Date;
import java.sql.*; 
import java.math.*;
import mqtt.*;

MQTTClient buttonClient;
MQTTClient client;
Connection connection;

int participantNumber = 16;
int buttonPressed = 0;
int rotary = 0;
int fsr1 = 0; 
int fsr2 = 0; 
int fsrSq = 0; 
int accelX = 0; 
int accelY = 0; 
int accelZ = 0; 
int gyroX = 0; 
int gyroY = 0; 
int gyroZ = 0;

long calibratedTime = (new Date()).getTime();
long calibratedMillis = -1;
int lastButtonPressed = 0;
long lastMeasurementTime = 0;

void setup() {
  System.out.println("Booting...");
  size(500, 500);

  System.out.println("Connecting to MQTT...");
  client = new MQTTClient(this);
  client.connect("mqtt://localhost", "data-client");
  buttonClient = new MQTTClient(this);
  buttonClient.connect("mqtt://localhost", "button-client");

  try {
    String databasePath = sketchPath("informe-p"+ participantNumber +".db");
    println("Creating database at: "+ databasePath);

    connection = DriverManager.getConnection("jdbc:sqlite:"+ databasePath);
    Statement statement = connection.createStatement();
    statement.executeUpdate("CREATE TABLE IF NOT EXISTS informe (timestamp INT, fsr1 INT, fsr2 INT, fsrSq INT, rotary INT, accelX INT, accelY INT, accelZ INT, gyroX INT, gyroY INT, gyroZ INT, currentAudio INT)");
    statement.executeUpdate("CREATE TABLE IF NOT EXISTS buttons (timestamp INT, buttonPressed INT)");

    println("Initialized database!");
  } 
  catch (Exception error) {
    println("Could not connect to SQL database!");
    println(error);
  }

  frameRate(50); //  Specifies the number of frames to be displayed every second. For example, the function call frameRate(30) will attempt to refresh 30 times a second.

  // Load a soundfile from the /data folder of the sketch and play it back
  file1 = new SoundFile(this, "How_an_mri_works.mp3");
  file2 = new SoundFile(this, "Preperations.mp3");
  file3 = new SoundFile(this, "Noise.mp3");
  file4 = new SoundFile(this, "Keeping_still.mp3");
  file5 = new SoundFile(this, "Duration.mp3");
  file6 = new SoundFile(this, "Head_coil.mp3");
  file7 = new SoundFile(this, "Claustrophobia.mp3");
  file8 = new SoundFile(this, "Risks.mp3");
  file9 = new SoundFile(this, "Contrast_dye.mp3");


  rotaryNew = rotary;
  rotaryOld = rotary;
  buttonPressed = 0;
}

void draw() {
  cueAudio();
  scrollAudio2();
  background(255, 255, 255);
  fill(0, 0, 0);
  text("Calibrated time: "+ (new Date(calibratedTime)).toString(), 50, 50);
  text("Last button pressed: "+lastButtonPressed, 50, 75);
  text("Measurement time: "+ (new Date(lastMeasurementTime)).toString(), 50, 100);
  text("Current time: "+ (new Date()).toString(), 50, 125);
  text("Current Audio: "+ currentAudio, 50, 150);
  text("AccX: "+ accelX, 50, 175);
  text("AccY: "+ accelY, 50, 200);
  text("AccZ: "+ accelZ, 50, 225);
  text("GyroX: "+ gyroX, 50, 250);
  text("GyroY: "+ gyroY, 50, 275);
  text("GyroZ: "+ gyroZ, 50, 300);
  text("FsrSq: "+ fsrSq, 50, 325);
  text("Fsr1: "+ fsr1, 50, 350);
  text("Fsr2: "+ fsr2, 50, 375);
  text("Rotary: "+ rotary, 50, 400);
  
}


void clientConnected() {
  println("MQTT client connected");

  client.subscribe("informe-package", 2);
  buttonClient.subscribe("button-pressed", 2);
}

void messageReceived(String topic, byte[] payload) {
  Date date = new Date();
  long timestamp = date.getTime();

  if (topic.equals("button-pressed")) {
    String parsedPayload = new String(payload);
    buttonPressed = Integer.parseInt(parsedPayload); 
    lastButtonPressed = buttonPressed;

    if (buttonPressed != 0) {
      println(timestamp +" The following button was pressed: "+ buttonPressed);
    }

    try {
      String sql = "INSERT INTO buttons(timestamp, buttonPressed) VALUES(?, ?)";
      PreparedStatement statement = connection.prepareStatement(sql);
      statement.setLong(1, timestamp);
      statement.setInt(2, buttonPressed);
      statement.execute();
    } 
    catch (Exception error) {
      println("Could not write button press to database!");
      println(error);
    }   

    return;//if you do not return, it will execute the following part of this void as well. You don't want that as you just want the data package to write every 20 milliseconds.
  }

  String parsedPayload = new String(payload);
  String[] parts = parsedPayload.split(",");
  long millis = new BigInteger(parts[0]).longValue(); //getting the HEX from the arduino. And get the sepcific index in the array [0] 
  fsr1 = Integer.parseInt(parts[1]); 
  fsr2 = Integer.parseInt(parts[2]); 
  fsrSq = Integer.parseInt(parts[3]); 
  rotary = Integer.parseInt(parts[4]);
  accelX = Integer.parseInt(parts[5]); 
  accelY = Integer.parseInt(parts[6]); 
  accelZ = Integer.parseInt(parts[7]); 
  gyroX = Integer.parseInt(parts[8]); 
  gyroY = Integer.parseInt(parts[9]); 
  gyroZ = Integer.parseInt(parts[10]);
  //buttonPressed = Integer.parseInt(parts[11]); 

  int startupTime = 10000;
  if (millis < startupTime) {
    calibratedMillis = millis;
    calibratedTime = (new Date()).getTime();
    println("CALIBRATED TO: "+ new Date(calibratedTime));
  }

  if (calibratedMillis < 0) {
    calibratedTime = (new Date()).getTime();
    calibratedMillis = millis;
  }

  long measurementTime = calibratedTime + millis - calibratedMillis;
  lastMeasurementTime = measurementTime;
  Date measurementDate = new Date(measurementTime);

  println("The real time of the measurement was: "+ measurementTime +", with date: "+ measurementDate);

  try {
    String sql = "INSERT INTO informe(timestamp, fsr1, fsr2, fsrSq, rotary, accelX, accelY, accelZ, gyroX, gyroY, gyroZ,  currentAudio) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
    PreparedStatement statement = connection.prepareStatement(sql);
    statement.setLong(1, measurementTime); // this is the first '?' in the SQL (for this reason it is 1)
    statement.setInt(2, fsr1);
    statement.setInt(3, fsr2);
    statement.setInt(4, fsrSq);
    statement.setInt(5, rotary);
    statement.setInt(6, accelX);
    statement.setInt(7, accelY);
    statement.setInt(8, accelZ);
    statement.setInt(9, gyroX);
    statement.setInt(10, gyroY);
    statement.setInt(11, gyroZ);
    statement.setInt(12, currentAudio);
    statement.execute();
  } 
  catch (Exception error) {
    println("Could not write data to database!");
    println(error);
  }
}

void connectionLost() {
  println("MQTT connection lost");
}

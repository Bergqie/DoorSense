/*
  LED

  This example creates a Bluetooth® Low Energy peripheral with service that contains a
  characteristic to control an LED.

  The circuit:
  - Arduino MKR WiFi 1010, Arduino Uno WiFi Rev2 board, Arduino Nano 33 IoT,
    Arduino Nano 33 BLE, or Arduino Nano 33 BLE Sense board.

  You can use a generic Bluetooth® Low Energy central app, like LightBlue (iOS and Android) or
  nRF Connect (Android), to interact with the services and characteristics
  created in this sketch.

  This example code is in the public domain.
*/

#include <stdio.h>
#include <ArduinoBLE.h>
#include <Adafruit_Fingerprint.h>
#include <string.h>

// Define states
enum State {
  IDLE,
  CONNECTING,
  RECEIVING,
  TRANSMITTING,
  ENROLLING
};

#if (defined(__AVR__) || defined(ESP8266)) && !defined(__AVR_ATmega2560__)
// For UNO and others without hardware serial, we must use software serial...
// pin #2 is IN from sensor (GREEN wire)
// pin #3 is OUT from arduino  (WHITE wire)
// Set up the serial port to use softwareserial..
SoftwareSerial mySerial(2, 3);

#else
// On Leonardo/M0/etc, others with hardware serial, use hardware serial!
// #0 is green wire, #1 is white
#define mySerial Serial1

#endif

BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214");  // Bluetooth® Low Energy LED Service

// Bluetooth® Low Energy LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEByteCharacteristic switchCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite);

BLECharacteristic writeCharacteristic("19B10002-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, 16);

BLECharacteristic deleteCharacteristic("19B10003-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, 16);



const int ledPin = LED_BUILTIN;  // pin to use for the LED

Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

uint8_t id;

uint8_t isEnrolling = 0;

char inputString[32];

// Initialize the state
State currentState = IDLE;

const int relayPin1 = 4; //Digital Pin 4 (D4)
const int relayPin2 = 5; //Digital Pin 5 (D5)

void setup() {
  Serial.begin(9600);
  while (!Serial)
    ;

  delay(100);
  pinMode(relayPin1, OUTPUT);
  pinMode(relayPin2, OUTPUT);
  Serial.println("\n\nAdafruit Fingerprint sensor enrollment");

  // set the data rate for the sensor serial port
  finger.begin(57600);

  if (finger.verifyPassword()) {
   Serial.println("Found fingerprint sensor!");
  } else {
    Serial.println("Did not find fingerprint sensor :(");
    while (1) { delay(1); }
  }

  Serial.println(F("Reading sensor parameters"));
  finger.getParameters();
  Serial.print(F("Status: 0x"));
 Serial.println(finger.status_reg, HEX);
  Serial.print(F("Sys ID: 0x"));
 Serial.println(finger.system_id, HEX);
  Serial.print(F("Capacity: "));
Serial.println(finger.capacity);
  Serial.print(F("Security level: "));
 Serial.println(finger.security_level);
  Serial.print(F("Device address: "));
Serial.println(finger.device_addr, HEX);
 Serial.print(F("Packet len: "));
 Serial.println(finger.packet_len);
 Serial.print(F("Baud rate: "));
 Serial.println(finger.baud_rate);

  finger.getTemplateCount();

  if (finger.templateCount == 0) {
    Serial.print("Sensor doesn't contain any fingerprint data. Please run the 'enroll' example.");
  } else {
    Serial.println("Waiting for valid finger...");
     Serial.print("Sensor contains "); Serial.print(finger.templateCount); Serial.println(" templates");
  }

  delay(100);
  Serial.println("Start initialization of bluetooth...");

  // set LED pin to output mode
  pinMode(ledPin, OUTPUT);

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy module failed!");

    while (1)
      ;
  }

  // set advertised local name and service UUID:
  BLE.setLocalName("Doorsense");
  BLE.setDeviceName("Doorsense");
  BLE.setAdvertisedService(ledService);

  // add the characteristic to the service
  ledService.addCharacteristic(switchCharacteristic);
  ledService.addCharacteristic(writeCharacteristic);
  ledService.addCharacteristic(deleteCharacteristic);

  // add service
  BLE.addService(ledService);

  // set the initial value for the characeristic:
  switchCharacteristic.writeValue(0);

  // start advertising
  BLE.advertise();

  Serial.println("BLE LED Peripheral");

  // pinMode(relayPin1, OUTPUT);
  // pinMode(relayPin2, OUTPUT);

  digitalWrite(relayPin2, HIGH); 
  digitalWrite(relayPin1, LOW);
  Serial.println("Locking door...");
  delay(5000);
  digitalWrite(relayPin1, LOW); 
  digitalWrite(relayPin2, LOW);
}

void loop() {
  // listen for Bluetooth® Low Energy peripherals to connect:
  BLEDevice central = BLE.central();

  getFingerprintID();
  delay(50);

  // if a central is connected to peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's MAC address:
    Serial.println(central.address());

    // while the central is still connected to peripheral:
    while (central.connected()) {
      stateMachine();
    }

    // when the central disconnects, print it out:
    Serial.print(F("Disconnected from central: "));
    Serial.println(central.address());
  }
}

void stateMachine() {
  switch (currentState) {
    case IDLE:
      isEnrolling = 0;

      // Serial.println("State: IDLE");

      getFingerprintID();
      delay(50);

      // Transition to the Connecting state when a condition is met
      if (switchCharacteristic.value() == 1) {
        currentState = CONNECTING;
      } else if (switchCharacteristic.value() == 2) {
        currentState = RECEIVING;
      } else if (switchCharacteristic.value() == 3) {
        currentState = TRANSMITTING;
      } else if (switchCharacteristic.value() == 4) {
        currentState = ENROLLING;
      } else if (switchCharacteristic.value() == 8) {
        byte idToDelete = 0;
        deleteCharacteristic.readValue(idToDelete);
        Serial.println("Deleting ID: ");
        Serial.println(idToDelete);
        switchCharacteristic.writeValue(0);
      } else if (switchCharacteristic.value() == 9) {
        finger.emptyDatabase();
        Serial.println("Fingerprint Database Deleted");
        switchCharacteristic.writeValue(0);
      } else {
        currentState = IDLE;
      }
      break;

    case CONNECTING:
      // Perform tasks when in the Connecting state
    // Serial.println("Connecting");

      break;

    case RECEIVING:
      // Perform tasks when in the Receiving state
     // Serial.println("Receiving");
      // Simulating a transition to Transmitting state after a delay
      delay(1000);
      currentState = TRANSMITTING;
      break;

    case TRANSMITTING:
      // Perform tasks when in the Transmitting state
   //   Serial.println("Transmitting");
      // Simulating a transition back to Idle state after a delay
      delay(1000);
      currentState = IDLE;
      break;
    case ENROLLING:
    //  Serial.println("Enroll Fingerprint Mode: ");

      finger.getTemplateCount();
      //set the id to the next available slot
      id = finger.templateCount + 1;
      Serial.println("New fingerprint ID: ");
      Serial.println(id);



      if (isEnrolling != 0) {  //break out and go back to idle state
        currentState = IDLE;
        switchCharacteristic.writeValue(0);
      } else {
        // Call the function only if conditions are not met
        getFingerprintEnroll();
      }
      break;
  }
}


uint8_t getFingerprintID() {

  uint8_t p = finger.getImage();
  switch (p) {
    case FINGERPRINT_OK:
    //  Serial.println("Image taken");
      break;
    case FINGERPRINT_NOFINGER:
      //  Serial.println("No finger detected");
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
      //  Serial.println("Communication error");
      return p;
    case FINGERPRINT_IMAGEFAIL:
      // Serial.println("Imaging error");
      return p;
    default:
      //  Serial.println("Unknown error");
      return p;
  }

  // OK success!

  p = finger.image2Tz();
  switch (p) {
    case FINGERPRINT_OK:
    //  Serial.println("Image converted");
      break;
    case FINGERPRINT_IMAGEMESS:
      //  Serial.println("Image too messy");
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
      //  Serial.println("Communication error");
      return p;
    case FINGERPRINT_FEATUREFAIL:
      //  Serial.println("Could not find fingerprint features");
      return p;
    case FINGERPRINT_INVALIDIMAGE:
      //  Serial.println("Could not find fingerprint features");
      return p;
    default:
      //  Serial.println("Unknown error");
      return p;
  }

  // OK converted!
  p = finger.fingerSearch();
  if (p == FINGERPRINT_OK) {
  //  Serial.println("Found a print match!");
    //unlockDoor();
    digitalWrite(relayPin1, HIGH);
    digitalWrite(relayPin2, LOW);
    Serial.println("Unlocking door...");
     delay(5000);
     digitalWrite(relayPin1, LOW); 
     digitalWrite(relayPin2, LOW);
  } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
    //  Serial.println("Communication error");
    return p;
  } else if (p == FINGERPRINT_NOTFOUND) {
    //  Serial.println("Did not find a match");
     digitalWrite(relayPin2, HIGH); 
     digitalWrite(relayPin1, LOW);
     Serial.println("Finger print not found!");
     delay(5000);
     digitalWrite(relayPin2, LOW); 
     digitalWrite(relayPin1, LOW);
    return p;
  } else {
    //  Serial.println("Unknown error");
    return p;
  }

  // found a match!
 // Serial.print("Found ID #");
 // Serial.print(finger.fingerID);
//  Serial.print(" with confidence of ");
 // Serial.println(finger.confidence);

  return finger.fingerID;
}

// returns -1 if failed, otherwise returns ID #
int getFingerprintIDez() {
  uint8_t p = finger.getImage();
  finger.getTemplateCount();
  if (p != FINGERPRINT_OK) return -1;

  p = finger.image2Tz();
  if (p != FINGERPRINT_OK) return -1;

  p = finger.fingerFastSearch();
  if (p != FINGERPRINT_OK) return -1;

  // found a match!
  // Serial.print("Found ID #"); Serial.print(finger.fingerID);
  // Serial.print(" with confidence of "); Serial.println(finger.confidence);
  return finger.fingerID;
}

uint8_t getFingerprintEnroll() {

  int p = -1;
//  Serial.print("Waiting for valid finger to enroll as #");
 // Serial.println(id);
  while (p != FINGERPRINT_OK) {
    p = finger.getImage();
    switch (p) {
      case FINGERPRINT_OK:
   //     Serial.println("Image taken");
        break;
      case FINGERPRINT_NOFINGER:
   //     Serial.println(".");
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
    //    Serial.println("Communication error");
        break;
      case FINGERPRINT_IMAGEFAIL:
    //    Serial.println("Imaging error");
        break;
      default:
     //   Serial.println("Unknown error");
        break;
    }
  }

  // OK success!

  p = finger.image2Tz(1);
  switch (p) {
    case FINGERPRINT_OK:
  //    Serial.println("Image converted");
      // sprintf(inputString, "R");
      // writeCharacteristic.writeValue((unsigned char *)inputString, 1);
      // Serial.println(inputString);
      break;
    case FINGERPRINT_IMAGEMESS:
   //   Serial.println("Image too messy");
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
    //  Serial.println("Communication error");
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
      return p;
    case FINGERPRINT_FEATUREFAIL:
    //  Serial.println("Could not find fingerprint features");
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
      return p;
    case FINGERPRINT_INVALIDIMAGE:
    //  Serial.println("Could not find fingerprint features");
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
      return p;
    default:
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
    //  Serial.println("Unknown error");
      return p;
  }

  //Serial.println("Remove finger");
  delay(2000);
  p = 0;
  while (p != FINGERPRINT_NOFINGER) {
  //  Serial.println("Waiting...");
    p = finger.getImage();
  }
 // Serial.print("ID ");
 // Serial.println(id);
  p = -1;
 // Serial.println("Place same finger again");
  while (p != FINGERPRINT_OK) {
    p = finger.getImage();
    switch (p) {
      case FINGERPRINT_OK:
       // Serial.println("Image taken");
        break;
      case FINGERPRINT_NOFINGER:
     //   Serial.print(".");
        break;
      case FINGERPRINT_PACKETRECIEVEERR:
        sprintf(inputString, "E");
        writeCharacteristic.writeValue((unsigned char *)inputString, 1);
      //  Serial.println("Communication error");
        break;
      case FINGERPRINT_IMAGEFAIL:
        sprintf(inputString, "E");
        writeCharacteristic.writeValue((unsigned char *)inputString, 1);
     //   Serial.println("Imaging error");
        break;
      default:
        sprintf(inputString, "E");
        writeCharacteristic.writeValue((unsigned char *)inputString, 1);
      //  Serial.println("Unknown error");
        break;
    }
  }

  // OK success!

  p = finger.image2Tz(2);
  switch (p) {
    case FINGERPRINT_OK:
   //   Serial.println("Image converted");
      break;
    case FINGERPRINT_IMAGEMESS:
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
    //  Serial.println("Image too messy");
      return p;
    case FINGERPRINT_PACKETRECIEVEERR:
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
    //  Serial.println("Communication error");
      return p;
    case FINGERPRINT_FEATUREFAIL:
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
    //  Serial.println("Could not find fingerprint features");
      return p;
    case FINGERPRINT_INVALIDIMAGE:
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
  //    Serial.println("Could not find fingerprint features");
      return p;
    default:
      sprintf(inputString, "E");
      writeCharacteristic.writeValue((unsigned char *)inputString, 1);
   //   Serial.println("Unknown error");
      return p;
  }

  // OK converted!
 // Serial.print("Creating model for #");
//  Serial.println(id);

  p = finger.createModel();
  if (p == FINGERPRINT_OK) {
   // Serial.println("Prints matched!");
    isEnrolling = 1;
  } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
    sprintf(inputString, "E");
    writeCharacteristic.writeValue((unsigned char *)inputString, 1);
  //  Serial.println("Communication error");
    return p;
  } else if (p == FINGERPRINT_ENROLLMISMATCH) {
    sprintf(inputString, "E");
    writeCharacteristic.writeValue((unsigned char *)inputString, 1);
  //  Serial.println("Fingerprints did not match");
    return p;
  } else {
    sprintf(inputString, "E");
    writeCharacteristic.writeValue((unsigned char *)inputString, 1);
   // Serial.println("Unknown error");
    return p;
  }

//  Serial.print("ID ");
 // Serial.println(id);
  p = finger.storeModel(id);
  if (p == FINGERPRINT_OK) {
 //   Serial.println("Stored!");
    //stored! set state to IDLE
    isEnrolling = 1;
    // Assuming inputString is a character array
    inputString[0] = 'S';
    sprintf(inputString + 1, "%d", id);

    // Assuming writeCharacteristic.writeValue expects a character array
    writeCharacteristic.writeValue((unsigned char *)inputString, strlen(inputString));
  } else if (p == FINGERPRINT_PACKETRECIEVEERR) {
  //  Serial.println("Communication error");
    return p;
  } else if (p == FINGERPRINT_BADLOCATION) {
  //  Serial.println("Could not store in that location");
    return p;
  } else if (p == FINGERPRINT_FLASHERR) {
  //  Serial.println("Error writing to flash");
    return p;
  } else {
 //   Serial.println("Unknown error");
    return p;
  }

  return true;
}

void unlockDoor() {
 // Serial.println("Unlocking Door...");
  digitalWrite(relayPin2, HIGH);
  digitalWrite(relayPin1, LOW);
  delay(500);
  digitalWrite(relayPin2, LOW);
}

void lockDoor() {
 // Serial.println("Locking Door...");
  digitalWrite(relayPin1, HIGH);
  digitalWrite(relayPin2, LOW);
  delay(500);
  digitalWrite(relayPin1, LOW);
}

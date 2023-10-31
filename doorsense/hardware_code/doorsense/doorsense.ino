#include <ArduinoBLE.h>
#include <Adafruit_Fingerprint.h>
#include <string.h>

// Define states
enum State {
  IDLE,
  CONNECTING,
  RECEIVING,
  TRANSMITTING
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
 
BLEService ledService("19B10000-E8F2-537E-4F6C-D104768A1214"); // Bluetooth® Low Energy LED Service
 
// Bluetooth® Low Energy LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLECharacteristic dataCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLEWrite, 16);
 
const int ledPin = LED_BUILTIN; // pin to use for the LED

Adafruit_Fingerprint finger = Adafruit_Fingerprint(&mySerial);

uint8_t id;

char inputString[32];

// Initialize the state
State currentState = IDLE;

void setup() {
 Serial.begin(9600);
  while (!Serial);

  delay(100);
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
  Serial.print(F("Status: 0x")); Serial.println(finger.status_reg, HEX);
  Serial.print(F("Sys ID: 0x")); Serial.println(finger.system_id, HEX);
  Serial.print(F("Capacity: ")); Serial.println(finger.capacity);
  Serial.print(F("Security level: ")); Serial.println(finger.security_level);
  Serial.print(F("Device address: ")); Serial.println(finger.device_addr, HEX);
  Serial.print(F("Packet len: ")); Serial.println(finger.packet_len);
  Serial.print(F("Baud rate: ")); Serial.println(finger.baud_rate);

  delay(100);
  Serial.println("Start initialization of bluetooth...");
 
  // set LED pin to output mode
  pinMode(ledPin, OUTPUT);
 
  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting Bluetooth® Low Energy module failed!");
 
    while (1);
  }
 
  // set advertised local name and service UUID:
  BLE.setLocalName("DoorSense");
  BLE.setDeviceName("DoorSense");
  BLE.setAdvertisedService(ledService);
 
  // add the characteristic to the service
  ledService.addCharacteristic(ledCharacteristic);
  ledService.addCharacteristic(inputCharacteristic);
 
  // add service
  BLE.addService(ledService);
 
  //set the initial values for the characteristic to zeros
  ledCharacteristic.writeValue(0);
  inputCharacteristic.writeValue(0);
 
  // start advertising
  BLE.advertise();
 
  Serial.println("Bluetooth® device active, waiting for connections...");

}

uint8_t readnumber(void) {
  uint8_t num = 0;

  while (num == 0) {
    while (! Serial.available());
    num = Serial.parseInt();
  }
  return num;
}


void loop() {
  // put your main code here, to run repeatedly:
  stateMachine();

}

void stateMachine() {
  switch(currentState) {
    case IDLE:
      // Perform tasks when in the Idle state
      Serial.println("Idle");

      BLE.poll(); // poll for Bluetooth® Low Energy events

      // Transition to the Connecting state when a condition is met
      if (inputCharacteristic.value() == 1) {
        inputCharacteristic.writeValue(1);
        currentState = CONNECTING;
      }
      break;

    case CONNECTING:
      // Perform tasks when in the Connecting state
      Serial.println("Connecting");
      // Simulating a transition to Receiving state after a delay
      delay(1000);
      currentState = RECEIVING;
      break;

    case RECEIVING:
      // Perform tasks when in the Receiving state
      Serial.println("Receiving");
      // Simulating a transition to Transmitting state after a delay
      delay(1000);
      currentState = TRANSMITTING;
      break;

    case TRANSMITTING:
      // Perform tasks when in the Transmitting state
      Serial.println("Transmitting");
      // Simulating a transition back to Idle state after a delay
      delay(1000);
      currentState = IDLE;
      break;
  }
}

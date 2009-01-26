/*
  Sharp GP2D12 IR ranger reader
  Language: Wiring/Arduino
  
  Reads the value from a Sharp GP2D12 IR ranger and sends 
  it out serially.
  
  Based on an example from Tom Igoe's Making Things Talk.
  
*/
int sensorPin = 0;     // Analog input pin 
int sensorValue = 0;   // value read from the sensor
int pin1 = 9;   // blinking light 1
int pin2 = 10;  // blinking light 2
int pin3 = 11;  // blinking light 3
int pin4 = 13;  // A light for fun
int val1 = 64; // light 1 brightness
int val2 = 64; // light 2 brightness
int val3 = 64; // light 3 brightness

void setup() {
  pinMode(pin1, OUTPUT);    // set pins to be outputs
  pinMode(pin2, OUTPUT);
  pinMode(pin3, OUTPUT);
  pinMode(pin4, OUTPUT);
  
  randomSeed(42);

  digitalWrite(pin4, HIGH);
  digitalWrite(8, LOW);
  Serial.begin(9600);  // for debugging
}

void loop() {
  
  sensorValue = analogRead(sensorPin); // read the sensor value
  if (sensorValue> 3) { // don't process weak results

    // the sensor actually gives results that aren't linear.
    // this formula converts the results to a linear range.
    int range = (6787 / (sensorValue - 3)) - 4;
    Serial.print("Raw value: ");
    Serial.println(sensorValue, DEC);
    Serial.println(range, DEC);    // print the sensor value     

    // Flash bright when someone's there.
    if (range >0 && range < 72) {
      analogWrite(pin1, 0);
      analogWrite(pin2, 0);
      analogWrite(pin3, 0);

      delay(125);
      analogWrite(pin1, 255);
      analogWrite(pin2, 255);
      analogWrite(pin3, 255);

      delay(125);      
    }
  }
  // flicker like a candle when no one's around
  val1 = flicker(val1);
  val2 = flicker(val2);
  val3 = flicker(val3);
  analogWrite(pin1, val1);
  analogWrite(pin2, val2);
  analogWrite(pin3, val3);

  delay(25);
}

int flicker(int val) {
  val += random(0,20) - 10;     // add a random value between -10 and 10
  val = constrain(val, 0, 255); // don't let it get too bright
  Serial.print("Val:");  Serial.println(val, DEC);
  return val;
}



//Distance Ping Alarm v1.0
//by John Park (jp @ jpixl.net)
//Read more at blog.makezine.com
//
//based on PING))) sensor sketch by David A. Mellis and Tom Igoe
//and 7SEG-SHIELD code by Gravitech
//
//This is a digital tape measure with display. It has a memory for the first distance average, and reactions to new higher and
//lower distances.
//
//Reads the PING))) ultrasonic rangefinder for ten samples to find an average.
//Shows distance value on the seven segment display in inches.
//Checks every 100 millis to see if anything has gotten closer,
//if so, lights LED on pin 13.
//On board 10mm LED is cyan while calibrating, green when default, blue when farther, red when closer
//
//Hardware: Arduino with PING))) distance sensor (plugged into 5V, GND, pin 7) and 7-Segment Shield.

#include <Wire.h> 
#define _7SEG (0x38)   //I2C address for the 7-Segment
#define RED (3)        // Red color pin of RGB LED 
#define GREEN (5)      // Green color pin of RGB LED 
#define BLUE (6)       // Blue color pin of RGB LED 
#define BUTTON (12)    //pushbutton pin
int buttVal = 0; //store the button value
const byte NumberLookup[16] =   {0x3F,0x06,0x5B,0x4F,0x66,
                                 0x6D,0x7D,0x07,0x7F,0x6F, 
                                 0x77,0x7C,0x39,0x5E,0x79,0x71}; //table for numbers 0-9,A-F on display
   
const int pingPin = 7;//which pin the PING sensor's plugged into
int ledPin = 13;
int pingDist = 0; //variable for distance reading
int pingInitial[10] = {0,0,0,0,0,0,0,0,0,0};//store initial reads
int pingAvg = 0;//average of the samples

void setup() {
  Wire.begin();//initialize wire library, join I2C bus
  // initialize serial communication:
  Serial.begin(9600);
    pinMode(ledPin, OUTPUT);
    pinMode(RED, OUTPUT); //set all three led pins to output mode
    pinMode(GREEN, OUTPUT);
    pinMode(BLUE, OUTPUT);
    
    pinMode(BUTTON, INPUT); //add button as an input
    
    delay(250); //let the system stabilize
    //
    RGBLED(6);
    //Configure 7-segment to 12mA segment output current, Dynamic mode, and Digits 1,2,3,4 not blanked
    Wire.beginTransmission(_7SEG);
    Wire.send(0);
    Wire.send(B01000111);
    Wire.endTransmission();
    delay(250);
    
    //display "CAL." while calibrating
    Send7SEG (4, B00111001);//c
    Send7SEG (3, B01110111);//a
    Send7SEG (2, B10111000);//l
    Send7SEG (1, B00000000);

  //calibration to default distance
  Serial.println("Calibrating distance... ");
    for(int i=0; i< 10; i++){

  // establish variables for duration of the ping, 
  // and the distance result in inches and centimeters:
  long duration, inches, cm;

  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);

  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(pingPin, INPUT);
  duration = pulseIn(pingPin, HIGH);

  // convert the time into a distance
  inches = microsecondsToInches(duration);
  cm = microsecondsToCentimeters(duration);
  
  Serial.print(inches);
  Serial.print("in, ");
  Serial.print(cm);
  Serial.print("cm");
  Serial.println();
  
  delay(200);
       
       pingInitial[i]=inches;
      } 
      
  pingAvg=((pingInitial[0]+pingInitial[1]+pingInitial[2]+pingInitial[3]+pingInitial[4]+pingInitial[5]+pingInitial[6]+pingInitial[7]+pingInitial[8]+pingInitial[9])*0.1);
  Serial.println("Default distance initialized.");
  Serial.print("Default distance is ");
  Serial.print(pingAvg);
  Serial.println("in");
  

      /////////////////// 7 segment stuff
    int ones=(pingAvg%10); 
    int tens=(pingAvg/10);
    
    Send7SEG (1, B11010100);//n.
    Send7SEG (2, B00000100);//i
    Send7SEG (3, NumberLookup[ones]);
    Send7SEG (4, NumberLookup[tens]);
    delay(100);
  RGBLED(2);
}


void loop()
{
  // establish variables for duration of the ping, 
  // and the distance result in inches and centimeters:
  long duration, inches, cm;

  // The PING))) is triggered by a HIGH pulse of 2 or more microseconds.
  // Give a short LOW pulse beforehand to ensure a clean HIGH pulse:
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);

  // The same pin is used to read the signal from the PING))): a HIGH
  // pulse whose duration is the time (in microseconds) from the sending
  // of the ping to the reception of its echo off of an object.
  pinMode(pingPin, INPUT);
  duration = pulseIn(pingPin, HIGH);

  // convert the time into a distance
  inches = microsecondsToInches(duration);
  cm = microsecondsToCentimeters(duration);
  
  Serial.print(inches);
  Serial.print("in, ");
  Serial.print(cm);
  Serial.print("cm");
  Serial.println();
  
  delay(100);
  //if the distance is closer than the default, do this:
  if(inches<pingAvg){
    RGBLED(1);//sets the 10mm LED to red
   digitalWrite(ledPin,HIGH); //sets the LED on pin 13 (or a relay, etc.) to high
   Serial.println("INTRUDER DETECTED");
   int ones=(inches%10);
   int tens=(inches/10);
   Send7SEG (1, B11010100);//n.
   Send7SEG (2, B00000100);//i
   Send7SEG (3, NumberLookup[ones]);
   Send7SEG (4, NumberLookup[tens]);
   delay(100);
   }
   //if the distance equals the default, do this:
  else if(inches==pingAvg) {
    RGBLED(2);//sets the 10mm LED to green
    int ones=(pingAvg%10);
    int tens=(pingAvg/10);
    digitalWrite(ledPin,LOW);//sets the LED on pin 13 (or a relay, etc.) to low
    Send7SEG (1, B11010100);//n.
    Send7SEG (2, B00000100);//i
    Send7SEG (3, NumberLookup[ones]);
    Send7SEG (4, NumberLookup[tens]);
    delay(100);
  }
  //if the distance is greater than the default, do this:
    else{
    RGBLED(3);//sets the 10mm LED to green
      digitalWrite(ledPin,LOW);//sets the LED on pin 13 (or a relay, etc.) to low
    int ones=(inches%10);
    int tens=(inches/10);
    
    Send7SEG (1, B11010100);//n.
    Send7SEG (2, B00000100);//i
    Send7SEG (3, NumberLookup[ones]);
    Send7SEG (4, NumberLookup[tens]);
    delay(100);
    
  }
}

//other procs
long microsecondsToInches(long microseconds)
{
  // According to Parallax's datasheet for the PING))), there are
  // 73.746 microseconds per inch (i.e. sound travels at 1130 feet per
  // second).  This gives the distance travelled by the ping, outbound
  // and return, so we divide by 2 to get the distance of the obstacle.
  // See: http://www.parallax.com/dl/docs/prod/acc/28015-PING-v1.3.pdf
  return microseconds / 74 / 2;
}

long microsecondsToCentimeters(long microseconds)
{
  // The speed of sound is 340 m/s or 29 microseconds per centimeter.
  // The ping travels out and back, so to find the distance of the
  // object we take half of the distance travelled.
  return microseconds / 29 / 2;
}

void Send7SEG (byte Digit, byte Number){
  Wire.beginTransmission(_7SEG);
  Wire.send(Digit);
  Wire.send(Number);
  Wire.endTransmission();
}

//this is the color lookup table for the onboard 10mm LED
void RGBLED (byte Color){
  //0=black, 1=red, 2=green, 3=blue, 4=yellow, 5=purple, 6=cyan, 7=white
 if (Color == 0) {
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, LOW);
    digitalWrite(BLUE, LOW);
 }
 else if (Color == 1) {
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, LOW);
    digitalWrite(BLUE, LOW);
 }
 else if (Color == 2) {
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, LOW);  
 }
  else if (Color == 3) {
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, LOW);
    digitalWrite(BLUE, HIGH);
 }
  else if (Color == 4) {
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, LOW);
 }
  else if (Color == 5) {
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, LOW);
    digitalWrite(BLUE, HIGH);
 }
  else if (Color == 6) {
    digitalWrite(RED, LOW);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, HIGH);
 }
  else if (Color == 7) {
    digitalWrite(RED, HIGH);
    digitalWrite(GREEN, HIGH);
    digitalWrite(BLUE, HIGH);
 }
}
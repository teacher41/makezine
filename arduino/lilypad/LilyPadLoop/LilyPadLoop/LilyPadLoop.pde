 /* LilyPad Loop
 * by Becky Stern
 * 
 * Based on 'Loop' by David A. Mellis
 *
 * Lights 12 LEDs, two at a time, in a rotational sequence.
 * 
 */

int timer = 100;                   // The higher the number, the slower the timing.
int pins[] = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 }; // an array of pin numbers
int num_pins = 12;                  // the number of pins (i.e. the length of the array)

void setup()
{
  int i;

  for (i = 0; i < num_pins; i++)   // the array elements are numbered from 0 to num_pins - 1
    pinMode(pins[i], OUTPUT);      // set each pin as an output
}

void loop()
{
  int i;
  
  for (i = 0; i < num_pins/2; i++) { // loop through each pin state (there are six)
    digitalWrite(pins[i], HIGH);   // turn one LED on,
    digitalWrite(pins[i+num_pins/2], HIGH); //then turn its opposite LED on (six positions away)
    
    //now turn the previous LEDs off:
    
    if (i == 0){                //turn the last LED off from the previous go 'round
      digitalWrite(pins[num_pins-1], LOW);  //
    } else{
      digitalWrite(pins[i-1], LOW);    // turn off each previous LED
    }
    digitalWrite(pins[(i+num_pins/2)-1], LOW);
    
    delay(timer);                  // pausing

  }

}

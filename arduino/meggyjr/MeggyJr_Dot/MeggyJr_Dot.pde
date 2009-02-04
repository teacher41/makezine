/*
  MeggyJr_Dot.pde
 
  Dot - v.1, 090202a Collin Cunningham
    You are a blinking white/green dot in need of some fun.
    so avoid the raindrops and go grab the sun!
 
     - press A to start
     - move the dot with the crosspad
     - avoid the blue raindrops
     - collect the orange suns, to progress
 
 things to be added:
     - extra lives
     - umbrella powerup?
     - a third raindrop after level 15
     - more music bits / soundtrack
     - pause function
     - clouds?
 
 
 Meggy Jr. Library
 Version 1.25 - 12/2/2008
 Copyright (c) 2008 Windell H. Oskay.  All right reserved.
 http://www.evilmadscientist.com/
 
 This library is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this library.  If not, see <http://www.gnu.org/licenses/>.
 	  
 */



#include <MeggyJrSimple.h>    // Required code, line 1 of 2.
boolean state = false;
byte dotX;
byte dotY;
byte sunX;
byte sunY;
byte sunOld;
byte rainX;
byte rainY;
byte rain2X;
byte rain2Y;
byte rainOld;
byte auxval ;
char dotColor;
char levelColor;
char sunColor;
byte rainColor0;
byte rainColor1;
byte rainColor2;
byte rainColor3;
char xcolor;
int xwait;
int delayTime;
int sunny;
byte level; // <------------------------------------to change starting level, adjust "level" value in "titleScreen()"
byte rainfall = 8;
byte rainPalette[] = { 19, 20, 21, 22 };            //colors we'll use for raindrops
int i = 0;
byte x = 0;
char sunshine = CustomColor0;
byte count;

void setup()                 
{

  MeggyJrSimpleSetup();      
  EditColor(16, 2, 2, 0); // CustomColor0 = a less dim orange
  EditColor(17, 4, 4, 0); // CustomColor1 = a medium orange
  EditColor(18, 4, 4, 0); // CustomColor2 = yet another orange
  EditColor(23, 2, 2, 0); // CustomColor7 = yet another orange
  EditColor(19, 3, 4, 7); // CustomColor3 = bright rain
  EditColor(20, 1, 2, 5); // CustomColor4 = less bright rain
  EditColor(21, 0, 1, 3); // CustomColor5 = medium rain
  EditColor(22, 0, 0, 1); // CustomColor6 = dim rain
  
  resetGame();            //triggers the title screen and once a button is pressed, level screen, starts
}




void loop()                     
{
  count++;                                                                  // bump up our counter
  state = (!state);                                                         // toggle reference stat

  if (!state) { 
    dotColor = Green;
    if (count % 3 == 0){sunColor = Yellow;}
    else {sunColor = White;}
  }  
  else {
    dotColor = White;
    sunColor = Orange;
  }

  CheckButtonsDown();                                                       //check which buttons are being pressed
  
  
  if ((Button_Up)&&(dotY<7)) {                                              // pushing directional button will move our dot
    dotY ++; 
    Tone_Start(ToneD3, 10); 
  }     
  if ((Button_Down)&&(dotY >=1)) {                                          // but it won't go off the screen
    dotY--; 
    Tone_Start(ToneA3, 10); 
  }   
  if ((Button_Right)&&(dotX<7)) {
    dotX ++; 
    Tone_Start(ToneB3, 10);                                                 // moving makes a noise as well
  }   
  if ((Button_Left)&&(dotX >=1)) { 
    dotX--; 
    Tone_Start(ToneC3, 10); 
  }
  dotX = constrain(dotX, 0, 7);
  dotY = constrain(dotY, 0, 7);


  if (rainY==0) {                                                           // if first raindrop hits bottom, draw a new raindrop
    rainOld = rainX;
    while (rainOld == rainX){
    rainX = random(7);
    rainX = constrain(rainX, 0, 7);
    }
    rainY = 7;
  }
  
  
  if (rain2Y==0) {                                                         // if second raindrop hits bottom, draw a new raindrop
    while (rainX == rain2X){
    rain2X = random(7);
    rain2X = constrain(rain2X, 0, 7);
    }
    rain2Y = 7;
  }
  

  if (rainfall == 0) {                                                     // make those raindrops fall
    rainY--;
    if (!state || count % 5 == 0) { 
    rain2Y--;
    }
    if (level == 1) {rainfall = 8;}
    else if (level < 11){rainfall = (18 / level);}                         // faster as levels progress to 11
    else {rainfall = 1;}
  }
  else {
    rainfall--;
  }


  if (count % 2 == 0) {                                                    // cycle colors of sunrays
  
    if (sunshine == CustomColor0) {
      sunshine = CustomColor1;
    }
    else if  (sunshine == CustomColor1) {
      sunshine = Yellow;
    }
    else if  (sunshine == Yellow) {
      sunshine = CustomColor2;
    }
    else if  (sunshine == CustomColor2) {
      sunshine = CustomColor7;
    }
    else if  (sunshine == CustomColor7) {
      sunshine = CustomColor0;
    }
  }  

  DrawPx(constrain(sunX-1,0,7), sunY, sunshine);                         //draw the sunrays
  DrawPx(constrain(sunX+1,0,7), sunY, sunshine);
  DrawPx(sunX, constrain(sunY-1,0,7), sunshine);
  DrawPx(sunX, constrain(sunY+1,0,7), sunshine);

  DrawPx(dotX, dotY, dotColor);                                         //draw player dot


  DrawPx(sunX, sunY, sunColor);                                         //draw sun


 if (count % 1 == 0) {                                                  // cycle colors of raindrop
   i++;
  if (i == 4){i = 0;}
 rainColor0 = rainPalette[i];
  i++;
  if (i == 4){i = 0;}
  rainColor1 = rainPalette[i];
  i++;
  if (i == 4){i = 0;}
  rainColor2 = rainPalette[i];
  i++;
  if (i == 4){i = 0;}
  rainColor3 = rainPalette[i];
  i++;
  if (i == 4){i = 0;}
    
}


  DrawPx(rainX, rainY, rainColor0);                                        //draw a raindrop
  DrawPx(rainX, constrain(rainY+1, 0, 7), rainColor1);                    
  if (level >=2){                                                          //if we're over level 2, draw the drop twice as long  
    DrawPx(rainX, constrain(rainY+2, 0, 7), rainColor2);
    DrawPx(rainX, constrain(rainY+3, 0, 7), rainColor3);
  }
  if (level >=8){                                                          //if we're over level 8, draw the drop another pixel longer
    DrawPx(rainX, constrain(rainY+4, 0, 7), rainColor0);                      
  }
  
  
  if (level >= 3){
  DrawPx(rain2X, rain2Y, rainColor0);                                       //if we're over level 3, draw a secondraindrop
  DrawPx(rain2X, constrain(rain2Y+1, 0, 7), rainColor1);
  if (level >= 6){                                                          //if we're over level 6, draw the second drop 1 pixel longer
  DrawPx(rain2X, constrain(rain2Y+2, 0, 7), rainColor2);
  }
  if (level >= 9){                                                          //if we're over level 9, draw the drop yet another pixel longer
    DrawPx(rain2X, constrain(rain2Y+3, 0, 7), rainColor3);
  }
  }


  if (ReadPx(dotX,dotY) == 19 || ReadPx(dotX,dotY) == 20 ||                 //check to see if player hit rain by looking for rain ...
      ReadPx(dotX,dotY) == 21 || ReadPx(dotX,dotY) == 22) {                 //by looking for rain colors @ the dot's current position
    gameOver();                                                             //if they did hit rain, then it's game over time 
  }
  
  // check to see if sun was rained on

  else if (dotX == sunX && dotY == sunY) {                                  // Check to see if we got some sun
    sunny = 0;
    chompSound();                                                           // play chomp noise

    if (auxval == 255) {                                                    // set score on auxiliary LEDs
      auxval = 0;

      levelUp();                                                            //if player got the sun 9 times, got to next level
    }
    else  auxval = ((auxval*2)+1);
  }

  if (sunny == 0) {
    sunOld = sunY;
    do{                                                                     //choose new random spot for sun
      sunX = random(7);
    }                                                                       //make sure it's not on top of the player dot
    
    while (sunX == dotX || sunX == dotX+1 || sunX == dotX+2 || sunX == dotX-1 || sunX == dotX-2);       

    do{                                                                     //choose new random spot for sun
      sunY = random(6);          
    }
                                                                           //make sure it's not on top of the player dot, or at the last height

    while (sunY == dotY || sunY == dotY+1 || sunY == dotY+2 || sunY == dotY-1 || sunY == dotY-2 || sunY == sunOld);       
    sunny = 1;


  }



  SetAuxLEDs(auxval);                                                     //display the level score on auxiliary LEDs
  auxval = constrain(auxval, 0, 255); 

  DisplaySlate();                                                         // Write the drawing to the screen.
  delay(65);                                                              // waits for a a bit, 70ms = the 'gamerate'

  ClearSlate();                                                          // Erase drawing

}

void chompSound() {

  Tone_Start(ToneC4, 10);                                               //make a little munch/chomp noise
  delay(10);
  Tone_Start(ToneE5, 10);
  delay(10);
  Tone_Start(ToneE5, 10);
  delay(10);
  Tone_Start(ToneG6, 2);
  delay(3);
  Tone_Start(ToneG6, 2);
  delay(3);  
  Tone_Start(ToneG6, 3);
  delay(4);  
  Tone_Start(ToneG6, 4);
  delay(5);
  Tone_Start(ToneG6, 20);
  return;
}

void levelUp() {                                                       //when a level is finished, animate the dot where in it's current postion

  ClearSlate();
  DrawPx(dotX, dotY, dotColor);                                        //flash the dot in its last position
  DisplaySlate();
  Tone_Start(ToneG4, 200);
  delay(200);
  ClearSlate();
  DisplaySlate();
  delay(200);

  DrawPx(dotX, dotY, dotColor);                                       //flash the dot
  DisplaySlate();
  Tone_Start(ToneG4, 200);
  delay(200);
  ClearSlate();
  DisplaySlate();
  delay(200);

  DrawPx(dotX, dotY, dotColor);                                       //flash the dot yet again
  DisplaySlate();
  Tone_Start(ToneD3, 200);
  delay(200);
  ClearSlate();
  DisplaySlate();
  delay(200);

  DrawPx(dotX, dotY, dotColor);                                        //yep, another dot flash
  DisplaySlate();
  Tone_Start(ToneE3, 200);
  delay(200);
  Tone_Start(ToneG4, 200);
  level++;
  levelScreen();

  dotX = 3;                                                          // reset values for next level
  dotY = 3;
  rainY = 7;
  rain2Y = 7;
  auxval = 0;
  sunny = 1;

  return;

}

void levelScreen(){                                                //when we reach a new level, display it in flashing green and white
  levelColor = DimGreen;
  delayTime = 100;
  levelNumber();

  levelColor = Green;
  delayTime = 200;
  levelNumber();

  levelColor = White;
  delayTime = 1200;
  levelNumber();

  levelColor = Green;
  delayTime = 100;
  levelNumber();

  levelColor = DimGreen;
  delayTime = 50;
  levelNumber();

  ClearSlate();
  DisplaySlate();
  delay(100);

}

void levelNumber(){                                              //take the new level number and display it on screen
  ClearSlate();                                                  
  switch (level){
    case 1: x = -1; draw1(); break;                             // this function could use a simpler way to derive display #s from level value
    case 2: x = -1; draw2(); break;
    case 3: x = -1; draw3(); break;
    case 4: x = -1; draw4(); break;
    case 5: x = -1; draw5(); break; 
    case 6: x = -1; draw6(); break;
    case 7: x = -1; draw7(); break;
    case 8: x = -1; draw8(); break;
    case 9: x = -1; draw9(); break;
    case 10: x = -2; draw1(); x=1; draw0(); break;
    case 11: x = -2; draw1(); x=1; draw1(); break;
    case 12: x = -2; draw1(); x=1; draw2(); break;
    case 13: x = -2; draw1(); x=1; draw3(); break;
    case 14: x = -2; draw1(); x=1; draw4(); break;
    case 15: x = -2; draw1(); x=1; draw5(); break;
    case 16: x = -2; draw1(); x=1; draw6(); break;
    case 17: x = -2; draw1(); x=1; draw7(); break;
    case 18: x = -2; draw1(); x=1; draw8(); break;
    case 19: x = -2; draw1(); x=1; draw9(); break;
    case 20: x = -2; draw2(); x=1; draw0(); break;
    // no level numbers after 20 ... yet
  }

  DisplaySlate();
  ClearSlate();
  delay(delayTime);
}

  void draw0(){                                                    // draw a big "0"
    DrawPx(3+x,2, levelColor); 
    DrawPx(3+x,3, levelColor);
    DrawPx(3+x,4, levelColor);
    DrawPx(3+x,5, levelColor);    
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,2, levelColor);
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);
    DrawPx(5+x,5, levelColor);
    DrawPx(5+x,6, levelColor);
  }


  void draw1(){                                                  // draw a big "1"
    DrawPx(3+x,2, levelColor); 
    DrawPx(3+x,5, levelColor); 
    DrawPx(4+x,2, levelColor); 
    DrawPx(4+x,3, levelColor); 
    DrawPx(4+x,4, levelColor); 
    DrawPx(4+x,5, levelColor); 
    DrawPx(4+x,6, levelColor); 
    DrawPx(5+x,2, levelColor);
  }

  void draw2(){                                                 // draw a big "2"
    DrawPx(3+x,2, levelColor); 
    DrawPx(3+x,3, levelColor);
    DrawPx(3+x,4, levelColor);
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,2, levelColor);
    DrawPx(4+x,4, levelColor);
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,4, levelColor);
    DrawPx(5+x,5, levelColor);
    DrawPx(5+x,6, levelColor);
  }
  
  void draw3(){
    DrawPx(3+x,2, levelColor);                                 // draw a big "3"
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,2, levelColor);
    DrawPx(4+x,4, levelColor);
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);
    DrawPx(5+x,5, levelColor);
    DrawPx(5+x,6, levelColor);
  }
  
  void draw4(){
    DrawPx(3+x,4, levelColor);                                 // draw a big "4"
    DrawPx(3+x,5, levelColor);
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,4, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);
    DrawPx(5+x,5, levelColor);
    DrawPx(5+x,6, levelColor);
  }
  
  void draw5(){
    DrawPx(3+x,2, levelColor);                                // draw a big "5"
    DrawPx(3+x,4, levelColor);
    DrawPx(3+x,5, levelColor);
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,2, levelColor);
    DrawPx(4+x,4, levelColor);
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);
    DrawPx(5+x,6, levelColor);
  }
  
  void draw6(){
    DrawPx(3+x,2, levelColor);                                // draw a big "6"
    DrawPx(3+x,3, levelColor);
    DrawPx(3+x,4, levelColor);
    DrawPx(3+x,5, levelColor);
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,2, levelColor);
    DrawPx(4+x,4, levelColor);
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);
    DrawPx(5+x,6, levelColor);
  }
    
  void draw7(){
    DrawPx(3+x,6, levelColor);                                // draw a big "7"
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);    
    DrawPx(5+x,5, levelColor);
    DrawPx(5+x,6, levelColor);
  }
    
    void draw8(){
    DrawPx(3+x,2, levelColor);                                // draw a big "8"
    DrawPx(3+x,3, levelColor);
    DrawPx(3+x,4, levelColor);
    DrawPx(3+x,5, levelColor);    
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,2, levelColor);
    DrawPx(4+x,4, levelColor);
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);
    DrawPx(5+x,5, levelColor);
    DrawPx(5+x,6, levelColor);
}

  void draw9(){
    DrawPx(3+x,4, levelColor);                               // draw a big "9"
    DrawPx(3+x,5, levelColor);
    DrawPx(3+x,6, levelColor);
    DrawPx(4+x,4, levelColor);
    DrawPx(4+x,6, levelColor);
    DrawPx(5+x,2, levelColor);
    DrawPx(5+x,3, levelColor);
    DrawPx(5+x,4, levelColor);    
    DrawPx(5+x,5, levelColor);
    DrawPx(5+x,6, levelColor);
    }
    
  void bigX()                                                //draw a crazy big "X"
{
  ClearSlate();
  DrawPx(0,0,xcolor);
  DrawPx(0,1,xcolor);
  DrawPx(0,2,xcolor);
  DrawPx(0,3,xcolor);
  DrawPx(0,4,xcolor);
  DrawPx(0,5,xcolor);
  DrawPx(0,6,xcolor);
  DrawPx(0,7,xcolor);

  DrawPx(1,0,xcolor);
  DrawPx(2,0,xcolor);
  DrawPx(3,0,xcolor);
  DrawPx(4,0,xcolor);
  DrawPx(5,0,xcolor);
  DrawPx(6,0,xcolor);
  DrawPx(7,0,xcolor);

  DrawPx(1,7,xcolor);
  DrawPx(2,7,xcolor);
  DrawPx(3,7,xcolor);
  DrawPx(4,7,xcolor);
  DrawPx(5,7,xcolor);
  DrawPx(6,7,xcolor);

  DrawPx(1,1,xcolor);
  DrawPx(2,2,xcolor);
  DrawPx(3,3,xcolor);
  DrawPx(4,4,xcolor);
  DrawPx(5,5,xcolor);
  DrawPx(6,6,xcolor);

  DrawPx(6,1,xcolor);
  DrawPx(5,2,xcolor);
  DrawPx(4,3,xcolor);
  DrawPx(3,4,xcolor);
  DrawPx(2,5,xcolor);
  DrawPx(1,6,xcolor);

  DrawPx(7,0,xcolor);
  DrawPx(7,1,xcolor);
  DrawPx(7,2,xcolor);
  DrawPx(7,3,xcolor);
  DrawPx(7,4,xcolor);
  DrawPx(7,5,xcolor);
  DrawPx(7,6,xcolor);
  DrawPx(7,7,xcolor);

  DisplaySlate();
  delay(xwait);
  ClearSlate();
}

void titleScreen()                                           //the logo titlescreen with intro tune
{
  dotX = 3;                                                  //reset our variables
  dotY = 3;
  sunX = 6;
  sunY = 1;
  rainX = 0;
  rainY = 7;
  rain2X = 0;
  rain2Y = 0;
  rainOld = 0;
  auxval = 0;
  sunny = 1;
  level = 1;                                                //change this level number to start @ a different level
  sunshine = CustomColor0;
  rainfall = 8;
  x = 0;
  i = 0;
  count = 0;

  SetAuxLEDs(auxval);                                       // reset score after game over

  Tone_Start(ToneC4, 200);
  DrawPx(0, 5, Blue);                                      // draw a blue "D"
  DrawPx(0, 4, Blue);
  DrawPx(0, 3, Blue);
  DrawPx(0, 2, Blue);
  DrawPx(1, 5, Blue);
  DrawPx(1, 2, Blue);
  DrawPx(2, 4, Blue);
  DrawPx(2, 3, Blue);
  DisplaySlate();
  delay(200);

  Tone_Start(ToneE3, 400);
  DrawPx(0, 5, DimBlue);                                  // draw a dim blue "D"
  DrawPx(0, 4, DimBlue);
  DrawPx(0, 3, DimBlue);
  DrawPx(0, 2, DimBlue);
  DrawPx(1, 5, DimBlue);
  DrawPx(1, 2, DimBlue);
  DrawPx(2, 4, DimBlue);
  DrawPx(2, 3, DimBlue);
  DisplaySlate();
  delay(400);

  Tone_Start(ToneC4, 200);
  DrawPx(3, 3, Violet);                                 // draw a violet "o"
  DrawPx(4, 2, Violet);
  DrawPx(4, 4, Violet);
  DrawPx(5, 3, Violet);
  DisplaySlate();
  delay(200);

  Tone_Start(ToneE3, 400);
  DrawPx(3, 3, DimViolet);                              // draw a dim violet "o"
  DrawPx(4, 2, DimViolet);
  DrawPx(4, 4, DimViolet);
  DrawPx(5, 3, DimViolet);
  DisplaySlate();
  delay(400);

  Tone_Start(ToneC4, 200);
  DrawPx(5, 5, Blue);                                  // draw a blue "T"
  DrawPx(6, 2, Blue);
  DrawPx(6, 3, Blue);
  DrawPx(6, 4, Blue);
  DrawPx(6, 5, Blue);
  DrawPx(7, 5, Blue);
  DisplaySlate();
  delay(200);

  Tone_Start(ToneG3, 400);
  DrawPx(5, 5, DimBlue);                              // draw a dim blue "T"
  DrawPx(6, 2, DimBlue);
  DrawPx(6, 3, DimBlue);
  DrawPx(6, 4, DimBlue);
  DrawPx(6, 5, DimBlue);
  DrawPx(7, 5, DimBlue);
  DisplaySlate();
  Tone_Start(ToneFs3, 200);
  delay(200);
  Tone_Start(ToneF4, 800);

  ClearSlate();

  while (!Button_A){                                //wait for player to push the A button
    CheckButtonsDown();

  }
}

void gameOver()                                    //game over - sorry, please try again 
{
  xcolor = DimRed;
  xwait = 100;
  bigX();
  Tone_Start(ToneG3, 400);
  xcolor = Red;
  xwait = 200;
  bigX();
  xcolor = Orange;
  xwait = 200;    
  bigX();
  Tone_Start(ToneF3, 400);
  xcolor = Yellow;
  xwait = 200;
  bigX();
  xcolor = DimYellow;
  xwait = 200;
  bigX();
  Tone_Start(ToneD3, 400);
  xcolor = DimOrange;
  xwait = 200;
  bigX();

  xcolor = DimRed;
  xwait = 200;
  bigX();
  Tone_Start(ToneC3, 1600);
  xcolor = Red;
  xwait = 1600;
  bigX();

  resetGame();
}



void resetGame(){                                    //reset the game
  titleScreen();
  levelScreen();
}


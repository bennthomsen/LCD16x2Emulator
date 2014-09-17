/**
 * 16x2 LCD Emulator 
 * 
 * 
 */

// The next line is needed if running in JavaScript Mode with Processing.js
/* @pjs preload="/Users/bthomsen/Documents/MSP430/sh-lcd-top_large.jpg"; */

import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
DropdownList d1;

int serialRef = 0;

String portName;
Serial myPort;      // The serial port
int whichKey = -1;  // Variable to hold keystoke values
char inByte = 0;    // Incoming serial data
boolean serialActive = false;

int Xorigin = 70;
int Line1Y = 115;
int Cursor1Y = 120;
int CursorLength = 18;
int LineSpace = 40;
int CharSpace = 23;
int switchSize = 10;
int cursorCol = 0;
int cursorRow = 0;

int[] bgColor = {
  34, 43, 72
};

int[][] buttons = {
  {
    36, 269
  }
  , {
    124, 269
  }
  , {
    80, 246
  }
  , {
    80, 285
  }
  , {
    167, 269
  }
  , {
    417, 247
  }
};
int buttonState = 0;

String[] buttonLabel = {
  "Left", "Right", "Up", "Down", "Select", "Reset"
};
boolean cursorState = false;

boolean overLeft = false;
boolean overRight = false;
int cols = 16;
int rows = 2;
char[][] displayChars = new char[cols][rows];

PImage bg;

void setup() {

  cp5 = new ControlP5(this);
  cp5.setControlFont(new ControlFont(createFont("Arial", 12), 12));
  // create a DropdownList
  d1 = cp5.addDropdownList("myList-d1")
    .setPosition(200, 40)
      ;
      printArray(Serial.list());
  customize(d1, Serial.list());
  // Set the port number to the one corresponding to your device.



  size(480, 307);
  textSize(30);
  //  PFont myFont = createFont(PFont.list()[2], 14);
  //  textFont(myFont);
  // The background image must be the same size as the parameters
  // into the size() method. In this program, the size of the image
  // is 640 x 360 pixels.
  bg = loadImage("sh-lcd-top_large.jpg");
}

void draw() {
  background(bg);
  //  text("123456789ABCDEF", 55, 115);
  //  text("123456789ABCDEF", 55, 155);
  for (int j = 0; j < rows; j = j+1) {
    for (int i = 0; i < cols; i = i+1) {
      writeLCDChar(displayChars[i][j], i, j);
    }
  }
  textCursor(cursorCol, cursorRow);


  cursorState = false;
  for (int i = 0; i < 6; i = i+1) {
    if (mouseX > buttons[i][0]-switchSize && mouseX < buttons[i][0]+switchSize && 
      mouseY > buttons[i][1]-switchSize && mouseY < buttons[i][1]+switchSize) {
      cursorState = true;
      if (mousePressed) ellipse(buttons[i][0], buttons[i][1], 20, 20);
    }
  }
  if (cursorState) cursor(HAND);
  else cursor(ARROW);
  //  println(mouseX + ", " +mouseY);
  //ellipse(left[0],left[1],20,20);
}

void serialEvent(Serial myPort) {
  inByte = char(myPort.read());
  switch (inByte) {
  case 14: 
    moveCursorLeft();
    break;
  case 15: 
    moveCursorRight();
    break;
  case 16: 
    moveCursorUp();
    break;
  case 17: 
    moveCursorDown();
    break;
  case 18: 
    println("Select");
    break;
  case BACKSPACE:
    moveCursorLeft();
    displayChars[cursorCol][cursorRow] = 0;
    break;
  default:
    displayChars[cursorCol][cursorRow] = inByte;
    moveCursorRight();
    break;
  }
}

void writeLCDChar(char character, int x, int y) {

  if (character != 0) {
    textAlign(CENTER);
    text(character, Xorigin + x * CharSpace, Line1Y + y * LineSpace);
  }
}

void mouseClicked() {
  for (int i = 0; i < 6; i = i+1) {
    if (mouseX > buttons[i][0]-switchSize && mouseX < buttons[i][0]+switchSize && 
      mouseY > buttons[i][1]-switchSize && mouseY < buttons[i][1]+switchSize) {
      buttonState = i+1;
      println(buttonLabel[i] + " clicked");
    }
  }
  if (serialActive) {
    switch(buttonState) {
    case 0: 
      break;
    case 1: 
      //moveCursorLeft();
      myPort.write(14);
      break;
    case 2: 
      //moveCursorRight();
      myPort.write(15);
      break;
    case 3: 
      //moveCursorUp();
      myPort.write(16);
      break;
    case 4: 
      //moveCursorDown();
      myPort.write(17);
      break;
    case 5: 
      myPort.write(18);
      break;
    }
  } else {
    switch(buttonState) {
    case 0: 
      break;
    case 1: 
      moveCursorLeft();
      break;
    case 2: 
      moveCursorRight();
      break;
    case 3: 
      moveCursorUp();
      break;
    case 4: 
      moveCursorDown();
      break;
    }
  }
  buttonState = 0;
}

void mousePressed() {
  for (int i = 0; i < 6; i = i+1) {
    if (mouseX > buttons[i][0]-switchSize && mouseX < buttons[i][0]+switchSize && 
      mouseY > buttons[i][1]-switchSize && mouseY < buttons[i][1]+switchSize) {
      ellipse(buttons[i][0], buttons[i][1], 20, 20);
    }
    //while (mousePressed);
  }
}

void textCursor(int x, int y) {
  strokeWeight(2);
  stroke(255);
  line(Xorigin-10 + x * CharSpace, Cursor1Y + y * LineSpace, Xorigin-10 + CursorLength + x * CharSpace, Cursor1Y + y * LineSpace);
}

void keyTyped() {
  if (serialActive) myPort.write(char(key));
    else {
  if (key == BACKSPACE) {
    moveCursorLeft();
    displayChars[cursorCol][cursorRow] = 0;
  } else {
      displayChars[cursorCol][cursorRow] = key;
      moveCursorRight();
    }
  }
}

void moveCursorLeft() {
  if (--cursorCol < 0) {
    cursorCol = 15;
    if (++cursorRow > 1) cursorRow = 0;
  }
}

void moveCursorRight() {
  if (++cursorCol == 16) {
    cursorCol = 0;
    if (++cursorRow > 1) cursorRow = 0;
  }
}

void moveCursorUp() {
  if (--cursorRow < 0) cursorRow = 1;
}

void moveCursorDown() {
  cursorRow = ++cursorRow % 2;
}

void customize(DropdownList ddl, String[] items ) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setWidth(250);
  ddl.setHeight((items.length+1)*20);
  ddl.setBarHeight(20);
  ddl.captionLabel().set("Select Serial Port");
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 3;
  ddl.valueLabel().style().marginTop = 3;
  for (int i=0; i<items.length; i++) {
    ddl.addItem(items[i], i);
  }
  //ddl.scroll(0);
  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}

void controlEvent(ControlEvent theEvent) {
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.

  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    serialRef = int(theEvent.getGroup().getValue());
    String portName = Serial.list()[serialRef];
    myPort = new Serial(this, portName, 9600);
    serialActive = true;
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
  } else if (theEvent.isController()) {

    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
}


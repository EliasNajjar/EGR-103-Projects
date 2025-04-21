#include <Stepper.h>

const int stepsPerRevolution = 2052; //Defines a rotation
int rotate = 0;                      //Asssign Rotate

Stepper myStepper = Stepper(stepsPerRevolution, 8, 10, 9, 11);  //Define the Stepper

void setup() {
  Serial.begin(9600);
  myStepper.setSpeed(10); //Set speed
}

void loop() {
if (Serial.available() > 0 ) {      // Check for communication
  rotate = Serial.parseInt();       // Take number communicated and assign to rotate
  myStepper.step(rotate);           // Run the stepper for rotate amount
  rotate = 0;                       //Reassign rotate to 0 before the relooping
}
}
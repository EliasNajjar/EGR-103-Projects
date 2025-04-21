#include <Stepper.h>

const int stepsPerRevolution = 2052;

String stepper_1;
String stepper_1_steps;
String stepper_2;
String stepper_2_steps;

Stepper myStepper1 = Stepper(stepsPerRevolution, 8, 10, 9, 11);
Stepper myStepper2 = Stepper(stepsPerRevolution, 4, 6, 5, 7);

void setup() {
  Serial.begin(9600);
  myStepper1.setSpeed(10);
  myStepper2.setSpeed(10);

}

void loop() {
  if (Serial.available() > 0) {
    stepper_1 = Serial.readStringUntil(',');
    stepper_1_steps = Serial.readStringUntil(',');
    int steps_for_stepper_1 = stepper_1_steps.toInt();

    myStepper1.step(steps_for_stepper_1);
    steps_for_stepper_1 = 0;

    stepper_2 = Serial.readStringUntil(',');
    stepper_2_steps = Serial.readStringUntil(',');
    int steps_for_stepper_2 = stepper_2_steps.toInt();

    myStepper2.step(steps_for_stepper_2);
    steps_for_stepper_2 = 0;
  }
}

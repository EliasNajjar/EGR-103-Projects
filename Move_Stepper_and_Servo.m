clc;
clear;
clear s
% Establish connections
s = serialport('COM3',9600);     %Your COM port is likely different. Make sure to watch the above video to see how to find where each board is
a = arduino('COM4');                 %Your COM port is likely different. Make sure to watch the above video to see how to find where each board is
pause(2);   %Pause for 2 seconds to allow the connection to the serial port to be established
% Initialize Servo. We usually say s = servo, but since we already have s = serialport, we have to use a different variable name. So, we'll use "servo".
servo = servo(a,'D9','MinPulseDuration',700*10^-6,'MaxPulseDuration',2300*10^-6);                                                                                                                                                                                                                                                                                                                        
writePosition(servo, 0); %Tell the Servo to go to its 0 Position (So we know where its starting from)
% When sending a string to control multiple steppers, the format should be
% as follows "Stepper #1, Steps for Stepper 1 to move, Stepper #2, Steps
% for Stepper 2 to move". If you have changed the Arduino IDE code to allow
% for additional steppers (i.e., 3 or more), then you would continue this
% format to account for your additional stepper motors.
% Have the first stepper do a full rotation while the second stepper does nothing
steps_for_1 = 2052;
steps_for_2 = 0;
% Point the Servo at the first stepper (0.4 worked for the testing of this code, but you will likely have to change it to whatever works for you)
writePosition(servo, 0.4);
% Append combines the various strings into one individual string to be sent over to the Arduino
Multiple_Stepper_String = append("1,",int2str(steps_for_1),",","2,",int2str(steps_for_2));
% Send the string to the Arduino using the connected serial port
write(s,Multiple_Stepper_String,'string');
% Pause to allow the previous movements to complete before sending new movements
pause(7)

% Have the first stepper do nothing while the second stepper does a full rotation
steps_for_1 = 0;
steps_for_2 = 2052;
% Point the Servo at the second stepper (0.85 worked for the testing of this code, but you will likely have to change it to whatever works for you)
writePosition(servo, 0.85);
% Append combines the various strings into one individual string to be sent
% over to the Arduino
Multiple_Stepper_String = append("1,",int2str(steps_for_1),",","2,",int2str(steps_for_2));
% Send the string to the Arduino using the connected serial port
write(s,Multiple_Stepper_String,'string');
% Pause to allow the previous movements to complete before sending new movements
pause(7)
% Move the servo back to the starting position
writePosition(servo, 0);
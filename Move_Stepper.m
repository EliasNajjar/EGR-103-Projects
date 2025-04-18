close all force
clear
clc

pause(5);
s = serialport('COM4',9600);
pause(5);
steps_for_1 = -300;
% Append combines the various strings into one individual string to be sent over to the Arduino
Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
% Send the string to the Arduino using the connected serial port
write(s,Multiple_Stepper_String,'string');
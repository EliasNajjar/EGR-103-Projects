clc;         %Clear the command window

clear;      %Clear the workspace

clear s;   %Clear any existing connections to the serial port

s = serialport('COM3',9600);      %Establish a connection to the serial port on COM3. Remember to check which COM your board is on

pause(2);  %Pause for 2 seconds to allow the connection to be established

 

distance = 2052;    %Assign a value of 2052 steps to the variable distance. Remember, this will make the stepper do one full rotation.

write(s,int2str(distance),'string');   %Convert distance from an integer to a string (using int2str) and write it to s (serial port) as a string
                                       %value

pause(5);  %Pause for 5 seconds to allow the stepper to complete the movement. In the case of this assignment, 5 seconds is enough time
           %for the previous movement to finish. IF YOU CHANGE THE DISTANCE TO MORE THAN 2052 STEPS THEN YOU
           %NEED TO ALSO INCREASE THE LENGTH OF THE PAUSE. If you send another signal to the stepper
           %before it is finished moving, it will cause it to not work properly.

 

distance = -2052;    %Assign a value of -2052 steps to the variable distance. Remember, this will make the stepper do one full rotation in
                     %the opposite direction.

write(s,int2str(distance),'string');   %Convert distance from an integer to a string (using int2str) and write it to s (serial port) as a string
                                       %value
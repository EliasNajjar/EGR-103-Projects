clear

%cam = webcam(2);

a = arduino('COM3');
a2 = arduino('COM4');

clear

tower = serialport('COM4',9600);
steps_for_1 = -300;
% Append combines the various strings into one indserividual string to be sent over to the Arduino
Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
% Send the string to the Arduino using the connected serial port
write(tower,Multiple_Stepper_String,'string');


%{
other = serialport('COM3',9600);
steps_for_1 = 50;
% Append combines the various strings into one individual string to be sent over to the Arduino
Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
% Send the string to the Arduino using the connected serial port
write(other,Multiple_Stepper_String,'string');
%}

%{
servoMotor = servo(a2, 'D9', 'MinPulseDuration', 700e-6, 'MaxPulseDuration', 2300e-6);
writePosition(servoMotor, 0);
pause(1)
writePosition(servoMotor, 1);
pause(1)
%}

%{
servoMotor = servo(a, 'D11', 'MinPulseDuration', 700e-6, 'MaxPulseDuration', 2300e-6);
writePosition(servoMotor, 0);
pause(1)
writePosition(servoMotor, 1);
pause(1)
%}

%{
servoMotor = servo(a2, 'D12', 'MinPulseDuration', 700e-6, 'MaxPulseDuration', 2300e-6);
writePosition(servoMotor, 0);
pause(1)
writePosition(servoMotor, 1);
pause(1)
%}
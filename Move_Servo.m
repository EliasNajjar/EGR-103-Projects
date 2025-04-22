close all force
clear
clc

a = arduino('COM6');
%servoMotor = servo(a, 'D9', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
rackPinion = servo(a, 'D11', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2600*10^-6);
pause(1);
writePosition(rackPinion,0)
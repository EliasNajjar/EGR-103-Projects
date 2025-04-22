close all force
clear
clc

s = serialport('COM4',9600);
pause(5);
steps_for_1 = 200;
write(s, int2str(steps_for_1),'string');
pause(5);
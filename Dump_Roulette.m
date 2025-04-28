close all force
clear
clc

a1 = arduino('COM3', 'Uno', 'Libraries', 'Servo');
pause(2);
dumpServo = servo(a1, 'D11', 'MinPulseDuration', 700e-6, 'MaxPulseDuration', 2300e-6);
writePosition(dumpServo,1);

Pos6Rand=randi(4);
if Pos6Rand==2
    %fprintf('Position 8 has been dumped \n');
    pause(5);
    writePosition(dumpServo, 0);
    pause(1);
    writePosition(dumpServo, 1);
end
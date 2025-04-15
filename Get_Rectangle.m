close all force
clear
clc
%%
camList = webcamlist % finds webcams
%%
cam = webcam(2); % USB cam is the second
preview(cam); % shows video
pause(1);

image = snapshot(cam);

% this will make your picture appear on the screen.
imshow(image)

roi4dice=round(getPosition(imrect)); % to find the region of interest
disp(roi4dice)
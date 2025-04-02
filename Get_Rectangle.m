close all force
clear
clc
%%
camList = webcamlist % finds webcams
%%
cam = webcam(2); % USB cam is the second
preview(cam); % shows video
for i=5:-1:1
    disp(i); % count down
    pause(1); % wait one second in between
end
image = snapshot(cam);

% this will make your picture appear on the screen.
imshow(image)

roi4dice=round(getPosition(imrect)); % to find the region of interest
disp(roi4dice)
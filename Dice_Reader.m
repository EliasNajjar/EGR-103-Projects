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

roi4dice = [141   154   216   141];
disp(roi4dice)

croppedImage=imcrop(image,roi4dice);
imshow(croppedImage);

r_channel=croppedImage(:,:,1);
g_channel=croppedImage(:,:,2);
b_channel=croppedImage(:,:,3);

imtool(croppedImage)

found = r_channel < 80 & g_channel < 80 & b_channel > 75;
Improved2=bwareaopen(found,25); % gets rid of object smaller than 5 pixels area
imshow(Improved2)

filledHoles=imfill(found,'holes');
imshow(filledHoles)

tableOfProp = regionprops('table',Improved2, 'BoundingBox');
NumberRolled=height(tableOfProp); % this command works on tables not matrix

roll = size(tableOfProp);
fprintf("You rolled %d",roll(1));
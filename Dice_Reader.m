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

roi4dice = [326   240    95    76];
disp(roi4dice)

croppedImage=imcrop(image,roi4dice);
imshow(croppedImage);

r_channel=croppedImage(:,:,1);
g_channel=croppedImage(:,:,2);
b_channel=croppedImage(:,:,3);

rg_ratio=double(r_channel)./double(g_channel);% red green ratio
rb_ratio=double(r_channel)./double(b_channel);% red blue ratio
gb_ratio=double(g_channel)./double(b_channel);% green blue ratio

rg_ratio(isnan(rg_ratio))=0;% if it is nan it sets it to zero
rb_ratio(isnan(rb_ratio))=0;% this should only happen if it is black
gb_ratio(isnan(gb_ratio))=0;

imtool(croppedImage)

found = rg_ratio < 1.5 & r_channel < 100 & g_channel < 100 & b_channel < 100;
Improved2=bwareaopen(found,18); % gets rid of object smaller than 5 pixels area
imshow(Improved2)

filledHoles=imfill(found,'holes');
imshow(filledHoles)

tableOfProp = regionprops('table',Improved2, 'BoundingBox');
NumberRolled=height(tableOfProp); % this command works on tables not matrix

roll = NumberRolled;
fprintf("You rolled %d",roll);
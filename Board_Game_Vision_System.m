%{
Board Game Vision System
Author:     Elias Najjar
Assignment: EGR 103-001
Changed:    3/4/2025

Purpose:
  Read an image for a dice roll and re-align the board
%}

close all
clear
clc
%%
% read in the image
image=imread('Homing Picture Example.jpg');

% this will make your picture appear on the screen.
imshow(image)
%%
%roi4dice=round(getPosition(imrect)); % to find the region of interest
%disp(roi4dice)
%%
croppingForRealign = [3,186,184,211];
croppedImage=imcrop(image,croppingForRealign);
imshow(croppedImage);
%%
% First I will get the values for each separated out:
r_channel=croppedImage(:,:,1);
g_channel=croppedImage(:,:,2);
b_channel=croppedImage(:,:,3);

% I create variables for the ratios
rg_ratio=double(r_channel)./double(g_channel);% red green ratio
rb_ratio=double(r_channel)./double(b_channel);% red blue ratio
gb_ratio=double(g_channel)./double(b_channel);% green blue ratio

rg_ratio(isnan(rg_ratio))=0;% if it is nan it sets it to zero
rb_ratio(isnan(rb_ratio))=0;% this should only happen if it is black
gb_ratio(isnan(gb_ratio))=0;

imtool(croppedImage)

found = rb_ratio <= .5;
ImprovedPic=bwareaopen(found,1000); % gets rid of object smaller than 1000 pixels area
imshow(ImprovedPic)

filledHoles=imfill(found,'holes');
imshow(filledHoles)

blue_overlay = imoverlay(croppedImage,filledHoles,[0,0,1]);
imshow(blue_overlay)

centroids = regionprops('table',filledHoles,'Centroid');
centroids = centroids{:,:};

figure, imshow(croppedImage), title('Centroids for Alignment Stickers')
hold on
    plot(centroids(:,1),centroids(:,2),'r+','MarkerSize',10,'LineWidth',2);
hold off

Centroid_Distance=sqrt(((centroids(3,1)-centroids(6,1))^2)+((centroids(3,2)-centroids(6,2))^2));
fprintf('The distance between centroids is %.2f pixels \n',Centroid_Distance);

% Now find the dice roll
croppingForDice = [512,216,89,82];
croppedImage=imcrop(image,croppingForDice);
imshow(croppedImage);

r_channel=croppedImage(:,:,1);
g_channel=croppedImage(:,:,2);
b_channel=croppedImage(:,:,3);

imtool(croppedImage)

found = r_channel < 50 & g_channel < 50 & b_channel < 50;
Improved2=bwareaopen(found,15); % gets rid of object smaller than 1000 pixels area
imshow(ImprovedPic)

filledHoles=imfill(found,'holes');
imshow(filledHoles)

tableOfProp = regionprops('table',Improved2, 'BoundingBox');
NumberRolled=height(tableOfProp); % this command works on tables not matrix
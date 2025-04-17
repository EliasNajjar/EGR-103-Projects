close all force
clear
clc

s = serialport('COM4',9600);
while true
    close all force
    clear cam
    cam = webcam(2);
    preview(cam); % shows video
    for i=5:-1:1
        disp(i); % count down
        pause(1); % wait one second in between
    end
    image = snapshot(cam);
    
    % this will make your picture appear on the screen.
    imshow(image)
    
    %roi4dice=round(getPosition(imrect)); % to find the region of interest
    %disp(roi4dice)
    
    croppingForRealign = [0 0 200 480];
    croppedImage=imcrop(image,croppingForRealign);
    imshow(croppedImage);
    
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
    
    found = rg_ratio < .85 & gb_ratio > 1.2;
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
    
    centroidslen = size(centroids);
    index = 1;
    for i = 1:centroidslen(1)
        edge = false;
        for x = -1:1
            for y = -1:1
                if ImprovedPic(round(centroids(index,2)+y),round(centroids(index,1)+x)) == false
                    edge = true;
                end
            end
        end
        if edge
            centroids(index,:) = [];
            index = index - 1;
        end
        index = index + 1;
    end
    centroidslen = size(centroids);

    if centroidslen(1) == 1
        pause(5);
        steps_for_1 = 1000;
        % Append combines the various strings into one individual string to be sent over to the Arduino
        Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
        % Send the string to the Arduino using the connected serial port
        write(s,Multiple_Stepper_String,'string');
        % Pause to allow the previous movements to complete before sending new movements
        pause(7)
        
    else
        Centroid_Distance=sqrt(((centroids(1,1)-centroids(2,1))^2)+((centroids(1,2)-centroids(2,2))^2));
        if Centroid_Distance < 110
            break;
        end
        fprintf('The distance between centroids is %.2f pixels \n',Centroid_Distance);
        pause(5);
        if centroids(2,1) > centroids(1,1)
            if centroids(2,2) < centroids(1,2)
                steps_for_1 = 4 * Centroid_Distance - 400;
            else
                steps_for_1 = -4 * Centroid_Distance + 400;
            end
        else
            if centroids(2,2) < centroids(1,2)
                steps_for_1 = -4 * Centroid_Distance + 400;
            else
                steps_for_1 = 4 * Centroid_Distance - 400;
            end
        end
        if abs(steps_for_1) < 50
            steps_for_1 = steps_for_1 * 3;
        end
        % Append combines the various strings into one individual string to be sent over to the Arduino
        Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
        % Send the string to the Arduino using the connected serial port
        write(s,Multiple_Stepper_String,'string');
        % Pause to allow the previous movements to complete before sending new movements
        pause(7)
    end
end
% NOTE ALL PROGRAMS START WITH A HEADER COMMENT.
% This program is to do a MATLAB scrip version of playing the board game
% This code was written starting January 8, 2024 by Dr. Julie Whitney
close all force
clear
clc
% ********************************************************************
% Initial set-up of the array that tracks the game
% *******************************************************************
% Start by creating the array which keeps track of where everything is.
% Instead of generating the board setup in MATLAB I created it in excel
% it is called StartingBoardSetup.xlsx. I will import it.
BoardSetup=readmatrix('StartingBoardSetup.xlsx');
% Create a fourth column that is the sum of columns 2 and 3 so that we know
% if a space is available
SpaceAvailable=(BoardSetup(:,2)+BoardSetup(:,3));
BoardSetup=[BoardSetup,SpaceAvailable];
% In this setup the position numbers are the first column, the postion of
% the red pieces are the second column and the position of the blue pieces
% are the third column.
%***********************************************************************
% SECTION 1 - Set score to zero and enter while loop
%***********************************************************************
% Start the game. We can limit the game by total number of turns or by some
% player getting all their pieces in to 'home'. This will be set up by
% number of turns. Right now I will limit that to 10.
ScorePlayer1=0;
ScorePlayer2=0;
turnNum=0;
%***********************************************************************
%***********************************************************************
%***********************************************************************
%
% Before you go into the while loop you want to do the following things:
% 1) Connect to any arduinos not running IDE. That code will look like
% a=arduino(uno,'COM3') depending on your com port.
% 2) set up your servos. That code will look something like
% s1 = servo(a, 'D9', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
% If you have more than one servo, each will have a different digital
% pin. If you have more than one Arduino running each will have a "name"
% like a1 and a2 and you want to associate the right name with the right
% servo.
% 3) set up your stepper connection code. Most likely you will be running
% IDE so that command will look like: s=serialport('COM6',9600); again
% depending on the com port that your steppers are on.
% 4) Connect to your camera. You do not need a webcam list, but you do
% need to identify your camera. That code will look like cam=webcam(3);
%
%
% 5) Home your game. This is the VISION SYSTEM person's code and your
% GAME STRUCTURE person's code. It should work like this:
% a) The vision code will take a photo that includes the
% alighnment markers.
% b) The vision code will process the image and determine if
% the markers are close enough together of if the game
% structure needs to rotate. VISION SYSTEM PERSON: for example
% code look at the slides from week 8 where we did image
% processing.
% c) Likely the GAME STRUCTURE person will need to initiate a
% move with a stepper motor to try to get the alignment better.
% That command will look like:
% distance = 2052;
% write(s,int2str(distance),'string');
% pause(5);
% Note that the pause is important after all stepper moves to
% allow the stepper to finish moving before Matlab moves on.
% d) repeat steps a-c until the distance is small enough that
% the system is considered "homed"
%
% If you are running multiple steppers off of the same board remember that
% you will be using a code more like:
%
% steps_for_1=260; %260 steps is 180 degrees for this servo
% steps_for_2=0; % Doesn't move stepper 2
%
% Multiple_Stepper_String=append("1,",int2str(steps_for_1),",","2,",int2str(steps_for_2));
% write(s,Multiple_Stepper_String,'string');
%
%
%*********************************************************************
%*********************************************************************
%*********************************************************************
previous_roll = 0;
roi4dice = [287 229 121 82];
croppingForRealign = [0 0 200 480];
cam = webcam(2); % USB cam is the second
s = serialport('COM5',9600);
% Connect to Arduino
swap = serialport('COM3',9600);
%swap2 = serialport(,9600);
a = arduino('COM6'); % Connect to Arduino using default port
% Attach standard servo to pin D9
servoMotor = servo(a, 'D9', 'MinPulseDuration', 700e-6, 'MaxPulseDuration', 2300e-6);
% Attach continuous rotation servo to pin D114
rackPinion = servo(a, 'D11', 'MinPulseDuration', 700e-6, 'MaxPulseDuration', 2700e-6);
%preview(cam); % shows video
stepsForOneSpace = 2052 / 7;

while turnNum<= 10
    % Check whose turn it is
    if rem(turnNum,2)==0 % Turn number is EVEN
        ColOfInterest=3;
        fprintf('Player 1, your turn, you are playing blue \n');
    else
        ColOfInterest=2;
        fprintf('Player 2, your turn, you are playing red \n');
    end
    % Let me see if I can make a bar graph of where everyone is.
    figure(1)
    b1=bar(BoardSetup(:,1),BoardSetup(:,2),'r');
    hold on
    b2=bar(BoardSetup(:,1),BoardSetup(:,3),'b');
    ylim([0 2]);
    title=('Starting Game Board');
    hold off
    % ******************************************************************
    % Section 2 - rolling the dice and checking for legal moves
    %*******************************************************************
    % now let me roll a dice and get a random value, integer between 1 and 6
    MoveComplete=0;
    if mod(turnNum,2) == 0
        roll = previous_roll;
        dice_removed = false;
        while (roll == previous_roll & ~dice_removed) || (roll == 0 & dice_removed) % go until dice is picked up, then rolled
            pause(5); % wait five seconds in between
            image = snapshot(cam);
            % this will make your picture appear on the screen.
            %imshow(image)
            croppedImage=imcrop(image,roi4dice);
            %imshow(croppedImage);
            r_channel=croppedImage(:,:,1);
            g_channel=croppedImage(:,:,2);
            b_channel=croppedImage(:,:,3);
            rg_ratio=double(r_channel)./double(g_channel);% red green ratio
            rb_ratio=double(r_channel)./double(b_channel);% red blue ratio
            gb_ratio=double(g_channel)./double(b_channel);% green blue ratio
            rg_ratio(isnan(rg_ratio))=0;% if it is nan it sets it to zero
            rb_ratio(isnan(rb_ratio))=0;% this should only happen if it is black
            gb_ratio(isnan(gb_ratio))=0;
            %imtool(croppedImage)
            found = rb_ratio < 1.4 & r_channel < 150 & g_channel < 150 & b_channel < 150;
            Improved2=bwareaopen(found,25); % gets rid of object smaller than 5 pixels area
            %imshow(Improved2)
            filledHoles=imfill(found,'holes');
            %imshow(filledHoles)
            tableOfProp = regionprops('table',Improved2, 'BoundingBox');
            NumberRolled=height(tableOfProp); % this command works on tables not matrix
            roll = size(tableOfProp);
            roll = roll(1);
            %fprintf("You rolled %d",roll(1));
            if roll == 0
                dice_removed = true;
                %disp("dice removed");
            end
        end
        if roll < 1 || roll > 6
            roll = randi(6);
        end
        previous_roll = roll;
        dice = roll;
    else
        dice=randi(6);
    end
    % realign

    while true
        image = snapshot(cam);
        croppedImage=imcrop(image,croppingForRealign);
        %imshow(croppedImage);
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
        %imtool(croppedImage)
        found = rg_ratio < .85 & gb_ratio > 1.2;
        ImprovedPic=bwareaopen(found,1000); % gets rid of object smaller than 1000 pixels area
        %imshow(ImprovedPic)
        filledHoles=imfill(found,'holes');
        %imshow(filledHoles)
        blue_overlay = imoverlay(croppedImage,filledHoles,[0,0,1]);
        %imshow(blue_overlay)
        centroids = regionprops('table',filledHoles,'Centroid');
        centroids = centroids{:,:};
        %{
figure, imshow(croppedImage), title('Centroids for Alignment Stickers')
hold on
plot(centroids(:,1),centroids(:,2),'r+','MarkerSize',10,'LineWidth',2);
hold off
        %}
        centroidslen = size(centroids);
        imageSize = size(ImprovedPic);
        index = 1;
        for i = 1:centroidslen(1)
            edge = false;
            for x = -1:1
                if centroids(index, 1) == 1 && x == -1
                    continue;
                end
                if centroids(index, 1) == imageSize(2) && x == -1
                    continue;
                end
                for y = -1:1
                    if centroids(index, 2) == 1 && y == -1
                        continue;
                    end
                    if centroids(index, 2) == imageSize(1) && y == 1
                        continue;
                    end
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
            steps_for_1 = 1000;
            % Append combines the various strings into one individual string to be sent over to the Arduino
            % Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
            % Send the string to the Arduino using the connected serial port
            write(s,int2str(steps_for_1),'string');
            % Pause to allow the previous movements to complete before sending new movements
            pause(5)
        else
            Centroid_Distance=sqrt(((centroids(1,1)-centroids(2,1))^2)+((centroids(1,2)-centroids(2,2))^2));
            if Centroid_Distance < 110
                break;
            end
            fprintf('The distance between centroids is %.2f pixels \n',Centroid_Distance);
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
            %Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
            % Send the string to the Arduino using the connected serial port
            write(s,int2str(steps_for_1),'string');
            % Pause to allow the previous movements to complete before sending new movements
            pause(5)
        end
    end
    %}
    pause(5);

    %**********************************************************************
    %**********************************************************************
    %**********************************************************************
    %
    % To test your device you will have one person rolling the dice for
    % real and the computer pretending to be the other person far away. That
    % far away dice roll is given by the command above: dice=randi(6);
    %
    % So whose turn is it? If it is the far away person then that dice roll is
    % the one you use. However if it is the person here locally, you want to
    % really roll the dice and get the real answer. Here is how you do that.
    %
    % 1) Use an "if" statement to determine whose turn it is, and if it is the
    % local players turn then you want to use the vision system to determine
    % the roll. Your if statement will look something like this:
    % if ColOfInterest==3
    % ***vision code stuff***
    % dice= ** the height of the bounding box ***
    % end
    %
    % **********************************************************************
    %***********************************************************************
    %***********************************************************************
    fprintf('dice rolled a %d \n', dice);
    %***********************************************************************
    % Now I want to find all the legal moves for the player given that dice
    % roll, and display them to that player
    %***********************************************************************
    % Regular moving a piece on the board forward
    %***********************************************************************
    opportunities=0;
    for i= 1:14
        checkPosition=i;
        possibleMove=i+dice; % the piece will be that many spaces from where the piece is now
        if BoardSetup(i,ColOfInterest)>=1
            if possibleMove >=14 % Past the last position on the board
                fprintf('Game piece in postion %d can move to home \n', checkPosition);
                opportunities=opportunities+1;
            elseif possibleMove<=13 % Not past the last position on the bard
                if BoardSetup(possibleMove,4)==0
                    fprintf('Game piece in position %d can move to position %d \n', checkPosition,possibleMove);
                    opportunities=opportunities+1;
                end
            end
        end
    end
    %***********************************************************************
    % check to see if the player can get a man out
    GamePiecesOut=sum(BoardSetup(:,ColOfInterest));
    if GamePiecesOut<4 && BoardSetup((dice+1),4)==0
        fprintf('You can start a new game piece \n');
        opportunities=opportunities+1;
    end
    %**********************************************************************
    % Check that there is a valid move for this player. If not turn passes to
    % next player.
    if opportunities==0
        fprintf('You have %d options, if that number is zero turn passes to next player. \n',opportunities);
        MoveComplete=1;
    end
    %****************************************************************
    % Section 3 - Move Pieces
    %****************************************************************
    while MoveComplete==0
        Piece2Move=input('Enter the position of the piece you want to move, if starting a game piece enter 1=> ');
        if BoardSetup(Piece2Move,ColOfInterest)==1 && (Piece2Move + dice)>=14
            BoardSetup(Piece2Move,ColOfInterest)=0;
            if ColOfInterest==3
                ScorePlayer1=ScorePlayer1+1;
                fprintf('Score! Player 1 score %d, Player 2 score %d. \n',ScorePlayer1, ScorePlayer2);
            else
                ScorePlayer2=ScorePlayer2+1;
                fprintf('Score! Player 1 score %d, Player 2 score %d. \n',ScorePlayer1, ScorePlayer2);
            end
            MoveComplete=1;
        elseif BoardSetup(Piece2Move,ColOfInterest)==1&& BoardSetup((Piece2Move+dice),4)==0
            fprintf('Valid Move, moving piece now \n');
            BoardSetup(Piece2Move,ColOfInterest)=0;
            NewPosition=Piece2Move+dice;
            BoardSetup(NewPosition,ColOfInterest)=1;
            MoveComplete=1;
        elseif Piece2Move==1 && BoardSetup((Piece2Move+dice),4)==0
            fprintf('Valid Move, moving piece now \n');
            BoardSetup(Piece2Move,ColOfInterest)=0;
            NewPosition=Piece2Move+dice;
            BoardSetup(NewPosition,ColOfInterest)=1;
            MoveComplete=1;
        else
            fprintf('Invalid Move, please try again \n');
            MoveComplete=0;
        end
    end
    BoardSetup(:,4)=(BoardSetup(:,2)+BoardSetup(:,3));
    %********************************************************************
    %********************************************************************
    %********************************************************************
    %
    % Here is where you actually move the game pieces. Moving the pieces will
    % require a rotation of the board or game piece mover by the GAME STRUCTURE
    % team member, and a lower/grab/lift and lower/release/rise from the GAME
    % PIECE MOVER team member.
    %
    % Here are those steps:
    % 1) The game position should start at HOME.
    % 2) The game piece mover should rotate from home to the position to pick
    % up the piece. That position is called Piece2Move in this code and it
    % is a number. You will need to determine how many steps your stepper
    % motor needs to move to get to that position. If the positions are
    % evenly spaced, you can do this by figuring out (partly by trial and
    % error) how many steps are between any two positions and then multiply
    % by the number of postions you need to go. However you do that if you
    % are using IDE to turn your stepper your code will look something like
    % this:
    %
    % distance = 2052;
    % write(s,int2str(distance),'string');
    % pause(5);
    %
    % 3) With the grabber open, up or otherwise set to get a piece, lower the
    % game piece mover to the board. This is likely a servo motor and the
    % code for that will look like: writePosition(s2, 0);
    % 4) Now close the gripper, engage the hook or otherwise grab the game
    % piece. Likely this is also a servo, but a differnt servo than you use
    % to raise and lower. It should have a different name but the movement
    % code is still the same format: writePosition(s1, 1);
    % 5) Now raise the game piece mover. Something like writePosition(s2, 0.5);
    % 6) Now rotate the game piece mover or board to the location where the
    % game piece will end up. The postion number will be equal to
    % Piece2Move+dice. Your distance in steps is just the distance between
    % where you are at the beginning of the move and where you are going.
    % That code will look something like:
    %
    % distance = 1000;
    % write(s,int2str(distance),'string');
    % pause(5);
    %
    % Remember you may be using multiple stepper code as discussed above and
    % so you code needs to be configured to send zero steps to the stepper
    % that is not suppose to move and the right number of steps to the one
    % that is suppose to move.
    %
    % 7) Now lower the game piece mover with a servo command something like
    % Something like writePosition(s2, 0);
    % 8) Now open or release the gripper to leave the game piece on the
    % board. Something like writePosition(s1, 0.5);
    % 9) Now raise the game piece mover out of the way. Something like
    % writePosition(s2, 1);
    % 10) At this point it is a good idea to take the game board back to the
    % home position. You want to do this by turning the stepper motor back
    % all of the steps you just took, but in the opposite direction. You do
    % that by using a negative for the distance.
    %
    %************************************************************************
    %************************************************************************
    %************************************************************************
    % move claw to piece
    steps_for_1 = stepsForOneSpace * (8.5 - Piece2Move);
    % Append combines the various strings into one individual string to be sent over to the Arduino
    %Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
    % Send the string to the Arduino using the connected serial port
    write(s,int2str(steps_for_1),'string');
    pause(5);
    %neutral = 0.49; % Adjust this based on testing
    %x = 0.047;
    % go down
    %writePosition(rackPinion, neutral + (0.28 * x));
    %pause(2);
    % Stop movement
    %writePosition(rackPinion, neutral);
    %pause(2);
    % Grab
    %writePosition(servoMotor, 0);
    %pause(2);
    % Stop movement
    %writePosition(rackPinion, neutral - 0.01);
    %pause(2);
    % go up
    %x = 0.066;
    %writePosition(rackPinion, neutral - (1.1 * x));
    %pause(2);
    %x = 0.0435;
    % Stop continuous rotation servo
    %writePosition(rackPinion, neutral);
    %pause(3);
    % move piece
    % Connect to Arduino
    %a = arduino("COM6"); % Connect to Arduino using default port
    % Attach servo motor to pin 9 (adjust pin number as per your setup)
    %servoMotor = servo(a, 'D9', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);
    %rackPinion = servo(a, 'D11', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2600*10^-6);
    desiredTimeRack = .5;
    desiredTimeClaw = .25;
    nSteps = 40; % number of increments
    dtRack = desiredTimeRack/nSteps;
    dtClaw = desiredTimeClaw/nSteps;
    writePosition(rackPinion, 0);
    pause(2);
    for p = linspace(0,1,nSteps)
        writePosition(rackPinion,p);
        pause(dtRack);
    end
    pause(2);
    % Rotate servo to 180 degrees
    % writePosition(servoMotor, 0);
    %pause(2);
    %writePosition(rackPinion, 1);
    %writePosition(servoMotor, 0);
    for p = linspace(.58,0,nSteps)
        writePosition(servoMotor,p);
        pause(dtClaw);
    end
    pause(2);
    %pause(6);
    for p = linspace(1,0,nSteps)
        writePosition(rackPinion,p);
        pause(dtRack);
    end
    %writePosition(rackPinion, 0);
    pause(7);

    % Disconnect from Arduino
    %%%clear servoMotor; % Clear servo object
    %%%clear rackPinion;
    %%%clear a; % Clear Arduino object
    steps_for_1 = -stepsForOneSpace * dice;
    % Append combines the various strings into one individual string to be sent over to the Arduino
    write(s, int2str(steps_for_1), 'string');
    %Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
    % Send the string to the Arduino using the connected serial port
    %write(s,Multiple_Stepper_String,'string');
    pause(5);
    for p = linspace(0,1,nSteps)
        writePosition(rackPinion,p);
        pause(dtRack);
    end
    %writePosition(rackPinion, 1);
    % Rotate servo back to original position (0 degrees)
    %pause(3);
    for p = linspace(0,.5,nSteps)
        writePosition(servoMotor,p);
        pause(dtClaw);
    end
    %writePosition(servoMotor, 0.5);
    pause(2);
    % Rotate servo back to original position (0 degrees)
    % writePosition(rackPinion, 1);
    writePosition(rackPinion, 0);
    % pause(12);
    % go down
    %x = 0.050;
    %writePosition(rackPinion, neutral + (0.25 * x));
    %pause(2);
    % Stop continuous rotation servo
    %writePosition(rackPinion, neutral);
    %pause(2);
    % Ungrab
    %writePosition(servoMotor, 0.5);
    %pause(2);
    % Stop continuous rotation servo
    %writePosition(rackPinion, neutral - 0.015);
    %pause(2);
    % go up
    %x = 0.066;
    %writePosition(rackPinion, neutral - (1.23 * x));
    %pause(2);
    % Stop continuous rotation servo
    %writePosition(rackPinion, neutral);
    % reset claw
    steps_for_1 = stepsForOneSpace * (dice + .5 + Piece2Move);
    % Append combines the various strings into one individual string to be sent over to the Arduino
    %Multiple_Stepper_String = append("1,",int2str(steps_for_1),",");
    % Send the string to the Arduino using the connected serial port
    write(s, int2str(steps_for_1),'string');
    pause(5);
    %**********************************************************************
    % Section 4 - SWAP AND DUMP
    %**********************************************************************
    %Check for trick spots in game board
    %Trick spots for this game board will be 3 & 4 can swap, 11 & 12 can swap
    %and 6&9 can both dump.
    %***************************************************************************
    %*************************************************************************
    %************************************************************************
    %
    %
    % Swap and Dump
    %
    % Below is the swap and dump code. You need to move the right motor if the
    % code gets inside the if statement. The places are shown in the actual
    % code below. A few notes:
    % 1) The code is set up to update the array keeping track of where pieces
    % are so you want to keep that code.
    % 2) The actual spots where your swap and dump stations are will be
    % differnt, so look carefully at how this code is indexed and update
    % that for your game.
    % 3) The code below generates a random number to determine whether or
    % not a spot is activated. Your criteria is probably different. For
    % the code below this will happen for each 1/4 of the time, which means
    % on average one of these will happen per turn because I have 4 of them below.
    %
    %
    %************************************************************************
    % SWAP
    %***********************************************************************
    Pos3Rand=randi(4); % Get a random number between 1 & 4
    if Pos3Rand==2
        %swap the pieces currently in positions 3 and 4
        if BoardSetup(4,4)==1 || BoardSetup(5,4)==1
            PlaceHolder=BoardSetup(4,2:3);
            BoardSetup(4,2:3)=BoardSetup(5,2:3);
            BoardSetup(5,2:3)=PlaceHolder;
            fprintf('swapped positions 4 and 5 \n');
            % **************************************************
            % **************************************************
            % Put your GAME BOARD stepper swap code here
            % make sure it is the right stepper for this spot
            % example stepper code is found above
            % **************************************************
            %***************************************************
            steps_for_1 = 2052 / 2;
            steps_for_2 = 0;
            % Append combines the various strings into one individual string to be sent over to the Arduino
            Multiple_Stepper_String = append("1,",int2str(steps_for_1),",","2,",int2str(steps_for_2));
            % Send the string to the Arduino using the connected serial port
            write(swap,Multiple_Stepper_String,'string');
            % Pause to allow the previous movements to complete before sending new movements
            pause(5);
        end
    end
    Pos11Rand=randi(4);
    if Pos11Rand==2
        %swap the pieces currently in positions 11 and 12
        if BoardSetup(11,4)==1 || BoardSetup(12,4)==1
            PlaceHolder=BoardSetup(11,2:3);
            BoardSetup(11,2:3)=BoardSetup(12,2:3);
            BoardSetup(12,2:3)=PlaceHolder;
            fprintf('swapped positions 11 & 12 \n');
            % **************************************************
            % **************************************************
            % Put your GAME BOARD stepper swap code here
            % make sure it is the right stepper for this spot
            % example stepper code can be found above
            % **************************************************
            %***************************************************
            steps_for_2 = 2052 / 2;
            steps_for_1 = 0;
            % Append combines the various strings into one individual string to be sent over to the Arduino
            Multiple_Stepper_String = append("1,",int2str(steps_for_1),",","2,",int2str(steps_for_2));
            % Send the string to the Arduino using the connected serial port
            write(swap,Multiple_Stepper_String,'string');
            % Pause to allow the previous movements to complete before sending new movements
            pause(5);
        end
    end
    %*********************************************************************
    % DUMP
    % ********************************************************************
    Pos6Rand=randi(4);
    if Pos6Rand==2
        % Dump the game piece and it goes back to start
        BoardSetup(8,2:3)=0;
        fprintf('Position 8 has been dumped \n');
        % **************************************************
        % **************************************************
        % Put your GAME BOARD servo dump code here
        % make sure it is the right servo for this spot
        % example servo code is found above
        % **************************************************
        %***************************************************
        a1 = arduino('COM4');
        dumpServo = servo(a1, 'D9', 'MinPulseDuration', 700e-6, 'MaxPulseDuration', 2300e-6);
        writePosition(dumpServo, .7);
        pause(1);
        writePosition(dumpServo, 0);
    end
    %***********************************************************************
    %***********************************************************************
    %************************************************************************
    %*******************************************************************
    % Put some visual space in so you can see which player is playing
    %
    fprintf('*************************************** \n \n \n');
    % *******************************************************************
    figure(2)
    b1=bar(BoardSetup(:,1),BoardSetup(:,2),'r');
    hold on
    b2=bar(BoardSetup(:,1),BoardSetup(:,3),'b');
    ylim([0 2]);
    hold off
    turnNum=turnNum+1;
    %********************************************************************
    % Check to see if one player has gotten all 4 game pieces to home
    %********************************************************************
    if ScorePlayer1==4 | ScorePlayer2==4
        turnNum=50; % if they have, declare a winner so set turns>10
    end
    %*******************************************************************
end
% *********************************************************************
% Declare a winner!
% ******************************************************************
fprintf('Game Over! Player 1 has %d goals, Player 2 has %d goals! \n',ScorePlayer1, ScorePlayer2);
% NOTE ALL PROGRAMS START WITH A HEADER COMMENT.  
% This program is to do a MATLAB scrip version of playing the board game
% This code was written starting January 8, 2024 by Dr. Julie Whitney and
% was edited by Dr. Danny Francis during Fall 2024 Semester.
clear all
clc
% ********************************************************************
% Use Image Processing to find the Spots on Our Example Board (IMAGE
% PROCESSING IS DONE TO SHOW THE VISUAL OF THE BOARD AND THE PROCESSING
% SHOWN HERE IS NOT NECESSARY FOR YOUR PROJECTS)
% *******************************************************************
I = imread('Game Board.png');
% Find circles on the board with a radius range of 10-50 pixels
[centers_game,radii_game] = imfindcircles(I,[10,50],"ObjectPolarity","dark");
% Find the width and height of our image (example board) in pixels
width = size(I,2);
height = size(I,1);
% Shift the image so the origin is at the middle of the image rather than
% the top left as MATLAB defaults to
centers_game_x_origin = centers_game(:,1) - width/2;
centers_game_y_origin = (height/2) - centers_game(:,2);
% Normalize the shifted X and Y pixel locations
Norm_x = normalize(centers_game_x_origin);
Norm_y = normalize(centers_game_y_origin);
% Find angles of the middle of each circle using Unit Circle
Angles = atan2(Norm_y,Norm_x);
% Organize the spots around the circle based on their angles
Spots_with_angles = [centers_game,radii_game,Angles];
Sorted_Spots = sortrows(Spots_with_angles,-4);

%remove the angles column after sorting
Sorted_Spots(:,4) = [];
% Save as the variable "Space_Info" which is now an ordered (around the
% circle) array of our spots. Ordering is clockwise and spot #1 is about
% 9:30 on the board. 
Space_info = Sorted_Spots;

% ********************************************************************
% Put Annotations on the Board
% *******************************************************************
Labeled_Board = insertText(I,[45 240],"1","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[95 142],"2","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[190 65],"3","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[332.0973 25],"4","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[480 65],"5","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[570 142],"6","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[620 240],"7","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[620 400],"8","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[570 505],"9","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[480 590],"10","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[332.0973 630],"11","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[185 590],"12","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[90 505],"13","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[40 400],"14","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[305 220],"SWAP","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[305 440],"SWAP","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[470 240],"DUMP","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[470 420],"DUMP","BoxOpacity",0,"FontSize",35,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[95 275],"Start","BoxOpacity",0,"FontSize",22,"AnchorPoint","Center");
Labeled_Board = insertText(Labeled_Board,[95 385],"Home","BoxOpacity",0,"FontSize",22,"AnchorPoint","Center");
% ********************************************************************
% Initial set-up of the array that tracks the game
% *******************************************************************

% Start by creating the array which keeps track of where everything is.

% Instead of generating the board setup in MATLAB I created it in excel
% it is called StartingBoardSetup.xlsx.  I will import it. 
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
% player getting all their pieces in to 'home'.  This will be set up by
% number of turns.  Right now I will limit that to 10.
ScorePlayer1=0;
ScorePlayer2=0;
turnNum=0;
while turnNum<= 10
    % Check whose turn it is
    if rem(turnNum,2)==0 % Turn number is EVEN
        ColOfInterest=3;
        fprintf('Player 1, your turn, you are playing blue \n');
    else
        ColOfInterest=2;
        fprintf('Player 2, your turn, you are playing red \n');
    end

% Find locations in the array where Player 1 is
player_1_position = find(BoardSetup(:,3) == 1);
% Find locations in the array where Player 2 is
player_2_position = find(BoardSetup(:,2) == 1);
% Pull game board spot information (center and radius) so we know where to
% indicate Player 1 is
player_1_pieces = (Space_info((player_1_position),:));
% Pull game board spot information (center and radius) so we know where to
% indicate Player 2 is
player_2_pieces = (Space_info((player_2_position),:));

% Use insertShape to insert red and blue circles at the corresponding
% locations for Players 1 and 2
game_pieces_1 = insertShape(Labeled_Board,"filled-circle",player_1_pieces,"Color",'blue',"Opacity",1);
game_pieces_both = insertShape(game_pieces_1,"filled-circle",player_2_pieces,"Color",'red',"Opacity",1);
imshow(game_pieces_both)

% Add arrows to indicate dump and swap spots
% Swap spot 3 and 4 arrows
annotation('textarrow',[.44 .39],[.7 .78])
annotation('textarrow',[.5 .5],[.7 .8])
% Dump spot 6 arrow
annotation('textarrow',[.67 .695],[.67 .695])
% Dump spot 9 arrow
annotation('textarrow',[.66 .69],[.38 .35])
% Swap spot 11 and 12 arrows
annotation('textarrow',[.47 .405],[.35 .265])
annotation('textarrow',[.5 .5],[.35 .25])

% ******************************************************************
%  Section 2 - rolling the dice and checking for legal moves
%*******************************************************************

% now let me roll a dice and get a random value, integer between 1 and 6
MoveComplete=0;
dice=randi(6);
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
    if BoardSetup(i,ColOfInterest)>=1;
        if possibleMove >=14 % Past the last position on the board
                fprintf('Game piece in postion %d can move to home \n', checkPosition);
                opportunities=opportunities+1;
        elseif possibleMove<=13; % Not past the last position on the bard
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
%MoveComplete==1;
end
%****************************************************************
% Section 3 - Move Pieces
%****************************************************************

while MoveComplete==0
Piece2Move=input('Enter the position of the piece you want to move, if starting a game piece enter 1  \n ');
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
elseif BoardSetup(Piece2Move,ColOfInterest)==1&& BoardSetup((Piece2Move+dice),4)==0;
    fprintf('Valid Move, moving piece now \n');
    BoardSetup(Piece2Move,ColOfInterest)=0;
    NewPosition=Piece2Move+dice;
    BoardSetup(NewPosition,ColOfInterest)=1;
    MoveComplete=1;
elseif Piece2Move==1 && BoardSetup((Piece2Move+dice),4)==0;
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

%**********************************************************************
% Section 4 - SWAP AND DUMP
%**********************************************************************
%Check for trick spots in game board
%Trick spots for this game board will be 3 & 4  can swap, 11 & 12 can swap
%and 6&9 can both dump.  

% this will happen for each 1/4 of the time, which means on average one of
% these will happen per turn. 
%************************************************************************
% SWAP
%***********************************************************************
Pos3Rand=randi(4); % Get a random number between 1 & 4
if Pos3Rand==2
    %swap the pieces currently in positions 3 and 4
    if BoardSetup(3,4)==1 | BoardSetup(4,4)==1;
        PlaceHolder=BoardSetup(3,2:3);
        BoardSetup(3,2:3)=BoardSetup(4,2:3);
        BoardSetup(4,2:3)=PlaceHolder;
        fprintf('swapped positions 3 and 4 \n');
    end
end

Pos11Rand=randi(4);
if Pos11Rand==2
    %swap the pieces currently in positions 11 and 12
    if BoardSetup(11,4)==1 | BoardSetup(12,4)==1;
        PlaceHolder=BoardSetup(11,2:3);
        BoardSetup(11,2:3)=BoardSetup(12,2:3);
        BoardSetup(12,2:3)=PlaceHolder;
        fprintf('swapped positions 11 & 12 \n');
    end
end

%*********************************************************************
% DUMP
% ********************************************************************
Pos6Rand=randi(4);
if Pos6Rand==2
    % Dump the game piece and it goes back to start
    BoardSetup(6,2:3)=0;
    fprintf('Position 6 has been dumped \n');
end

Pos9Rand=randi(4);
if Pos9Rand==2
    % Dump the game piece and it goes back to start
    BoardSetup(9,2:3)=0;
    fprintf('Position 9 has been dumped \n');
end

pause (2);

%*******************************************************************
% Put some visual space in so you can see which player is playing
% 
fprintf('*************************************** \n  \n  \n');
% *******************************************************************
% figure(2)
% b1=bar(BoardSetup(:,1),BoardSetup(:,2),'r');
% hold on
% b2=bar(BoardSetup(:,1),BoardSetup(:,3),'b');
% ylim([0 2]);
% hold off

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
fprintf('Game Over!  Player 1 has %d goals, Player 2 has %d goals! \n',ScorePlayer1, ScorePlayer2);


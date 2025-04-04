close all force
clear
clc

start_position = 1;
end_position = 14;
stats_rows = ["Distance Travelled","Dumps","Swaps"];
stats_table = [0,0;0,0;0,0];
player_1_pos = 0;
player_2_pos = 0;
turn = 1;
turn_count = 1;

while true
    disp("Player 1's turn");

    % take pictures until dice is picked up
    % take pictures until dice is there and get dice roll
    roll = 3;
    if player_1_pos == 0
        player_1_pos = roll;
        stats_table(1,1) = stats_table(1,1) + roll;
        disp("Place the piece on position " + roll);
    else
        player_1_pos = player_1_pos + roll;
        stats_table(1,1) = stats_table(1,1) + roll;
        % move piece number of spaces
    end
    
    if player_1_pos >= end_position
        break;
    end
    turn = 2;

    disp("Player 2's turn");
    
    if player_2_pos == 0
        player_2_pos = roll;
        stats_table(1,2) = stats_table(1,2) + roll;
        disp("Place the piece on position " + roll);
    else
        player_2_pos = player_2_pos + roll;
        stats_table(1,2) = stats_table(1,2) + roll;
        % move piece number of spaces
    end
    
    if player_2_pos >= end_position
        break;
    end
    turn = 1;
    
    turn_count = turn_count + 1;
end

disp("Player " + turn + " wins!");

displacement = 25;
disp("                      Player 1    Player 2")
fprintf("Average Roll");
for j = 1:displacement - 12
    fprintf(" ");
end
if turn == 1
    disp(stats_table(1,1) / turn_count + "           " + stats_table(1,2) / (turn_count-1));
else
    disp(stats_table(1,1) / turn_count + "           " + stats_table(1,2) / turn_count);
end


for i = 1:length(stats_rows)
    fprintf(stats_rows(i));
    for j = 1:displacement - strlength(stats_rows(i)) - floor(strlength(num2str(stats_table(i,1)))/3)
        fprintf(" ");
    end
    fprintf(num2str(stats_table(i,1)));
    for j = 1:11 - floor(strlength(num2str(stats_table(i,1)))/2) - floor(strlength(num2str(stats_table(i,1)))/3)
        fprintf(" ");
    end
    fprintf(num2str(stats_table(i,2)) + "\n");
end

disp("Turns: " + turn_count)
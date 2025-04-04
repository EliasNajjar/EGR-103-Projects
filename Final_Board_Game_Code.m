close all force
clear
clc

start_position = 1;
end_position = 14;
stats_rows = ["Distance Travelled","Dumps","Swaps"];
stats_table = [0,0;0,0;0,0];
player_pos = [0,0];
turn = 1;
turn_count = 1;

while true
    % take pictures until dice is picked up
    % take pictures until dice is there and get dice roll
    roll = randi(6);

    disp("Player " + turn + "'s turn");

    if player_pos(turn) == 0
        player_pos(turn) = roll;
        stats_table(1,turn) = stats_table(1,turn) + roll;
        disp("Place the piece on position " + roll);
    else
        player_pos(turn) = player_pos(turn) + roll;
        stats_table(1,turn) = stats_table(1,turn) + roll;
        % move piece number of spaces
    end

    if player_pos(turn) >= end_position
        break;
    end

    if turn == 1
        turn = 2;
    else
        turn = 1;
        turn_count = turn_count + 1;
    end    
end

disp("Player " + turn + " wins!");

displacement = 25;
disp("                      Player 1    Player 2")
fprintf("Average Roll");
for j = 1:displacement - 12 - floor((strlength(num2str(round(stats_table(1,1) / turn_count,2)))-1)/2)
    fprintf(" ");
end

fprintf(num2str(round(stats_table(1,1) / turn_count,2)));
for i = 1:11 - floor((strlength(num2str(round(stats_table(1,1) / turn_count,2))))/2) - floor((strlength(num2str(round(stats_table(1,1) / turn_count,2)))-1)/2)
    fprintf(" ");
end
fprintf(round(stats_table(1,2) / (turn_count-mod(turn,2)),2) + "\n");

for i = 1:length(stats_rows)
    fprintf(stats_rows(i));
    for j = 1:displacement - strlength(stats_rows(i)) - floor((strlength(num2str(stats_table(i,1)))-1)/2)
        fprintf(" ");
    end
    fprintf(num2str(stats_table(i,1)));
    for j = 1:11 - floor((strlength(num2str(stats_table(i,1))))/2) - floor((strlength(num2str(stats_table(i,1)))-1)/2)
        fprintf(" ");
    end
    fprintf(num2str(stats_table(i,2)) + "\n");
end

disp("Turns: " + turn_count);
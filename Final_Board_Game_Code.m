close all force
clear
clc

start_position = 1;
end_position = 14;
dump_spaces = [4,10];
swap_spaces = [6,8]; % only enter the first spot
stats_table = [0,0;0,0;0,0;0,0]; % distance, swaps, dumps
distance_offset = [0,0];
player_pos = [0,0];
turn = 1;
turn_count = 1;

while true
    disp("Player " + turn + "'s turn");

    % take pictures until dice is picked up
    % take pictures until dice is there and get dice roll
    roll = randi(6);

    if player_pos(turn) + roll == player_pos(mod(turn,2)+1)
        roll = roll - 1;
        distance_offset(turn) = distance_offset(turn) + 1;
        if roll == 1
            disp("You rolled 2 but your opponent is already there, moving 1 space");
        else
            disp("You rolled " + (roll+1) + " but your opponent is already there, moving " + roll + " spaces");
        end
    else
        disp("You rolled " + roll);
    end

    stats_table(1,turn) = stats_table(1,turn) + roll; % increase distance travelled stat

    if roll > 0
        if player_pos(turn) == 0 % if player not on board, do not use claw, tell player to place piece
            player_pos(turn) = roll; % 0 + roll = roll
            disp("Place the piece on position " + roll);
        else
            player_pos(turn) = player_pos(turn) + roll; % increase pos
            if player_pos(turn) >= end_position % if reached the end, end the game
                % move piece to 14
                break;
            end
            % move piece number of spaces
        end
    end

    if randi(4) == 1 % if 25% chance hits
        for j = dump_spaces
            if player_pos(turn) == j % if player is on the dump space
                % dump player
                player_pos(turn) = 0;
                stats_table(2,turn) = stats_table(2,turn) + 1;
                disp("You got dumped");
                break;
            end
        end
    end

    if randi(2) == 1 % if 50% chance hits
        for j = swap_spaces
            if player_pos(turn) == j % if player is on first place of swap
                if player_pos(mod(turn,2)+1) == j+1 % if other player is on second place of swap, both players switch
                    % swap space
                    player_pos(turn) = j+1;
                    player_pos(mod(turn,2)+1) = j;
                    stats_table(3,turn) = stats_table(3,turn) + 1; % you swapped forward
                    stats_table(4,mod(turn,2)+1) = stats_table(4,mod(turn,2)+1) + 1; % other swapped backward
                    disp("Players got swapped");
                    break;
                else % only this player switches
                    % swap space
                    player_pos(turn) = j+1;
                    stats_table(3,turn) = stats_table(3,turn) + 1;
                    disp("You got swapped forwards");
                    break;
                end
            elseif player_pos(turn) == j+1 % if player is on second place of swap
                if player_pos(mod(turn,2)+1) == j% if other player is on first place of swap, both players switch
                    % swap space
                    player_pos(turn) = j;
                    player_pos(mod(turn,2)+1) = j+1;
                    stats_table(4,turn) = stats_table(4,turn) + 1; % you swapped backward
                    stats_table(3,mod(turn,2)+1) = stats_table(3,mod(turn,2)+1) + 1; % you swapped forward
                    disp("Players got swapped");
                    break;
                else % only this player switches
                    % swap space
                    player_pos(turn) = j;
                    stats_table(4,turn) = stats_table(4,turn) + 1;
                    disp("You got swapped backwards");
                    break;
                end
            end
        end
    end

    turn = mod(turn,2) + 1; % 1->2 2->1
    turn_count = turn_count + mod(turn,2); % only increase if turn is 1
end

disp("Player " + turn + " wins!");

displacement = 25;
disp("                      Player 1    Player 2")
fprintf("Average Roll");
for j = 1:displacement - 12 - floor((strlength(num2str(round((stats_table(1,1)+distance_offset(1)) / turn_count,2)))-1)/2)
    fprintf(" ");
end
fprintf(num2str(round((stats_table(1,1)+distance_offset(1)) / turn_count,2)));
for i = 1:11 - floor((strlength(num2str(round((stats_table(1,1)+distance_offset(1)) / turn_count,2))))/2) - floor((strlength(num2str(round((stats_table(1,2)+distance_offset(2)) / (turn_count-mod(turn,2)),2)))-1)/2)
    fprintf(" ");
end
fprintf(round((stats_table(1,2)+distance_offset(2)) / (turn_count-mod(turn,2)),2) + "\n");

stats_table(1,turn) = stats_table(1,turn) - player_pos(turn) + 14;

stats_rows = ["Distance Travelled","Dumps","Swaps Forward","Swaps Backward"];
for i = 1:length(stats_rows)
    fprintf(stats_rows(i));
    for j = 1:displacement - strlength(stats_rows(i)) - floor((strlength(num2str(stats_table(i,1)))-1)/2)
        fprintf(" ");
    end
    fprintf(num2str(stats_table(i,1)));
    for j = 1:11 - floor((strlength(num2str(stats_table(i,1))))/2) - floor((strlength(num2str(stats_table(i,2)))-1)/2)
        fprintf(" ");
    end
    fprintf(num2str(stats_table(i,2)) + "\n");
end

disp("Turns: " + turn_count);
function [row,col] = pipjtorowcol(pi,pj)

%% convert the pi pj index output by compute_Atraj_neighbour
%% to rows and cols

row = double(pi + 1);
col = zeros(length(row),1);



for id = 1: (length(pj)-1)
   col([(pj(id)+1): pj(id+1)]) = id;
end


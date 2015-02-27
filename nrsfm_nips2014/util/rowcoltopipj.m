function [pi,pj] = rowcoltopipj(row,col, n)

%% convert row col to pi, pj
%% note : pi & pj start from zero index, they are uint32
%%        n is the number of element. Assume it's square matrix

pi = uint32(row -1);
pj = uint32(zeros(n + 1,1));

%% non-empty col
ne_col = unique(col);
ne_col = sort(ne_col,'ascend');

%% assgin the first one
pj(ne_col+1) = [find(diff(col)); length(row)];

%% fill in the rest
MAX = 0;
for id = 1: (n+1)
    if pj(id)~=0
        MAX = pj(id);
    else
        pj(id) = MAX;
    end
end

%pj(end) = length(row);



end
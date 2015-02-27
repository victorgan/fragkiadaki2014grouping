function position = spp(row,col,axis)
%%%%%%%%%%%%% position = spp(row,col,axis)
%%%%%%%%%%%%%           

if ~exist('axis','var') | isempty(axis)
    axis = [0,0,1,1];
end

if(nargin==1) % case one , just number
    nplots = length(row);
    row = floor(sqrt(nplots));
    col = ceil(nplots/row);
end

axis(3) = axis(1)+axis(3);
axis(4) = axis(2)+axis(4);

rowid = linspace(axis(4),axis(2),row+1); rowid = rowid(2:end);
colid = linspace(axis(1),axis(3),col+1); colid = colid(1:end-1);

[posy, posx] = meshgrid(rowid, colid);
posx = posx(:); posy = posy(:);

width = range(axis([1,3]))/col * 0.95;
height = range(axis([2,4]))/row* 0.95;


for i = 1: numel(posx)
    position(i,:) = [posx(i),posy(i),width,height];
end

end
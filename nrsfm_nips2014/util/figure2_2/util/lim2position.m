function [left, bottom, width, height] = lim2position(i1,i2,j1,j2)
if nargin == 1
    i2=i1(2);
    j1 = i1(3);
    j2 = i1(4);
    i1 = i1(1);
end
pos0 = get(0,'ScreenSize');
height0 = pos0(4);
bottom = -i2 + height0 + 1;

% bottom = i2;
left = j1;
width = j2-j1+1;
height = i2-i1+1;

if nargout <= 1
    left = [left, bottom, width, height];
end

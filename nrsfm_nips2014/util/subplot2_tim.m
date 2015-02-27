function h = subplot2(p,q,i,j,border);
% Timothee Cour, 11-Jan-2009 07:37:44 -- DO NOT DISTRIBUTE

if nargin < 4 || isempty(j)
    [i,j]=ind2sub([p,q],i);
end
%subplot(p,q,j+(i-1)*p);

%subplot(p,q,j+(i-1)*q);
if nargin < 5 || isempty(border)
    border = 0.02;
%     border = 0.05;
    %border = 0.04;
%     border = 0.2;
end
border_p = 1/p*border;
border_q = 1/q*border;

left = (j-1)/q+border_q/2;
bottom = (p-i)/p+border_p/2;
width = 1/q-border_q;
% height = 1/p-border_p;
height = 1/p-2*border_p;

factor = (1-0.04);
left = factor*(left) + 0.02;
width = factor * width;
bottom = 1-(factor*(1-bottom) + 0.02);
height = factor * height;
h = subplot('Position',[left , bottom , width, height ]);

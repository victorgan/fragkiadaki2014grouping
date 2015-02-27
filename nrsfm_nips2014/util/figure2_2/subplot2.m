function h = subplot2(p,q,i,j,border);
%subplot(p,q,j+(i-1)*p);

%subplot(p,q,j+(i-1)*q);
if nargin < 5
    %border = 0.02;
    %border = 0.04;
%    border = 0.05;
    border = 0;
%     border = 0.2;
end

if nargin == 3
  [i,j] = ind2sub([p q], i);
end



border_p = 1/p*border;
border_q = 1/q*border;

left = (j-1)/q+border_q/2;
bottom = (p-i)/p+border_p/2;
width = 1/q-border_q;
% height = 1/p-border_p;
height = 1/p-2*border_p;

%pad = 0.02;
pad =  0;
factor = (1-0.04);
left = factor*(left) + pad;
width = factor * width;
bottom = 1-(factor*(1-bottom) + pad);
height = factor * height;
h = subplot('Position',[left , bottom , width, height ]);

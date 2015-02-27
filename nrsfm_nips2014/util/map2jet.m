function colors=map2jet(value,w)
if min(value)<0
    value=value+abs(min(value));
end
if nargin<2
w=colormap(jet);
end
value=(size(w,1)-1)*value/(max(value));
value=round(value);
value=value+1;


colors=w(value,:);
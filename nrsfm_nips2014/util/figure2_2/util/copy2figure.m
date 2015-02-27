function copy2figure
currentFigure = gcf;
currentAxes = gca;
% gca
% posXLim = get(gca,'XLim');
% posYLim = get(gca,'YLim');
% q = posXLim(2)-posXLim(1);
% p = posYLim(2)-posYLim(1);
% % size(getimage);
[p,q,r] = size(getimage(gca));

figure2(get(currentFigure,'Name'),[p,q]);
newFigure = gcf;

newAxes = copyobj(currentAxes,newFigure);

figure(newFigure);
subplot(newAxes);

set(newAxes,'Position',[0 0 1 1]);
set(newFigure,'Colormap',get(currentFigure,'Colormap'));
% positionFigure;
% axis image;
% axis normal;
axis off;
% axis image;

positionFigure;%(p,q,newFigure);

% axis fill;
% gca
% newAxes
% z=get(gcf,'Children')
% positionFigure;
%     temp = get(currentAxes,'Children');
%     image = get(temp(length(temp)),'CData');

%     options = get(currentAxes,'UserData');
%     if ~isempty(options) && options.grid
%         afficheGrid(options.imageX,0,options.dataPatches.tableau_i,options.dataPatches.tableau_j);
%     end


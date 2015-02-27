function fig = figure2(name,position,options,fig)
if nargin < 4
    global data;
    if isfield(data,'gui')
        if data.gui.newWindow ==1
            while ishandle(data.gui.indexNextFigure)
                data.gui.indexNextFigure=data.gui.indexNextFigure+1;
            end
        else
            if data.gui.indexNextFigure < 1
                data.gui.indexNextFigure = 1;
            end
        end
        data.figureCourante = figure(data.gui.indexNextFigure);
        clf;
    else
        data.figureCourante = figure;
    end
else
    figure(fig);
end
if nargin >= 1
    set(gcf,'Name',name);
end
try %in case no display available
    if nargin >=2
        positionFigure(position);
    else
        positionFigure(1,1);
    end
catch
end
if nargin >= 3
    set(gca,'UserData',options);
end
axis off

setPropertyFigure2(gcf);
% set(gcf,'WindowButtonDownFcn',@actionFigure);

fig = gcf;

function actionFigure(hObject, eventdata, handles);

selectionType = get (gcf , 'SelectionType');
switch selectionType
    case 'alt'
        cmenu = uicontextmenu;
        uimenu(cmenu, 'Label', 'saveFigure','Callback','saveFigure(gcf)');
        uimenu(cmenu, 'Label', 'save to data.image','Callback',@saveImageToData);
        uimenu(cmenu, 'Label', 'open in new window','Callback',@openInNewWindow);
        uimenu(cmenu, 'Label', 'analyze data point','Callback',@analysePoint);
        uimenu(cmenu, 'Label', 'axis image','Callback',@axisImage);
        if norm1(get(gca,'Position')-[0,0,1,1])
            uimenu(cmenu, 'Label', 'remove margin','Callback',@removeMargin);
        else
            uimenu(cmenu, 'Label', 'replace margin','Callback',@replaceMargin);
        end
        uimenu(cmenu, 'Label', 'Colorbar','Callback',@colorbar2);
        if norm1(get(gcf,'colormap')-gray)
            uimenu(cmenu, 'Label', 'Colormap gray','Callback',@colormapGray);
        else
            uimenu(cmenu, 'Label', 'Colormap default','Callback',@colormapDefault);
        end
        uimenu(cmenu, 'Label', 'pixel property','Callback',@pixelProperty);
        uimenu(cmenu, 'Label', 'flip-ud,invert color','Callback',@flipUpDown);

        set(gco,'UIContextMenu',cmenu,'Visible','on');%,'Selected','on');
    case 'open'
        openInNewWindow;
    case 'extend'
        % todo : choose what to do
    otherwise
end

function openInNewWindow(hObject, eventdata,handles)
copy2figure;

function saveImageToData(hObject, eventdata,handles)
global data;
XLim = round(get(gca,'XLim'));
YLim = round(get(gca,'YLim'));
temp = get(gca,'Children');
temp = get(temp(end));
imageX = double(temp.CData);
[p,q,r] = size(imageX);
i1 = max(1,YLim(1));
i2 = min(p,YLim(2));
j1 = max(1,XLim(1));
j2 = min(q,XLim(2));
imageX = imageX(i1:i2,j1:j2,:);
[data.ImageOriginale , data.imageCouleur , data.image] = computeImagesGui(imageX , data.p,data.q);

function analysePoint(hObject, eventdata,handles)
currentFigure = gcf;

z=get(gca,'CurrentPoint');
UserData = get(gca,'UserData');
X = UserData.X;
Example = UserData.Example;
index = dataPoint2image(Example,X,z(1,:));
figure(currentFigure);
hold on;
selected = num2cell(X(index,:));
if length(selected)<=2
    h = plot(selected{:},'or');
else
    h = plot3(selected{:},'or');
end
hold off;
%pause(0.2);
%delete(h);

function colorbar2(hObject, eventdata,handles)
%set(gca,'Position',[0 0 0.75 1]);
colorbar;
set(gca,'Position',[0 0 0.75 1]);

function colormapGray(hObject, eventdata,handles)
colormap(gray);

function colormapDefault(hObject, eventdata,handles)
colormap('default');

function axisImage(hObject, eventdata,handles)
axis image

function removeMargin(hObject, eventdata,handles)
set(gca,'Position',[0,0,1,1]);
axis off

function replaceMargin(hObject, eventdata,handles)
set(gca,'Position',[0.1300, 0.1100, 0.7750, 0.8150]);
axis on

function pixelProperty(hObject, eventdata,handles)
pixel=get(gca,'CurrentPoint');
image = getimage(gca);
i = round(pixel(1,2));
j = round(pixel(1,1));
[p,q,r] = size(image);
if r > 1
    rgb = image(i,j,:);
    hsv(1,1,1:3) = rgb2hsv(rgb);
else
    intensity = image(i,j);
end
disp(sprintf('\n'));
disp(['[i,j] = [',num2str(i),',',num2str(j),']']);
if r > 1
    disp(['rgb = [',num2str(rgb(1)),',',num2str(rgb(2)),',',num2str(rgb(3)),']']);
    disp(['hsv = [',num2str(hsv(1)),',',num2str(hsv(2)),',',num2str(hsv(3)),']']);
else
    disp(['intensity = ',num2str(intensity)]);
end

function flipUpDown(hObject, eventdata,handles)
image = getimage(gca);
image = 1-image(end:-1:1,:,:);
imagesc(image);
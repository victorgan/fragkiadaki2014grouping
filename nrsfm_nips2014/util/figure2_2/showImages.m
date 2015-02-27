function h=showImages(filters,fig,isRescale,colorMap,imagesContext)
if iscell(filters)
    nbFilters = numel(filters);
else
    isColor = 0; 
    fSize = size(filters);
    % Assume it is color if 3rd dim is 3
    if (fSize(3) == 3 && length(fSize) > 3)
      filters = reshape(filters, fSize(1), fSize(2), 3, prod(fSize(4:end)));
      nbFilters = fSize(4);
      isColor = 1;
    else
      fSize = size(filters);
      nbFilters = fSize(3);
    end    
    p = fSize(1);
    q = fSize(2);
end

if iscell(filters) && (~isvector(filters) || length(filters) < 8)
    filters = reshapeBloc(filters);
    nbFilters = numel(filters);
    [n_i,n_j] = size(filters);
else
    n_i = ceil(sqrt(nbFilters));
    n_j = ceil(nbFilters / n_i);
end

if nargin < 2 || isempty(fig)
    h=figure2('filters' , n_i/n_j);
elseif ishandle(fig)
    h=figure(fig);
    positionFigure(n_i/n_j);
elseif ischar(fig)
    h=figure2(fig, n_i/n_j);
else
    h=figure(fig);clf;
   % error('wrong argument');
end

if nargin < 3 || isempty(isRescale)
    isRescale = 0;
end
if nargin < 4 || isempty(colorMap)
    colorMap = 'default';
end
if nargin < 5
    isImageContext = 0;
else
    isImageContext = 1;
end

if isRescale
    if iscell(filters)
        maxi = -Inf;
        mini = Inf;
        for i=1:nbFilters
            maxi = max(maxi,max(filters{i}(:)));
            mini = min(mini,min(filters{i}(:)));
        end
    else
        maxi = max(filters(:));
        mini = min(filters(:));
    end
end



colormap(colorMap);
k = 0;

for j=1:n_j
    if mod(j,2)
        pause(0);
        %if too slow, remove this (but the displays won't show until the
        %end)
    end
    for i=1:n_i
        k = k+1;
        if k > nbFilters
            return;
        end
        subplot2(n_i,n_j,i,j);
        if iscell(filters)
            if ~isempty(filters{k})
                imagesc(filters{k});
            end
        else
          if (isColor)
            imagesc(filters(:,:,:,k));
          else
            imagesc(filters(:,:,k));
          end
        end
        axis image;

        axis off;
        if isRescale
            caxis([mini,maxi + eps]);
        end
        if isImageContext && ~isempty(imagesContext{k})
            hold on;
            if isfield(imagesContext{k},'function')
                feval(imagesContext{k}.function,imagesContext{k}.argument{:});
            else
                eval(imagesContext{k});
            end
            hold off;
        end
%         title([num2str(k) '  (' num2str(i) ',' num2str(j) ')'],'Position',[]);
%         text(0 , -10 , [num2str(k) '  (' num2str(i) ',' num2str(j) ')']);
       % text(0 , -10 , [num2str(k)]);

    end
end

function h = plot_trajectory_labels(tr, tr_labels, imnames,figno,cols,put_text,...
    markersize)

[XYT,tr_id]=quick_tr(tr);
if ~exist('markersize', 'var')
    markersize = 4;
end
if ~exist('put_text', 'var')
    put_text = 0;
end
if ~exist('figno', 'var')
    figno = 1;
end

ts=cat(2,imnames(:).t);


nf = length(ts);
nr = ceil(sqrt(nf));
nc = ceil(nf/nr);


cl_id = setdiff(unique(tr_labels(tr_labels>=0)),0);
if ~exist('cols', 'var')| isempty(cols)
    if ~isempty(find(cl_id==0))
        cols=jet(length(cl_id)-1);
        cols = cols(randperm(length(cl_id)-1),:);
        cols=[[1 1 1];cols];
    else
        cols = jet(length(cl_id)+1);
        cols = cols(randperm(length(cl_id)),:);
    end
end



if figno>0
    h = figure(figno);clf;
elseif figno==0
    h = figure('visible', 'off');
elseif isempty(figno)
    h=0;
end



for i = 1:length(imnames)
    t=imnames(i).t;
    img = imread(imnames(i).name);
    subplot2(nr,nc, i);
    imshow(img);
    hold on;
    [X,Y,tr_id_c]=get_current_xytrid(XYT,tr_id,t);
    tr_pts=[X Y];
    tr_labels_c = tr_labels(tr_id_c);
    id_inds = cell(length(cl_id),1);
    for n = 1:length(cl_id)
        id_inds{n} = tr_labels_c==cl_id(n);
        if sum(id_inds{n})==0
            continue;
        end
        
        plot(tr_pts(id_inds{n},1), tr_pts(id_inds{n},2), 'o', 'markersize',markersize, 'color', cols(n,:));
    end
    
    if put_text > 0
        for n = 1:length(cl_id)
            mc = mean(tr_pts(id_inds{n},:),1);
            text(mc(1),mc(2),num2str(cl_id(n)),'BackgroundColor',[1 1 1]);
        end
    end
    title(num2str(t))
end

set(gcf,'name','Trajectory Cluster Label');
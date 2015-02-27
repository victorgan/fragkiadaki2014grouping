warning('off');
video_dir='./video/';
nclusters=3;
flow_dir=setdir([video_dir 'flow/']);
imnames=get_file_list(video_dir,'jpg');
ts=cell2struct(num2cell([1:length(imnames)]),'t',1);
imnames = cell2struct([struct2cell(imnames); struct2cell(ts')], ...
    [fieldnames(imnames); fieldnames(ts)], 1);

[para]=get_para(video_dir, 'jpg',length(imnames),4);


disp('compute dense trajectories');
computeFlowLDOF(imnames,flow_dir,para)
tr=linkFlowLDOF(imnames,para);

lens=get_tr_lengths(tr);
tr=tr(lens>=para.min_tr_len);
if 0
    plot_trajectory_labels(tr, ones(length(tr),1), imnames(1:5:end),1,[],0,...
        4);
end

disp('compute trajectory affinities');
[Atr]=computeTrAffinities(tr,para,0);



disp('compute trajectory clustering');
[Vtr,Str] = ncut(Atr,para.nv);


binsoltr = getbinsol(Vtr(:,1:nclusters));
tr_labels = full(sum(binsoltr.*repmat(1:nclusters, size(binsoltr,1),1),2)')';
h=plot_trajectory_labels(tr,tr_labels,imnames(1:10:end),nclusters,[],1,5);
tr=tr(tr_labels==1);
%%

[W,H,tr_ids_keep]=tr2W(tr,1,length(imnames));
W=W(:,1:2:end);
H=H(:,1:2:end);
for K=[1 2 3 4 5]
    fprintf('rank:%d \n',K)
    if K==1

        [Shape, Shat, translation, scale,  Rsh, R_Recover] =...
            dsfm(W,H,7,4);
        
    else
        [Shape, Shat, translation, scale,  Rsh, R_Recover] = ...
            dnrsfm(W,H,K);
    end

    
    
    %% reprojection of missing data
    if 0
        Wout=(Rsh*Shat_BMM)*scale+repmat(translation',1,nPts);
        tr_out=W2tr(Wout)';
        plot_trajectory_labels(tr_out,ones(length(tr_out),1),imnames(1:5:end),...
            1,[],0,6);
    end
    
    
    
    if 0
        %% plot Shape
      
        if K>1
        Shape=rotateStruct(Shape, R_Recover)*scale;
    else
       % figure(3);clf;plot3(Shape(1,:),Shape(2,:),Shape(3,:),'.k')
        Shape=rotateRigidStruct(Shape, R_Recover)*scale;
    end
        xmax = max(max(Shape(1:3:end,:),[], 1));
        xmin = min(min(Shape(1:3:end,:),[], 1));
        ymax = max(max(Shape(2:3:end,:),[], 1));
        ymin = min(min(Shape(2:3:end,:),[], 1));
        zmax = max(max(Shape(3:3:end,:),[], 1));
        zmin = min(min(Shape(3:3:end,:),[], 1));
        F=size(Shape,1)/3;
        close all;
        
        %figure(1); clf;
        for t=1:F
            h=figure(1); clf;
            set(h,'position', [800, 800, 800, 600]);
            plot3(Shape((t-1)*3+1,:),Shape((t-1)*3+2,:),Shape((t-1)*3+3,:),'.g');
            axis([xmin xmax ymin ymax zmin zmax]);
            hold on;
            %     view(-56,-44)
            view(-60,70)
            % view(-t*3,-16)
            %view(-300,-16)
            % camva(7.93)
            if t==1
                pause(2)
            end
            pause(0.05)
            drawnow;
        end
        
        
    end
    %% visualize
    
    continue;
    nPts=size(Shape,2);
    if K>1
        TemporalShape=rotateStruct(Shape, R_Recover)*scale;
    else
       % figure(3);clf;plot3(Shape(1,:),Shape(2,:),Shape(3,:),'.k')
        TemporalShape=rotateRigidStruct(Shape, R_Recover)*scale;
    end
    % TemporalShape=(Rsh*Shape)*scale;
    TemporalShape2D=TemporalShape;
    TemporalShape2D(3:3:end,:)=[];
    Zout=TemporalShape2D+repmat(translation,1,nPts);
    trout=W2tr(Zout,ts');
    if 1
        for t=1:length(ts)
            x=TemporalShape(3*(t-1)+1,:)';
            y=TemporalShape(3*(t-1)+2,:)';
            z=TemporalShape(3*(t-1)+3,:)';
            figure(10);clf; %imshow(img); hold on;
            plot3(x,y,z,'.k');
            view(0,-90)
            %pause(0.1);
            xlabel('x'); ylabel('y'); zlabel('z');
            title('face rotate the point cloud')
        end
    end
    
    
    
end




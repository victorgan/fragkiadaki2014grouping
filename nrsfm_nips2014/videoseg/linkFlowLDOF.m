function tr=linkFlowLDOF(imnames,para)

p = para.p;
q = para.q;
nf= length(imnames);
margin=para.g;
sample_step=para.sample_step;
[ys,xs]=ndgrid(margin:sample_step:p-margin,margin:sample_step:q-margin);
ys=ys(:);
xs=xs(:);
pinds=sub2ind([p,q],ys,xs);
X=zeros(nf,2*ceil(p*q/(sample_step^2)));
Y=zeros(nf,2*ceil(p*q/(sample_step^2)));
Start=zeros(2*ceil(p*q/(sample_step^2)),1);
X(1,1:length(xs))=xs;
Y(1,1:length(ys))=ys;
Start(1:length(ys),1)=1;
Xtr=cell(nf);
Ytr=cell(nf);
Ttr=cell(nf);
lens=cell(nf);

for t=1:length(imnames)-1
    progress(sprintf('\t\t compute trajectory in frame'),t,length(imnames)-1);
    I1=imread(imnames(t).name);
    I2=imread(imnames(t+1).name);
    Ff = readFlowFile([para.flow_dir 'Forward' get_image_name(imnames(t).name)  'LDOF.flo']);
    Fb = readFlowFile([para.flow_dir 'Backward' get_image_name(imnames(t).name)  'LDOF.flo']);
    
    [ON]=prune_flow_field(I1,I2,Ff,Fb,para,0);
    inds_off=find(ON==0);
    length(inds_off);
    U=Ff(:,:,1);
    V=Ff(:,:,2);
    U(inds_off)=-Inf;
    V(inds_off)=-Inf;
    
    %bilinear interpolation
    Inds=find(Start>0);
    xs1=X(t,Inds);
    ys1=Y(t,Inds);
    u=interp2(U,xs1,ys1);
    v=interp2(V,xs1,ys1);
    xs2=xs1+u;
    ys2=ys1+v;
    
    
    %filter pts based on flow filtering
    choose=xs2>margin & ys2>margin & xs2<q-margin & ys2<p-margin;
    inds_on=Inds(choose);
    xs2=xs2(choose);
    ys2=ys2(choose);
    X(t+1,inds_on)=xs2;
    Y(t+1,inds_on)=ys2;
    
    %terminate
    inds_off=setdiff(Inds,inds_on);
    [Xtr{t},Ytr{t},Ttr{t},lens{t}]=terminate_at_t(inds_off,t,Start,X,Y);
    Start(inds_off)=0;
    
    
    %sample new points at t+1-> cover with 1 the area to be sampled and 0 the area to be left untouched
    map_occupied=ones(p,q);
    pixel_inds=sub2ind([p q],round(ys2),round(xs2));
    map_occupied(pixel_inds)=0;
    if sample_step>1
        map_occupied=imerode(map_occupied,strel('disk',sample_step));
        map_occupied=double(map_occupied>0);
    end
    ys_add=ys(map_occupied(pinds)>0);
    xs_add=xs(map_occupied(pinds)>0);
    
    if 0
        figure(12),
        imagesc(map_occupied)
        hold on;
        plot(xs_add,ys_add,'.g','markersize',0.1);
%         plot(xs2,ys2,'.r');
        axis image
        title('newly added points')
    end
    
    
    
    num_add=length(xs_add);
    free_inds=find(Start==0);
    X(t+1,free_inds(1:num_add))=xs_add;
    Y(t+1,free_inds(1:num_add))=ys_add;
    Start(free_inds(1:num_add))=t+1;
    
    
end
t=t+1;
%terminate
inds_on=find(Start>0);
[Xtr{t},Ytr{t},Ttr{t},lens{t}]=terminate_at_t(inds_on,t,Start,X,Y);



A=[Xtr{:};Ytr{:};Ttr{:}];
LL=cat(1,lens{:})';
B=mat2cell(A,3,LL);
tr=cell2struct(B,{'XYTPos'},1);

tr=tr(LL>1);


end

function [Xt,Yt,Tt,lens_c]=terminate_at_t(inds_end,t,Start,X,Y)
inds1=sub2ind(size(X),Start(inds_end),inds_end);
inds2=sub2ind(size(X),t*ones(length(inds_end),1),inds_end);
lens_c=t-Start(inds_end)+1;
L=[0;cumsum(lens_c)];
inds=zeros(1,sum(lens_c));
ts=zeros(1,sum(lens_c));
for i=1:length(inds1)
    inds(L(i)+1:L(i+1))=inds1(i):inds2(i);
    ts(L(i)+1:L(i+1))=Start(inds_end(i)):t;
end
Xt=X(inds);
Yt=Y(inds);
Tt=ts;
end


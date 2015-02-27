function [A]=computeTrAffinities(tr,para,verbose)
sigma=0.1;
ntr=length(tr);
%% neighbors
%away from 2*cuttoff alays affinity zero
cutoffx=para.dist_thresh_x;
cutoffy=para.dist_thresh_y;
sample_step = para.sample_step;

trFrame=get_help_struct(tr);
[pi, pj] = compute_Atraj_neighbour(tr, trFrame, cutoffx, cutoffy, sample_step,verbose);
[rows,cols] = pipjtorowcol(pi,pj);
clear pi pj


%% tr distance
[XYT,tr_id]=quick_tr(tr);
[tr_id_on,Is1]=unique(tr_id,'first');
[~,Is2]=unique(tr_id,'last');
tr_start=-1*ones(ntr,1);
tr_end=-1*ones(ntr,1);
tr_start(tr_id_on)=Is1;
tr_end(tr_id_on)=Is2;
V=ones(size(XYT(1,:)'));
vals = compute_tr_affinities_mex(XYT(1,:)', XYT(2,:)', XYT(3,:)', V,...
    tr_start'-1, tr_end'-1, ntr,...
    sigma, uint32(rows-1), uint32(cols-1), length(rows));

%A=sparse(rows,cols,vals,ntr,ntr);
%return;
B=sparse(rows(vals>0.95),cols(vals>0.95),vals(vals>0.95),ntr,ntr);

[i,j,v]=find(B);
bins=hist(i,[1:length(tr)])/2+1;

v=1./sqrt((bins));

V=v(tr_id);
sigma=0.01;

vals = compute_tr_affinities_mex(XYT(1,:)', XYT(2,:)', XYT(3,:)', V,...
    tr_start'-1, tr_end'-1, ntr,...
    sigma, uint32(rows-1), uint32(cols-1), length(rows));


A=sparse(rows,cols,vals,ntr,ntr);
end


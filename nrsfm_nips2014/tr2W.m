function [W,D,tr_ids_keep]=tr2W(tr,t1,t2)
[XYT,tr_id]=quick_tr(tr);
nf=max(XYT(3,:));
ntr=length(tr);
X=sparse(tr_id,XYT(3,:),XYT(1,:),ntr,nf);
Y=sparse(tr_id,XYT(3,:),XYT(2,:),ntr,nf);
X=X(:,t1:min(t2,nf));
Y=Y(:,t1:min(t2,nf));
tr_ids_keep=find(sum(X,2)>0 &sum(Y,2)>0);
nf=size(X,2);
ntr=length(tr_ids_keep);
W=reshape([X(tr_ids_keep,:); Y(tr_ids_keep,:)],ntr,2*nf)';
D=ones(size(W));
D(W==0)=0;

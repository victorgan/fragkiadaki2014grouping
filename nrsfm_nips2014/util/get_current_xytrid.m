function [X,Y,tr_id_c]=get_current_xytrid(XYT,tr_id,t)
inds=find(XYT(3,:)==t);
X=XYT(1,inds);
Y=XYT(2,inds);
tr_id_c=tr_id(inds);
[A,is]=unique([X; Y]','rows');
X=A(:,1);
Y=A(:,2);
tr_id_c=tr_id_c(is);
end
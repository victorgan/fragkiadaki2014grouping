function [XYT,tr_id]=quick_tr(tr)
if isempty(tr) XYT=[]; tr_id=[]; tr=[]; return; end
XYT=cat(2,tr.XYTPos);
tr_id=zeros(1,size(XYT,2));
c=1;
for ii=1:length(tr)
    tr_id(c:c+size(tr(ii).XYTPos,2)-1)=ii;
    c=c+size(tr(ii).XYTPos,2);
end

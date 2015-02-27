function L=get_tr_lengths(tr)
L=zeros(length(tr),1);
for ii=1:length(tr)
    L(ii)=size(tr(ii).XYTPos,2);
end
end
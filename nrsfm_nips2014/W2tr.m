function tr=Z2tr(Z,ts)

nf=size(Z,1)/2;
if nargin<2
    ts=[1:nf]';
end
m=size(Z,2);
X=Z(1:2:end,:);
Y=Z(2:2:end,:);
if size(ts,2)>size(ts,1)
    ts=ts';
end
T=ts*ones(1,m);

tr=struct('XYTPos',mat2cell(reshape([X;Y;T],nf,3*m)',3*ones(m,1),nf));

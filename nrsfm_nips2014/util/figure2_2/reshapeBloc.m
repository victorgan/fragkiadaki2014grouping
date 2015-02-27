function [A2,isValid] = reshapeBloc(A);
% Timothee Cour, 29-Aug-2006 09:33:38

[n,k]=size(A);
n2=ceil(sqrt(k*n)/k);
n1 = ceil(n/n2);
isValid=false(n1,n2);

for j=1:n2
    if (j-1)*n1+n1 <= n
        A2(1:n1,(j-1)*k+1:(j-1)*k+k) = A((j-1)*n1+1:(j-1)*n1+n1,:);
        isValid(1:n1,(j-1)*k+1:(j-1)*k+k)=true;
    else
        A2(1:n-(j-1)*n1,(j-1)*k+1:(j-1)*k+k) = A((j-1)*n1+1:n,:);
        isValid(1:n-(j-1)*n1,(j-1)*k+1:(j-1)*k+k)=true;
    end
end



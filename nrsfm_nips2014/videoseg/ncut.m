% function [V,S] = ncut(A)
% Input:
%    A = attraction, nonnegative
%    nv = number of eigenvectors, default = 6
% Output:
%    V = generalized eigenvectors of A  and D_A 
%    S = eigenvalues

% Stella X. Yu, 1 March 2004.

function [V,S] = ncut(A,nv)





if not(isequal(A,A')),
    A = A + A';
end
%get node degrees
W = A;
d = full(sum(A,2));

clear A 
if not(issparse(W)),
    W = sparse(W);
end



dih = 1./(sqrt(d)+eps);

% we use symmetric normalized affinity matrix
W = spmtimesd(W,dih,dih);



if not(isequal(W,W')),
    W = 0.5 * (W + W'); % ensure symmetry
end




options.issym = 1;
options.disp = 0;
options.maxit=20;

[V,S] = eigs(W,nv,'LA',options);

[i,j] = sort(diag(S));
S = i(end:-1:1);
V = V(:,j(end:-1:1));

V = V .* repmat(dih,1,nv);
function z = norm1(X);
if prod(size(X)) < 2^31-2
    z = norm(X(:));
else
    z = sqrt(sum(sum(abs(X).^2,2)));
end
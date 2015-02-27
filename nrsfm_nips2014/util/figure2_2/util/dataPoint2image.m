function index = dataPoint2image(Example,X,Position);
[n,k] = size(X);

z = X - repmat(Position(1:k),n,1);
[junk,index] = min(sum(z.^2,2));
figure(100);
imagesc(Example(index).image);

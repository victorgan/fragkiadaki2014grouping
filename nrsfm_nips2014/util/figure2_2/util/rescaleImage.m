function image2 = rescaleImage(image1);
m = min(image1(:));
M = max(image1(:) - m);
image2 = (image1 - m ) / (M+eps);

function structureness=compute_image_texturedness(im,image_smooth_sigma)
if size(im,3)>1
    im=im2double(rgb2gray(im));
else
    im=im2double(im);
end
%image_smooth_sigma=3;
gauss_1D = mk_gaussian(image_smooth_sigma);
gauss_2D = conv2(gauss_1D,gauss_1D');
dx = [-1 0 1];   % Derivative masks
dy = dx';
gradient_filter_x = conv2(gauss_2D,dx,'same');
gradient_filter_y = conv2(gauss_2D,dy,'same');
% im_smooth=conv2(im,gauss_2D,'same');
%%% compute gradient
Ix = conv2(im, gradient_filter_x, 'same');      % Image derivatives
Iy = conv2(im, gradient_filter_y, 'same');
gauss_1D = mk_gaussian(image_smooth_sigma);
gauss_2D = conv2(gauss_1D,gauss_1D');
Ix2 = conv2(Ix.^2, gauss_2D, 'same');
Iy2 = conv2(Iy.^2, gauss_2D, 'same');
Ixy = conv2(Ix.*Iy, gauss_2D, 'same');
%%% Estimate the cornerness
structureness = (Ix2.*Iy2 - Ixy.^2)./(Ix2 + Iy2 + eps);
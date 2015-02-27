function gauss = mk_gaussian(hsamples)
% creating 1D Gaussian, of size hsamples * 2 + 1
%
% the gaussian is truncated at x = +- tail, and there are samples samples
% inbetween, where samples = hsamples * 2 + 1
%
%  Jianbo Shi, 2007

tail=2;
samples = hsamples * 2 + 1;

x = linspace(-tail, tail, samples);
gauss = exp(-x.^2);
%s = sum(gauss)/length(x);gauss = gauss-s;
gauss = gauss/sum(abs(gauss));

n = gauss * ones(samples,1);
gauss = gauss/n;


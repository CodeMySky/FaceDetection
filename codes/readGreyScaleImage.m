function [image, nrows, ncols] = readGreyScaleImage(imagefile)
%image = double(imread(imagefile));
image = double(histeq(imread(imagefile)));
[nrows, ncols] = size(image);
image = image(:);
image = image - mean(image(:));
n = norm(image(:));
if n ~= 0
    image = image / n;
else
    image = ones(nrows*ncols,1)/(nrows*ncols);
end
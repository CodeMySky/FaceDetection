function [image, nrows, ncols] = readGreyScaleImage(imagefile)
%image = double(imread(imagefile));
image = double(histeq(imread(imagefile)));
[nrows, ncols] = size(image);
image = image(:);
image = image - mean(image(:));
if (norm(image(:)) ~= 0)
    image = image / norm(image(L));
else
    image = ones(nrows,ncols)/(nrows*ncols);
end
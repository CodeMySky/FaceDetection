function [image, nrows, ncols] = readGreyScaleImage(imagefile)
%image = double(imread(imagefile));
image = double(histeq(imread(imagefile)));
[nrows, ncols] = size(image);
image = image(:);
if mean(image) ~= 0
    image = image - mean(image(:));
    image = image / norm(image);
end
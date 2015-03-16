function [img,nrows,ncols] = readGreyScaleImage(imagefile)
img = double(imread(imagefile));
[nrows, ncols] = size(image);
img = img(:);
img = img - mean(img);
img = img / norm(img);
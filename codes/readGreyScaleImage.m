function [img,nrows,ncols] = readGreyScaleImage(imagefile)
img = double(imread(imagefile));
[nrows, ncols] = size(image);
img = img(:);
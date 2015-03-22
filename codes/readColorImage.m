function [greyScaleImage,rawImage] = readColorImage(file)
rawImage = imread(file);
greyScaleImage = squeeze(mean(rawImage,3));
%greyScaleImage = double(histeq(uint8(greyScaleImage)));
greyScaleImage = greyScaleImage / norm(greyScaleImage);
function [greyScaleImage,rawImage] = readColorImage(file)
rawImage = imread(file);
greyScaleImage = squeeze(mean(rawImage,3));
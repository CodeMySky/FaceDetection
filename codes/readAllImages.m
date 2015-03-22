function [imageMatrix, nrows, ncols]  = readAllImages(folder)
imagePaths = dir([folder,'/*.pgm']);
[nextImage, nrows, ncols] = readGreyScaleImage([folder,'/',imagePaths(1).name]);
imageMatrix = zeros(nrows * ncols, length(imagePaths));
imageMatrix(:,1) = nextImage;
for i = 2:length(imagePaths)
    nextImage = readGreyScaleImage([folder,'/',imagePaths(i).name]);
    imageMatrix(:,i) = nextImage;
end
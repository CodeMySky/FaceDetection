function [imageMatrix, nrows, ncols]  = readAllImages(folder, num)
imagePaths = dir([folder,'/*.pgm']);
[nextImage, nrows, ncols] = readGreyScaleImage([folder,'/',imagePaths(1).name]);
imageMatrix = zeros(nrows * ncols, length(imagePaths));
imageMatrix(:,1) = nextImage;
if isEmpty(num)
    num = length(imagePaths);
end
for i = 2:num
    nextImage = readGreyScaleImage([folder,'/',imagePaths(i).name]);
    imageMatrix(:,i) = nextImage;
end
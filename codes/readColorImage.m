function greyScaleImage = readColorImage(file)
colorImage = imread(file);
greyScaleImage = squeeze(mean(colorImage,3));
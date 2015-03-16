function imgMatrix  = readAllImages(folder)
imgs = dir([folder,'/*.pgm']);
imgMatrix = zeros(4096, length(imgs));
for i = 1:length(imgs)
    nextImg = readGreyScaleImage([folder,'/',imgs(i).name]);
    imgMatrix(:,i) = nextImg;
end
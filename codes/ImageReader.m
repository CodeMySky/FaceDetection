classdef ImageReader <handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function [image, nrows, ncols] = readGreyScaleImage(imagefile)
            %image = double(imread(imagefile));
            image = double(histeq(imread(imagefile)));
            [nrows, ncols] = size(image);
            image = image(:);
            image = image - mean(image(:));
            n = norm(image(:));
            if n ~= 0
                image = image / n;
            else
                image = ones(nrows*ncols,1)/(nrows*ncols);
            end
        end
        function [greyScaleImage,rawImage] = readColorImage(file)
            rawImage = imread(file);
            greyScaleImage = squeeze(mean(rawImage,3));
        end
        
        function [imageMatrix, nrows, ncols]  = readAllImages(folder)
            imagePaths = dir([folder,'/*.pgm']);
            [nextImage, nrows, ncols] = ImageReader.readGreyScaleImage([folder,'/',imagePaths(1).name]);
            imageMatrix = zeros(nrows * ncols, length(imagePaths));
            imageMatrix(:,1) = nextImage;
            for i = 2:length(imagePaths)
                nextImage = ImageReader.readGreyScaleImage([folder,'/',imagePaths(i).name]);
                imageMatrix(:,i) = nextImage;
            end
        end
    end
    
end


classdef simpleFaceDetector < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        primaryFace;
        greyScaleImage;
        rawImage;
        nRow;
        nCol;
        scaleSet = [0.5,0.75,1,1.5,2];
    end
    
    methods
        function obj=simpleFaceDetector()
            [obj.primaryFace, obj.nRow, obj.nCol] = eigenFace('lfw1000',1);
            obj.primaryFace = reshape(obj.primaryFace, obj.nRow, obj.nCol);
        end
        function detect(obj,filename, nFace)
            [obj.greyScaleImage, obj.rawImage] = readColorImage(filename);
            isFirst = true;
            % detect face under different scale
            for i = obj.scaleSet
                resizedImage = imresize(obj.greyScaleImage,size(obj.greyScaleImage) * i);
                hotMap = hotmap(resizedImage, obj.primaryFace);
                hotMap = imresize(hotMap, size(obj.greyScaleImage));
                if (isFirst)
                    sizeMap = ones(size(image,1), size(image,2)) * i;
                    bestMap = hotMap;
                    isFirst = false;
                else
                    higherPoints = bestMap < hotMap;
                    sizeMap(higherPoints) = i;
                    bestMap(higherPoints) = hotMap(higherPoints);
                end
            end
            
            % find local maximum
            hLocalMax = vision.LocalMaximaFinder;
            hLocalMax.MaximumNumLocalMaxima = nFace;
            hLocalMax.NeighborhoodSize = [floor(size(image,1)/6)*2+1 floor(size(image,2)/6)*2+1];
            threshold = mean(hotMap(:)) + std(hotMap(:));
            hLocalMax.Threshold = threshold;
            locations = step(hLocalMax, hotMap);
            figure(1);
            imagesc(obj.rawImage);
            
            for j = 1:size(locations,1)
                y = locations(j,1);
                x = locations(j,2);
                len = 64 / sizeMap(y,x);
                disp([y,x]);
                disp('Once');
                rectangle('Position',[y x len len], 'LineWidth',2, 'EdgeColor','b');
            end
            figure;
            colormap('hot');   % set colormap
            imagesc(hotMap);
        end
    end
    
end


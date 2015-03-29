classdef SimpleFaceDetector < handle
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
        function obj=SimpleFaceDetector()
            [obj.primaryFace, obj.nRow, obj.nCol] = Eigen.eigenFace('lfw1000',1);
            obj.primaryFace = reshape(obj.primaryFace, obj.nRow, obj.nCol);
        end
        
        function detect(obj,filename, nFace)
            [obj.greyScaleImage, obj.rawImage] = ImageReader.readColorImage(filename);
            isFirst = true;
            % detect face under different scale
            for i = obj.scaleSet
                resizedImage = imresize(obj.greyScaleImage,size(obj.greyScaleImage) * i);
                hotMap = obj.generateHotmap(resizedImage);
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
            hold on;
            for j = 1:size(locations,1)
                x = locations(j,1);
                y = locations(j,2);
                len = 64 / sizeMap(x,y);
                rectangle('Position',[x y len len], 'LineWidth',2, 'EdgeColor','b');
            end
            figure(2);
            colormap('hot');   % set colormap
            imagesc(hotMap);
        end
        
        function map = generateHotmap(obj,image)
            obj.primaryFace= obj.primaryFace/norm(obj.primaryFace(:));
            [P, Q] = size(image);
            [N, M] = size(obj.primaryFace);

            %pixelsinpatch = N * M; %The size of the eigenface is N x M.
            %first compute the integral image
            integralImage = cumsum(cumsum(image,1),2);

            %Now, at each pixel compute the mean
            patchmeansofImage = zeros(P,Q);
            for i = 1:(P-N+1)
                for j = 1:(Q-M+1)
                    a1 = 0;a2 = 0;a3 = 0;
                    if (i > 1 && j > 1)
                        a1 = integralImage(i-1,j-1);
                    end
                    if (j > 1)
                        a2 = integralImage(i+N-1,j-1);
                    end
                    if (i > 1)
                        a3 = integralImage(i-1,j+M-1);
                    end
                    a4 = integralImage(i+N-1,j+M-1);
                    patchmeansofImage(i,j) = (a4 + a1 - a2 - a3)/(N*M);
                end
            end
            map = zeros(P,Q);
            pEigenFace = pinv(obj.primaryFace(:));
            for i = 1:(P-N)
                disp(i)
                for j = 1:(Q-M)
                    patch = image(i:i+N-1,j:j+M-1);
                    patch = patch - patchmeansofImage(i,j);
                    if (norm(patch(:)) ~= 0)
                        patch = patch / norm(patch(:));
                    else
                        patch = ones(N,M)/(N*M);
                    end

                    map(i,j) = pEigenFace * patch(:);
                end
            end
        end
    end
    
end


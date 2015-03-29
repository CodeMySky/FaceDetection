classdef Eigen
    %UNTITLED11 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods(Static)
        function [face, nrows, ncols] = eigenFace(folder, nFace)
            [imageMatrix, nrows, ncols] = ImageReader.readAllImages(folder);
            [faces,~,~] = svd(imageMatrix, 0);
            face = faces(:,1:nFace);
        end
    end
    
end


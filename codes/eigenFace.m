function [face, nrows, ncols] = eigenFace(folder, nFace)
[imageMatrix, nrows, ncols] = readAllImages(folder);
[faces,~,~] = svd(imageMatrix, 0);
face = faces(:,1:nFace);
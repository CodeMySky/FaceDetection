function [face, nrows, ncols] = eigenFace(folder, nFace)
[imageMatrix, nrows, ncols] = readAllImages(folder);
[face,~,~] = svds(imageMatrix, nFace);
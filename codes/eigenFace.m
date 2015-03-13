function face = eigenFace(folder)
imgMatrix = readAllImages(folder);
[U,S,V] = svds(imgMatrix, 1);
eigenface = U;
face = reshape(eigenface,[64 64]);
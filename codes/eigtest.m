imgMatrix = readAllImages('lfw1000/');
corrmatrix = imgMatrix * imgMatrix';
[eigvecs, eigvals] = eig(corrmatrix);
plot(diag(eigvals));
eigface = eigvecs(:,4096);
eigfaceimg = reshape(eigface,[64 64]);
imshow(eigfaceimg)


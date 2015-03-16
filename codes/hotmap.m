function map = hotmap(image, eigenFace)
eigenFace= eigenFace/norm(eigenFace(:));
[P, Q] = size(image);
[N, M] = size(eigenFace);
map = zeros(P-N, Q-M);

%pixelsinpatch = N * M; %The size of the eigenface is N x M.
%first compute the integral image
integralImage = cumsum(cumsum(image,1),2);

%Now, at each pixel compute the mean
patchmeansofImage = zeros(P,Q);
for i = 1:(P-N+1)
    for j = 1:(Q-M+1)
        a1 = integralImage(i,j);
        a2 = integralImage(i+N-1,j);
        a3 = integralImage(i,j+M-1);
        a4 = integralImage(i+N-1,j+M-1);
        patchmeansofImage(i,j) = a4 + a1 - a2 - a3;
    end
end
tmpim = conv2(image, rot90(eigenFace,2));
convolvedimage = tmpim(N:end, M:end);
sumE = sum(eigenFace(:));
map = convolvedimage - sumE * patchmeansofImage(1:size(convolvedimage,1),1:size(convolvedimage,2));

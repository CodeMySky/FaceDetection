function map = hotmap(image, eigenFace)
eigenFace= eigenFace/norm(eigenFace(:));
[P, Q] = size(image);
[N, M] = size(eigenFace);

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
pEigenFace = pinv(eigenFace(:));
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
% tmpim = conv2(image, rot90(eigenFace,2));
% convolvedimage = tmpim(N:end, M:end);
% sumE = sum(eigenFace(:));
% map = convolvedimage - sumE * patchmeansofImage(1:size(convolvedimage,1),1:size(convolvedimage,2));
% map = map(1:P-N, 1:Q-M);

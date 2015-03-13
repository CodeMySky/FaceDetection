function map = hotmap(image, eigenFace)
eigenFace= eigenFace/norm(eigenFace(:));
[P, Q] = size(image);
[N, M] = size(eigenFace);
map = zeros(P-N, Q-M);
for i = 1:(P-N)
    for j = 1:(Q-M)
        patch = I(i:i+N-1,j:j+M-1);
        map(i,j) = eigenFace(:)'* patch(:) / norm(patch(:));
    end
end
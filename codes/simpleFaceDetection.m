function locations = simpleFaceDetection(filename)
[image, rawImage] = readColorImage(filename);
[face, nrows, ncols] = eigenFace('lfw1000',1);
face = reshape(face, nrows, ncols);
isFirst = true;
for i=[1];%[0.5,0.75,1,1.5,2]
    map = hotmap(imresize(image,[size(image,1)*i,size(image,2)*i]), face);
    map = imresize(map, [size(image,1), size(image,2)]);
    if (isFirst)
        sizeMap = ones(size(image,1), size(image,2)) * i;
        hotMap = map;
        isFirst = false;
    else
        higherPoints = hotMap < map;
        sizeMap(higherPoints) = i;
        hotMap(higherPoints) = map(higherPoints);
    end
end
hLocalMax = vision.LocalMaximaFinder;
hLocalMax.MaximumNumLocalMaxima = 1;
hLocalMax.NeighborhoodSize = [floor(size(image,1)/6)*2+1 floor(size(image,2)/6)*2+1];
threshold = mean(hotMap(:)) + std(hotMap(:));
hLocalMax.Threshold = threshold;
locations = step(hLocalMax, hotMap);
figure;
imagesc(rawImage);
colormap('hot');   % set colormap
for j = 1:size(locations,1)
    y = locations(j,1);
    x = locations(j,2);
    len = 64 / sizeMap(y,x);
    disp([y,x]);
    disp('Once');
    rectangle('Position',[y x len len], 'LineWidth',2, 'EdgeColor','b');
end
figure;
imagesc(hotMap);

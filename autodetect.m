[image, rawImage] = readColorImage('MLSP_Images/Image1.jpg');
face = eigenFace('lfw1000');
hLocalMax = vision.LocalMaximaFinder;
hLocalMax.MaximumNumLocalMaxima = 3;
hLocalMax.NeighborhoodSize = [123 123];
hLocalMax.Threshold = 700;
figure;
for i=[1]
    map = hotmap(imresize(image,[size(image,1)*i,size(image,2)*i]), face);
    colormap('hot');   % set colormap
    imagesc(map);        % draw image and scale colormap to values range
    colorbar;
    locations = step(hLocalMax, map);
    figure;
    imagesc(rawImage);
    hold on;
    for j = 1:size(locations,1)
        x = locations(j,1) / i;
        y = locations(j,2) / i;
        len = 64 /i;
        disp([x,y]);
        disp('Once');
        rectangle('Position',[x y len len], 'LineWidth',2, 'EdgeColor','b');
    end
    hold off;
    pause(5);
    
end

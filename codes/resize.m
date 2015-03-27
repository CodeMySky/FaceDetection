function resizedImage = resize(originalImage, oldSize, newSize)
originalImage = reshape(originalImage,oldSize);
resizedImage = imresize(originalImage,newSize);
resizedImage = resizedImage(:);
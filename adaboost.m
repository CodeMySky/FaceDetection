nFeature = 10;

% %read in training set
% [trainingFace, nRowsTrain, nColsTrain] = readAllImages('BoostingData/train/face');
% trainingNonFace = readAllImages('BoostingData/train/non-face');
% trainingSet = [trainingFace, trainingNonFace];
% nTrainingFace = length(trainingFace) + length(trainingNonFace);
% 
% %prepare eigen faces
% [eigenfaces, nRowsEigen, nColsEigen] = eigenFace('lfw1000', nFeature);
% resizedEigenFaces = zeros(nRowsTrain * nColsTrain, nFeature);
% for i=1:nFeature
%     resizedEigenFaces(:,i) = resize(eigenfaces(:,i), [nRowsEigen, nColsEigen], [nRowsTrain, nColsTrain]);
% end

% fill in class
% linearCombination = zeros(nTrainingFace, nFeature);
% y = ones(nTrainingFace, 1);
% y((length(trainingFace)+1):nTrainingFace) = -1;
% % initial distribution with 1/N
% for i = 1 : nFeature
%     linearCombination(:, i) = resizedEigenFaces(:,i)' * trainingSet;
%     trainingSet = trainingSet - (linearCombination(:,i) * resizedEigenFaces(:,i)')';
% end
nClassifier = 10;
distribution = ones(nTrainingFace, 1) / nTrainingFace;
weights = zeros(nFeature,1);
signs = ones(nFeature, 1);
thresholds = zeros(nFeature,1);
classifiers = zeros(nFeature,1);

for i = 1:nClassifier
    bestClassifier = 1;
    bestThreshold = 0;
    bestErrorRate = 1;
    bestSign = 1;
    for j = 1:nFeature
        featureValues = linearCombination(:,j);
        minValue = min(featureValues);
        maxValue = max(featureValues);
        delta = maxValue - minValue;
        for k = 1:50
            threshold = minValue + delta / 50 * k;
            prediction = 2 * (featureValues > threshold) - 1;
            %prediction = weight > threshold;
            
            errors = (prediction .* y) < 0;
            errorRate =  sum(errors .* distribution);
            sign = 1;
            if errorRate > 0.5
                sign = -1;
                errorRate = 1 - errorRate;
                prediction = -prediction;
            end
            if errorRate < bestErrorRate
                bestClassifier = j;
                bestErrorRate = errorRate;
                bestThreshold = threshold;
                bestSign = sign;
                bestPrediction = prediction;
            end
        end
    end
    weights(i) = log((1-bestErrorRate)/bestErrorRate)/2;
    signs(i) = bestSign;
    thresholds(i) = bestThreshold;
    classifiers(i) = bestClassifier;
    rightness = bestPrediction .* y;
    distribution = distribution .* exp(-weights(i) .* rightness);
    distribution = distribution / sum(distribution);
end

% for i = 1:nFeature
%     linearCombination(:,1) = resizedEigenFaces(:,i)' * trainingSet;
%     sortedCombination = sortrows(linearCombination);
%     score = cumsum(sortedCombination(:,2));
%     [~, index] = max(score);
%     thresholds(i) = sortedCombination(index,1);
%     sign(i) = 1;
%     percent = index / nTrainingFace;
%     if index == 1 || index == nTrainingFace
%         [~, index]= min(score);
%         thresholds(i) = sortedCombination(index,1);
%         sign(i) = -1;
%     end
%     predict = (linearCombination(:,1) <= thresholds(i)) * sign(i) * 2 - sign(i);
%     rightness = predict .* linearCombination(:,2);
%     error = rightness < 0;
%     nError = sum(distribution .* error);
%     weight(i) = log((1-nError)/nError)/2;
%     distribution = distribution .* exp(-weight(i) * rightness);
%     distribution = distribution / sum(distribution);
%     trainingSet = trainingSet - (linearCombination(:,1) * resizedEigenFaces(:,1)')';
% end

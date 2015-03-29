classdef Classifier < handle
    %CLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nFeature = 25;
        nClassifier = 20;
        threshHold = -2;
        nTraining;
        errors;
        weights;
        signs;
        thresholds;
        classifiers;
        featureMatrix;
        trainLabels;
        eigenFaces;
        nRows;
        nCols;
        nFace;
        nNonFace;
        trainingSet;
        useResidual = 1;
    end
    
    methods
        function obj = Classifier(trainingFolder)
            % read in training set
            [trainingFace, obj.nRows, obj.nCols] = readAllImages([trainingFolder,'/face']);
            trainingNonFace = readAllImages([trainingFolder,'/non-face']);
            %equalSize = min([length(trainingFace),length(trainingNonFace)]);
            %trainingFace = trainingFace(:,1:equalSize);
            %trainingNonFace = trainingNonFace(:,1:equalSize);
            obj.nFace = length(trainingFace);
            obj.nNonFace = length(trainingNonFace);
            
            obj.trainingSet = [trainingFace, trainingNonFace];
            obj.nTraining = obj.nFace + obj.nNonFace;
            
            % prepare eigen faces
%             [obj.eigenFaces] = eigenFace([trainingFolder,'/face'], obj.nFeature);
            [eigenfaces, nRowsEigen, nColsEigen] = eigenFace('lfw1000', obj.nFeature);
            obj.eigenFaces = zeros(obj.nRows * obj.nCols, obj.nFeature);
            for i=1:obj.nFeature
                obj.eigenFaces(:,i) = resize(eigenfaces(:,i), [nRowsEigen, nColsEigen], [obj.nRows, obj.nCols]);
            end
            
            
        end
        function decompose(obj)
            obj.featureMatrix = zeros(obj.nTraining, obj.nFeature);
            
            
            trainingMatrix = obj.trainingSet(1:end,1:end);
            for i = 1 : (obj.nFeature  - obj.useResidual)
                obj.featureMatrix(:, i) = pinv(obj.eigenFaces(:,i)) * trainingMatrix;
                expressablePart = obj.eigenFaces(:,i) * obj.featureMatrix(:, i)';
                trainingMatrix = trainingMatrix - expressablePart;
            end
            
            if (obj.useResidual)
                obj.featureMatrix(:,obj.nFeature) = sum(trainingMatrix.^2)/(obj.nRows* obj.nCols);
            end
        end
        
        function fit(obj)
            obj.trainLabels = [ones(obj.nFace, 1); -ones(obj.nNonFace,1)];
            obj.weights = zeros(obj.nClassifier,1);
            obj.errors = zeros(obj.nClassifier,1);
            obj.signs = ones(obj.nClassifier, 1);
            obj.thresholds = zeros(obj.nClassifier,1);
            obj.classifiers = zeros(obj.nClassifier,1);
            
            
            % Initialize distribution as equally distributed
            distribution = ones(obj.nTraining, 1) / obj.nTraining;
            
            % Begin to find n weak classifiers
            for i = 1 : obj.nClassifier
                bestFeature = 1;
                bestThreshold = 0;
                bestErrorRate = 1;
                bestSign = 1;
                % Search among different features
                for j = 1 : obj.nFeature
                    featureValues = obj.featureMatrix(:,j);
                    minValue = min(featureValues);
                    maxValue = max(featureValues);
                    delta = maxValue - minValue;
                    % Search for best threshold for this classifier
                    for k = 1 : 50
                        % calculate threshold for testing
                        threshold = minValue + delta / 50 * k;
                        sign = 1;
                        % predict using this threshold, +1/-1
                        prediction = 2 * (featureValues >= threshold) - 1;
                        % select out wrong ones
                        errorOnes = (prediction .* obj.trainLabels) < 0;
                        % accumulate the error rate for compare
                        errorRate =  sum(errorOnes .* distribution);
                        
                        % reverse the result if get wrong on more than 50%.
                        if errorRate > 0.5
                            sign = -1;
                            errorRate = 1 - errorRate;
                            prediction = -prediction;
                        end
                        
                        % compare current result with best result.
                        % update if better
                        if errorRate < bestErrorRate
                            bestFeature = j;
                            bestErrorRate = errorRate;
                            bestThreshold = threshold;
                            bestSign = sign;
                            bestPrediction = prediction;
                        end
                    end
                end
                % we selected out the best feature.
                alpha = log((1-bestErrorRate)/bestErrorRate)/2;
                obj.errors(i) = bestErrorRate;
                obj.weights(i) = alpha;
                obj.signs(i) = bestSign;
                obj.thresholds(i) = bestThreshold;
                obj.classifiers(i) = bestFeature;
                
                % adjust distribution, decrease wrong ones and
                % increase right ones
                rightness = bestPrediction .* obj.trainLabels;
                distribution = distribution .* exp(-alpha * rightness);
                distribution = distribution / sum(distribution);
            end
        end
        
        function isFace = predict(obj, testImage)
            %testImage = imresize(testImage, obj.nRows, obj.nCols);
            imageVector = testImage(:);
            features = zeros(1,obj.nFeature);
            for i = 1 : (obj.nFeature - obj.useResidual)
                features(1, i) = pinv(obj.eigenFaces(:,i)) * imageVector;
                expressablePart = obj.eigenFaces(:,i) * features(1, i)';
                imageVector = imageVector - expressablePart;
            end
            if (obj.useResidual)
                features(1,obj.nFeature) = sum(imageVector.^2)/length(imageVector);
            end
            score = 0;
            for i = 1 : obj.nClassifier
                classifier = obj.classifiers(i);
                threshold = obj.thresholds(i);
                sign = obj.signs(i);
                weight = obj.weights(i);
                prediction = (2 * (features(1,classifier) >= threshold) - 1) * sign;
                score = score + prediction * weight;
            end
            isFace = 2*(score > obj.threshHold)-1;
        end
        
        function set.nFeature(obj,value)
            obj.nFeature = value;
        end
        
        function set.nClassifier(obj,value)
            obj.nClassifier = value;
        end
    end
    
end


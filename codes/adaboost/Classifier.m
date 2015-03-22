classdef Classifier < handle
    %CLASSIFIER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nFeature = 10;
        nClassifier = 10;
        nTraining;
        weights;
        signs;
        thresholds;
        classifiers;
        featureMatrix;
        trainLabels;
    end
    
    methods
        function obj = Classifier(trainingFolder)
            % read in training set
            [trainingFace, nRowsTrain, nColsTrain] = readAllImages([trainingFolder,'/face']);
            trainingNonFace = readAllImages([trainingFolder,'/non-face']);
            trainingSet = [trainingFace, trainingNonFace];
            obj.nTraining = length(trainingSet);
            
            % prepare eigen faces
            % TODO: replace eigenface using training face
            [eigenfaces, nRowsEigen, nColsEigen] = eigenFace('lfw1000', obj.nFeature);
            resizedEigenFaces = zeros(nRowsTrain * nColsTrain, obj.nFeature - 1);
            for i=1:obj.nFeature -1
                resizedEigenFaces(:,i) = resize(eigenfaces(:,i), [nRowsEigen, nColsEigen], [nRowsTrain, nColsTrain]);
            end
            
            % initialze features and labels
            obj.featureMatrix = zeros(obj.nTraining, obj.nFeature);
            
            nFace = length(trainingFace);
            nNonFace = length(trainingNonFace);
            obj.trainLabels = [ones(nFace, 1); -ones(nNonFace,1)];
            
            obj.weights = zeros(obj.nFeature,1);
            obj.signs = ones(obj.nFeature, 1);
            obj.thresholds = zeros(obj.nFeature,1);
            obj.classifiers = zeros(obj.nFeature,1);
            
            % initial distribution with 1/N
            for i = 1 : obj.nFeature - 1
                obj.featureMatrix(:, i) = resizedEigenFaces(:,i)' * trainingSet;
                trainingSet = trainingSet - (obj.featureMatrix(:,i) * resizedEigenFaces(:,i)')';
            end
            
            obj.featureMatrix(:,obj.nFeature) = sum(trainingSet.^2)/size(obj.featureMatrix,1);
        end
        
        function obj = fit(obj)
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
                        prediction = 2 * (featureValues > threshold) - 1;
                        % select out wrong ones
                        errors = (prediction .* obj.trainLabels) < 0;
                        % accumulate the error rate for compare
                        errorRate =  sum(errors .* distribution);
                        
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
        function set.nFeature(obj,value)
            obj.nFeature = value;
        end
        function set.nClassifier(obj,value)
            obj.nClassifier = value;
        end
    end
    
end


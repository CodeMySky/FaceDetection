testFace = readAllImages('BoostingData/test/face');
testNonFace = readAllImages('BoostingData/test/non-face');
testNonFace = [];
c = Classifier('BoostingData/train/');
% equalSize = min([length(testFace),length(testNonFace)]);
% testFace = testFace(:,1:equalSize);
% testNonFace = testNonFace(:,1:equalSize);
testSet = [testFace,testNonFace];
c.decompose();
c.fit();
y_hat = zeros(1, size(testSet,2));
y_real = [ones(1, size(testFace,2)),-ones(1, size(testNonFace,2))];


for k = 1:size(testSet,2)
    y_hat(k) = c.predict(testSet(:,k));
end
accuracy = sum(y_hat(1:size(testSet,2)) == y_real(1:size(testSet,2)))/size(testSet,2);
disp(accuracy);
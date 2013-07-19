function [predictedTgts,dcdObj] = KNNdecoder(trainingX, trainingY, testX, numNeighbors, distance)

% function [predictedTgts,dcdObj] = KNNdecoder(trainingX, trainingY, testX, numNeighbors, distance)
% 
% k-Nearest Neighbor classifier decoder -- assigns predicted target based on target for n nearest-neighbor training trials
% 
% INPUTS (see ClassificationKNN for further details):
% numNeighbors  Number of nearest neighbors to find in trainingX to find for classifying each point (trial) in testX
% distance      Name of distance metric to use to calculate neighborhood.  Values include: 
%               'cityblock','euclidean','seuclidean','mahalanobis'. 'cityblock' seems to work best for us.
% 
% OUTPUTS:
% dcdObj      Classification object variable returned by ClassificationKNN.fit

% Remove any predictors from X (both training and testing) that are all 0
zeroPreds = all(trainingX == 0,1);
trainingX(:,zeroPreds) = [];
if ~isempty(testX)
  testX(:,zeroPreds) = [];
end

% Fit k-Nearest Neighbor classifier to training data
dcdObj = ClassificationKNN.fit(trainingX, trainingY, ...
              'NumNeighbors',numNeighbors, 'Distance',distance, 'BreakTies','nearest');

% Predicted response on the test trial(s)
if ~isempty(testX)
  predictedTgts = predict(dcdObj,testX);
else                  % (or you may just want to fit the decoder model, return its object,
  predictedTgts = []; %  w/o making any predictions)
end

end

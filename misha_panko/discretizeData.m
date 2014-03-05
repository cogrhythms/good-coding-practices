function discreteData = discretizeData(data, nBins, method)

% Discretize data into nBins equal sized and linearly spaced bins

switch method
    
    % equally spaced discretization
    case 'eq-space'
        discreteData = nan(size(data));
        for c = 1:size(data,2)
            step = range(data(:,c))/nBins;
            offset = min(data(:,c));
            %discreteData(:,c) = ceil((data(:,c)-offset+1e-99)/step);
            discreteData(:,c) = floor((data(:,c)-offset)/step)+1;
            discreteData(discreteData(:,c)==(nBins+1),c) = nBins;
        end
        
    % equally populated discretization
    case 'eq-popul'
        [nTr, nCh] = size(data);
        discreteData = nan(size(data));
        for c = 1:nCh
            %sortedMtx = sortrows([data(:, c), [1:nTr]']);
            %binnedMtx = ceil([1:nTr]'/nTr*nBins);
            %unsortedMtx = sortrows([sortedMtx(:,2), binnedMtx]);
            %discreteData(:,c) = unsortedMtx(:,2);
            edges = quantile(data(:,c), [0:1/nBins:1]);
            [~, discreteData(:,c)] = histc(data(:,c), edges);
            discreteData(discreteData(:,c)==(nBins+1),c) = nBins;
        end
       
end

%%%%%% OLD METHODS
%% discretize data in place
% step = range(data)/nBins;
% offset = min(data);
% discreteData = floor((data-offset)/step);
% discreteData(discreteData==nBins) = nBins-1;
% discreteData = discreteData*step+offset+step/2;
% 
% figure('position', get(0,'ScreenSize'));
% [n, xout] = hist(discreteData, [0:nBins-1]*step+offset+step/2);
% bar(xout, n, 'FaceColor', 'red');
% hold on;
% [n, xout] = hist(data, unique(data));
% bar(xout, n, 'FaceColor', 'blue');
% grid on;

%% discretize data lumping outliers together and scale it to [0:nBins-1]
% outlierRatio = 1/nBins/2;
% midRange = quantile(data, [outlierRatio, 1-outlierRatio]);
% adjRangeSize = diff(midRange)/(1-2*outlierRatio);
% step = adjRangeSize/nBins;
% offset = midRange(1)-adjRangeSize*outlierRatio;
% discreteData = floor((data-offset)/step);
% discreteData(discreteData<0) = 0;
% discreteData(discreteData>(nBins-1)) = nBins-1;
% 
% figure('position', get(0,'ScreenSize'));
% [n, xout] = hist(discreteData, [0:nBins-1]);
% bar(xout, n, 'FaceColor', 'red');
% grid on;

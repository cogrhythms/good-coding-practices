function trData = extractTrialData(data, trTimes, timeWnd, sampFreq, startTime)

% Extract data by trials

numTr = length(trTimes);
if nargin<4
    
    % discrete data (spikes)
    trWnds = [trTimes+timeWnd(1), trTimes+timeWnd(2)];
    trData = cell(numTr, 1);
    for tr = 1:numTr
        trData{tr} = data( data>=trWnds(tr,1) & data<=trWnds(tr,2) ) - trTimes(tr);
    end
    
else
    
    % continuous data (LFPs, MUAs, ...)
    idx = [ round(timeWnd(1)/1000*sampFreq) : round(timeWnd(2)/1000*sampFreq) ]';
    idx = repmat(round((trTimes-startTime)'/1000*sampFreq), [length(idx),1]) + repmat(idx, [1,length(trTimes)]) + 1;
    trData = data(idx);
    
end



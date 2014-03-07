%function [features, params] = extractLfpFeaturesMulti(params)

% Extract and save LFP features from the data

% set parameters
% params.session = 'SS050511';
% params.chs = [1:14];
% params.sigType = 'lfp';
% params.freqWnd = [15, 20; 20, 25]; % Hz
% params.alignEvt = 36; % go cue
% params.timeWnd = [-1000, -400]; % ms
% params.timeBinSize = 200; % ms

params.session = 'CS20120505';
params.chs = [1:32];
params.sigType = 'lfp';
params.freqWnd = [15, 20; 20, 25]; % Hz
params.alignEvt = 8; % go cue
params.timeWnd = [-750, -150]; % ms
params.timeBinSize = 200; % ms

nCh = length(params.chs);
nT = floor(diff(params.timeWnd)/params.timeBinSize);
nF = size(params.freqWnd, 1);

% load events
loadParams.session = params.session;
loadParams.dataType = 'evt';
Evt = loadData(loadParams);

% select only successful delayed-saccade trials
idxTr = selectTrials(params.session, Evt, 'success');
if params.session(1)=='C'
    % select delayed-saccade trials
    idxTrDlySacc = selectTrials(params.session, Evt, 'dly-sacc');
    idxTr = idxTr & idxTrDlySacc;
end
params.trials = idxTr;
nTr = sum(idxTr);

% find epoch times around which to extract data
evtID = Evt.EvtIDTrial(idxTr, :);
evtTimes = Evt.EvtTimesTrial(idxTr, :);
alignEvtTimes = evtTimes(evtID==params.alignEvt);

features = nan(nTr, nCh, nT, nF);
for iCh = 1:nCh
    lfpStr = ['lfp', num2str(params.chs(iCh), '%03d')];
    chNum = params.chs(iCh);
    
    % load lfp data
    loadParams.session = params.session;
    loadParams.dataType = 'lfp';
    loadParams.chs = chNum;
    Lfp = loadData(loadParams);
    
    params.lfpRef = 'ground';
    if params.session(1)=='C'
        % re-reference LFP data for BRA (better contrast between conditions)
        Lfp.(lfpStr) = referenceLfpByArea(Lfp.(lfpStr), params.session, chNum);
        params.lfpRef = 'area';
    end
    
    for iF = 1:nF
        
        % filter
        data = filterData(Lfp.(lfpStr), params.freqWnd(iF,:), Lfp.ChInfo(chNum).Fs);
        
        % rectify
        data = abs(hilbert(data));
        %data = abs(data);
        
        % extract trial data
        trData = extractTrialData(data, alignEvtTimes, params.timeWnd, Lfp.ChInfo(chNum).Fs, Lfp.ChInfo(chNum).StartTime);
        
        % break trial data into smaller time bins
        timeBinIdxSize = params.timeBinSize/1000*Lfp.ChInfo(chNum).Fs;
        trData = reshape(trData(1:timeBinIdxSize*nT,:), [timeBinIdxSize, nT, nTr]);
        
        % collapse data across time within trials
        trData = sum(trData, 1);
        features(:, iCh, :, iF) = shiftdim(trData, 2);
        
    end
    
    disp([num2str(iCh), '/', num2str(nCh)]);
end

% save features to disk
outputDir = ['C:\!analysis\', params.session];
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
save([outputDir, '\', params.session, '-features-multi.mat'], 'features', 'params');

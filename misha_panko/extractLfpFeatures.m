function [features, params] = extractLfpFeatures(params)

% Extract and save LFP features from the data

% set parameters
% params.session = 'SS050511';
% params.chs = [1:14];
% params.sigType = 'lfp';
% params.freqWnd = [30, 50]; % Hz
% params.alignEvt = 36; % go cue
% params.timeWnd = [-1000, 0]; % ms
% params.alignEvt = 44; % eye movement onset
% params.timeWnd = [-200, 400]; % ms

%params.session = 'CS20120505';
%params.chs = [1:96];
params.sigType = 'lfp';
%params.freqWnd = [0, 5]; % Hz
%params.alignEvt = 8; % go cue
%params.timeWnd = [-1100, -750]; % ms
% % params.alignEvt = 19; % eye movement onset
% % params.timeWnd = [-100, 800]; % ms

nCh = length(params.chs);

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

features = nan(nTr, nCh);
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
    
    % filter
    data = filterData(Lfp.(lfpStr), params.freqWnd, Lfp.ChInfo(chNum).Fs);
    
    % rectify
    data = abs(hilbert(data));
    %data = abs(data);
    
    % extract trial data
    trData = extractTrialData(data, alignEvtTimes, params.timeWnd, Lfp.ChInfo(chNum).Fs, Lfp.ChInfo(chNum).StartTime);
    
    % collapse data across time within trials
    features(:, iCh) = sum(trData, 1)';
    
    disp([num2str(iCh), '/', num2str(nCh)]);
end

% save features to disk
outputDir = ['C:\!analysis\', params.session];
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
%save([outputDir, '\', params.session, '-features-lfp-[', num2str(params.freqWnd(1)), '-', num2str(params.freqWnd(2)), 'Hz]-new.mat'], 'features', 'params');

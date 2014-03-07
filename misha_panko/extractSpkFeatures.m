%function [features, params] = extractSpkFeatures(params)

% Extract and save spike features from the data

% set parameters
params.session = 'SS050511';
params.chs = [1:14];
params.sigType = 'spk';
params.alignEvt = 44;%36; % go cue
params.timeWnd = [-200, 400]; % ms

% params.session = 'CS20120505';
% params.chs = [1:96];
% params.sigType = 'spk';
% params.alignEvt = 8; % go cue
% params.timeWnd = [-750, 0]; % ms

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

% load spike data
loadParams.session = params.session;
loadParams.dataType = params.sigType;
loadParams.chs = params.chs;
Spk = loadData(loadParams);

features = nan(nTr, 5*nCh);
idxUn = 0;
chSet = [];
unSet = [];
for iCh = 1:nCh
    chNum = params.chs(iCh);
    for iUn = 1:Spk.SpikeInfo(chNum).nUnits
        unNum = Spk.SpikeInfo(chNum).Units(iUn);
        unStr = ['nrn_c', num2str(chNum, '%03d'), '_u', num2str(unNum, '%02d')];
        idxUn = idxUn + 1;
        chSet(idxUn) = chNum;
        unSet(idxUn) = unNum;
        
        % extract trial data
        trData = extractTrialData(Spk.(unStr), alignEvtTimes, params.timeWnd);
        
        % compute spike counts
        for iTr = 1:nTr
            features(iTr, idxUn) = length(trData{iTr});
        end
        
    end
    disp([num2str(iCh), '/', num2str(nCh)]);
end
features = features(:, 1:idxUn);
params.chs = chSet;
params.uns = unSet;

% save features to disk
outputDir = ['C:\!analysis\', params.session];
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end
save([outputDir, '\', params.session, '-features-', params.sigType, '-new.mat'], 'features', 'params');

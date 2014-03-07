function unsortUnits(session)

% Unsort units in a specified session: combine single units from each
% channel into one multiunit

% input parameters
%session = 'SS050511';
%session = 'CS20120817';

tic;
disp(['SCRIPT: ', mfilename]);
disp(['START [', datestr(now), ']']);
disp(['session: ', session]);

% set parameters
analysisParams = setAnalysisParams(session);
newSpkType = 'spk-unsorted';
newWfsType = 'wfs-unsorted';

% load spikes and waveforms
loadParams.session = session;
loadParams.chs = analysisParams.chs;
loadParams.dataType = 'spk';
Spk = loadData(loadParams);
loadParams.dataType = 'wfs';
Wfs = loadData(loadParams);

% merge units for each channel into one (unsort them)
for ch = 1:length(Spk.SpikeInfo)
    
    % count total number of spikes on a channel
    nSpk = [];
    for un = 1:Spk.SpikeInfo(ch).nUnits
        unLbl = Spk.SpikeInfo(ch).Units(un);
        spkStr = ['nrn_c', num2str(ch, '%03d'), '_u', num2str(unLbl, '%02d')];
        nSpk = [nSpk, length(Spk.(spkStr))];
    end
    
    % merge units
    spk = nan(sum(nSpk), 1);
    wfs = nan(Wfs.WaveInfo(1).nSamples, sum(nSpk));
    pos = 1;
    for un = 1:Spk.SpikeInfo(ch).nUnits
        unLbl = Spk.SpikeInfo(ch).Units(un);
        spkStr = ['nrn_c', num2str(ch, '%03d'), '_u', num2str(unLbl, '%02d')];
        wfsStr = ['wfs_c', num2str(ch, '%03d'), '_u', num2str(unLbl, '%02d')];
        spk(pos:(pos+nSpk(un)-1)) = Spk.(spkStr);
        wfs(:, pos:(pos+nSpk(un)-1)) = Wfs.(wfsStr);
        Spk = rmfield(Spk, spkStr);
        Wfs = rmfield(Wfs, wfsStr);
        pos = pos + nSpk(un);
    end
    tmp = sortrows([spk, [1:length(spk)]']);
    spk = tmp(:, 1);
    wfs = wfs(:, tmp(:,2));
    Spk.(['nrn_c', num2str(ch, '%03d'), '_u00']) = spk;
    Wfs.(['wfs_c', num2str(ch, '%03d'), '_u00']) = wfs;
    if nSpk > 0
        Spk.SpikeInfo(ch).Units = 0;
        Spk.SpikeInfo(ch).nUnits = 1;
        Wfs.WaveInfo(ch).Units = 0;
        Wfs.WaveInfo(ch).nUnits = 1;
    else
        Spk.SpikeInfo(ch).Units = [];
        Spk.SpikeInfo(ch).nUnits = 0;
        Wfs.WaveInfo(ch).Units = [];
        Wfs.WaveInfo(ch).nUnits = 0;
    end
        
end

% save results to disk
save([analysisParams.dataPath, '\', session, '-', newSpkType, '.mat'], '-struct', 'Spk');
save([analysisParams.dataPath, '\', session, '-', newWfsType, '.mat'], '-struct', 'Wfs');

disp(['new spike data: ', newSpkType]);
disp(['new waveform data: ', newWfsType]);
disp(['DONE [',datestr(now),']']);
toc;
disp(' ');

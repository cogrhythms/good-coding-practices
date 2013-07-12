function refData = referenceLfpByArea(data, session, ch)

% Re-reference LFP data by implant area

switch session(1)
    
    case 'C'
        areaNames = {'PFC','SEF','FEF1','FEF2'};
        areaChs = {[1:32], [33:64], [65:78,81:83,87:89,93:94], [79:80,84:86,90:92,95:96]};
        for a = 1:length(areaNames)
            if any(areaChs{a}==ch)
                refStr = ['lfp', areaNames{a}];
            end
        end
        
        loadParams.session = session;
        loadParams.dataType = refStr;
        LfpRef = loadData(loadParams);
        refData = data - LfpRef.(refStr);
        
    case 'S'
        if ismember(ch, 1:8)
            chs = 1:8;
        elseif ismember(ch, 9:14)
             chs = 9:14;
        end
        
        disp(['loading lfp data from ', session, '...']);
        load(['C:\!data\shane\', session, '\', session, '_lfp_cnt.mat'], 'SampValues');
        disp('done.');
        refChData = mean(SampValues(:,chs), 2)*1000;
        refData = data - refChData;        
        
end
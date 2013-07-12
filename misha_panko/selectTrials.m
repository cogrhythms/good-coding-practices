function idx = selectTrials(session, Evt, trialType, condNum)

% Select conditions

switch trialType
    
    case 'success'
        idx = Evt.EventInfo.CorrectTrials;
        
    case 'dly-sacc'
        idx = (Evt.EventInfo.BlockNumber==1);
        
    case 'right-targets'
        switch session(1)
            case 'S'
                idx = ismember(Evt.EventInfo.TargetNumber, [1:2, 7:10, 16:18, 23:26, 32:34, 39:42, 48]);
            case 'C'
                idx = ismember(Evt.EventInfo.ExpectedResponse, [1:2, 6:7, 12:14, 18:19, 24:26, 30:31, 36]);
        end

    case 'specific-targets'
        switch session(1)
            case 'S'
                idx = ismember(Evt.EventInfo.TargetNumber, condNum);
            case 'C'
                idx = ismember(Evt.EventInfo.ExpectedResponse, condNum);
        end
        
    case 'specific-eccentricities'
        switch session(1)
            case 'S'
                condNum = find(ismember(ceil([1:48]/8), condNum));
                idx = ismember(Evt.EventInfo.TargetNumber, condNum);
            case 'C'
                condNum = find(ismember(ceil([1:36]/6), condNum));
                idx = ismember(Evt.EventInfo.ExpectedResponse, condNum);
        end
        
end
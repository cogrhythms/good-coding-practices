function conds = selectConditions(session, Evt, condType)

% Select conditions

switch condType
    
    case 'targets'
        switch session(1)
            case 'S'
                conds = Evt.EventInfo.TargetNumber;
            case 'C'
                conds = Evt.EventInfo.ExpectedResponse;
        end
        
    case 'targets-direction'
        switch session(1)
            case 'S'
                conds = mod(Evt.EventInfo.TargetNumber-1, 8)+1;
            case 'C'
                conds = mod(Evt.EventInfo.ExpectedResponse-1, 6)+1;
        end
        
    case 'targets-eccentricity'
        switch session(1)
            case 'S'
                conds = floor((Evt.EventInfo.TargetNumber-1)/8)+1;
            case 'C'
                conds = floor((Evt.EventInfo.ExpectedResponse-1)/6)+1;
        end

    case 'targets-2'
        switch session(1)
            case 'S'
                mask = [1; 1; 2; 2; 2; 2; 1; 1];
                conds = mask(mod(Evt.EventInfo.TargetNumber-1, 8)+1);
            case 'C'
                mask = [1; 1; 2; 2; 2; 1];
                conds = mask(mod(Evt.EventInfo.ExpectedResponse-1, 6)+1);
        end
        
    case 'images'
        switch session(1)
            case 'S'
                conds = Evt.EventInfo.ImageNumber;
            case 'C'
                error('NO IMAGE CONDITION FOR CHICO DATA!');
        end
        
end
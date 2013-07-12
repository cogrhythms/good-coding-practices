function newSig = transformSignal(oldSig, transformType)

switch transformType
    case 'sqrt'
        newSig = sqrt(oldSig);
    case 'log'
        newSig = log(oldSig);
    case 'cubic-root'
        newSig = oldSig.^(1/3);
    case 'none'
        newSig = oldSig;
end

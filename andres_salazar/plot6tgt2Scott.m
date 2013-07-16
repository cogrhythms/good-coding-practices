function plot6tgt2Scott
% function plot6tgt2Scott
% 
% You will need the TgtPlot params included below since these determine the subplot
% values. Then, just call the getSubPlot function indicating the target number. 
% The target number follows the convention used in the offlineBCI.m code: 1
% for zero degrees, 2 for 60 degrees, etc. Target 6 is 300 degrees.
%
% 
%% Plot target params
subPlot.rows = 12;
subPlot.colms = 12;
subPlot.subplot = {57:60,7:10,3:6,49:52,99:102,103:106};       %{[3:6],[7:10],[49:52],[57:60],[99:102],[103:106]};

%% For each target
for iTgt = 1:nTgts          %nTgts must be 6 for the plotInfo params used
    % Select the subplot based on the target number
    get6TgtSubPlot(iTgt,subPlot), hold on
    % Now you can plot here whatever you want since the subplot has already
    % being assigned
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function get6TgtSubPlot(iTgt,subPlot)
% function get6TgtSubPlot(iTgt,subPlot)
%
% Selects the subplot based on the target number (iTgt)
%
% iTgt: target location following offlineBCI target distribution
%

tgtLoc = subPlot.subplot{iTgt};
plotLoc = [tgtLoc,tgtLoc + subPlot.colms,tgtLoc + 2*subPlot.colms,tgtLoc + 3*subPlot.colms];
subplot(subPlot.rows,subPlot.colms,plotLoc);

end

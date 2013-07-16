function [nsSize2,nsSize5,Fs,sessionList] = nsSessionSize(session)
% function [nsSize2,nsSize5,Fs,sessionList] = nsSessionSize(session)
%
% Usage: [nsSize2,nsSize5,Fs,sessionList] = nsSessionSize('CS20120817') or
%        [nsSize2,nsSize5,Fs,sessionList] = nsSessionSize
% 
% Checks size of and black rock raw datafile to check if the sampling
% frequency was 30kHz or 1kHz. If no session is in the input, all sessions 
% with CSYYYMMDD format are search in the dirs.DataIn folder 
%
% INPUT:
% session:      Name of the files following the CS20120919 format. monkey,
%               task, year, month, day.
%
% Output:
% nsSizeX:      structure. X e (2,5). The structure has the field 'byte': 
%               data size.
% Fs:           sampling frequency. Nan is session does not exist
% sessionList:  list of sessions for 1 kHz Fs
%
% Last modified: Andres. 28 april 2013

% Server path
dirs.DataIn     = 'https://github.com/mikpanko/good-coding-practices';

% Vbles for data size analysis
divGb = 1e9;            % For files in gigabytes

%% Input vbles. Reading all sessions in server or only the designated session
if nargin < 1
    fileList = dir(dirs.DataIn);
    
    fileNames = {fileList(:).name};
    %Finding only files for delaysaccade paradigm 'CS'
    csFiles = strfind(fileNames,'CS');
    
    % Not the best way to include the empty cell but thisworks!
    csIndx = nan(1,length(cell2mat(csFiles)));
    csK = 0;
    for jj = 1:length(fileNames)
        IndxVal = csFiles{jj};
        if ~isempty(IndxVal)
            csK = csK + 1;
            csIndx(csK) = jj;
        end
    end
    sessionList = {fileNames{csIndx}};
else
    sessionList{1} = session;
end

%% Calculating files sizes
% disp(sessionList)
nSessions = length(sessionList);
nsSize2 = repmat( struct(...
    'name',     '',...
    'date',     '',...
    'bytes',    nan,...
    'isdir',    nan,...
    'datenum',  nan),...
    [1 nSessions] );

nsSize5 = nsSize2;

% Choosing CS sessions only
for ii = 1:nSessions
    % Session
    session = sessionList{ii};
    %disp(sprintf('Session %s',session))
    
    % Filename
    fileName = fullfile(dirs.DataIn,session,session);
    fileName2 = sprintf('%s.ns2',fileName);
    fileName5 = sprintf('%s.ns5',fileName);
    
    % 1kHz files. ~ 2GB for 100 channels 2.5 hours of recording
    if exist(fileName2,'file')
        nsSize2(ii) = dir(fileName2);
    end
    
    % 30kHz files. Between 38-90 GB for 96 channels 3 hours of recording
    if exist(fileName5,'file')
        nsSize5(ii) = dir(fileName5);
    end
    clear session fileName fileName2 fileName5
end

% Checking if neural data was sampled at 1kHz or 30 kHz
sessionOrder = 1:nSessions;
ns2 = [nsSize2(:).bytes]/divGb;
ns5 = [nsSize5(:).bytes]/divGb;

if (nSessions == 1) && (isnan(ns2)) && (isnan(ns5))
    Fs = nan;
else
    ns5nan = isnan(ns5);        % If ns5 is nan, it will seem as 30 kHz data
    ns2Bigger = ns2 > ns5;
    Indx1kHz = sessionOrder(logical(ns5nan + ns2Bigger));
    sessions1kHz = {sessionList{Indx1kHz}};
    
    % Sampling Frequency
    Fs = ones(1,nSessions)*30000;
    Fs(Indx1kHz) = 1000;
end

%% Plotting file size info
if nSessions > 1
    divByte = 1000000000;           % for Giga bytes
    switch divByte
        case 1000000000;
            sizeTxt = 'GB';
        case 1000000;
            sizeTxt = 'MB';
        case 1000;
            sizeTxt = 'KB';
    end
    
    numXticks = 1;
    XticksVals = 1:numXticks:nSessions;
    XtickLbls = {sessionList{1:numXticks:end}};
    Xt = 1:nSessions;
    
    % Plotting values
    hold on, plot(Xt,[nsSize2(:).bytes]/divByte,'b','lineWidth',3),
    hold on
    plot(Xt,[nsSize5(:).bytes]/divByte,'r','lineWidth',3)
    
    plot(Fs/1000,'k','lineWidth',3);
    % Legend
    hLeg = legend('ns2 Files','ns5 Files','Fs/1000');
    set(hLeg,'FontWeight','Normal','FontSize',12,'Location','SouthWest');
    
    % Axis labels
    ylabel(sprintf('BlackRock raw data size in %s',sizeTxt),'FontWeight','bold','FontSize',14);
    xlabel('CS Session','FontWeight','bold','FontSize',14);
    pos = get(gca,'Position');
    set(gca,'Xtick',XticksVals,'XTicklabels',XtickLbls,'FontSize',8);%,'Position',[pos(1), .2, pos(3) .65])
    
    % Tile
    title('CS Session data size for ns2 and ns5 files','FontWeight','bold','FontSize',16);
end


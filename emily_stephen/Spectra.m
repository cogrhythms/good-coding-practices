% MT Spectrum Example
% ES 6/25/12

% Taking data in a lab-format DSC file, with trials defined 500ms before to
% 500ms after the onset of speech
% Compute the spectra for "before" and "after" and perform a f-test for
% significant differences.

clear all
close all

%% Parameters
subject = '026';
reftype = 'Physical';
processing = 'broad1to200';
ecogrun = '03';

conf = 0.975;

%% Load lab-format data 
% DSC File (high-pass filtered already: my data has been bandpass filtered between 1 and 200 Hz)
dsc_utterances = load('ECOGS001R03_justE31_dsc.mat');

%% Helpful variables
ntrials = size(dsc_utterances.SegValues,1); % # trials
ntotalsamples = size(dsc_utterances.SegValues,2); % # samples (not split into before and after)
nelecs = size(dsc_utterances.SegValues,3); % # electrodes
Fs = dsc_utterances.SegSampFreq; % Sample Frequency
ChLbl = dsc_utterances.ChLbl; % Names of electrodes

% indices into the trial for the before and after periods
window = dsc_utterances.SegMask;
before_indices = window<0;
after_indices = window>0;
nsamples = sum(before_indices);

if sum(after_indices)~=nsamples,
    error('subsequent code assumes before and after epochs are the same length')
end

%% set up MT parameters

specparams.Fs = Fs;
specparams.tapers = [5 8]; % [time-bandwidth product, #tapers]
specparams.trialave = true;
specparams.fpass = [1 200];
specparams.pad = 0;

trial_len = nsamples/Fs;
disp(['Trial length (seconds): ' num2str(trial_len) 's'])
disp(['Time-bandwidth product: ' num2str(specparams.tapers(1))])
disp(['Bandwidth: ' num2str(specparams.tapers(1)/trial_len) '*2 Hz'])

% check concentrations for tapers 
% (all should be very close to 1, otherwise use fewer tapers)
[~,v] = dpss(nsamples,specparams.tapers(1),specparams.tapers(2));
disp(v)

%% calculate and display spectra for first electrode
n = 1;
ecog = dsc_utterances.SegValues(:,:,n)'; % time x trials

% subtract out the means in time and trials
trialmean = mean(ecog,2);
ecog = ecog - trialmean*ones(1,ntrials);
ecog = ecog - ones(ntotalsamples,1)*mean(ecog,1);

% plot mean and residuals
figure(1)
subplot(2,1,1),plot(window/Fs,trialmean),ylabel('Trial Mean'),title(['Channel #' ChLbl{n}]),axis tight
subplot(2,1,2),plot(window/Fs,ecog),ylabel('Trial Residuals'),axis tight

% split into before and after epochs
ecog_before = ecog(before_indices,:);
ecog_after = ecog(after_indices,:);

[Splus,fplus] = mtspectrumc(ecog_after, specparams);
[Smin,fmin] = mtspectrumc(ecog_before, specparams);

% Spectra ratio
H = Splus./Smin;

% Basic confidence bounds
dof = specparams.tapers(2)*2*ntrials;
lowsig = finv(conf,dof,dof);
highsig = finv(1-conf,dof,dof);

% plot spectra
figure(2)
ax(1)=subplot(2,1,1);
plot(fplus,10*log(Smin),'b',fmin,10*log(Splus),'r');legend('500ms before','500ms after','Location','SouthWest'), xlabel('Frequency (Hz)'), ylabel('Power (dB)'), title(['Channel #' ChLbl{n}])

ax(2)=subplot(2,1,2);
plot(fplus,H,'k'), xlabel('Frequency (Hz)'),ylabel('Power Ratio')
line(xlim,[lowsig lowsig],'color','k','linestyle','--')
line(xlim,[highsig highsig],'color','k','linestyle','--')
title(['Channel #' ChLbl{n} ': 500ms after / 500ms before'])



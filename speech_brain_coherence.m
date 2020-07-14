%{
Name: speech_brain_coherence.m
Desc: Gathers EEG sensors with the highest mean coherence to speech/audio
between 2 frequencies for localizer experiment
Date: 10/10/2019
Authors: Francisco Javier Carrera Arias, Mikel Lizarazu

Inputs: Struct with the following parameters:
- localizer.eeg_data: character array with the EEG data from 
  the offline localizer experiment (currently tested only for brainamp
  products)
- localizer.stimulus: character array with the trigger type for trial/epoch
  segmentation (e.g. 'Stimulus' or 'Response')
- localizer.value: character array with the trigger value
- localizer.prestim: float representing how many seconds to gather prior to
  the trigger onset
- localizer.poststim: float or integer representing how many seconds
  to gather after trigger onset
- localizer.frequencies: numeric vector of dimensions 1x2 conatining the
  frequencies to calculate mean coherence
- localizer.top_n: integer indicating the number of channels desired after
  mean coherence calculation
- localizer.audio: cell array with audio files vectors (i.e. wav files
  after being read with audioread)
- localizer.audio_fs: float or integer representing the sampling frequency
  of the audio
- localizer.plot: 0 or 1 indicating whether you want to plot the coherence
  between your selected frequencies across an EEG map
- localizer.layout: character vector with your desired EEG map layout
  (default 32 channel easycapM7)
%}

function [top_coherence,channel_names,indices] = speech_brain_coherence(localizer)

% Load the data
% Create Initial Variables
Fdata=[];
Faudio=[];

% Load localizer data
data_clean = Trial_Segment(localizer.eeg_data,localizer.stimulus,...
    localizer.value,localizer.prestim,localizer.poststim,...
    localizer.frequencies);

%% FFTs
% Obtain the fourier transforms of the EEG data and audio envelope
for i=1:size(data_clean.trial,2)
    for j=1:length(data_clean.label)
            Fdata(j,:,i)=fft(data_clean.trial{1,i}(j,:),[],2);           
    end
    audio_en = audio_envelope(localizer.audio{i},data_clean.fsample,localizer.audio_fs);
    Faudio(:,i)=fft(audio_en,[],2);
end

%% Compute Coherence based on CSD
Fxx=[];
Fyy=[];
Fxy=[];
Faudio = permute(Faudio,[3 1 2]);
Fxx=mean(Fdata.*conj(Fdata),3);
Fyy=mean(Faudio.*conj(Faudio),3);
Fxy=mean(Fdata.*repmat(conj(Faudio),[length(data_clean.label) 1]),3);
coh_audio(:,:)=Fxy.*conj(Fxy)./(repmat(Fyy,[length(data_clean.label) 1]).*Fxx);

%% Plot results if desired
%Select the frequency to plot, in this case 1 Hz
fs = data_clean.fsample;
window = length(coh_audio);

C=[];
for i=1:length(data_clean.label)
    C.label{i,1}=data_clean.label{i,1};
end
C.fsample=fs;
C.time{1,1}= 0:fs/window:fs-fs/window;
cfg=[];
C.trial{1,1}=squeeze(coh_audio(:,:));
Coh = ft_preprocessing(cfg,C);

% Calculate Channels with top average coherence over frequencies of
% interest
datapoints = Coh.time{1} >= localizer.frequencies(1) & Coh.time{1} <= localizer.frequencies(2);
% Extract these datapoints from the coherence
coherence = Coh.trial{1}(:,datapoints);
% Gather mean coherence and the top channel names
mean_coherence = mean(coherence,2);
[top_coherence, indices] = maxk(mean_coherence,localizer.top_n);
channel_names = data_clean.label(indices);
% Reshape cell array for NF section
channel_names = reshape(channel_names,[1,length(channel_names)]);

if localizer.plot == 1
    cfg = [];
    cfg.layout = localizer.layout;
    cfg.hlim = localizer.frequencies;
    cfg.interactive ='yes';
    cfg.showlabels = 'yes';
    figure; ft_multiplotER(cfg,Coh);
end

end
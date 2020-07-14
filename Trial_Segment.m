%{
Name: Trial_Segment.m
Desc: Identifies the trials based on the stimulus for the localizer data
Date: 04/10/2020
Authors: Francisco Javier Carrera Arias
%}

%{
Inputs:
 - localizer_data: a .eeg file as given by BrainVision Recorder that
 contains the EEG data from the localizer experiment
- trigger: Character with the name of the trigger type (e.g. Stimulus)
- trigger_name: character vector or cell array of character vectors
  with numbers or strings of the trigger values
- prestim: float, latency in seconds prior to the trigger
- poststim: integer or float with latency in seconds after the trigger
- frequencies: integer vector of dimensions 1x2 with the desired band
  pass frequencies
Outputs:
- data_clean: Preprocessed and epoched EEG data
%}

function data_clean = Trial_Segment(localizer_data,trigger,trigger_name, prestim, poststim, frequencies)

%Define the trials based on the function parameters
cfg                         = [];
cfg.dataset                 = localizer_data;
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = trigger;
cfg.trialdef.eventvalue     = trigger_name; 
cfg.trialdef.prestim        = prestim; % in seconds
cfg.trialdef.poststim       = poststim; % in seconds

cfg = ft_definetrial(cfg);

% Segment the data and prepocess it from all the channels
% By default we perform baseline correction and band pass
% filtering accross the desired frequencies of the localizer
cfg.channel        = 'all';
cfg.bpfilter       = 'yes';
cfg.bpfreq         = frequencies;
cfg.bpfilttype     = 'fir'; % Apply FIR filtering to be consistent with NF
data_clean = ft_preprocessing(cfg);
end

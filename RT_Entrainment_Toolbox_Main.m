%{
Name: RT_Entrainment_Toolbox_Main.m
Desc: Main script to run a neurofeedback experiment/session with
entrainment measures using the real-time entrainment toolbox
Date: 10/06/2020
Authors: Francisco Javier Carrera Arias, Mikel Lizarazu
%}

% Import libraries and dependencies
close all;
clear all;
clc;
startup()

%% Localizer Experiment Analysis

% The audio files must be in the order that they were presented to the
% participant/patient. Since the localizer experiment/session only has the
% clear audio condition and participants go through it only once,
% randomization should not be needed
[localizer_audio,audio_fs] = Audio_Processor('S  2','all');

% Localizer struct definition
% Note: So far only tested with brainvision products
localizer.eeg_data = 'Test_Trigger.eeg';
localizer.stimulus = 'Stimulus';
localizer.value = 'S  2';
% Keep prestim at 0, baseline correction not as relevant for RT Entrainment
localizer.prestim = 0;
localizer.poststim = 9.59;
localizer.frequencies = [1 7];
localizer.top_n = 5;
localizer.audio = localizer_audio;
localizer.audio_fs = audio_fs;
localizer.plot = 0;
localizer.layout = 'easycapM7.mat';

% Gather top channels from localizer
[top_coherence,channel_names,indices] = speech_brain_coherence(localizer);

%% Define Parameters for BCI loop - Neurofeedback

% Define FIR filter specifications. Order in this case is 4 cycles
% of desired EEG frequency band. Calculated as follows:
% Delta band -> 2 Hz: 1/2 = 0.5/500 ms
% 500 ms x 4 = 2000 ms
% Sampling -> 500 Hz: 1/500 = 0.002/2 ms
% 2 ms * order = 2000 ms -> order = 1000
filtSpec_Freq1.order = 1000;
% The range is the desired frequency band. In this case theta
filtSpec_Freq1.range = [1,3];

% Define FIR filter specifications. Order in this case is 4 cycles
% of desired EEG frequency band. Calculated as follows:
% Theta band -> 6 Hz: 1/6 = 0.166/166.6 ms
% 166.6 ms x 4 = 666.4 ms
% Sampling -> 500 Hz: 1/500 = 0.002/2 ms
% 2 ms * order = 666 ms -> order = 333
filtSpec_Freq2.order = 333;
% The range is the desired frequency band. In this case theta
filtSpec_Freq2.range = [4,7];

% Initialize the cfg struct
cfg = [];
cfg.channel = channel_names; % Channel selection already obtained from localizer
% Read data from local buffer at port 1972
cfg.dataset = 'buffer://localhost:1972';
% Trial Definition Parameters
cfg.trialfun = 'ft_trialfun_speechwindow';
cfg.trialdef.eventtype   = 'Stimulus';
cfg.trialdef.eventvalue  = {'S  2', 'S  8', 'S128'};
% Keep prestim at 0, baseline correction not as relevant for RT Entrainment
cfg.trialdef.prestim     = 0;
cfg.trialdef.poststim    = 9.59;
cfg.window = 2;
% Stimuli and design parameters
cfg.n_stimuli = 3;
cfg.reference_chan = "wav";

% Run Neurofeedback BCI - Make sure to execute rda2ft to create the buffer
% from the command line prior to running the line below
NF_results = ft_realtime_plv_fully_sync(1070,1920,filtSpec_Freq1,...
    filtSpec_Freq2,cfg);
%{
Name: plv_realtime_fun.m
Desc: Displays plv average between EEG channels and/or audio in real-time
Date: 10/10/2019
Authors: Francisco Javier Carrera Arias, Mikel Lizarazu

Inputs:
- dat: an eeg dataset from Fieldtrip's buffer. Currently only tested with
  data from Brain Products Devices
- hdr: a hdr struct from Fieldtrip's ft_read_header
- filtSpec_Freq1: a struct with the order and frequencies in hertz of the
  first set of frequencies that want to track as part of the neurofeedback
- filtSpec_Freq2: a struct with the order and frequencies in hertz of the 
  second set of frequencies that want to track as part of the neurofeedback
- reference_chan: a string or integer with "wav" if you want to use audio
  files or an integer with the channel index that you would like to use
  instead of audio files (this index must be taken from the cell array
  given by the localizer, not from all the channels)
- target_baseline: a float with the moving average basline
- audio_env: an array with the audio envelope. Only used if reference_chan is
  "wav"
Outputs:
 - A neurofeedback visualization displaying the average PLV between the two
   selected frequencies of interest (for example average entrainment within
   the theta and delta bands)
%}

function plv_avg = plv_realtime_fun(dat,hdr,filtSpec_Freq1,...
    filtSpec_Freq2,reference_chan,target_baseline,...
    audio_env)

% Set defaults if not using audio
if nargin < 7
    audio_env = [];
end

% if target_baseline is nan at the beginning place a 0
if isnan(target_baseline)
    target_baseline = 0;
end

% % (for testing) If window is even set channel 1 and audio to be the same
% dat(1,:) = audio_env;

if string(reference_chan) ~= "wav"
    % Calculate phase locking value (PLV) with respect to channel
    plv_freq1 = eegPLV_RT(dat,hdr.Fs,filtSpec_Freq1,reference_chan);
    plv_freq2 = eegPLV_RT(dat,hdr.Fs,filtSpec_Freq2,reference_chan);
else
    % Calculate phase locking value (PLV) with respect to audio
    plv_freq1 = eegPLV_RT(dat,hdr.Fs,filtSpec_Freq1,...
        reference_chan,audio_env);
    plv_freq2 = eegPLV_RT(dat,hdr.Fs,filtSpec_Freq2,...
        reference_chan,audio_env);
end

% Calculate average between bands and append to mother vector
freq1_avg = sum(plv_freq1)/length(plv_freq1);
freq2_avg = sum(plv_freq2)/length(plv_freq2);
plv_avg = (freq1_avg+freq2_avg)/2;

% Plot PLV for user feedback
Neurofeedback_Vis_II(plv_avg,target_baseline);
drawnow;
end
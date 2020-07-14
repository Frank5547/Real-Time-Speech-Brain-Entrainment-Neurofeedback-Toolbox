%{
audio_envelope.m
Desc: Gathers the phase of the speech envelope downsamples to EEG
sampling frequency
Author: Francisco Javier Carrera Arias
Date: 05/25/2020

Inputs:
- audio: a float vector with an audiofile read with audioread
- eeg_fs: a number with the sampling frequency of the EEG system
- audio_fs: a number with the sampling frequency of the audio

Outputs:
- env_ds: a float vector with the resampled audio envelope
%}

function env_ds = audio_envelope(audio,eeg_fs,audio_fs)
% Gather the audio ennvelope by gathering the amplitude after a hilbert
% transform
env = abs(hilbert(audio));
% Downsample to EEG sampling frequency
env_ds = resample(env,eeg_fs,audio_fs);
end
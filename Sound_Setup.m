%{
Name: Screen_Setup.m
Desc: Sets up the sound parameters for audio presentation
Date: 12/20/2019
Authors: Francisco Javier Carrera Arias

Outputs:
- pahandle: a Psychtoolbox audio handle
%}

function pahandle = Sound_Setup()

% Initialize Sounddriver
InitializePsychSound(1);

% Number of channels and Frequency of the sound
nrchannels = 1;

% Open Psych-Audio port, with the follow arguements
% (1) [] = default sound device
% (2) 1 = sound playback only
% (3) 1 = default level of latency
% (4) Requested frequency in samples per second
% (5) 2 = stereo putput
pahandle = PsychPortAudio('Open', [], 1, 1, [], nrchannels);

% Set the volume to half for this demo
PsychPortAudio('Volume', pahandle, 0.5);
end
%{
Trigger_Gen_Multi.m
Desc: Sends triggers to Brain Vision Recorder through a parallel port
Date: 05/15/2020
Author: Francisco Javier Carrera Arias

Inputs:
- n_Trigger: a number indicating how many triggers to send
- n_Trigger_Type: a number indicating how many different trigger types to
send. Current parallel port drivers in this script allow for 3 different
types (i.e input a number between 1 and 3)
- Start_Pause: a number inidicating the pause in seconds before the
function begins sending triggers
- Inter_Stimuli_Pause: a number indicating the pause in seconds in between
triggers. Bear in mind the length of each stimulus at the time of
determining this pause 
- LPT1_Port: a character array indicating the hex LPT1 port address,
defaults to '4FF8' if nothing is given.
%}

function Trigger_Gen_Multi(n_Trigger,n_Trigger_Type,Start_Pause,...
    Inter_Stimuli_Pause,LPT1_Port)

% Set default LPT1 Port if none given
if nargin < 5
    LPT1_Port = '4FF8';
end

% Initialize parallel port setup
% initialize access to the inpoutx64 low-level I/O driver
config_io;
% optional step: verify that the inpoutx64 driver was successfully initialized
global cogent;
if( cogent.io.status ~= 0 )
   error('inp/outp installation failed');
end
% write a value to the default LPT1 printer output port (at 0x378)
address = hex2dec(LPT1_Port);

% Pause for NF system startup
pause(Start_Pause)

% Send triggers to EEG based on stimuli duration
for k = 1:n_Trigger
    % Select trigger pin
    val = randi([1,n_Trigger_Type]);
    % Send Trigger
    outp(address,val);
    fprintf("Trigger\n");
    % Reset Parallel port
    outp(address,0);
    % Inter stimuli pause for questions
    pause(Inter_Stimuli_Pause)
end

% Close parallel port when done
clear all
end
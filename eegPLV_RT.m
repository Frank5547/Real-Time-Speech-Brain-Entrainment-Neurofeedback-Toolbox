function [plv] = eegPLV_RT(eegData, srate, filtSpec,...
    compareChannel, audio_env)
% Computes the Phase Locking Value (PLV) for a signal over time
% with respect to a given channel
%
% Input parameters:
%   - eegData: is a 2D matrix numChannels x numTimePoints
%   - srate: is a double with the sampling rate of the EEG data
%   - filtSpec: is the filter specification to filter the EEG signal in the
%     desired frequency band of interest. It is a structure with two
%     fields, order and range. 
%      - Range specifies the limits of the frequency
%        band, for example, put filtSpec.range = [35 45] for gamma band.
%      - The order of the FIR filter in filtSpec.order. A useful
%        rule of thumb can be to include about 4 to 5 cycles of the desired
%        signal. For example, filtSpec.order = 50 for eeg data sampled at
%        500 Hz corresponds to 100 ms and contains ~4 cycles of gamma band
%        (40 Hz).
%   - compareChannel: is a number with the reference channel to 
%     used to calculate entrainment or "wav" if an audio file is used
%   - audio_env: is a vector with the audio envelope
%     It is only used if compareChannel = "wav"
%
% Output parameters:
%   plv is a 2D matrix - 
%     numChannels x plv
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Created By: Francisco Javier Carrera Arias, Mikel Lizarazu
% Credit to Praneeth Namburi

% Set defaults if audio is not used
if nargin < 5
    audio_env = [];
end

% Gather the number of channels
numChannels = size(eegData, 1);

% Run an FIR filter through the EEG data accross the time dimension
filtPts = fir1(filtSpec.order,filtSpec.range/(srate/2));
filteredData = filter(filtPts, 1, eegData, [], 2);

% Initilize an empty array for phase locking values and phases
plv = zeros(numChannels,1);
filteredData_Hi = zeros(numChannels,size(filteredData,2));

% Gather the phase from the analytic signal of each channel after 
% passing the filtered EEG data through a Hilbert transform
for channelCount = 1:numChannels
    filteredData_Hi(channelCount, :) = angle(hilbert(filteredData(channelCount, :)));
end

% Obtain the data of the compare channel
% If the compare channel is an audio wav file filter it and compute phase
% separately
if string(compareChannel) ~= "wav"
    compareChannelData = squeeze(filteredData_Hi(compareChannel, :));
else
    fprintf("Using Audio...")
    filteredAudio = filter(filtPts,1,audio_env,[],2);
    compareChannelData = squeeze(angle(hilbert(filteredAudio)));
end

% Calculate the phase locking value between all channels and the compare
% channel
for channelCount = 1:numChannels
    channelData = squeeze(filteredData_Hi(channelCount, :));
    % Phase locking value - the absolute value of the mean phase difference
    plv(channelCount,1) = abs(sum(exp(1i*(channelData - compareChannelData)), 2))/size(filteredData_Hi,2);
end
return;
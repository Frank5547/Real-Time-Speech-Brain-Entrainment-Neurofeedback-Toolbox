%{
Name: ft_realtime_plv_avg_sync.m
Desc: Displays plv between EEG channels in real-time for BCI or neurofeedback
Date: 10/10/2019
Authors: Francisco Javier Carrera Arias
%}

%{
Inputs:
- screen_height: a number with the screen height in pixels (i.e. 1080)
- screen_width: a number with the screen width in pixels (i.e. 1920)
- filtSpec_Freq1: a struct with the order and frequencies in hertz of the
  first set of frequencies that want to track as part of the neurofeedback
- filtSpec_Freq2: a struct with the order and frequencies in hertz of the 
  second set of frequencies that want to track as part of the neurofeedback
- cfg: a configuration struct with the following fields:
    - cfg.channel: a cell array with the channel selections from the
    localizer
    - cfg.dataset: a charater array with the address of the data buffer.
    Usually 'buffer://localhost:1972'
    - cfg.trialfun: a charater array with name of the trial function
    - cfg.trialdef.eventtype: a character array with the name of the type of
    event that the neurofeedback should sync to. Usually 'Stimulus'
    - cfg.trialdef.eventvalue: a character array or cell array with the
    names of the events/triggers
    - cfg.trialdef.prestim: Period in seconds before trigger onset for
    entrainment neurofeedback typically 0
    - cfg.trialdef.poststim: Period in seconds after trigger onset. This
    should be equal to the length of the audio file in seconds
    - cfg.window: a number indicating the number of neurofeedback
    presentation windows
    - cfg.n_stimuli: a number indicating how many stimuli will be presented
    in the neurofeedback session
    - cfg.reference_chan: a string or integer with "wav" if you want to use audio
    files or an integer with the channel index that you would like to use
    instead of audio files (this index must be taken from the cell array
    given by the localizer, not from all the channels)
Outputs:
- NF_results: an array containing the results of the neurofeedback
session. It has n_stimuli rows and columns for the stimuli type, answers to
any experimental responses and the PLV value between the selected channels
and the reference channels for every presentation window.
%}

function NF_results = ft_realtime_plv_fully_sync(screen_height, screen_width,...
    filtSpec_Freq1,filtSpec_Freq2,cfg)

% Setup screen parameters
 [window,white,xCenter,yCenter,...
     allCoords,lineWidthPix] = Screen_Setup(screen_width,screen_height);

% Sound Setup Parameters
pahandle = Sound_Setup();

% Set up keyboard queue
KbQueueCreate; 
KbQueueStart;

% Draw Fixation Prior to starting loop
Draw_Fixation(window,allCoords,lineWidthPix,white,xCenter,yCenter)
%% Setup Prior to BCI Loop

% translate dataset into datafile+headerfile
cfg = ft_checkconfig(cfg, 'dataset2files', 'yes');
cfg = ft_checkconfig(cfg, 'required', {'datafile' 'headerfile'});

% ensure that the persistent variables related to caching are cleared
clear ft_read_header

% start by reading the header from the realtime buffer
hdr = ft_read_header(cfg.headerfile, 'headerformat', cfg.headerformat, 'cache', true, 'retry', true);

% define a subset of channels for reading
cfg.channel = ft_channelselection(cfg.channel, hdr.label);
chanindx    = match_str(hdr.label, cfg.channel);
nchan       = length(chanindx);
if nchan==0
  ft_error('no channels were selected');
end

% Housekeeping Variables
prevSample = 0;
count = 0;
count_stimuli = 0;
%test_c = 0; % for testing only

% Obtain how many trials are going to be obtained for each stimulus
window_elements = fix(cfg.trialdef.poststim/cfg.window);

% Initialize master and individual PLV arrays, target and reference sensors
% and target baseline
master_plv_array = zeros(cfg.n_stimuli,window_elements);
condition_array = string();
answer_array = zeros(cfg.n_stimuli,1);
baseline_vec = []; % This ia a vector to calculate a global moving average
%% BCI Loop
while true
    
    % Detect Status of Audio Playback
    status = PsychPortAudio('GetStatus', pahandle);
    
    % determine latest header and event information
    event     = ft_read_event(cfg.dataset, 'minsample', prevSample+1);  % only consider events that are later than the data processed sofar
    hdr       = ft_read_header(cfg.dataset, 'cache', true);             % the trialfun might want to use this, but it is not required
    cfg.event = event;                                                  % store it in the configuration, so that it can be passed on to the trialfun
    cfg.hdr   = hdr;                                                    % store it in the configuration, so that it can be passed on to the trialfun
    
    % evaluate the trialfun, note that the trialfun should not re-read the events and header
    fprintf('evaluating ''%s'' based on %d events\n', cfg.trialfun, length(event));
    [trl,~] = feval(cfg.trialfun, cfg);
    
     % If trigger is detected in the latest sample,
     % play audio based on trigger value
     if isempty(event) == 0 && event(end).type == "Stimulus" && status.Active == 0
             % Randomly select a speech piece based on trigger value
             [audio,audio_fs,condition] = Audio_Processor(event(end).value,'one');
             % Obtain audio envelope if reference channel is wav
             if string(cfg.reference_chan) == "wav"
                audio_env = audio_envelope(audio,hdr.Fs,audio_fs);
             end
             % Load audio
             PsychPortAudio('FillBuffer', pahandle, audio);
             % Start audio playback
             PsychPortAudio('Start', pahandle, 1, 0, 1);
     end
     
     fprintf('processing %d trials\n', size(trl,1));
                 
     if isempty(trl) == 0
         
         % Intialize trial PLV array
         trial_plv_array = [];
         
         % Initialize audio segmentation sample if needed
         audio_begsample = 1;
         
         % Plot Figure
         figure('units','normalized','outerposition',[0 0 1 1])
         
         for trllop=1:size(trl,1)
 
             begsample = trl(trllop,1);
             endsample = trl(trllop,2);
 
             % remember up to where the data was read
             prevSample  = endsample;
             count       = count + 1;
             fprintf('-------------------------------------------------------------------------------------\n');
             fprintf('processing segment %d from sample %d to %d\n', count, begsample, endsample);
 
             % read data segment from buffer
             dat = ft_read_data(cfg.datafile, 'header', hdr, 'begsample',...
                 begsample + 1, 'endsample', endsample,...
                 'chanindx', chanindx, 'checkboundary', false,...
                 'blocking','yes','timeout',60);
             
             tic;
             % Calculate global plv average
             target_baseline = mean(baseline_vec);
             
             % Segment the audio envelope to match trial window if
             % needed
             if string(cfg.reference_chan) == "wav"
                audio_endsample = audio_begsample + (endsample-begsample);
                fprintf('processing audio from sample %d to %d\n',...
                    audio_begsample, audio_endsample);
                audio_env_seg = audio_env(audio_begsample:audio_endsample-1);
                audio_begsample = audio_endsample;
             end
             
             if string(cfg.reference_chan) ~= "wav"
                 % Calculate the iPLV of the target EEG sensors
                 % with respect to the reference channel
                 iplv = plv_realtime_fun(dat,hdr,filtSpec_Freq1,...
                     filtSpec_Freq2,cfg.reference_chan,target_baseline);
             else
                 % Calculate the iPLV of the target EEG sensors
                 % with respect to audio
                 iplv = plv_realtime_fun(dat,hdr,filtSpec_Freq1,...
                     filtSpec_Freq2,cfg.reference_chan,target_baseline,...
                     audio_env_seg);
             end
             
             % Append PLV of this window to the vector for the moving
             % average and trial plv array
             baseline_vec = [baseline_vec iplv];
             trial_plv_array = [trial_plv_array iplv];
             toc;
         end
         
         % Stop audio when complete
         PsychPortAudio('Stop', pahandle, 1);
         
         % Close the NF Figure - window pause for visualization
         pause(cfg.window)
         close all
             
         % Add stimuli to tally and the PLV values to the master
         % PLV array
         count_stimuli = count_stimuli + 1;
         master_plv_array(count_stimuli,:) = trial_plv_array;
             
         % Intellegibility Question
         answer = Intel_Question(window,white);
             
         % further validation questions could be added at this point
             
         % Flip Fixation cross back
         Draw_Fixation(window,allCoords,lineWidthPix,white,...
             xCenter,yCenter)
              
         % Collect answer
         answer_array(count_stimuli,:) = answer;
         % Collect condition
         condition_array(count_stimuli,:) = string(condition);
     end
     
     % Close the bci loop if all the stimuli have been presented
     if count_stimuli == cfg.n_stimuli
         % Concatenate all results
         NF_results = cat(2,condition_array,answer_array,master_plv_array);
         % Clear the screen
         sca;
         % Close the audio device
         PsychPortAudio('Close', pahandle);
         break
     end
end
end
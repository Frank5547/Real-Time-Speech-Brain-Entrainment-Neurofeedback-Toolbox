%{
Audio_Processor.m
Desc: Loads audio files from stimuli folders based on trigger values
Author: Francisco Javier Carrera Arias
Date: 05/10/2020

Note: for this script to work each stimuli folder must have in its name the
associated trigger name as well as the condition name separated by underscores
For example: if the trigger values expected for condition 'No Noise' are
'S  8', the folder must be named 'Stimuli_S8_NoNoise' 

Inputs:
- trigger: a character array obtained from the event struct of Fieldtrip
- amount: a character array that can be either 'all' to obtain a cell array
  with all the audio files in a stimuli folder or 'one' to obtain an audio
  file at random from a given stimuli folder. The 'all' option is meant
  for the offline localizer session that expects each audio file to be
  presented only once since and not in a random order since this is only
  run once per participant. The 'one' option is meant for the neurofeedback
  session since the audio files of each condition will be presented at random
Outputs:
- audio: a cell array with the audio files if amount is 'all' or a
  numeric array if amount is 'one'
- audio_fs: an integer with the sampling frequency of the audio files
  if the sampling frequency of the audio files is not uniform, the
  localizer session will fail.
- condition: a character array with the condition name of the stimuli
  folder. If amount is 'all' this is 'localizer' otherwise it is obtained
  from the stimuli folder name.
%}

function [audio, audio_fs, condition] = Audio_Processor(trigger, amount)
    % Show folders in the current working directory
    folders = dir();
    folder_names = {folders(:).name};
    folder_flag = [folders(:).isdir];
    folder_names = folder_names(:,folder_flag);
    
    % Gather the folder associated with the trigger value
    trigger = trigger(~isspace(trigger)); % Remove any whitespace
    id = cellfun('isempty',regexp(folder_names,trigger));
    target_audio_folder = folder_names(~id);
    
    % Read all stimuli in the folder as presented in localizer session
    % or one by one at random for neurofeedback
    if isequal(amount,'all')
        % Gather the audio stimuli folder and set up arrays
        stimuli = dir(sprintf("%s/%s",pwd,target_audio_folder{1}));
        audio = {};
        audio_fs = [];
        % Read the audio and sampling rate for all stimuli
        for k = 3:length(stimuli)
            [aud,fs] = audioread(sprintf("%s/%s",stimuli(k).folder,...
                stimuli(k).name));
            audio{k-2} = aud.';
            audio_fs = [audio_fs fs];
        end
        % Gather unique sampling frequency
        audio_fs = unique(audio_fs);
        % Conidition is localizer
        condition = 'localizer';
        % If the sampling frequency is not unique warn the user (the NF will
        % fail)
        if length(audio_fs) > 1
            warndlg("The files contain more than 1 sampling frequency. Please correct this before proceeding further")
        end
    elseif isequal(amount,'one')
        % Gather the audio stimuli folder and set up arrays
        stimuli = dir(sprintf("%s/%s",pwd,target_audio_folder{1}));
        % Read single audio at random based on how many stimuli there are
        random = randi([3,length(stimuli)]);
        [audio,audio_fs] = audioread(sprintf("%s/%s",stimuli(random).folder,...
            stimuli(random).name));
        % Transpose audio
        audio = audio.';
        % Gather condition from the target folder
        condition = regexp(target_audio_folder{1},'(?<=_\w+_)\w+$',...
            'once','match');
    end
end
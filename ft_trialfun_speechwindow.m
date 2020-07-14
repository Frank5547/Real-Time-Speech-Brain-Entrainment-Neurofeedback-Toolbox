%{
Name: ft_trialfun_speechwindow.m
Desc: Splits a single speech stimulus into several trials for NF if desired
Date: 04/10/2020
Authors: Francisco Javier Carrera Arias
%}

%{
Inputs:
- cfg: a configuration struct with the following fields:
    - cfg.header: EEG header as given by fieldtrip's ft_read_header
    - cfg.event: Events as given by fieldtrip's ft_read_event
    - cfg.trialdef.eventvalue: The Trigger values to listen to
    - cfg.trialdef.prestim: Period in seconds before trigger onset for
    entrainment neurofeedback typically 0
    - cfg.trialdef.poststim: Period in seconds after trigger onset. This
    should be equal to the length of the audio file in seconds
    - cfg.window: a number indicating the number of neurofeedback
    presentation windows
Outputs:
- trl: An array with the starting and finishing samples of all the
neurofeedback presentation windows. If the audio length is not an exact
division by the window number, this will contain as many windows as the
nearest exact division (i.e window of 2 and audio length of 9 seconds
would be 4 windows of 2 seconds each)
- event: The event structure with the trigger values
%}


function [trl, event] = ft_trialfun_speechwindow(cfg)

% Gather header and events from configuration structure
ft_info('using the header from the configuration structure\n');
hdr = cfg.hdr;
ft_info('using the events from the configuration structure\n');
event = cfg.event;

trl = [];
if ~isempty(event)
    % Check if the event is in the desired list
    if any(strcmp(cfg.trialdef.eventvalue,event(end).value))
        % Gather sample of last desired event
        sample = event(end).sample;
        
        % determine the number of samples before and after the trigger
        pretrig  =  round(cfg.trialdef.prestim  * hdr.Fs);
        posttrig =  round(cfg.trialdef.poststim * hdr.Fs);
        
        % Define total length of audio trial based on post stimulus
        total_length = sample + posttrig;
        
        if isequal(cfg.window,'full')
            trlbegin = sample;
            trlend   = total_length;
            offset   = pretrig;
            newtrl   = [trlbegin trlend offset];
            trl      = [trl; newtrl];
        else
            % Break down in smaller trials based on chosen NF presnetation window
            % In cases where the length of the audio is not a perfect division
            % by the window size, the last window will be the up to the
            % last exact division (i.e. stimuli of length 9s with a window
            % of 2s will have 4 trials of 2 seconds each and the last
            % second will not be used)
            win_num = fix(cfg.trialdef.poststim/cfg.window);
            while size(trl,1) ~= win_num
                trlbegin = sample;
                trlend   = sample + (cfg.window * hdr.Fs);
                offset   = pretrig;
                newtrl   = [trlbegin trlend offset];
                trl      = [trl; newtrl];
                sample   = trlend;
            end
        end
    end
end
end

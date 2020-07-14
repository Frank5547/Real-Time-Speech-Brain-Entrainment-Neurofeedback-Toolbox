%{
File_Stream.m
Desc: Real-Time Data Stream from Test file. Use this for Neurofeedback
presentation testing only in a separate Matlab session
Date: 10/10/2019

Inputs:
- test_file: an .eeg file as given by Brain Vision software
- speed: relative speed as to the test eeg file is streamed to the buffer
 (i.e 4)
- maxblocksize: number in seconds indicating how many samples to process
per block
%}

function File_Stream(test_file,speed,maxblocksize)
% Configuration
cfg = [];
cfg.source.dataset = test_file;
cfg.speed = speed;
cfg.maxblocksize = maxblocksize;
cfg.readevent = 'yes';
% Generate simulated real-time signal
ft_realtime_fileproxy(cfg)
end
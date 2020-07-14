%{
Name: Screen_Setup.m
Desc: Sets up the screen parameters for question output and fixation cross
Date: 04/15/2020
Authors: Francisco Javier Carrera Arias

Inputs:
- screen_height: Screen height in pixels
- screen_width: Screen width in pixels

Outputs:
- window: a Psychtoolbox window
- allCoords: the coordinates of the fixation cross
- lineWidthPix: the line width of the fixation cross in pixels
- white: white RGB values as given by Screen_Setup()
- xCenter: coordinates of the fixation cross center on the x axis
- yCenter: coordinates of the fixation cross center on the y axis
%}

function [window,white,xCenter,yCenter,...
    allCoords,lineWidthPix] = Screen_Setup(screen_height,screen_width)

    %clear the screen
    sca;
    
    % Get the screen numbers
    screens = Screen('Screens');

    % Select the external screen if it is present, else revert to the native
    % screen
    screenNumber = max(screens);

    % Define black
    black = BlackIndex(screenNumber);
    white = WhiteIndex(screenNumber);

    % Open an on screen window and color it grey
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black,...
        [50 50 screen_height screen_width], [], [], [], [], [],...
        kPsychGUIWindow);

    % Set the blend funciton for the screen
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Get the centre coordinate of the window in pixels
    % For help see: help RectCenter
    [xCenter, yCenter] = RectCenter(windowRect);

    % Here we set the size of the arms of our fixation cross
    fixCrossDimPix = 40;

    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];

    % Set the line width for our fixation cross
    lineWidthPix = 4;
end
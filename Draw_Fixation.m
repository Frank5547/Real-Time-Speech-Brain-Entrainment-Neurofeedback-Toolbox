%{
Name: Draw_Fixation.m
Desc: Draws a fixation cross in the center of the screen while the
neurofeedback is not active
Date: 04/20/2020
Authors: Francisco Javier Carrera Arias

Inputs:
- window: a Psychtoolbox window as given by Screen_Setup()
- allCoords: the coordinates of the fixation cross as given by
Screen_Setup()
- lineWidthPix: the line width of the fixation cross in pixels. This
parameter is also given by Screen_Setup()
- white: white RGB values as given by Screen_Setup()
- xCenter: coordinates of the fixation cross center on the x axis as given
by Screen_Setup()
- yCenter: coordinates of the fixation cross center on the y axis as given
by Screen_Setup()
%}

function Draw_Fixation(window,allCoords,lineWidthPix,white,...
    xCenter,yCenter)
    % Draw the fixation cross in white, set it to the center of our screen
    % and set good quality antialiasing
    Screen('DrawLines', window, allCoords,...
        lineWidthPix, white, [xCenter yCenter], 2);
    % Flip to the screen
    Screen('Flip', window);
end
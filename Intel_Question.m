%{
Name: Intel_Question.m
Desc: Presents the intellegibility question and gathers the answer
Date: 04/20/2020
Authors: Francisco Javier Carrera Arias

Inputs:
- window: a Psychtoolbox window as given by Screen_Setup()
- white: white RGB values as given by Screen_Setup()

Outputs:
- answer: Gathers the keyboard pressed for answering the question
%}

function answer = Intel_Question(window,white)
    % Draw text
    DrawFormattedText(window, ['Del 1 (imposible de entender) al 9 (perfectamente claro),'...
         ' califique la intelegibilidad del sonido'],...
         'center', 'center', white);
    % Flip to the screen
    Screen('Flip', window);
    
    % % Wait for a key press and check key
    KbStrokeWait;
    [~,pressed] = KbQueueCheck;
    [~, Index] = max(pressed);
    pressed_key = regexp(KbName(Index),'\d','Match');
    pressed_key = pressed_key{1};
    
    % Gather the answer
    answer = str2double(pressed_key);
end
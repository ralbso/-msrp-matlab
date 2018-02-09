% Clear workspace and screen
sca;
close all;
clearvars;

% Default settings for setup
PsychDefaultSetup(2);

% Get screen numbers (screens attached to computer)
screens = Screen('Screens');

% Select the max of these numbers. If there are two screens attached
% we will draw to the external screen
screenNumber = max(screens);

% Define black and white (white will be 1 an black 0).
% Luminance values are defined between 0 and 1 with 255 steps in between.
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simple calculation to get the luminance value for grey.
grey = white/2;

% Open an on screen window using PsychImaging and color it grey.
[win, winRect] = PsychImaging('OpenWindow', screenNumber, grey);

 % Screen has been drawn on. We wait for a keyboard button press to
 % terminate the demo
 KbStrokeWait;
 
 % Clear screen
 sca; 
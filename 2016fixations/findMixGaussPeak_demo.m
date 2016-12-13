% function findMixGaussPeak_demo
% 2016.12.12 Karen
% Run this script to obtain the cluster centers and corresponding cluster
% Before running, modify the variable dataroot to be your Mouse-Eye
% directory
clear; clc
close all;
% Path to the fixation directory
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
% Choose the subject type
user = 'UndergraduateParticipants\';
% user = 'PsychosisParticipants\';
% Eliminate too-small cluster?
less = 1;

% Find all the files and pick the desired one
fixdir = [dataroot '\' user '\data\clean\mouse_samples\'];
fixfile = dir(fixdir);
% nmidx = 16; % Index of image name

for i=4:length(fixfile)
    nmidx = i;
    % Load image and the fixation structure: fixations (.subj .coord .order)
    nowname = fixfile(nmidx).name;
    fprintf('[%2d] %s\n', nmidx, nowname(1:end-4));
    I = imread([dataroot 'annotation\stimuli\' nowname(1:end-4) '.jpg']);
    load([fixdir '\' nowname]);
    % Extract Fixation coordinates
    x = fixations.coord(:,2); % along width  [1,640]
    y = fixations.coord(:,1); % along height [1,480]
    % Pick certain amount of samples
    % subj = fixations.subj; % Test subject
    % x = x(subj<10);
    % y = y(subj<10);

    % Display the fixation data
    fig = 10;
%     figure; 
%     imshow(uint8((I)/1)); hold on;
%     plot(x,y,'y.'); % Data point
%     title(['Image: ' nowname(1:end-4) ' (with fixation points)']);
    % Before calling function findMixGaussPeak.m
    [cx,cy,cid] = findMixGaussPeak(x,y,I,less,fig);
    pause;
end
% function d170417saveCtr_demo
clear; clc
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'rawData_20170321_104subj/';

fixdir = fullfile(dataroot,user, '/data/clean/mouse_samples/');
fixfile = dir(fullfile(fixdir, '*.mat'));
% Parameters for function "findMixGaussPeak"
less = 0; % decrease #center if the cluser is too small
fig = 10; % the figure name while display
display = 0; % display or not

% Generate the saving directory if not exist
myDirName = 'fixation_clusters';
saveroot = fullfile(dataroot, user, myDirName);
if ~exist(saveroot,'dir')
    mkdir(saveroot);
end
allfile = cell(length(fixfile),1);
% Iterated through each image
for i=1:length(fixfile)
    fprintf('Now running: %d\n', i);
    nmidx = i;
    % Load image and the fixation structure: fixations (.subj .coord .order)
    nowname = fixfile(nmidx).name(1:end-4);
    imgname = [dataroot '/' user '/data/demo/stimuli/' nowname '.jpg'];
    if ~exist(imgname, 'file') % if the file does not exist -> skip
        fprintf('\tInexist Stimuli\n');
        continue
    end
    I = imread(imgname);
    % Load the preprocess fixation data
    load([fixdir '/' nowname '.mat']);
    % Extract Fixation coordinates
    x = fixations.coord(:,2); % along width  [1,640]
    y = fixations.coord(:,1); % along height [1,480]
    [cx,cy,cid] = findMixGaussPeak(x,y,I,less,fig,display);
    
    % Put the data into a large cell for saving
    allfile{i}.x = x;
    allfile{i}.y = y;
    allfile{i}.cx = cx;
    allfile{i}.cy = cy;
    allfile{i}.cid = cid;
    allfile{i}.nowname = nowname;
    
    % Save the data we need
    save(fullfile(saveroot,[nowname '.mat']), ...
        'x','y','cx','cy','cid','nowname');
end
save(fullfile(dataroot,user,'170417allfile.mat'), 'allfile');
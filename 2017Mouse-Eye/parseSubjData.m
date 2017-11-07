% function parseSubjData(nowSubj, fileroot, nowImg)
clear; clc
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'rawData_20170321_104subj/';

rawdir = fullfile(dataroot, user, 'data', 'demo', 'results');
rawfile = dir(fullfile(rawdir, '*.mat'));

% Initialize the index
nowSubj = 10;
nowImg = 2; 

subjname = rawfile(nowSubj).name;

% Load the initial parameters
load(fullfile(rawdir,subjname),'window_size','mouse_samples','img_id');
% Load the center data
load(fullfile(dataroot,user,'170417allfile.mat'), 'allfile');

files = dir(fullfile(rawdir, 'MT_*.mat'));
filenames = {files.name};
nSubj = length(files);
for iSubj = 1:nSubj
    terms = strsplit(filenames{iSubj}, '_');
    subjects{iSubj} = terms{2};
    fileobj = load(fullfile(rawdir, filenames{iSubj}));
    [imgIds(iSubj,:), imgIdx(iSubj,:)] = sort(fileobj.img_id);
    rawData{iSubj} = fileobj;
    samples(:, iSubj) = fileobj.mouse_samples(imgIdx(iSubj,:));
    windowSize(iSubj, :) = fileobj.window_size;
end
%%
imgDir = fullfile(dataroot, user, 'data', 'demo', 'stimuli');
nStimuli = size(imgIds, 2); % Number of images
imgs = dir(fullfile(imgDir, '*.jpg'));
% samplesDir = fullfile(outDir, 'mouse_samples');
% mkdir(samplesDir);

%% parse fixations
imgGroupJump=cell(nStimuli, 1); % recording all the jumping between groups
for iImg = 1:nStimuli
    
    fixations = [];
    fixations.subj = zeros(20000, 1);
    fixations.coord = zeros(20000, 2);
    fixations.order = zeros(20000, 1);
    nFix = 0;
    
    fprintf('IMG[%2d]: %s\n', iImg, imgs(iImg).name);
    
    im = imread(fullfile(imgDir, imgs(iImg).name));
    imgSize = size(im);
    tmpJumping = []; % Saving the jumping between groups in one image
    for j = 1:length(subjects)
        scan = samples{iImg,j};
        if isempty(scan)
            continue;
        end
        
        % Rescale to the same size of image
        scan(:,2) = scan(:,2) - windowSize(j,2)/imgSize(1)*imgSize(2)/2 + imgSize(2)/2;
        scan(:,3) = scan(:,3) - windowSize(j,2)/2 + imgSize(1)/2;

        % Process the points to be fixation location & duration
        fixes = scan(:,3:-1:2);
        dur = scan(:,1)*1000;
        
        tt=0:10:5000;
        x=interp1(dur, fixes(:,1), tt, 'pchip');
        y=interp1(dur, fixes(:,2), tt, 'pchip');
        
        fixes = [x; y]';
        speed = fixes(3:end,:)-fixes(1:end-2,:);
        fixes = fixes(2:end-1,:);
        speed = sqrt(sum(speed.^2, 2));
        
        % Analysis of fixations with cluster centers
        % fixation trace with correct dimension
        now_x = scan(:,2);
        now_y = scan(:,3);

        ctr = [allfile{iImg}.cx , allfile{iImg}.cy];
        % Assign each fixation point to a cluster
        idx = assignCluster(ctr, now_x,now_y);
        
        % Display
%         figure(10); 
%         subplot(121); imshow(im); hold on;
%         mygscatter(now_x,now_y,idx); % draw the points with different clusters
%         title(['Image ' num2str(nowImg) '; subject ' num2str(j) '/' num2str(length(subjects))]);
% 
%         subplot(122); 
%         plot(idx); ylim([0,length(ctr)]); % Setup y axis limit to #centers
%         title([num2str(length(ctr)) ' clusters']);
        
        % LDA?
%         W = LDA([now_x,now_y],idx); % W: #cls x 3 (constant, weight_x, weight_y)
        % Find the 
        out = findDur(idx);
        tmpJumping = [tmpJumping ; [j*ones(size(out,1),1) , out]]; % adding subject id at the front
%         pause
    end
    imgGroupJump{iImg} = tmpJumping;
end
allJpDur = imgGroupJump;
% save('170517allJumpDuration_113Sti104subj.mat', 'allJpDur', 'allfile');


%% 170522 Directly Saving the interface for html





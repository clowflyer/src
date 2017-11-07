% function raw2datamat
% 170321 transfer the raw data into needed form
% read all the raw data and display?
clear; clc;
% Path to the fixation directory
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
% Choose the subject type
user = 'rawData_20170321_104subj/';

rawdir = [dataroot '/' user '/data/demo/results/'];
rawfile = dir(rawdir);

imgN = 113; % number of images used when collecting data
allRawData = cell(imgN, size(rawfile,1)-3); % #images x #subjects
for i=4:length(rawfile)
    nmidx = i;
    % Load image and the fixation structure: fixations (.subj .coord .order)
    nowname = rawfile(nmidx).name;
    fprintf('[%2d] %s\n', nmidx, nowname(1:end-4));
    load([rawdir '/' nowname], 'img_id', 'mouse_samples');
    % Extract Fixation coordinates
    allRawData(:,i-3) = mouse_samples(img_id);
%     x = fixations.coord(:,2); % along width  [1,640]
%     y = fixations.coord(:,1); % along height [1,480]
%     [cx,cy,cid] = findMixGaussPeak(x,y,I,less,fig,display);
end
% save(['170321rawData_' num2str(size(rawfile,1)-3) 'subj.mat'], 'allRawData');

%%
% clear; clc;
% Path to the fixation directory
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
% Choose the subject type
user = 'PsychosisParticipants/';
% stimuli directory
imgDir = [dataroot '/' user '/data/demo/stimuli'];
imgfile = dir(imgDir);

for i=10:10%size(allRawData,1) % image
    imgname = imgfile(i+3).name;
    I = imread([imgDir '/' imgname]);
    for k=1:1%size(allRawData,2) % subject
        t = allRawData{i,k}(:,1);
        x = allRawData{i,k}(:,2);
        y = allRawData{i,k}(:,3);
        x = round(x/3); % data from 3 times of current image size
        y = round(y/2.25);
        % Display all fixation points of one subj.
        figure(10); imshow(I); hold on;
        plot(x,y,'rx');
        pause(0.1);
        % Display fixation trace during time of one subj.
%         for tt = 1:20:length(t) % timestamp
%             figure(10); imshow(I); hold on;
%             plot(x(tt),y(tt),'ro');
%             title(['subj' num2str(k) ':' 't=' num2str(t(tt))]);
%             pause(0.01);
%         end
    end
end

%% Show the blur results
% clear; clc
% load(['170321rawData_' num2str(size(rawfile,1)-3) 'subj.mat']);
i = 10;
imgname = imgfile(i+3).name;
I = imread([imgDir '/' imgname]);
txy = cell2mat(allRawData(i,:)'); % transfer data from all subjects to matrix
x = txy(:,2);
y = txy(:,3);
t = txy(:,1);
% x = round(x/2.25);
% y = round(y/2.25);
% function parameters
% less = 0;
% fig = 10;
% display = 1;
% Find cluster centers
% [cx,cy,cid] = findMixGaussPeak(x,y,I,less,fig,display);

% screen = 1920 x 1080
% image = 640 x 480

figure;
rg = 1;
plot3(t(1:rg:end),x(1:rg:end),y(1:rg:end),'r.');
grid on;
figure; imshow(I);
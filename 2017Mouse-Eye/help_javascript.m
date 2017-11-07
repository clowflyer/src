% function help_javascript
% 170523
clear; close all; clc
% ########## DATA DIRECTORY: change to the path you have ###############
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'rawData_20170321_104subj/';
% ######################################################################
myFig=5;
% Load x,y,cx,cy,cid,nowname to workspace
% load(fullfile(dataroot,user,'170417allfile.mat'), 'allfile');
%%
for nmidx=10:10%length(allfile)
    % Load the data from allfile
    nowname = allfile{nmidx}.nowname;
    x = allfile{nmidx}.x;
    y = allfile{nmidx}.y;
    cx = allfile{nmidx}.cx;
    cy = allfile{nmidx}.cy;
    cid = allfile{nmidx}.cid;
    figs = dispImgClusters(x,y,cx,cy,cid,nowname,'rectangle',myFig);
    % Save the image
    savename = fullfile(dataroot, 'javascript_gui',['images/labeling_' num2str(nmidx) '.jpg']);
%     saveas(gcf, savename);
%     pause
%     close(myFig)
end
%%
for nmidx = 1:length(allfile)
    nowname = allfile{nmidx}.nowname;
    fname = fullfile(dataroot,user, ['data/demo/stimuli/' nowname '.jpg']);
    I = imread(fname);
    savename = fullfile(dataroot, 'javascript_gui',['images/stimuli_' num2str(nmidx) '.jpg']);
    imwrite(I, savename);
end
%% Check any of them fitted to the sample image
I = imread('testSample.PNG');
I = imresize(I,[480,640]);
allc = [];
for nmidx=1:length(allfile)
    % Load the data from allfile
    nowname = allfile{nmidx}.nowname;
    x = allfile{nmidx}.x;
    y = allfile{nmidx}.y;
    cx = allfile{nmidx}.cx;
    cy = allfile{nmidx}.cy;
    cid = allfile{nmidx}.cid;
%     figs = dispImgClusters(x,y,cx,cy,cid,I,'rectangle',myFig);
%     pause
%     close(myFig)
    allc = [allc; length(cx)];
end
%%
savename = 'labeling_template.jpg';
saveas(gcf, savename);

%% 170713 Process the csv file from javascript
% Loading columns from the csv file: 

nimg = 10; % number of images/stimulus
% Find the difference = duration of each question
time_diff = diff(time_elapsed);
time_diff = [0 ; time_diff]; % adding 0 at the front to have the same size
% [number of center, description duration, labeling duration, index]
tmp = [ allc(1:nimg) , time_diff(4:2:end) , time_diff(5:2:end), trial_index(4:2:end)];
%%
% Description parts (8:end-2)
alldescp = cell(nimg,2);

for i=4:2:length(responses)
    alldescp{i/2-1,1} = responses{i}(8:end-2); % sentences
    alldescp{i/2-1,2} = length(responses{i}(8:end-2)); % word counts
end

%% Save the fixation clustering regions with given names

for i=47:length(allfile)
    fprintf('Now:%d\n', i);
    figs = dispDescriptionTest(i, 'rectangle', 0, myFig);
    savename = fullfile(dataroot, 'javascript_gui',['demo_images/origlabel_' num2str(i) '.jpg']);
%     saveas(gcf, savename);
end

%% 170713 try CSV reading
close all;

load(fullfile(dataroot,user,'170727allfile_10.mat'), 'allfile_10');
allfile = allfile_10;

% username = 'AMSewonoh_0717';
username = 'A1HUUSCZ4I5SOP';
% csvpath = fullfile(dataroot, 'javascript_gui', ['data/' username '.csv']);
csvpath = fullfile(dataroot, 'javascript_gui', 'data', ['170818Data/' username '.csv']);
% tmp = dlmread( csvpath, '', [3, 1, 32, 1] );
csvdat = readtable(csvpath);

ans_label = csvdat.responses(strcmp(csvdat.qtype, 'Labeling')); % labeling answers
ans_desc = csvdat.responses(strcmp(csvdat.qtype, 'Description')); % description answers
% ans_desc = ans_desc{qidx}(8:end-3); % erase the '"', '{' and 'Q0:'
ans_desc = erase(ans_desc, {'"','{','}','Q0',':'} );

% Deal with label
qidx = 5;
str = ans_label{qidx};
tmp = strsplit(str(2:end-1), '","'); % Split to each questions -> cell
tmp2 = erase(tmp, '"'); % erase " char and remaining: Q1:label

thislabel = cell(length(tmp),1);
for i=1:length(tmp)
    tmp3 = strsplit(tmp2{i}, ':');
    fprintf('%d: %s\n', i, tmp3{2});
    thislabel{i} = tmp3{2};
end
% image
nowname = allfile{qidx}.nowname;
imgname = [dataroot '/' user '/data/demo/stimuli/' nowname '.jpg'];
I = imread(imgname);
% figure; imagesc(I);
% title(strsplit(ans_desc{qidx}, {'. ', ', '}) );

% show the subbox and annotation
figs = dispDescriptionTest(qidx, 'rectangle', 0, myFig+1, [], []); % orig
figs = dispDescriptionTest(qidx, 'rectangle', 10, myFig, thislabel, ans_desc{qidx}); % ours
% msgbox(ans_desc(qidx), 'Description');

%% 170722 Check the 'less' ability of cutting # clusters
fixdir = fullfile(dataroot,user, '/data/clean/mouse_samples/');
less = 1;
numctr = zeros(length(allfile),1);
for nmidx=1:length(allfile)
    % Load the data from allfile
    nowname = allfile{nmidx}.nowname;
    imgname = [dataroot '/' user '/data/demo/stimuli/' nowname '.jpg'];
    I = imread(imgname);
    load([fixdir '/' nowname]);
    % Extract Fixation coordinates
    x = fixations.coord(:,2); % along width  [1,640]
    y = fixations.coord(:,1); % along height [1,480]
    [cx,cy,cid] = findMixGaussPeak(x,y,I,less,myFig,0);
    numctr(nmidx) = length(cx);
end

%% 170724 Saved for smaller size of center data
% New allfile: x,y,cx,cy,cid,nowname
fixdir = fullfile(dataroot,user, '/data/clean/mouse_samples/');
less = 10;
numctr = zeros(length(allfile),1);
allfile_10 = cell(length(allfile),1);
for nmidx=1:length(allfile)
    fprintf('now:%d\n', nmidx);
    % Load the data from allfile
    nowname = allfile{nmidx}.nowname;
    imgname = [dataroot '/' user '/data/demo/stimuli/' nowname '.jpg'];
    I = imread(imgname);
    load([fixdir '/' nowname]);
    % Extract Fixation coordinates
    x = fixations.coord(:,2); % along width  [1,640]
    y = fixations.coord(:,1); % along height [1,480]
    % Limit the cluster number to be no more than "less" (here = 10)
    [cx,cy,cid] = findMixGaussPeak(x,y,I,less,myFig,0);
    % cx and cy are still the old one, and cid with 0 in it
    newidx = unique(cid);
    newidx(newidx==0) = []; % skip the 0 index
    oldcx = cx;
    oldcy = cy;
    oldcid = cid;
    %mapout = changem(Z,newcode,oldcode)
    cid = changem(cid, 1:length(newidx), newidx);
    cx = oldcx(newidx);
    cy = oldcy(newidx);
    
    numctr(nmidx) = length(cx);
    allfile_10{nmidx}.x = x;
    allfile_10{nmidx}.y = y;
    allfile_10{nmidx}.cx = cx;
    allfile_10{nmidx}.cy = cy;
    allfile_10{nmidx}.cid = cid;
    allfile_10{nmidx}.oldcx = oldcx;
    allfile_10{nmidx}.oldcy = oldcy;
    allfile_10{nmidx}.oldcid = oldcid;
    allfile_10{nmidx}.nowname = nowname;
end

% save
% save(fullfile(dataroot,user,'170727allfile_10.mat'), 'allfile_10');

%% 170727 Load and save the 10-cluster images
load(fullfile(dataroot,user,'170727allfile_10.mat'), 'allfile_10');
allfile = allfile_10;
for nmidx=1:length(allfile)
    % Load the data from allfile
    nowname = allfile{nmidx}.nowname;
    x = allfile{nmidx}.x;
    y = allfile{nmidx}.y;
    cx = allfile{nmidx}.cx;
    cy = allfile{nmidx}.cy;
    cid = allfile{nmidx}.cid;
    figs = dispImgClusters(x,y,cx,cy,cid,nowname,'rectangle',myFig);
    % Save the image
%     savename = fullfile(dataroot, 'javascript_gui',['images/labeling_' num2str(nmidx) '.jpg']);
%     saveas(gcf, savename);
%     pause
    close(myFig)
end

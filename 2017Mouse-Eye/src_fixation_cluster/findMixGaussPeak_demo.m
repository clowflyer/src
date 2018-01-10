% function findMixGaussPeak_demo
% Usage for findMixGaussPeak.m
% Saved for smaller size of center data by using 'less' parameter
clear; clc
% ########## DATA DIRECTORY: change to the path you have ###############
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'Undergrad_20180103_64subj/';
% ######################################################################

% ###################### Modificable Parameters ########################
less = 10; % Indicate how many most clusters we needed
myFig= 5; % Display figure
mydisp=0; % Display or not
% ######################################################################


% New allfile: x,y,cx,cy,cid,nowname
fixdir = fullfile(dataroot,user, '/data/clean/mouse_samples/');
imgdir = dir(fullfile(dataroot,user,'data/demo/stimuli','*.jpg'));
num_process = length(imgdir); % number of images needed to be processed
% numctr = zeros(length(allfile),1);
allfile_10 = cell(num_process,1);
for nmidx=1:num_process
    fprintf('now:%d\n', nmidx);
    % Load the data from allfile
    nowname = imgdir(nmidx).name(1:end-4);
    imgname = [dataroot '/' user '/data/demo/stimuli/' nowname '.jpg'];
    I = imread(imgname);
    load([fixdir '/' nowname]);
    % Extract Fixation coordinates
    x = fixations.coord(:,2); % along width  [1,640]
    y = fixations.coord(:,1); % along height [1,480]
    % Limit the cluster number to be no more than "less" (here = 10)
    [cx,cy,cid] = findMixGaussPeak(x,y,I,less,myFig,mydisp);
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
    
%     numctr(nmidx) = length(cx);
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
save(fullfile(dataroot,user,[datestr(now,'yymmdd') 'allfile_' num2str(less) '.mat']), 'allfile_10', 'user');


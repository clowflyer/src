% function dispImgClusters_demo
% Usage of dispImgClusters.m

clear; clc
% ########## DATA DIRECTORY: change to the path you have ###############
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'Undergrad_20180103_64subj/';
allfile_name = '180110allfile_10.mat';
% ######################################################################

% ###################### Modificable Parameters ########################
shape = 'rectangle';
save_status = 0;
myFig = 5; % Display figure
% ######################################################################
mkdir(fullfile(dataroot, user, 'fixation_cluster_images'));
load(fullfile(dataroot,user,allfile_name), 'allfile_10');
allfile = allfile_10;
for nmidx=1:length(allfile)
    % Load the data from allfile
    nowname = allfile{nmidx}.nowname;
    fprintf('Now[%d]: %s\n', nmidx, nowname);
    x = allfile{nmidx}.x;
    y = allfile{nmidx}.y;
    cx = allfile{nmidx}.cx;
    cy = allfile{nmidx}.cy;
    cid = allfile{nmidx}.cid;
    figs = dispImgClusters(x,y,cx,cy,cid,nowname, shape,myFig, dataroot,user);
    % Save the image
    if save_status==1
        savename = fullfile(dataroot, user, 'fixation_cluster_images',['labeling_' num2str(nmidx) '.jpg']);
        saveas(gcf, savename);
    end
    pause(0.1);
    close(myFig)
end
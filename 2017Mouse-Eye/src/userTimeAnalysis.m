% function userTimeAnalysis
% 2017.04.11
clear; clc
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'rawData_20170321_104subj/';

% Load certain user data
datdir = [dataroot '/' user '/data/demo/results/'];
datfile = dir(fullfile(datdir, 'MT_*.mat'));

%% Analysis
clear; clc; close all
load('170517allJumpDuration_113Sti104subj.mat') %'allJpDur', 'allfile' -> 113x1 cells

% allJpDur{i}: (array)  [userid, begin_ctr, end_ctr, duration]
% allfile{i}:  (struct) x,y,cx,cy,cid,nowname

%% 170517 0-order baseline Markov: Not considering duration
allPredScore = zeros(length(allfile),1);
allNewScore = zeros(length(allfile),1);
mergeInfo = zeros(length(allfile),2);
thresh = 0.1; % threshold of communication reachability
for iImg=1:length(allfile) % Each image -> one transition matrix
    jumping = allJpDur{iImg}(:,2:3);
    jumping(jumping(:,2)==-1,:) = [];
    ctrnum = length(allfile{iImg}.cx); % number of centers
    idx = sub2ind([ctrnum,ctrnum], jumping(:,1), jumping(:,2));
    markovMat0 = reshape( hist(idx, 1:ctrnum^2),  [ctrnum,ctrnum]); % square matrix of #ctr
    markovMat0 = markovMat0 ./ length(jumping);
    
    % Spectral Clustering
%     S = .5* (markovMat0+markovMat0');
%     D = .5* (markovMat0-markovMat0');
%     D = diag(sum(markovMat0,2));
%     L = D-markovMat0;
%     [V,lambda] = eig(L);
%     [~,midx] = max(V(:,1));
    
    % Prediction
    [~,midx] = max(markovMat0,[],2); % find the most possible next step
    predScore = sum( jumping(:,2)==midx(jumping(:,1)) ) / length(jumping);
    allPredScore(iImg) = predScore;
    
    
    % Communication Classes
    [R,C,S,Z] = Reachability(markovMat0,thresh);
    Cl = CommunicationClasses(R,C,Z);
    
    % New jumping data with merged classes
    [newCls,~] = find(Cl.U==1); % index corresponding from old to new cls
    newClsNum = max(newCls); % class number
    mergeInfo(iImg,:) = [ctrnum, newClsNum]; % [Orig, New] class number
    newJump = newCls(jumping);
    tmp = find(newJump(:,1)==newJump(:,2)); % index of in class loop
    newJump(tmp,:) = []; % eliminate in class loop
    % Generate new transition matrix
    idx = sub2ind([newClsNum,newClsNum], newJump(:,1), newJump(:,2));
    markovMat0 = reshape( hist(idx, 1:newClsNum^2),  [newClsNum,newClsNum]); % square matrix of #ctr
    markovMat0 = markovMat0 ./ length(newJump);
    % New prediction
    [~,midx] = max(markovMat0,[],2); % find the most possible next step
    predScore = sum( newJump(:,2)==midx(newJump(:,1)) ) / length(newJump);
    allNewScore(iImg) = predScore;
    
    
    % Display
%     figure(10); imagesc(markovMat0);
%     colormap('gray')
%     title(['[Img' num2str(iImg) ']:' allfile{iImg}.nowname]);
%     title(['[Img' num2str(iImg) ']: prediction=' num2str(predScore)]);
%     pause
end
figure; plot(allPredScore); hold on;
plot(1:length(allfile), 0.5*ones(size(allPredScore)),'r');
title(['[0-order] Avg = ' num2str(mean(allPredScore)) ]);
axis([0,length(allfile),0,1]);
% After Communication Classes
figure; plot(allNewScore); hold on;
plot(1:length(allfile), 0.5*ones(size(allNewScore)),'r');
title( ['[Com Classes] Avg = ' num2str(mean(allNewScore)) ';Thresh=' num2str(thresh)] );
axis([0,length(allfile),0,1]);
%%
% 1-step Markov Analysis

%% Communication Classes
[R,C,S,Z] = Reachability(markovMat0,0.05);
Cl = CommunicationClasses(R,C,Z);
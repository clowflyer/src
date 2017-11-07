% function fixPtTemp_test

clear; clc
close all;
% Path to the fixation directory
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
% Choose the subject type
% user = 'UndergraduateParticipants/';
% user = 'PsychosisParticipants/';
user = 'rawData_20170321_104subj/';

fixdir = [dataroot '/' user '/data/clean/mouse_samples/'];
fixfile = dir(fixdir);

less = 0;
fig = 10;
display = 0;

for i=44:44%length(fixfile)
    nmidx = i;
    % Load image and the fixation structure: fixations (.subj .coord .order)
    nowname = fixfile(nmidx).name;
    fprintf('[%2d] %s\n', nmidx, nowname(1:end-4));
    imgname = [dataroot '/' user '/data/demo/stimuli/' nowname(1:end-4) '.jpg'];
    if ~exist(imgname, 'file') % if the file does not exist -> skip
        fprintf('\tInexist Stimuli\n');
        continue
    end
    I = imread(imgname);
    load([fixdir '/' nowname]);
    % Extract Fixation coordinates
    x = fixations.coord(:,2); % along width  [1,640]
    y = fixations.coord(:,1); % along height [1,480]
    [cx,cy,cid] = findMixGaussPeak(x,y,I,less,fig,display);
end
%%
wsize = 20;
last = 1;
less = 0;
fig = 10;
display = 1;
for i=wsize+1:wsize:length(x)
%     figure(10); imshow(I); hold on;
%     plot(x(last:i),y(last:i), 'rx');
    
    % Gaussian Blur
    [cx,cy,cid] = findMixGaussPeak(x(last:i),y(last:i),I,less,fig,display);
    title([num2str(last) ':' num2str(i)]);
    last = i;
    pause(0.1);
end
%% Generate the transition matrix for each centers
% cx,cy -> coordinates of all the centers
% cid -> index assigned to each fixation points
% 
% HMM_matrix = zeros(length(cx)); % #ctr x # ctr (square matrix)

% h = hist(fixations.subj,1:max(fixations.subj));
subjCid = cell(max(fixations.subj),1); % structure to save data for each subject
for i=1:max(fixations.subj) % for each subject
    idx = find(fixations.subj==i);
    if isempty(idx)
        fprintf('No data related to subject %d\n', i);
        continue
    end
    subjCid{i} = [cid(idx), fixations.order(idx), fixations.coord(idx,:)];
end

%% For each center, decide the range of fixations covering and display
ctr_range = zeros(length(cx),7);
% cx,cy,r | (bbox) x,y,w,h
figure(10); imshow(I); hold on;
for i=1:length(cx)
    % find all the points of this cluster
    idx = find(cid==i);
    now_x = x(idx);
    now_y = y(idx);
    now_w = max(now_x)-min(now_x);
    now_h = max(now_y)-min(now_y);
    % Save the cluster information
    ctr_range(i,:) = [cx(i),cy(i),floor((now_w+now_h)/4),... % bounding circle params
        min(now_x), min(now_y), now_w, now_h]; % bounding box params
    % Display
%     rectangle('Position', ctr_range(i,4:end), 'EdgeColor', 'r', 'LineWidth', 1);
    viscircles(ctr_range(i,1:2),ctr_range(i,3),'Color','b');
%     a=annotation('rectangle', [.5,.5,.2,.2], 'EdgeColor', 'r');
%     a=text(max(now_x)+2,max(now_y),num2str(i),'Color', 'r', 'FontSize', 20);
    a=text(ctr_range(i,1)+4,ctr_range(i,2)-2,num2str(i),'Color', 'r', 'FontSize', 15);
    plot(cx(i),cy(i),'bx');
    title( ['cluster[' num2str(i) ']: ' num2str(length(idx)) '/' num2str(length(cid))] );
%     pause
end
title(['all fixations for ' nowname ': ' num2str(length(cid))]);
%%
I2 = imread(['C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\UndergraduateParticipants\data\demo\blur\' nowname(1:end-4) '-6.jpg']);
% res = zeros(size(I));
[nX,nY] = meshgrid(1:size(I,2), 1:size(I,1));
distX = repmat(nX(:), [1,length(cx)]) - repmat(cx', [length(nX(:)),1]);
distY = repmat(nY(:), [1,length(cy)]) - repmat(cy', [length(nY(:)),1]);
dist_all = sqrt(distX.^2 + distY.^2);
for i=1:size(dist_all,2)
    thresh = ctr_range(i,3);
    mask = zeros(length(dist_all(:,i)),1);
    mask(dist_all(:,i)<thresh) = 1;
    mask = repmat( reshape(mask, size(I,1),size(I,2)) , [1,1,3]);
    mask = uint8(mask);
    res = mask.*I + (1-mask).*I2;
    figure(20); imshow(res); hold on;
%     viscircles(ctr_range(i,1:2),ctr_range(i,3),'Color','b');
    plot(cx(i),cy(i),'bx');
    title( ['cluster[' num2str(i) ']'] );
    pause
end


%% Genenerating the transition graph for all fixations
cid2graph(cid,length(cx),1,0); % graph for full cluster
title(['all fixations for ' nowname ': ' num2str(length(cid))]);
%% Generating the transition graph for each subject
for i=1:length(subjCid) % for each subject -> generate a small graph?
    HMM_mat = zeros(length(cx));
    fprintf('subj[%d]:', i);
    if isempty(subjCid{i})
        fprintf('no data\n');
        continue
    end
    nowcid = subjCid{i}(:,1);
    fprintf('%d points\n',length(nowcid));
    % Transfer the belonging cluster to voting on the graph of #cid x #cid
%     idx = sub2ind(size(HMM_mat),nowcid(1:end-1), nowcid(2:end));
%     h = hist(idx,1:size(HMM_mat,1)*size(HMM_mat,2));
%     result = reshape(h,size(HMM_mat));
%     figure(10); plot(digraph(result), 'Layout', 'force')
%     title(['subj[' num2str(i) ']: ' num2str(length(nowcid)) ' points']);
    cid2graph(nowcid,length(cx),1,i);
    pause
end

%% Hidden Markov Chain




% x: fixation trace - x coord
% y: fixation trace - y coord
% W: image width
% H: image height
clear; clc
close all;
% Path to the fixation directory
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'UndergraduateParticipants\';
% user = 'PsychosisParticipants\';
fixdir = [dataroot '\' user '\data\clean\mouse_samples\'];

% Find all the files and pick the desired one
nmidx = 16; % Index of name
fixfile = dir(fixdir);
nowname = fixfile(nmidx).name;
% nowname = '1200px-Living_room.mat';
% nowname = '800px-People_looking_and_talking_on_beach.mat';

% Load image and the fixation structure: fixations (.subj .coord .order)
I = imread([dataroot 'annotation\stimuli\' nowname(1:end-4) '.jpg']);
load([fixdir '\' nowname]);
% I = imread([nowname(1:end-4) '.jpg']);
% load(nowname);
x = fixations.coord(:,2); % along width  [1,640]
y = fixations.coord(:,1); % along height [1,480]
% Pick certain amount of samples
subj = fixations.subj; % Test subject
% [H,W,~] = size(I);
% x = x(subj<10);
% y = y(subj<10);
% Test the data
figure;
imshow(uint8((I)/1)); hold on;
plot(x,y,'y.'); % Data point
title('original image with fixation points');
% Before calling function findMixGaussPeak.m
[cx,cy,cid] = findMixGaussPeak(x,y,I);




%% Change x,y set (smaller)
% Way 1: eliminate repeated points
% Same setting as original code
imgSize = size(I);
map = zeros(imgSize(1:2)); % initial
ptInd = sub2ind(imgSize(1:2), y, x);
[ptIndUniq, ~, ptIndC] = unique(ptInd); %#provides sorted unique list of elements
map(ptIndUniq) = 1;
[ny,nx] = find(map==1);

% Show
x = nx;
y = ny;
figure;
imshow(uint8((I)/1)); hold on;
plot(x,y,'y.'); % Data point
title('eliminate repeated points');

%%
% Convergence Rule
% options = statset('Display','final');
% options = statset('TolBnd', 0.001); % converge to the bound=0.001?
% n_cluster = 4; % number of clusters
% % Fit Gaussian mixture distribution
% obj = gmdistribution.fit([x y],n_cluster,'Options',options);

% 11/21 Another way
k = 1:10; % Number of GMM that you want to test
nK = numel(k); % How many different number you're going to run
Sigma = {'diagonal', 'full'}; % Choices of Covariance matrix style
nSigma = numel(Sigma);
SharedCovariance = {true, false}; % Whether all Cov matrices are the same
SCtext = {'true', 'false'}; % For chart display
nSC = numel(SCtext);
RegularizationValue = 0.1; % Add to Cov matrix to ensure it's pos-definite
options = statset('MaxIter', 10000); % Limit 10000 iterations

% Saving structure
gm = cell(nK, nSigma, nSC); % Gaussian Mixture Model Saving
aic = zeros(nK, nSigma, nSC); % Akaike Information Criterion
bic = zeros(nK, nSigma, nSC); % Bayesian Information Criterion
converged = false(nK,nSigma,nSC); 

tic;
% Fit the GMM with different parameters
for sc = 1:nSC % Shared Covariance
    for sig = 1:nSigma % Covariance matrix
        for i=1:nK % # means
            gm{i,sig,sc} = fitgmdist([x,y], k(i),...
                'CovarianceType', Sigma{sig},...
                'SharedCovariance', SharedCovariance{sc},...
                'RegularizationValue', RegularizationValue,...
                'Options', options);
            aic(i,sig,sc) = gm{i,sig,sc}.AIC;
            bic(i,sig,sc) = gm{i,sig,sc}.BIC;
            converged(i,sig,sc) = gm{i,sig,sc}.Converged;
        end
    end
end
toc;



% Display

displayABIC

% Find the smallest value of bic that indicate the best result?
[t1,t2,t3]=ind2sub(size(bic), find(bic==min(bic(:))));
obj = gm{t1,t2,t3};
% obj = gm{3,2,2};
% Display on the image
figure;
imshow(uint8((I)/1)); hold on;
plot(x,y,'y.'); % Data point
plot(obj.mu(:,1), obj.mu(:,2), 'rx', 'linewidth', 3); % mean
h = ezcontour(@(x,y)pdf(obj,[x y]),[0 640],[0 480]); % GMM contour
title(['cluster=' num2str(t1)]);

%% Display within the clusters:
clusterX = cluster(obj, [x,y]); % assign cluster # to each point
kGMM = obj.NumComponents;
d = 500; % How many grids between these fixation points range?
x1 = linspace(min(x),max(x),d); % x grid coordinates
x2 = linspace(min(y),max(y),d); % y grid coordinates
[x1grid,x2grid] = meshgrid(x1,x2); % put them into a matrix
X0 = [x1grid(:) x2grid(:)]; % put them back to Nx2 array indicating (x,y)
mahalDist = mahal(obj,X0); % Mahalanobis distance of each point to means N x kGMM

threshold = sqrt(chi2inv(0.99,2)); % Setting a thresh for filtering points

figure; %imshow(I); hold on;
h1 = gscatter(x,y,clusterX); % plot each group with different color
hold on;
% Go through each cluster and set each grid to one of the clusters
for j=1:kGMM
    idx = mahalDist(:,j)<=threshold; % find those points within threshold
    Color = h1(j).Color*0.75 + (-.5)*(h1(j).Color-1);
    h2 = plot(X0(idx,1),X0(idx,2),'.', 'Color', Color, 'MarkerSize',1);
    uistack(h2,'bottom');
end
% Plot the mean value
h3 = plot(obj.mu(:,1),obj.mu(:,2), 'kx', 'LineWidth', 2, 'MarkerSize', 10);
title('Cluster Data and Component Structures');

%% Test of the fixation index
% close all;
% tmp=0;
% for i=1:max(subj)
%     idx = find(subj==i);
%     x = fixations.coord(idx,2); % along width  [1,640]
%     y = fixations.coord(idx,1); % along height [1,480]
%     figure(10+tmp); subplot(3,4,mod(i,12)+1);
%     imshow(I); hold on; plot(x,y,'y.');
%     title(i);
%     if mod(i,12)==0
%         tmp = tmp+1;
%     end
% end
% 
% 


%% 161205 Blur and find peak?
% Same setting as original code
imgSize = size(I);
map = zeros(imgSize(1:2)); % initial
ptInd = sub2ind(imgSize(1:2), y, x);
[ptIndUniq, ~, ptIndC] = unique(ptInd);       %#provides sorted unique list of elements
map(ptIndUniq) = 1;
% Show
figure;
subplot(121); imshow(map); title('fixation');
res = rangepeak2d(map,5); % find local max within 5x5
subplot(122); imshow(res); title('after finding local peak');

ppd = 25;
gauss = fspecial('gaussian', round(ppd * 5), ppd);
map = imfilter(map, gauss, 0);
% map = normalise(map);
map = map - min(map(:)); % saliency map with blur gaussian filters
s = max(map(:));
if s > 0
    normalised = map / s;
else
    normalised = map;
end
map = normalised;
% figure;
% subplot(121); imshow(I); title('original')
% subplot(122); imshow(map,[]); title('saliency')

tmp = imregionalmax(map);
tmp2 = rangepeak2d(map,11); % -> initial mean values?
figure;
subplot(131); imshow(tmp2); title('saliency->local max');
subplot(132); imshow(map,[]); title('saliency')
subplot(133); imshow(tmp); title('findregionalmax');


[cy,cx] = find(tmp2==1); % find the centers
cid = assignCluster([cx,cy], x, y); % assign each point to cloest center
figure;
% subplot(121);
imshow(I); hold on;
h1 = gscatter(x,y,cid); % plot each group with different color


% subplot(122);
% [t1,t2,~] = unique(cid);
% bar(t1,t2);
%% Try different size of regionpeak2d
figure;
RS = [5,11,15,21,41];
for i=1:length(RS)
    fprintf('[%d]:',i);
    tic;
    tmp2 = rangepeak2d(map,RS(i));
    subplot(2,3,i);
    imshow(I); hold on;
    [cy,cx] = find(tmp2==1);
    cid = assignCluster([cx,cy], x, y);
    h1 = gscatter(x,y,cid);
    title(RS(i))
    toc;
end




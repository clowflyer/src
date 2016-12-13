function [cx,cy,cid] = findMixGaussPeak(x,y,I,less,fig)
% x: fixation trace - x coord
% y: fixation trace - y coord
% I: image
imgSize = size(I);
map = zeros(imgSize(1:2)); % initial
% Find the location that has fixation (eliminate repeatness)
ptInd = sub2ind(imgSize(1:2), y, x);
[ptIndUniq, ~, ptIndC] = unique(ptInd);       %#provides sorted unique list of elements
map(ptIndUniq) = 1;
% Blur and generate saliency map from fixation map
ppd = 25;
gauss = fspecial('gaussian', round(ppd * 5), ppd);
map = imfilter(map, gauss, 0);
% Normalize the map to [0,1]
map = map - min(map(:)); % saliency map with blur gaussian filters
s = max(map(:));
if s > 0
    normalised = map / s;
else
    normalised = map;
end
map = normalised;

% tmp = imregionalmax(map);
% Fidn the local peak within a certain square range(here: 11x11)
rsize = 11;
tmp2 = rangepeak2d(map,rsize); % -> initial mean values?

[cy,cx] = find(tmp2==1); % find the centers
cid = assignCluster([cx,cy], x, y); % assign each point to cloest center

% Display
figure(fig);
subplot(121);
imshow(I); hold on;
% Be careful that the scatter class # is not the same index as in cid...
mygscatter(x,y,cid); % plot each group with different color
plot(cx,cy,'ko', 'LineWidth', 2); % plot the centers
title(['Peaks within square ' num2str(rsize) 'x' num2str(rsize) '=' num2str( length(cx) )]);

% Decrease the number of clusters
if less==1
    % t1:cluster id, t2: #points of this cluster
    [t2,t1] = hist(cid,unique(cid));
    thresh = length(x)/length(t1); % eliminate smaller clusters
    scidx = find(t2<thresh); % index of small clusters
    outidx = ismember(cid,t1(scidx)); % points belongs to the small clusters
    cid(outidx)=0;
end

% Display after thresholding
figure(fig);
subplot(122);
imshow(I); hold on;
% Be careful that the scatter class # is not the same index as in cid...
mygscatter(x,y,cid); % plot each group with different color
plot(cx,cy,'ko', 'LineWidth', 2); % plot the centers
title(['Peaks within square [' num2str(rsize) '] = ' num2str( length(cx) )]);
title(['After thresholding: ' num2str(length(unique(cid))-1) ' classes']);


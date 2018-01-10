function figs = dispImgClusters(x,y,cx,cy,cid,nowname,shapeType,fig,dataroot,user)
% 2017.04.20 clean up /optimizing of displaying images 
% Mainly integrated from dispDescriptionTest.m

% ########## DATA DIRECTORY: change to the path you have ###############
% dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
% user = 'rawData_20170321_104subj/';
% ######################################################################

% Read image
imgname = fullfile(dataroot, user, '/data/demo/stimuli/', [nowname '.jpg']);
if ~exist(imgname, 'file') % if the file does not exist -> skip
    fprintf('\tInexist Stimuli\n');
    return
end
I = imread(imgname);
% I = nowname;
% Decide the cluster range (box/circle)
ctr_range = dispCtrRegions(x,y,cid,cx,cy,I,'None'); % 'None':no display


% Display Original image as reference
numwin = ceil(length(cx)/3)+2;
figure(fig);
set(fig,'units','normalized'); 
set(fig,'position',[0 0.05 1 0.8]); % set figure to be fullscreen
subplot(3,numwin,[1:2 numwin+1:numwin+2 2*numwin+1:2*numwin+2]);
imshow(I); hold on;
title('Please describe these entities on the right.');

% Show the boxes/circles on the original image
for j=1:size(ctr_range,1)
    % Boxes on clusters
    if strcmp(shapeType, 'rectangle')
        rectangle('Position', ctr_range(j,4:end), 'EdgeColor', 'b', 'LineWidth', 1);
        a=text(ctr_range(j,4)+ctr_range(j,6)+2, ctr_range(j,5)+ctr_range(j,7),...
                num2str(j),'Color', 'r', 'FontSize', 10);
    end
    % Circles on clusters
    if strcmp(shapeType, 'circle')
        viscircles(ctr_range(j,1:2),ctr_range(j,3),'Color','b');
        text(ctr_range(j,1)+4,ctr_range(j,2)-2,num2str(j),'Color', 'r', 'FontSize', 15);
        plot(cx(j),cy(j),'rx');
    end
end
% Show the clustering boxes
figs = cell(size(ctr_range,1),1);
for j=1:size(ctr_range,1)
    subplot( 3,numwin,j+ceil(j/(numwin-2))*2 );
    imshow(I(ctr_range(j,5):ctr_range(j,5)+ctr_range(j,7) ,...
             ctr_range(j,4):ctr_range(j,4)+ctr_range(j,6), :));
    title(j);
    subpos = get(gca,'Position');
    figs{j} = subpos; % save and output the position of each subplot
end




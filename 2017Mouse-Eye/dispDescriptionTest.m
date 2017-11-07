function figs = dispDescriptionTest(img_idx, shapeType, less, fig, labels, desc)
%% 170325 Show the image with description
% clear; clc;
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'rawData_20170321_104subj/';

fixdir = fullfile(dataroot,user, '/data/clean/mouse_samples/');
fixfile = dir(fullfile(fixdir, '*.mat'));

% less = 0;
% fig = 10;
display = 0;

for i=img_idx:img_idx%length(fixfile)
    nmidx = i;
    % Load image and the fixation structure: fixations (.subj .coord .order)
    nowname = fixfile(nmidx).name;
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
    
    % Find the cluster regions:
    ctr_range = dispCtrRegions(x,y,cid,cx,cy,I,'None'); % 'None':no display
    % cx,cy,r | (bbox) x,y,w,h
    
    % Extract Annotation
    load([dataroot '\annotation\annotation_mat\' nowname(1:end-4) '.mat'])
    
    allPoly = annotation.object(:,3); % Extract the polygon from structure
    ctrInPoly = zeros(length(cx),length(allPoly)); % indicate if this center has label
    % Test the center inside labeling or not
    for j=1:length(allPoly) % #polygons of labeling
        now_pt = str2double(struct2cell(allPoly{j}.pt')');
        ctrInPoly(:,j) = inpolygon(cx,cy,now_pt(:,1),now_pt(:,2));
    end
    
%     annotation.object=cell2struct(annotation.object', {'name', 'categories', 'polygon'});
%     LMplot(annotation,I); % plot the annotation

    % Display
    numwin = ceil(length(cx)/3)+2;
    figure(fig);
    set(fig,'units','normalized'); 
    set(fig,'position',[0 0.05 1 0.8]); % set figure to be fullscreen
    subplot(3,numwin,[1:2 numwin+1:numwin+2 2*numwin+1:2*numwin+2]); imshow(I); hold on;
    % Having description of the image
    if ~isempty(desc)
        tmp = strsplit(desc, {'. ', ', '});
        title(tmp);
    else
        title('Original Image')
    end
    
    for j=1:size(ctr_range,1)
        if strcmp(shapeType, 'rectangle')
            rectangle('Position', ctr_range(j,4:end), 'EdgeColor', 'b', 'LineWidth', 1);
            a=text(ctr_range(j,4)+ctr_range(j,6)+2, ctr_range(j,5)+ctr_range(j,7),...
                    num2str(j),'Color', 'r', 'FontSize', 10);
        end
        if strcmp(shapeType, 'circle')
            viscircles(ctr_range(j,1:2),ctr_range(j,3),'Color','b');
            text(ctr_range(j,1)+4,ctr_range(j,2)-2,num2str(j),'Color', 'r', 'FontSize', 15);
            plot(cx(j),cy(j),'rx');
        end
    end
    figs = cell(size(ctr_range,1),1);
    for j=1:size(ctr_range,1)
        subplot( 3,numwin,j+ceil(j/(numwin-2))*2 );
        imshow(I(ctr_range(j,5):ctr_range(j,5)+ctr_range(j,7) ,...
                 ctr_range(j,4):ctr_range(j,4)+ctr_range(j,6), :));
        nidx = find(ctrInPoly(j,:)==1);
        if isempty(nidx)
            nowname = '';
        else
            nowname = annotation.object{nidx(1)};
        end
        % User-input annotation (170719: for collected annotation)
        if ~isempty(labels)
            nowname = labels{j};
        end
        % check the output length and split
        title_str = [num2str(j) ':' nowname];
        if length(title_str) > 20
            tmp = strsplit(title_str,' ');
            midx = floor(length(tmp)/2);
            title_str = {strjoin(tmp(1:midx)), strjoin(tmp(midx+1:end))};
        end
        title(title_str);
        subpos = get(gca,'Position');
        figs{j} = subpos;
%         fprintf('sub[%d]: %f,%f,%f,%f\n', j, subpos);
    end
    
    
end
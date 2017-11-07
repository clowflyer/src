function labelEntityUI
clc
% Initialize
myFig = 5;

% ########## DATA DIRECTORY: change to the path you have ###############
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'rawData_20170321_104subj/';
% ######################################################################
% ########### CREATE "LabelTask" FOLDER UNDER DATA DIRECTORY ###########

% User Input
myname = cell2mat(inputdlg('Please enter your ID or Name'));
if isempty(myname)
    fprintf('Invalid Name\n');
    return
end
fprintf('User name: %s\n', myname);

% Load x,y,cx,cy,cid,nowname to workspace
load(fullfile(dataroot,user,'170417allfile.mat'), 'allfile');

% Specify the name for saving
filename.description = fullfile(dataroot,user,'LabelTasks', [myname '_description.csv']);
filename.labeling = fullfile(dataroot,user,'LabelTasks', [myname '_labeling.csv']);
% Generate the first line of each csv file
fid = fopen(filename.description,'a');
fprintf(fid, 'Image Index, Image Name, Description\n');
fclose(fid);

fid = fopen(filename.labeling,'a');
fprintf(fid, 'Image Index, Image Name, Number of clusters, Entities Description\n');
fclose(fid);

% Run the first image
genImg(1,myFig,allfile,filename);

end

% ========= genImgBox callback: save labeling and go to next image ========
function saveLabel(src, event, data, myFig, img_idx, allfile,filename)
    fprintf('---Image[%d]---\n',img_idx);
    % Write the user description
    fid = fopen(filename.labeling,'a');
    fprintf(fid, '%d,%s,%d', img_idx, allfile{img_idx}.nowname,length(data));
    for i=1:length(data)
        str = get(data{i},'String');
        fprintf('%d: %s\n', i, str);
        fprintf(fid, ',%s', str); % Write (appending) the files
    end
    fprintf(fid, '\n');
    fclose(fid);
    close(myFig)
    
    % Test whether it's the last image
    if img_idx+1>length(allfile)
        helpdlg('This is the end of labeling task. Thanks!');
        return;
    end
    % Go to the next image
    genImg(img_idx+1,myFig,allfile,filename);
end

% ============ Generate entities labeing subimages and boxes ==============
function genImgBox(img_idx,myFig,allfile,filename)
    % If with description --> used dispDescriptionTest
%     figs = dispDescriptionTest(img_idx, 'rectangle',0, myFig);
    % Otherwise use dispImgClusters
    nmidx = img_idx;
    % Load the data from allfile
    nowname = allfile{nmidx}.nowname;
    x = allfile{nmidx}.x;
    y = allfile{nmidx}.y;
    cx = allfile{nmidx}.cx;
    cy = allfile{nmidx}.cy;
    cid = allfile{nmidx}.cid;
    figs = dispImgClusters(x,y,cx,cy,cid,nowname,'rectangle',myFig);
    
    labelbox = cell(length(figs),1);
    for j=1:length(figs)
    boxpos = [figs{j}(1)+figs{j}(3)/4,...       % x
              figs{j}(2)+figs{j}(4)-0.001,...   % y
              figs{j}(3)/2,...                  % width
              figs{j}(4)/4];                    % height
    labelbox{j} = uicontrol('Parent', myFig, ...
                            'Style', 'edit', ...
                            'units', 'normalized',...
                            'Position', boxpos,...
                            'String', num2str(j));
    end
    uicontrol('Parent', myFig,...
              'Style', 'pushbutton',...
              'units', 'normalized',...
              'Position', [0.9,0.1,0.05,0.05],...
              'String', 'NEXT IMAGE',...
              'Callback', {@saveLabel,labelbox,myFig,img_idx,allfile,filename});
end

% ================== genImg callback: save description ====================
function saveDescription(src, event, data, myFig, img_idx, allfile,filename)
    str = get(data,'String');
    fprintf('Description: %s\n', get(data,'String'));
    close(myFig)
    % Write the user description
    fid = fopen(filename.description,'a');
    fprintf(fid, '%d,%s,%s\n', img_idx, allfile{img_idx}.nowname, str);
    fclose(fid);
    % Go to the labeling process of this image
    genImgBox(img_idx,myFig,allfile,filename);
end

% ===================== Generate image description UI =====================
function genImg(img_idx,myFig,allfile,filename)
    % Read in the image
    dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
    user = 'rawData_20170321_104subj/';
    nowname = allfile{img_idx}.nowname;
    imgname = fullfile(dataroot, user, '/data/demo/stimuli/', [nowname '.jpg']);
    I = imread(imgname);
    
    % Display image
    figure(myFig);
    set(myFig,'units','normalized');  
    set(myFig,'position',[0 0.05 1 0.8]); % set figure to be fullscreen
    subplot(1,3,[1,2]); imshow(I);
    subplot(133); imshow(0.95*ones(100));
    title('Please describe what is happening in this image.');
    % Create description box
    descBox = uicontrol('Parent', myFig, ...
                            'Style', 'edit', ...
                            'units', 'normalized',...
                            'Position', [0.7 0.25 0.2 0.5]);
    % Button to save the description and go to the labeling part
    uicontrol('Parent', myFig,...
              'Style', 'pushbutton',...
              'units', 'normalized',...
              'Position', [0.9,0.1,0.05,0.05],...
              'String', 'Labeling',...
              'Callback', {@saveDescription,descBox,myFig,img_idx,allfile,filename});
    
end

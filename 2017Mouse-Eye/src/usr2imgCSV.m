function imgAnnoCell = usr2imgCSV(datadate, imgAnnoCell, opts)
% 170820 created
% Helping on reading MTurk Annotated CSV data and do further processing
% Current funtion: read and show one labeling results on single image
% Goal: read MTurk CSV and recompile all of them into img-oriented data

% clear; close all; clc
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
user = 'rawData_20170321_104subj/';

% ########## DATA DIRECTORY: change to the path you have ###############
% datadate = '170818Data';
% datadate = '170905_11-20';
% imgAnnoCell = [];
% load(fullfile(dataroot, 'src', '170828imgAnnotation_1-10.mat'));
% ######################################################################

myFig=5;

load(fullfile(dataroot,user,'170727allfile_10.mat'), 'allfile_10');
allfile = allfile_10;

% Find all the csv filenames
usrdir = fullfile(dataroot, 'javascript_gui', 'data', datadate);
usrfile = dir(fullfile(usrdir, '*.csv'));
%%

% ~~~~~~~~~~~OUTER LOOP: MTurk username~~~~~~~~~~~~~
for uidx=1:length(usrfile) % user index
    % ==FILENAME==
    % username = 'AMSewonoh_0717';
    username = usrfile(uidx).name;
    fprintf('Now processing[%d]: %s\n', uidx, username);
    % LOAD CSV FILE
    csvpath = fullfile(usrdir, username);
    % tmp = dlmread( csvpath, '', [3, 1, 32, 1] );
    csvdat = readtable(csvpath, opts); % READIN -> database struct

    % Check whether imgAnnoCell is empty
    if isempty(imgAnnoCell)
        % Create a new data struct
        imgAnnoCell = cell(113,1); % For all images
    end

    % Take out certain fields from the csv table
    ans_label = csvdat.responses(strcmp(csvdat.qtype, 'Labeling')); % labeling answers
    ans_label = lower(ans_label);
    ans_desc  = csvdat.responses(strcmp(csvdat.qtype, 'Description')); % description answers
    ans_desc = lower(ans_desc);
    ans_index = reshape( str2double(csvdat.index(3:end)), 2, length(ans_label))';

    % Erase these '"', '{' and 'Q0:'
    ans_desc = erase(ans_desc, {'q0',':','{','"','}'} );
    ans_desc = strrep(ans_desc, ',', ';');
    
    % Erase n/a
    ans_label = erase(ans_label, 'n/a');

    % ~~~~~~~~~~~~~~MID LOOP: IMG INDEX~~~~~~~~~~~~~~~~
    % fprintf('\t(min=%d, max=%d)\n', min(ans_index(:,1)) , max(ans_index(:,1)))
    for qidx = min(ans_index(:,1)) : max(ans_index(:,1))
        nowDataIdx = qidx-min(ans_index(:,1))+1;
        % Deal with label
        str = ans_label{ nowDataIdx };
        tmp = strsplit(str(2:end-1), '","'); % Split to each questions -> cell
        tmp2 = erase(tmp, '"'); % erase " char and remaining: Q1:label

        % ~~~~~~~~~INNER LOOP: SUBWINDOW ANNOTATION~~~~~~~~~
        thislabel = cell(length(tmp),1);
        for i=1:length(tmp)
            tmp3 = strsplit(tmp2{i}, ':');
        %     fprintf('%d: %s\n', i, tmp3{2});
            thislabel{i} = tmp3{2};
        end % END of INNER LOOP (SUBWINDOW / BOXES ANNOTATION)

        % Save to the cellStruct
        % fprintf('\t\tqidx=%d (empty=%d)\n', qidx, isempty(imgAnnoCell{qidx}));
        if isempty(imgAnnoCell{qidx}) % Create new cellStruct
            imgAnnoCell{qidx}.usr = username;
            imgAnnoCell{qidx}.date = datadate;
            imgAnnoCell{qidx}.description = {ans_desc{nowDataIdx}};
            imgAnnoCell{qidx}.annotation = thislabel';
        else % Concatenate
            imgAnnoCell{qidx}.usr = [imgAnnoCell{qidx}.usr ; {username}];
            imgAnnoCell{qidx}.date = [imgAnnoCell{qidx}.date ; {datadate}];
            imgAnnoCell{qidx}.description = [imgAnnoCell{qidx}.description ; ans_desc{nowDataIdx}];
            imgAnnoCell{qidx}.annotation = [imgAnnoCell{qidx}.annotation ; thislabel'];
        end

    end % END of MID LOOP (IMG INDEX)

end % END of OUT LOOP (USERNAME)
%% Save the sorted results
% fprintf
% or download cell2csv.m
for qidx = min(ans_index(:,1)) : max(ans_index(:,1))
    nowname = fullfile(dataroot, 'javascript_gui', 'data', 'Sorted', ['Annotation_img' num2str(qidx) '.csv']);
    cell2csv(nowname, [imgAnnoCell{qidx}.usr, imgAnnoCell{qidx}.description, imgAnnoCell{qidx}.annotation], ',');
end




%%

% DISPLAY

% Load Image
% nowname = allfile{qidx}.nowname;
% imgname = [dataroot '/' user '/data/demo/stimuli/' nowname '.jpg'];
% I = imread(imgname);
% % figure; imagesc(I);a
% % title(strsplit(ans_desc{qidx}, {'. ', ', '}) );
% 
% % show the subbox and annotation
% figs = dispDescriptionTest(qidx, 'rectangle', 0, myFig+1, [], []); % orig
% figs = dispDescriptionTest(qidx, 'rectangle', 10, myFig, thislabel, ans_desc{qidx}); % ours




% OUTPUT: imgAnnoCell

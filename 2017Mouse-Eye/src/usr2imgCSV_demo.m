% function usr2imgCSV_demo
% 170924 Demo of using usr2imgCSV
% Transfer
clear; clc
dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
% user = 'rawData_20170321_104subj/';


datadate_root = fullfile(dataroot, 'javascript_gui', 'data');
datadate_dir = dir(fullfile(datadate_root, '17*')); % find all possible directory

imgAnnoCell = [];
% Setup the import option in case any file cannot be detected.
opts = detectImportOptions( fullfile(dataroot, 'src', 'data_sampleFormat.csv') );

for i=1:size(datadate_dir,1)
    fprintf('------Now loading directory [%d]: %s...\n', i, datadate_dir(i).name);
    datadate_now = datadate_dir(i).name;
    if ~isdir(fullfile(dataroot, 'javascript_gui', 'data', datadate_now))
        fprintf('Not a directory\n');
        continue
    end
    imgAnnoCell = usr2imgCSV(datadate_now, imgAnnoCell, opts);
end

%% Save as .mat file
% save('171106imgAnnotation_1-113_10p.mat', 'imgAnnoCell');

%% Save in one .csv file
formatOut = 'yymmdd';
nowname = fullfile(dataroot, 'src', [datestr(now,formatOut) 'Annotation_all.csv']);
fprintf('Saving....\n');
fid = fopen(nowname,'w');
fprintf(fid, 'Image Index,User ID,Description,Language Level,#Annotation\n');
fclose(fid);
for qidx = 1:length(imgAnnoCell)
    fprintf('\tNow [%d]\n', qidx);
    % Concate all the data and index together
    nowcontent = [imgAnnoCell{qidx}.usr, imgAnnoCell{qidx}.description];
    nowcontent = [ num2cell(qidx.*ones(size(nowcontent,1),1)) , nowcontent]; % adding image index
    % Adding language level (empty for fill in manually)
    nowcontent = [nowcontent , num2cell(zeros(size(nowcontent,1),1)) ];
    % Adding number of annotations and contents
    numAnno = find(~cellfun(@isempty,imgAnnoCell{qidx}.annotation(1,:))); % find nonempty annotation cells
    nowcontent = [nowcontent , num2cell(length(numAnno).*ones(size(nowcontent,1),1)) ]; % adding number of annotations
    nowcontent = [nowcontent , imgAnnoCell{qidx}.annotation]; % adding the rest annotations
    cell2csv(nowname, nowcontent, ',');
end

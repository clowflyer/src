% function Mturk_userSort
% 170920 Load the user batch csv file from Mturk's download site
% And extract user ID, paid information, and the experiment they took
% Then output all of them into a compiled csv file.
clear; clc

dataroot = 'C:\Users\karen\Documents\Research\Mouse-Eye _data_20160927\';
% user = 'rawData_20170321_104subj/';
usrdir = fullfile(dataroot, 'javascript_gui', 'data', 'batches');
usrfile = dir(fullfile(usrdir, 'Batch_*.csv'));

% ====== Just creating the file of the task that I've deleted... ======
% Find all the csv filenames
% usrdir = fullfile(dataroot, 'javascript_gui', 'data', 'rejected', '170728Data');
% usrfile = dir(fullfile(usrdir, '*.csv'));
% tmp = struct2cell(usrfile);
% allname = tmp(1,:)';
% 
% allreward = repmat({'$2.00'}, length(allname), 1);
% tmpfile = fullfile(dataroot, 'javascript_gui', 'data', 'Batch_170728Data_batch_results.csv');
% fid = fopen(tmpfile,'w');
% fprintf(fid, 'Reward,WorkerId\n');
% fclose(fid);
% 
% cell2csv(tmpfile, [allreward , allname], ',');
% =====================================================================

% Requirement: Directly Download the csv file from the result of each batch/hit
% And 30 variables inside the csv file for readtable (without any comma)
opts = detectImportOptions( fullfile(dataroot, 'javascript_gui', 'data', 'batches', 'sample.csv') , 'Delimiter', ',' );

allUser = [];
allReward = [];
allTask = [];
for uidx=1:length(usrfile) % user index
    % FILENAME
    username = usrfile(uidx).name;
    fprintf('Now processing[%d]: %s\n', uidx, username);
    % LOAD CSV FILE
    csvpath = fullfile(usrdir, username);
    csvdat = readtable(csvpath,opts);
    
    % Fields needed: Reward, WorkerId, RequesterFeedback
    % Find accepted users
    idx_accept = find(cellfun(@isempty,csvdat.RejectionTime)==1);
    % Reward transform to number array
    nowreward = str2double(erase(csvdat.Reward(idx_accept), '$'));
    % User ID
    nowuser = csvdat.WorkerId(idx_accept);
    
    % Initial case
    if isempty(allUser)
        allUser = nowuser;
        allReward = nowreward;
        allTask = repmat({username},length(nowuser),1);
        continue;
    end
    
    % First Merge current data to our user list (allUser) -> sorted
    oldUser = allUser; % save it temperary for future indexing
    allUser = union(allUser, nowuser); % New user set
    
    % Sort the original reward matrix into the correct order
    [~,idx_old] = ismember(oldUser,allUser);
    oldReward = allReward; % save it temperary
    allReward = zeros(length(allUser),1);
    allReward(idx_old) = oldReward;
    % Sort the original task cell matrix
    oldTask = allTask;
    allTask = cell(length(allUser), size(oldTask,2));
    allTask(idx_old,:) = oldTask;
    
    % Add the new reward to sorted reward matrix
    [~,idx_new] = ismember(nowuser,allUser);
    allReward(idx_new) = allReward(idx_new) + nowreward;
    
    % Add the cell of all going through task
    allTask = [allTask , cell(length(allUser),1)];
    allTask(idx_new,end) = repmat({username},length(nowuser),1);
end

idx_task = ~cellfun(@isempty, allTask);
tmp = struct2cell(usrfile);
filename = tmp(1,:);
% Sort all tasks (get rid of empty cell)
% allTask_new = cell(length(allUser),1);
% for i=1:length(allUser)
%     idx_task = 
% end

% Save
nowname = fullfile(dataroot, 'javascript_gui', 'data', [datestr(date, 'yymmdd') 'Batch_combined.csv']);
fprintf('Saving....\n');
fid = fopen(nowname,'w');
fprintf(fid, 'User ID,Total Reward,Tasks');
for i=1:length(filename)
    fprintf(fid, ',%s', filename{i});
end
fprintf(fid, '\n');
fclose(fid);

cell2csv(nowname, [allUser , num2cell(allReward) , num2cell(sum(idx_task,2)), num2cell(double(idx_task))], ',');


function translateBev(Monkey, BEVpath, savePath)
%% path variable
wellPath = strcat("data/wellData/", Monkey);
if ~exist(wellPath, "dir")
    mkdir(wellPath)
end
%% Select well data from all behaviour data
% copy well
fprintf("=====copy data=====\n")
obj = BEVdata(BEVpath,'mat');
if ~exist(wellPath, 'dir')
    mkdir(wellPath)
end
obj.copywell(10,wellPath);
%% Preprocss well Behaviour data
% init variables
BEVpath = wellPath;
if ~exist(savePath, "dir")
    mkdir(savePath)
end
obj = BEVdata(BEVpath,'mat');
saveName = strcat(obj.folder, '.mat');
% main loop
fprintf("=====read data=====\n")
parfor i = 1:length(obj.folder)
    % check exist
    file_ = strcat(savePath, '/', saveName(i));
    if exist(file_,'file')
        continue
    end
    % read raw data and save
    Data = readFiles(i, obj);
    obj.saveData(savePath, saveName(i), Data);
end
end

function Data = readFiles(i, obj)
obj.folderI = i;
Data = obj.readData;
end
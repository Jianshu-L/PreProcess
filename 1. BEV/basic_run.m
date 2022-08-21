%% basic using of BEVdata
addpath(genpath(("src")));
BEVpath = "D:\data\Detron";
savePath = strcat("results/BEVdata");
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

function Data = readFiles(i, obj)
obj.folderI = i;
Data = obj.readData;
end
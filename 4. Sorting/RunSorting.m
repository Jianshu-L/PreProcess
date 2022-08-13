function RunSorting(dataPath, fPath)
if ~exist("fPath", "var")
    fPath = "/media/muscle/BRdata"; % ns6 file path
    %     fPath = "/media/pacman/TreeSSD";
end
if ~exist("dataPath", "var")
    dataPath = strcat("data/BEVdata");
end
[status,~] = unix("klusta");
if status == 127
    error("klusta command not found")
end
%% sorting
addpath(genpath(("src")));
savePath =  "results/BRdata/NS6/data";
archivePath = [];
% archivePath = "/media/muscle/Data/Sorting"; % archive sorting results
% archivePath = "/media/muscle/lab302";
for Monkey = ["o","p"]
    sortingData(Monkey, dataPath, fPath, savePath, archivePath);
end
rmpath(genpath(("src")));
end
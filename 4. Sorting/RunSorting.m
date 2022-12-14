function RunSorting(dataPath, fPath)
% dataPath = "D:\pacman_data\data_2021\Patamon\results\data";
% fPath = "H:";
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
Monkey = "p";
sortingData(Monkey, dataPath, fPath, savePath, archivePath);
rmpath(genpath(("src")));
end
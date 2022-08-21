%% default input
dataPath = "D:\data\datafile20220802";
BEVpath = "D:\matlab\PreProcess\1. BEV\results\BEVdata";
dataPath = strrep(dataPath,"\","/");
BEVpath = strrep(BEVpath,"\","/");
%% translate data
addpath(genpath("src"));
% create diary
diaryName = sprintf("ppBRDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% main
archivePath = strcat(dataPath,"/Eve"); % BR Eve marker path
savePath = "results/Neuron";
BRreport = translateNEV(dataPath, archivePath, savePath);
rmpath(genpath("src"));
diary off
%% Combine all data
addpath(genpath("src"));
dataPath = "results/data";
obj = combineNEV(dataPath);
% main loop
fprintf("=====combine bev and nev data=====\n")
BEVdata = strcat(BEVpath, "/Detron-02-Aug-2022-3.mat");
BRdata = strcat(savePath,"/datafile20220802Marker.mat");
data = obj.combine(BEVdata, BRdata);
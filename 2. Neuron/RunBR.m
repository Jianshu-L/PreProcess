function [BRreport,NEVreport] = RunBR(dataPath, BEVpath)
%% default input
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
%% combine data
addpath(genpath("src"));
% create diary
diaryName = sprintf("combineDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% main loop
NEVreport = strings(0);
BRpath = "results/Neuron";
savePath = "results/data";
NEVreport_ = combineData(BEVpath, BRpath, savePath);
if isempty(NEVreport)
    NEVreport = NEVreport_;
else
    NEVreport = [NEVreport;NEVreport_];
end
rmpath(genpath("src"));
end

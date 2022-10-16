function RunBEV(dataPath, elPath)
%% default input
if nargin == 0
    dataPath = "../data/Omega";
    elPath = "../data/Eyelink";
end
dataPath = strrep(dataPath,"\","/");
elPath = strrep(elPath,"\","/");
%% select well data
addpath(genpath(("src")));
BEVpath = selectWell(dataPath);
rmpath(genpath(("src")));
%% translate Behaviour data
addpath(genpath(("src")));
% process data
translateBev(BEVpath);
rmpath(genpath(("src")));
%% translate Eyelink data
addpath(genpath(("src")));
% create diary
diaryName = sprintf("ppELDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% process data
mouseData = translateEl(elPath); %#ok<NASGU>
rmpath(genpath(("src")));
diary off
%% combine data
addpath(genpath(("src")));
% create diary
diaryName = sprintf("combineDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% init variables
BEVpath = "../results/BEVdata/";
ELpath = "../results/Eyelink/";
mouseData = combineData(BEVpath, ELpath);
%% test data
addpath("test")
test_data("../results/data","../results/Eyelink");
rmpath("test")
rmpath(genpath(("src")));
diary off
end
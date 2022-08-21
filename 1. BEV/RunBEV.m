function mouseData = RunBEV(dataPath, elPath)
%% default input
if nargin ~= 1
    dataPath = "E:/Behaviour";
end
if nargin ~= 2
    elPath = "E:/Eyelink";
end
dataPath = strrep(dataPath,"\","/");
elPath = strrep(elPath,"\","/");
%% translate Behaviour data
addpath(genpath(("src")));
savePath = strcat("results/BEVdata");
translateBev(dataPath, savePath);
rmpath(genpath(("src")));
%% translate Eyelink data
addpath(genpath(("src")));
% create diary
diaryName = sprintf("ppELDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
for Monkey = ["Omega","Patamon"]
    dataPath = strcat(elPath, "/", Monkey);
    savePath = strcat("results/Eyelink/", Monkey);
    mouseData = translateEl(dataPath, savePath);
end
rmpath(genpath(("src")));
diary off
%% combine data
addpath(genpath(("src")));
% create diary
diaryName = sprintf("combineDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
for Monkey = ["Omega","Patamon"]
    % init variables
    BEVpath = strcat("results/BEVdata/", Monkey);
    ELpath = strcat("results/Eyelink/", Monkey);
    dataPath = strcat("results/data/", Monkey);
    mouseData = combineData(BEVpath, ELpath, dataPath);
end
addpath("test")
test_data("results/data","results/Eyelink");
rmpath("test")
rmpath(genpath(("src")));
diary off
end

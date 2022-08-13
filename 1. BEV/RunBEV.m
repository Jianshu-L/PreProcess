function mouseData = RunBEV(bevPath, elPath)
%% default input
if nargin ~= 2
    bevPath = "E:/Behaviour";
    elPath = "E:/Eyelink";
end
bevPath = strrep(bevPath,"\","/");
elPath = strrep(elPath,"\","/");
%% translate Behaviour data
addpath(genpath(("src")));
for Monkey = ["Omega","Patamon"]
    dataPath = strcat(bevPath, "/", Monkey);
    savePath = strcat("results/BEVdata/", Monkey);
    translateBev(Monkey, dataPath, savePath);
end
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

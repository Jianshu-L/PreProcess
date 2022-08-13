function RunDebug
% %% translate Behaviour data
% addpath(genpath(("src")));
% for Monkey = ["Omega","Patamon"]
%     dataPath = strcat(bevPath, "/", Monkey);
%     savePath = strcat("results/BEVdata/", Monkey);
%     translateBev(Monkey, dataPath, savePath);
% end
% rmpath(genpath(("src")));
%% translate Eyelink data
addpath(genpath(("src")));
% init variables
elPath = "data/Eyelink/bug";
dataPath = strcat(elPath, "/");
savePath = strcat("results/bug/");
% read EL data
fprintf("=====read eyelink data=====\n")
% init variables
if ~exist(savePath, "dir")
    mkdir(savePath)
end
% main loop
fprintf("read asc\n")
obj = ELdata(dataPath,'asc');
saveName = strrep(obj.file, '.asc', '.mat');
bugFiles = zeros(length(obj.file),1);
for i = 1:length(obj.file)
    % read asc data
    eyelink = readFile(obj, i);
    if isempty(eyelink) % mouse simulation data
        bugFiles(i) = 1;
        continue
    end
    if ~isstruct(eyelink)
        if eyelink == 0
            bugFiles(i) = 2;
            continue
        end
    end
    obj.saveData(savePath, saveName(i), eyelink); % save
end
diary off
rmpath(genpath(("src")));
% %% combine data
% addpath(genpath(("src")));
% % init variables
% Monkey = "Omega";
% BEVpath = strcat("results/bug/BEVdata");
% ELpath = strcat("results/bug/Eyelink");
% dataPath = strcat("results/bug/", Monkey);
% if ~exist(dataPath, "dir")
%     mkdir(dataPath)
% end
% obj = combineBEV(BEVpath, ELpath, dataPath);
% saveName = obj.BEV.file;
% files = strcat(dataPath, '/', saveName);
% % main loop
% fprintf("=====combine bev and el data=====\n")
% for index = 1:length(saveName)
%     fileName = saveName(index);
%     file_i = files(index);
%     % check exists
%     if exist(file_i,'file')
%         continue
%     end
%     % combine data
%     data = readFileV2(obj, fileName);
%     obj.saveData(file_i, data);
% end
end

function eyelink = readFile(obj, i)
obj.fileI = i;
eyelink = obj.readData;
end

function [data,bug] = readFileV2(obj, fileName)
bug = 0;
% find related eyelink data
[BEVdata, ELdata] = obj.checkBEV(fileName);
if isempty(ELdata)
    bug = 1;
end
data = obj.combine(BEVdata, ELdata);
end
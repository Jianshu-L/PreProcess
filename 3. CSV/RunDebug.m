function RunDebug(bevPath)
%% default input
if nargin ~= 1
    bevPath = "data/data";
end
%% python csv
addpath(genpath(("src")));
% create diary
diaryName = sprintf("csvDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
dataPath = bevPath;
savePath = "results/bug";
%% init variables
if ~exist(savePath, "dir")
    mkdir(savePath)
end
obj = ListData(dataPath, 'mat');
fileNames = strcat(obj.path,"/", obj.file);
csvNames = strcat(savePath, "/", obj.file);
%% main loop
fprintf("=====save as csv for python=====\n")
for i = 1:length(fileNames)
    file_i = fileNames(i);
    csv_i = csvNames(i);
    if exist(strrep(csv_i,'mat', 'csv'),"file") && exist(strrep(csv_i,'.mat', '-R.csv'),"file")
        continue
    end
    try
        [data,rewP] = readFiles(file_i);
        writetable(data, strrep(csv_i,'.mat', '.csv'))
        writetable(rewP, strrep(csv_i,'.mat', '-R.csv'))
    catch ME
        fprintf("*******%s*******\n",ME.message)
    end
end
rmpath(genpath(("src")));
diary off
end

function [data,rewP] = readFiles(file_i)
load(file_i, "data");
[data,rewP] = Mat2Csv(data); %#ok<NODEF>
end
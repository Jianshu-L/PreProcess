function RunCSV(dataPath)
%% default input
if nargin ~= 1
    dataPath = "../results/data_neuron";
end
%% python csv
addpath(genpath(("src")));
% create diary
diaryName = sprintf("csvDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% init variables
savePath = "../results/csv";
tic;
toCSV(dataPath, savePath);
Artime = toc;
fprintf("convert csv cost %.2f minutes\n", Artime/60);
rmpath(genpath(("src")));
diary off
%% output data size for test later
addpath(genpath(("src")));
fileNames = dirFiles(dataPath,"mat");
Height = zeros(length(fileNames),1);
parfor i = 1:length(fileNames)
    data = load(strcat(dataPath,"/",fileNames(i)),"data");
    Height(i) = height(data.data);
end
dataSize = table(fileNames,Height);
writetable(dataSize, "test/dataSize.csv");
rmpath(genpath(("src")));
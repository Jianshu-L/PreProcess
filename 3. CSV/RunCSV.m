function RunCSV(bevPath)
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
% for Monkey = ["Omega","Patamon"]
%     dataPath = strcat(bevPath, "/", Monkey);
%     savePath = strcat("results/csv/", Monkey);
%     t1 = GetSecs();
%     toCSV(dataPath, savePath);
%     t2 = GetSecs();
%     Artime = t2 - t1;
%     fprintf("convert csv cost %.2f minutes\n", Artime/60);
% end
dataPath = bevPath;
savePath = "results/csv";
tic;
toCSV(dataPath, savePath);
Artime = toc;
fprintf("convert csv cost %.2f minutes\n", Artime/60);
rmpath(genpath(("src")));
diary off
% output data size for test later
fileNames = dirFiles(bevPath,"mat");
Height = zeros(length(fileNames),1);
parfor i = 1:length(fileNames)
    data = load(strcat(bevPath,"/",fileNames(i)),"data");
    Height(i) = height(data.data);
end
dataSize = table(fileNames,Height);
writetable(dataSize, "test/dataSize.csv");
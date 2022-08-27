function test_data(dataPath,elPath)
%% default input
if nargin ~= 2
    dataPath = "../results/data";
    elPath = "../results/Eyelink";
end
% init variables
elFiles = dirFiles(elPath,"mat");
dataFiles = dirFiles(dataPath,"mat");
index = randperm(length(dataFiles),1);
elFiles_ = elFiles(contains(elFiles,dataFiles(index)));
while length(elFiles_) ~= length(dataFiles(index))
    index = randperm(length(dataFiles),1);
    elFiles_ = elFiles(contains(elFiles,dataFiles(index)));
end
dataFiles = strcat(dataPath,"/",orderFolder(dataFiles(index)));
elFiles = strcat(elPath,"/",orderFolder(elFiles_));
% test
load(dataFiles,"data")
load(elFiles,"eyelink")
data_i = data(randperm(height(data),1),["Step","DayTrial","elX","elY"]);
temp = split(data_i.DayTrial, '-');
trialName = sprintf('%d-%d', double(temp(1)), double(temp(2)));
eldata = eyelink.sample(contains(string({eyelink.sample.trial}),trialName)).timestep;
if all([data_i.elX,data_i.elY] == eldata(data_i.Step,1:2))
    fprintf("pass test\n")
else
    error("eyelink data of %s Step %d is not match", data_i.DayTrial, data_i.Step)
end
end
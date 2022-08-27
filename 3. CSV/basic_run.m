%% default path
dataPath = "../results/BEVdata";
savePath = "../results/csv";
%% python csv
addpath(genpath(("src")));
toCSV(dataPath, savePath);
rmpath(genpath(("src")));
function RunSelecting(Monkey)
if ~exist("Monkey", "var")
    Monkey = "o";
end
addpath(genpath(("src")));
dataPath = "results/BRdata/NS6/data";
savePath = "results/Neuron";
csvPath = "results/spikes";
%% selecting valid channels
if Monkey == "o"
    load('DriverUnit.mat','T');
else
    load('DriverUnitPatamon.mat','T');
end
selectingData(Monkey, dataPath, savePath, csvPath, T);
rmpath(genpath(("src")));
end
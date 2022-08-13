function RunWaveForm(ns6Path)
if ~exist("ns6Path", "var")
    ns6Path = "/media/muscle/BRdata";
end
addpath(genpath(("src")));
dataPath = "results/Neuron";
savePath = "results/waveform";
%% get waveform
for folderName  = dirFolders(dataPath)'
    folderName_ = strcat(dataPath,"/",folderName);
    if length(dirFiles(folderName_,"csv")) == 1
        csvName = dirFiles(folderName_,"csv");
        % ns6 files
        ns6Names = dirFiles(ns6Path,"ns6");
        temp = char(folderName);
        ns6Files = strcat(ns6Path,"/",ns6Names(contains(ns6Names,temp(1:8))));
    else
        error("more than one csv")
    end
    T = readtable(strcat(folderName_,"/",csvName));
    sP = strcat(savePath,"/",temp(1:9));
    plot_wf(ns6Files, sP, T);
    plot_ACG(sP, T);
    plot_ISI(sP, T);
    collectWF(csvName, sP, T);
end
rmpath(genpath(("src")));
end

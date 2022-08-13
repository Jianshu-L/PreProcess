function selectingDataDebug(dataPath,FeaturesPath)
% selecting main loop
fprintf("=====selecting NS6=====\n")
obj = readCSV(dataPath);
for i = 1:length(obj.folderNames)
    selectWell(obj, i, FeaturesPath);
end
fprintf("===== END =====\n")
diary off
end
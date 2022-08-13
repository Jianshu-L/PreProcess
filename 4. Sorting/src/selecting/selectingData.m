function selectingData(Monkey, dataPath, savePath, csvPath, T)
% create diary
diaryName = sprintf("selectingDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% selecting main loop
fprintf("=====selecting NS6=====\n")
obj = readCSV(Monkey, dataPath);
obj.Tu = T;
parfor i = 1:length(obj.folderNames)
    try
        [report,Tall] = selectWell(obj, i);
        saveData(obj, savePath, csvPath, report, Tall);
    catch ME
        fprintf("*****%d: %s*****\n", i, ME.message)
        continue
    end
end
fprintf("===== END =====\n")
diary off
end
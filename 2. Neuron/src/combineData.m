function NEVreport = combineData(BEVpath, BRpath, dataPath)
%% init variables
if ~exist(dataPath, "dir")
    mkdir(dataPath)
end
%% Combine all data
obj = combineNEV(BEVpath, BRpath, dataPath);
saveName = obj.BEV.file;
files = strcat(dataPath, '/', saveName);
bugFiles = zeros(length(files),1);
% main loop
fprintf("=====combine bev and nev data=====\n")
parfor index = 1:length(saveName)
    fileName = saveName(index);
    file_i = files(index);
    % check exists
    if exist(file_i,'file')
        continue
    end
    % combine data
    [data,bug] = readFile(obj, fileName);
    if bug
        bugFiles(index) = 1;
    end
    obj.saveData(file_i, data);
end
%% save report
NEVreport = obj.report;
saveMarker(NEVreport,"NEVreport");
if exist('BRreport.mat', "file")
    load('BRreport.mat','BRreport');
else
    BRreport = strings(0);
end
if sum(bugFiles) ~= 0
    [~,missFiles] = obj.FtoN(saveName(logical(bugFiles)));
    for missFile = missFiles'
        if contains(BRreport(:,1),missFile)
            continue
        end
        temp = size(BRreport);
        i_ = temp(1)+1;
        BRreport(i_,1) = missFile;
        BRreport(i_,2) = "";
        BRreport(i_,3) = "MarkerIsMissing";
    end
    saveMarker(BRreport,"BRreport");
end
end

function [data,bug] = readFile(obj, fileName)
bug = 0;
% find related eyelink data
[BEVdata, BRdata] = obj.checkNEV(fileName);
if isempty(BRdata)
    bug = 1;
end
data = obj.combine(BEVdata, BRdata);
end

function saveMarker(new,name)
if ~isempty(new)
    if exist(name,"file")
        load(sprintf("%s.mat",name),name);
        if eval(sprintf("~all(size(new) == size(%s))",name))
            eval(sprintf("%s= new;",name));
            fprintf("save marker\n")
            save(sprintf("%s.mat",name), sprintf("%s",name));
        end
    else
        eval(sprintf("%s= new;",name));
        fprintf("save marker\n")
        save(sprintf("%s.mat",name), sprintf("%s",name));
    end
end
end
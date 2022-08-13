function mouseData = combineData(BEVpath, ELpath, dataPath)
%% init variables
if ~exist(dataPath, "dir")
    mkdir(dataPath)
end
%% Combine all data
obj = combineBEV(BEVpath, ELpath, dataPath);
saveName = obj.BEV.file;
files = strcat(dataPath, '/', saveName);
bugFiles = zeros(length(files),1);
% main loop
fprintf("=====combine bev and el data=====\n")
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
if exist("mouseData.mat", "file")
    load('mouseData.mat','mouseData');
else
    mouseData = ["",""];
end
for i = 1:length(bugFiles)
    if bugFiles(i)
        fileName = saveName(i);
        if ~ismember(fileName,mouseData(:,1)) % check whether mouse simulation data
            fprintf("***no related asc data with %s***\n", fileName)
            i_ = length(mouseData(:,1))+1;
            mouseData(i_,1) = fileName;
            mouseData(i_,2) = "DataMissing";
        else
            fprintf("%s: mouse simulation data\n", fileName)
        end
    end
end
saveMarker(mouseData,"mouseData");

end

function [data,bug] = readFile(obj, fileName)
bug = 0;
% find related eyelink data
[BEVdata, ELdata] = obj.checkBEV(fileName);
if isempty(ELdata)
    bug = 1;
end
data = obj.combine(BEVdata, ELdata);
end

function saveMarker(new,name) %#ok<INUSL>
if exist(strcat(name,".mat"),"file")
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
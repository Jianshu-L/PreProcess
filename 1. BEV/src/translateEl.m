function mouseData = translateEl(elPath, savePath)
%% Preprocss Eyelink Data
% read EL data
fprintf("=====read eyelink data=====\n")
% init variables
if ~exist(savePath, "dir")
    mkdir(savePath)
end
% main loop
fprintf("read asc\n")
obj = ELdata(elPath,'asc');
saveName = strrep(obj.file, '.asc', '.mat');
bugFiles = zeros(length(obj.file),1);
parfor (i = 1:length(obj.file),12)
    % check exists
    file_ = strcat(savePath, '/', saveName(i));
    if exist(file_,'file')
        continue
    end
    % read asc data
    eyelink = readFile(obj, i);
    if isempty(eyelink) % mouse simulation data
        bugFiles(i) = 1;
        continue
    end
    if ~isstruct(eyelink)
        if eyelink == 0
            bugFiles(i) = 2;
            continue
        end
    end
    obj.saveData(savePath, saveName(i), eyelink); % save
end
k = 1;
mouseData = strings(0);
for i = 1:length(bugFiles)
    bugIndex = bugFiles(i);
    switch bugIndex
        case 1% mouse simulation data
            mouseData(k,1) = saveName(i);
            mouseData(k,2) = "mouse simulation";
            k = k + 1;
        case 2
            mouseData(k,1) = saveName(i);
            mouseData(k,2) = "bug data (revalidation fail, mouse simulation for parts, etc)";
            k = k + 1;
    end
end
saveMarker(mouseData,"mouseData");
end

function eyelink = readFile(obj, i)
obj.fileI = i;
eyelink = obj.readData;
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
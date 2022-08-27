function BRreport = translateNEV(dataPath)
%% init variables
archivePath = strcat(dataPath,"/Eve"); % BR Eve marker path
savePath = "../results/Neuron";
if ~exist(archivePath, "dir")
    mkdir(archivePath)
end
if ~exist(savePath, "dir")
    mkdir(savePath)
end
%% read raw nev data and save in archivePath
fprintf("=====neuron marker data=====\n")
fprintf("nev to mat\n")
nev2mat(dataPath, archivePath);
%% read neuron marker data
% init variables
obj = BRdata(archivePath,'mat');
saveName = strrep(obj.file, 'Eve', 'Marker');
% init report
if exist("BRreport.mat", "file")
    load('BRreport.mat','BRreport');
    obj.report = BRreport;
end
% main loop
fprintf("read marker data\n")
for i = 1:length(obj.file)
    obj.fileI = i;
    file_ = strcat(savePath, '/', saveName(i));
    if exist(file_,'file')
        continue
    end
    % read marker data
    [Event, Frame, Dir] = obj.readData;
    if isempty(Event) && isempty(Frame) && isempty(Dir)
        continue
    end
    obj.saveData(savePath, saveName(i), Event, Frame, Dir); % save
end
BRreport = obj.report;
saveMarker(BRreport,"BRreport");
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

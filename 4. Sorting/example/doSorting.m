function doSorting(fileName, folder, Monkey, conda_path)
% fileName = "datafile20210701p001.ns6";
% folder = "f:/";
% Monkey = "p";
% conda_path = "C:/Users/jsli/miniconda3";
savePath = "results/BRdata";
%% init vars
addpath("utils")
addpath(genpath("NPMK-5.5.0.0"))
[status,~] = unix("klusta");
if status ~= 2
    error("klusta command not found")
end
copyfile("utils/1_Pacman.prb", ...
    sprintf("%s/envs/klusta/Lib/site-packages/klusta/probes",conda_path));
if strcmp(Monkey, 'p')
    validChannels = PCB_Patamon;
elseif strcmp(Monkey, 'o')
    validChannels = PCB_Omega;
end
%% create diary
diaryName = sprintf("sortingDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
%% read ns6 and sorting
file = strcat(folder, fileName);
fileName = char(fileName);
saveName = strcat(savePath, "/", fileName(9:16), Monkey);
if ~exist(saveName,"dir")
    mkdir(saveName);
end
brTodat(file, saveName, validChannels, validChannels);
% sorting
doKlusta(saveName, validChannels);
%% select valid units
% init vars
obj = readCSV(Monkey, savePath);
if Monkey == "o"
    load('DriverUnit.mat','T');
else
    load('DriverUnitPatamon.mat','T');
end
obj.Tu = T;
savePath = "results/Neuron";
if ~exist(savePath,"dir")
    mkdir(savePath);
end
csvPath = "results/spikes";
if ~exist(csvPath,"dir")
    mkdir(csvPath);
end
% selecting
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
rmpath("utils")
rmpath(genpath("NPMK-5.5.0.0"))
end

function brTodat(file, folderName, channels, validChannels)
if ~exist(folderName, "dir")
    mkdir(folderName);
end
%% openNS6 and save dat
dbstop if error
temp = split(file,["/","\"]);
if size(temp,2) == 2
    fileNames = temp(:, end);
else
    fileNames = temp(end);
end
% one folder for each dat
chanNum = string(channels);
folderNames = strcat(folderName, "/", chanNum);
k = 1;
matrix = reshape(1:160,16,10)';
for i = 1:10
    c_ = matrix(i,:);
    clear NS6
    if ~any(ismember(c_,channels))
        continue
    end
    for fi = 1:length(file)
        file_ = file(fi);
        fileName = fileNames(fi);
        openNSx(char(file_),'uv', char(sprintf('c:%d:%d', min(c_), max(c_))));
        if fi == 1
            datIall = int16(NS6.Data);
        else
            datIall = [datIall,int16(NS6.Data)]; %#ok<AGROW>
        end
    end
    if i == 1
        MetaTags = NS6.MetaTags;
        %% save MetaTags
        name = split(fileNames(1), '.');
        name = name{1};
        name_ = sprintf("%sTags.mat", name);
        name_ = strcat(folderName, "/", name_);
        if ~exist(name_,"file")
            fprintf("save MetaTags file %s\n", name_)
            MetaTags.timeLength = length(datIall(1,:))/30000/3600;
            save(name_, "MetaTags")
        end
    end
    fprintf("channel ")
    for index_ = 1:16
        if ismember(c_(index_), channels)
            fprintf("%d ", c_(index_))
            datI = datIall(index_,:);
            if ~exist(folderNames(k), 'dir')
                mkdir(folderNames(k))
            end
            Name = saveDat(datI, c_(index_), fileName);
            clear NS6
            movefile(Name, folderNames(k))
            k = k + 1;
        end
    end
    fprintf("\n")
end
clear NS6
rmpath(genpath('NPMK'))
if length(dirFolders(folderName)) ~= length(validChannels)
    error("not all valid channels being open")
end
end

function Name = saveDat(datI, channel, fileName)
datKlusta = reshape(datI,1,numel(datI));
name = split(fileName, '.');
name = name{1};
Name = sprintf("%s-%d.dat", name, channel);
fid = fopen(Name, 'w');
% fprintf("save dat file %s\n", name)
fwrite(fid, datKlusta, 'int16');
fclose(fid);
end

function doKlusta(folder, validChannels)
[PRM, csvNames] = createPRM(folder);
parfor i = 1:length(PRM)
    klusta_sorting(folder, PRM, csvNames, validChannels, i)
end
end

function klusta_sorting(folderName, PRM, csvNames, validChannels, i)
prmname = PRM(i);
if ~exist(csvNames(i),"file")
    fprintf("sorting %s\n", prmname)
    [status,cmdout] = unix(sprintf("klusta %s --overwrite --output-dir ./", prmname));
    if status
        error(cmdout)
    end
end
kwik2csv(folderName, validChannels(i), csvNames(i));
end

function kwik2csv(Path,chan,csvName)
file = dir(strcat(Path, "/", char(chan), "/*.kwik"));
file = strcat(file.folder, "/", file.name);
try
    time_samples = hdf5read(file, '/channel_groups/0/spikes/time_samples'); %#ok<HDFR>
    cluster_number = hdf5read(file, '/channel_groups/0/spikes/clusters/main'); %#ok<HDFR>
catch
    time_samples = [];
    cluster_number = [];
end
T = table(time_samples,cluster_number);
writetable(T, csvName);
end

function [PRM, csvNames] = createPRM(folder)
csvNames = strcat(folder,"/klusta-",dirFolders(folder),".csv");
allData = strcat(folder, "/", dirFolders(folder));
Str = fileread('1_Omega.prm');
PRM = repmat("", 1,length(allData));
% DatFiles = repmat("", 1,length(allData));
for index = 1:length(allData)
    fileName = dir(strcat(allData(index),"/*.dat"));
    filename = string(fileName.name);
    fileName = strcat(allData(index), "/", filename);
    % index = 1;
    prmName = strrep(fileName,'.dat', '.prm');
    datName = strrep(fileName, '.dat', '');
    PRM(index) = prmName;
    %     DatFiles(index) = strrep(fileName, '.dat', '.kwik');
    fid = fopen(prmName, 'w');
    fprintf(fid,'experiment_name = "%s"\n',datName);
    fprintf(fid,'prb_file = "%s"\n',datName);
    fwrite(fid, Str, 'char');
    fclose(fid);
end
end

classdef Br2Fr < handle
    
    properties
        index = 1;
        nsF
        fileNames % neuron data for each date
        folder % folder of each date
        archiveFolder % archive dat files and sorting results
        datFolder % dat files and sorting results
        Channels
        report = "";
    end
    
    properties(Hidden)
        date
        timeLength
        rindex = 1;
    end
    
    methods
        function obj = Br2Fr(Monkey, dPath ,fPath, savePath, archivePath)
            obj.nsF = ns6F(Monkey, dPath, fPath, savePath, archivePath);
            %% Map information
            if strcmp(obj.nsF.Monkey, 'p')
                validChannels = PCB_Patamon;
            elseif strcmp(obj.nsF.Monkey, 'o')
                validChannels = PCB_Omega;
            end
            obj.Channels = validChannels;
        end
        
        function fileNames = get.fileNames(obj)
            fileNames = obj.nsF.files(contains(obj.nsF.files,obj.nsF.fDate(obj.index)));
        end
        
        function folder = get.folder(obj)
            folder = obj.nsF.datFolders(obj.index);
        end
        
        function archiveFolder = get.archiveFolder(obj)
            archiveFolder = obj.nsF.archiveFolders(obj.index);
        end
        
        function datFolder = get.datFolder(obj)
            datFolder = obj.nsF.datFolders(contains(obj.nsF.datFolders, obj.nsF.fDate(obj.index)));
        end
        
        function MetaTags = loadTags(obj)
            name = split(obj.fileNames(1), '.');
            name = name{1};
            name_ = sprintf("%sTags.mat", name);
            name_ = strcat(obj.datFolder, "/", name_);
            load(name_,"MetaTags");
        end
        
        function [Sort,Archive] = checkProgress(obj)
            Sort = 1;
            Archive = 0;
            dirExist = checkExist(obj, "csv");
            Channels_ = obj.Channels(~dirExist);
            if isempty(Channels_)
                Sort = 0;
                Archive = 1;
                dirExist = obj.checkExist("archive");
                if dirExist
                    Archive = 0;
                end
            end
        end
        
        function [csvNames, PRM, Channel_] = readingNS6(obj)
            fileName = obj.fileNames;
            folderName = obj.datFolder;
            if ~exist(folderName,"dir")
                mkdir(folderName)
            end
            fprintf("%s\n",obj.folder)
            dirExist = checkExist(obj, "csv");
            Channels_ = obj.Channels(~dirExist);
            %% only select valid Channels
            if obj.nsF.Monkey == "p"
                load('DriverUnitPatamon.mat','T');
            end
            Trecord =T(T.Date == double(obj.nsF.fDate(obj.index)),:);          
            if isempty(Trecord)
                error("no related driver record")
            end
            if sum(dirExist) == 0
                fprintf("saving\n")
                validChan = setdiff(Channels_,setdiff(Channels_,unique([Trecord.SU{1};Trecord.MU{1}])));
                if ~isempty(validChan)
                    obj.brTodat(fileName, folderName, validChan);
                else
                    fprintf("no valid channels\n")
                end
            end
            fprintf("sorting\n")
            [PRM, csvNames] = createPRM(folderName);
            Channel_ = dirFolders(folderName);
        end
        
        function [validChan, Tall, fr, frName] = selectWell(obj, LeastFiringCount)
            Tall = [];
            validChan = [];
            csvNames = strcat(obj.datFolder,"/",dirFiles(obj.datFolder,"csv"));
            RefractoryPeriod = 90; % 3ms
            fprintf("----------\n%s\n", obj.nsF.fDate(obj.index))
            [validChan_, T, fr, frName] = obj.datTofr(csvNames, ...
                LeastFiringCount, RefractoryPeriod);
            validChan = [validChan;validChan_];
            Tall = [Tall;T];
        end
        
        function archiveDat(obj)
            folder_ = obj.folder;
            afolder = obj.archiveFolder;
            if ~exist(afolder,"dir")
                mkdir(afolder);
            end
            [status, msg] = copyfile(folder_, afolder);
            if ~status
                error(msg);
            end
            rmdir(folder_,"s");
            mkdir(folder_);
            fileNames_ = [dirFiles(afolder,"csv");dirFiles(afolder,"mat")];
            for i = 1:length(fileNames_)
                copyfile(strcat(afolder,"/", fileNames_(i)), folder_);
            end
        end
        
        function deleteDat(obj)
            folder_ = obj.folder;
            afolder = strrep(folder_,"/data/","/results/");
            if ~exist(afolder,"dir")
                mkdir(afolder);
            end
            fileNames_ = [dirFiles(folder_,"csv");dirFiles(folder_,"mat")];
            for i = 1:length(fileNames_)
                copyfile(strcat(folder_,"/", fileNames_(i)), afolder);
            end
            rmdir(folder_,"s");
            mkdir(folder_);
            for i = 1:length(fileNames_)
                copyfile(strcat(afolder,"/", fileNames_(i)), folder_);
            end
        end
        
        function brTodat(obj, fileName, folderName, channels)
            if strcmp(obj.nsF.Monkey, 'p')
                [validChannels, valid_xcords, valid_ycords, Matrix] = PCB_Patamon;
            elseif strcmp(obj.nsF.Monkey, 'o')
                [validChannels, valid_xcords, valid_ycords, Matrix] = PCB_Omega;
            end
            
            %% openNS6 and save dat
            file = strcat(obj.nsF.fPath, "/", fileName);
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
                    name = split(fileName(1), '.');
                    name = name{1};
                    name_ = sprintf("%sTags.mat", name);
                    name_ = strcat(folderName, "/", name_);
                    if ~exist(name_,"file")
                        fprintf("save MetaTags file %s\n", name_)
                        MetaTags.validMatrixAll = Matrix;
                        MetaTags.validXcordsAll = valid_xcords;
                        MetaTags.validYcordsAll = valid_ycords;
                        MetaTags.validChannels = obj.Channels;
                        Matrix(:) = 0;
                        index_ = find(ismember(validChannels, obj.Channels));
                        Matrix(valid_xcords(index_)*12-valid_ycords(index_)+1) = MetaTags.validChannels;
                        MetaTags.validMatrix = Matrix;
                        MetaTags.validXcords = valid_xcords(index_);
                        MetaTags.validYcords = valid_ycords(index_);
                        MetaTags.timeLength = length(datIall(1,:))/30000/3600;
                        save(name_, "MetaTags")
                    end
                    obj.timeLength =length(datIall(1,:))/30000/3600;
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
            if length(dirFolders(folderName)) ~= length(channels)
                error("not all valid channels being open")
            end
        end
        
        function kwik2csv(~,Path,chan,csvName)
            file = dir(strcat(Path, "/", chan, "/*.kwik"));
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
        
        function [validChan, Tall, fr, frName] = datTofr(obj, csvNames, LeastFiringCount, RefractoryPeriod)
            temp = split(csvNames,{'-', '.'});
            chanNum = temp(:,2);
            % for loop
            validChan = double(chanNum');
            validChan(2,:) = 0;
            kcsv = csvNames;
            for i = 1:length(kcsv)
                T = readtable(kcsv(i));
                if isempty(T)
                    if obj.report == ""
                        obj.rindex = 1;
                        obj.report(obj.rindex,1) = string(kcsv(i));
                        obj.report(obj.rindex,2) = "";
                        obj.report(obj.rindex,3) = "";
                        obj.report(obj.rindex,4) = sprintf("hdf5read error");
                    else
                        obj.rindex = obj.rindex + 1;
                        obj.report(obj.rindex,1) = string(kcsv(i));
                        obj.report(obj.rindex,2) = "";
                        obj.report(obj.rindex,3) = "";
                        obj.report(obj.rindex,4) = sprintf("hdf5read error");
                    end
                    continue
                end
                T.channel = repmat(double(chanNum(i)),height(T),1);
                %     fprintf("==========\n")
                %     fprintf("read data %s\n", fileNames(i))
                % cluster firing count
                a = unique(T.cluster_number);
                index_ = histc(T.cluster_number, a) > LeastFiringCount;
                if sum(index_)
                    validChan(2,i) = sum(index_);
                else
                    if obj.report == ""
                        obj.rindex = 1;
                        obj.report(obj.rindex,1) = string(kcsv(i));
                        obj.report(obj.rindex,2) = join(string(a));
                        obj.report(obj.rindex,3) = join(string(histc(T.cluster_number, a)));
                        obj.report(obj.rindex,4) = sprintf("LowFR <%d",LeastFiringCount);
                    else
                        obj.rindex = obj.rindex + 1;
                        obj.report(obj.rindex,1) = string(kcsv(i));
                        obj.report(obj.rindex,2) = join(string(a));
                        obj.report(obj.rindex,3) = join(string(histc(T.cluster_number, a)));
                        obj.report(obj.rindex,4) = sprintf("LowFR <%d",LeastFiringCount);
                    end
                    %                     fprintf("data %s\n", kcsv(i))
                    %                     fprintf("----- most spikes cluster only has %d spikes, pass -----\n", ...
                    %                         max(histc(T.cluster_number, a)))
                    continue
                end
                Tv = T(ismember(T.cluster_number,a(index_)),:);
                clusterNum = ones(1,length(unique(Tv.cluster_number))) * -1;
                k = 0;
                for j = unique(Tv.cluster_number)'
                    k = k + 1;
                    T_ = Tv(Tv.cluster_number == j,:);
                    ISI = T_.time_samples(2:end)-T_.time_samples(1:end-1);
                    RPall = sum(ISI <= RefractoryPeriod)/height(T_);
                    if RPall > 0.3
                        %                         fprintf("data %s\n", kcsv(i))
                        %                         fprintf("----- cluster %d has %.2f spikes within RP, pass -----\n", j, RPall)
                        validChan(2,i) = sum(index_)-1;
                        if obj.report == ""
                            obj.rindex = 1;
                            obj.report(obj.rindex,1) = string(kcsv(i));
                            obj.report(obj.rindex,2) = join(string(j));
                            obj.report(obj.rindex,3) = string(RPall);
                            obj.report(obj.rindex,4) = sprintf(">%d%% spikes within %d ms", ...
                                0.3*100,RefractoryPeriod/30000);
                        else
                            obj.rindex = obj.rindex + 1;
                            obj.report(obj.rindex,1) = string(kcsv(i));
                            obj.report(obj.rindex,2) = join(string(j));
                            obj.report(obj.rindex,3) = string(RPall);
                            obj.report(obj.rindex,4) = sprintf(">%d%% spikes within %d ms", ...
                                0.3*100,RefractoryPeriod/30000*1000);
                        end
                        continue
                    else
                        clusterNum(k) = j;
                    end
                end
                clusterNum(clusterNum == -1) = [];
                Tchan = Tv(ismember(Tv.cluster_number,clusterNum),:);
                if ~exist("Tall", "var")
                    Tall = Tchan;
                else
                    Tall = [Tall;Tchan]; %#ok<AGROW>
                end
            end
            if isempty(validChan(1,validChan(2,:)~=0))
                if obj.report == ""
                    obj.rindex = 1;
                    obj.report(obj.rindex,1) = obj.fileNames;
                    obj.report(obj.rindex,2) = "";
                    obj.report(obj.rindex,3) = "";
                    obj.report(obj.rindex,4) = sprintf("no valid channel");
                else
                    obj.rindex = obj.rindex + 1;
                    obj.report(obj.rindex,1) = obj.fileNames;
                    obj.report(obj.rindex,2) = "";
                    obj.report(obj.rindex,3) = "";
                    obj.report(obj.rindex,4) = sprintf("no valid channel");
                end
                fprintf("no channel valid\n")
            else
                fprintf("%d cluster valid\n", sum(validChan(2,:)))
                fprintf("channel %s valid\n",join(string(sort(validChan(1,validChan(2,:)~=0)))))
            end
            if ~exist("Tall", "var")
                Tall = [];
            end
            temp = split(obj.folder, "/");
            fr = temp(end);
            frName = strcat(fr, "ST-", string(LeastFiringCount), ...
                "-", string(RefractoryPeriod/30),".mat");
            if isempty(Tall)
                error("Tall empty?")
            end
        end
        
        function dirExist = checkExist(obj, type)
            % check whether all channel files of type exist
            if strcmp(type, "archive")
                if exist(obj.archiveFolder,"dir")
                    dirExist = 1;
                    return
                else
                    dirExist = 0;
                    return
                end
            end
            if strcmp(type,"kwik")
                dirExist = zeros(length(obj.Channels),length(obj.datFolder));
                for i = 1:length(obj.Channels)
                    folderName = strcat(obj.datFolder,"/",string(obj.Channels(i)));
                    if ~isempty(dirFiles(folderName,"kwik"))
                        dirExist(i) = 1;
                    end
                end
            end
            if strcmp(type,"csv")
                dirExist = zeros(length(obj.Channels),length(obj.datFolder));
                folderName = obj.datFolder;
                file_ = dirFiles(folderName, "csv");
                for i = 1:length(obj.Channels)
                    if sum(contains(file_,string(obj.Channels(i))))
                        dirExist(i) = 1;
                    end
                end
            end
            if strcmp(type,"dat")
                folderName = obj.datFolder;
                dirExist = zeros(length(obj.Channels),length(obj.datFolder));
                folder_ = dirFolders(folderName);
                if ~isempty(folder_)
                    dirExist(ismember(obj.Channels,double(folder_))) = 1;
                end
            end
        end
        
    end
end

function fileNames = dirFolders(Path)
fileNames = dir(Path);
if isempty(fileNames)
    fileNames = [];
    return
end
dirPath = struct2table(fileNames);
dirPath = dirPath(~(dirPath.name == "." | dirPath.name == ".."),:);
index = dirPath.isdir;
fileNames = string(dirPath.name);
fileNames = fileNames(index);
end

function fileNames = dirFiles(Path, type)
Path = strcat(Path, "/*.", type);
fileNames = dir(Path);
temp = struct2table(fileNames);
index = temp.isdir;
fileNames = string(temp.name);
fileNames = fileNames(~index);
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
    fwrite(fid, Str, 'char');
    fclose(fid);
end
end

% function nPath = newPath(dPath)
% cp_ = split(string(cPath),"/");
% dp_ = split(string(dPath),"/");
% rp = join(cp_(ismember(cp_, dp_)),"/");
% nPath = strrep(dPath,rp,"..");
% end

function [validChannels, valid_xcords, valid_ycords, Matrix] = PCB_Omega
validChannels = [4,5,6,7,8,9,13,14,15,16,24,25,26,27,28,29,30,31, ...
    32,33,34,36,37,38,40,44,45,48,49,50,52,58,61,63,64, ...
    65,70,81,83,85,88,94, ...
    97,100,105,110,112,114,115,117,125, ...
    127,128,129,130,132,133,134,136,137,139,140,142];
valid_xcords = [13,13,13,13,13,13,12,12,12,12,11,11,11,11,11,11,11,11, ...
    11,11,11,10,10,10,10,10,10,9,9,9,9,9,8,8,8, ...
    8,8,7,7,6,6,6, ...
    5,5,5,4,4,4,4,3,3, ...
    2,2,2,2,2,2,2,1,1,1,1,1];
valid_ycords = [2,3,4,5,6,7,1,2,3,4,1,2,3,4,5,6,7,8, ...
    9,10,11,2,3,4,6,10,11,2,3,4,6,12,3,5,6, ...
    7,12,11,13,4,7,13, ...
    5,8,13,8,10,12,13,5,13, ...
    6,7,8,9,11,12,13,6,7,9,10,12];
Matrix = zeros(14,13);
Matrix(valid_xcords*14-valid_ycords+1) = validChannels;
end

function [validChannels, valid_xcords, valid_ycords, Matrix] = PCB_Patamon
validChannels = [1,2,3,4,5,8,9,10,11,12,13,14,15, ...
    17,18,19,20,21,22,23,24,25,27,28,29,30,31,32,33,34,35,36, ...
    37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58, ...
    59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82, ...
    83,84,85,86,87,88,89,90,91,92,93,95,96,97,98,99,100,101,102,103,104,105,106, ...
    107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128];
valid_xcords = [11,10,9,8,7,12,11,10,9,8,7,6,5, ...
    12,11,10,9,8,7,6,5,4,12,11,10,9,8,7,6,5,4,3, ...
    12,11,10,9,8,7,6,5,4,3,2,12,11,10,9,8,7,6,5,4,3,2, ...
    12,11,10,9,8,7,6,5,4,3,2,1,12,11,10,9,8,7,6,5,4,3,2,1, ...
    12,11,10,9,8,7,6,5,4,3,2,12,11,10,9,8,7,6,5,4,3,2,1, ...
    12,11,10,9,8,7,6,5,4,3,2,1,11,10,9,8,7,6,5,4,3,2];
valid_ycords = [1,1,1,1,1,2,2,2,2,2,2,2,2, ...
    3,3,3,3,3,3,3,3,3,4,4,4,4,4,4,4,4,4,4, ...
    5,5,5,5,5,5,5,5,5,5,5,6,6,6,6,6,6,6,6,6,6,6, ...
    7,7,7,7,7,7,7,7,7,7,7,7,8,8,8,8,8,8,8,8,8,8,8,8, ...
    9,9,9,9,9,9,9,9,9,9,9,10,10,10,10,10,10,10,10,10,10,10,10, ...
    11,11,11,11,11,11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12];
valid_ycords = 13 - valid_ycords;
Matrix = zeros(12,12);
Matrix(valid_xcords*12-valid_ycords+1) = validChannels;
end

classdef readCSV < handle
    properties
        index = 1
        dataPath
        folderNames
        folderName
        matName
        csvNames
    end
    
    methods
        function obj = readCSV(dataPath)
            obj.dataPath = dataPath;
            obj.folderNames = dirFolders(dataPath);
        end
        
        function folderName = get.folderName(obj)
            folderName = obj.folderNames(obj.index);
        end
        
        function matName = get.matName(obj)
            matName = dirFiles(strcat(obj.dataPath,"/",obj.folderName),"mat");
        end
        
        function csvNames = get.csvNames(obj)
            csvNames = dirFiles(strcat(obj.dataPath,"/",obj.folderName),"csv");
        end
        
        function [LeastFiringCount,RefractoryPeriod,timeLength] = getVar(obj)
            if ~isempty(obj.matName)
                load(strcat(obj.dataPath,"/",obj.folderName,"/",obj.matName),"MetaTags");
                timeLength = MetaTags.DataPoints/30000/3600;
                LeastFiringCount = 20000;
                RefractoryPeriod = 90; % 3ms
            else
                LeastFiringCount = [];
                RefractoryPeriod = []; % 3ms
                timeLength = [];
            end
        end
        
        function report = selectWell(obj, i, FeaturesPath)
            obj.index = i;
            [LeastFiringCount,RefractoryPeriod,~] = getVar(obj);
            if isempty(LeastFiringCount)
                fprintf("*****no sorting result in %s*****\n",obj.folderName)
                return
            end
            % select well channels
            [validChan, Tall, fr, frName, report] = obj.datTofr(LeastFiringCount, RefractoryPeriod);
            if ~exist(strcat("Neuron/",fr),"dir")
                mkdir(strcat("Neuron/",fr))
            end
            if ~exist(strcat(FeaturesPath,"/spikes"),"dir")
                mkdir(strcat(FeaturesPath,"/spikes"))
            end
            fprintf("%d cluster valid\nchannel %s valid\nsaving %s\n", ...
                sum(validChan(2,:)), ...
                join(string(sort(validChan(1,validChan(2,:)~=0)))), ...
                frName)
            save(strcat("Neuron/",fr,"/", fr,"Report.mat"), "report")
            save(strcat("Neuron/",fr,"/", fr, "ST-valid.mat"), "validChan");
            save(strcat("Neuron/",fr,"/", frName), "Tall");
            writetable(Tall, strrep(strcat("Neuron/",fr,"/", frName), "mat", "csv"))
            copyfile(strrep(strcat("Neuron/",fr,"/", frName), "mat", "csv"), strcat(FeaturesPath,"/spikes"));
        end
        
        function [validChan, Tall, fr, frName, report] = datTofr(obj, LeastFiringCount, RefractoryPeriod)
            report = "";
            Tall = [];
            temp = split(obj.csvNames,{'-', '.'});
            chanNum = temp(:,2);
            % for loop
            validChan = double(chanNum');
            validChan(2,:) = 0;
            kcsv = strcat(obj.dataPath,"/",obj.folderName,"/",obj.csvNames);
            for i = 1:length(kcsv)
                T = readtable(kcsv(i));
                if isempty(T)
                    if report == ""
                        rindex = 1;
                        report(rindex,1) = string(kcsv(i));
                        report(rindex,2) = "";
                        report(rindex,3) = "";
                        report(rindex,4) = sprintf("hdf5read error");
                    else
                        rindex = rindex + 1;
                        report(rindex,1) = string(kcsv(i));
                        report(rindex,2) = "";
                        report(rindex,3) = "";
                        report(rindex,4) = sprintf("hdf5read error");
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
                    if report == ""
                        rindex = 1;
                        report(rindex,1) = string(kcsv(i));
                        report(rindex,2) = join(string(a));
                        report(rindex,3) = join(string(histc(T.cluster_number, a)));
                        report(rindex,4) = sprintf("LowFR <%d",LeastFiringCount);
                    else
                        rindex = rindex + 1;
                        report(rindex,1) = string(kcsv(i));
                        report(rindex,2) = join(string(a));
                        report(rindex,3) = join(string(histc(T.cluster_number, a)));
                        report(rindex,4) = sprintf("LowFR <%d",LeastFiringCount);
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
                    pass = checkISI(ISI);
                    if ~pass
                        validChan(2,i) = validChan(2,i)-1;
                        if report == ""
                            rindex = 1;
                            report(rindex,1) = string(kcsv(i));
                            report(rindex,2) = join(string(j));
                            report(rindex,3) = string(RPall);
                            report(rindex,4) = sprintf("ISI distribution is weird\n");
                        else
                            rindex = rindex + 1;
                            report(rindex,1) = string(kcsv(i));
                            report(rindex,2) = join(string(j));
                            report(rindex,3) = string(RPall);
                            report(rindex,4) = sprintf("ISI distribution is weird\n");
                        end
                        continue
                    else
                        clusterNum(k) = j;
                    end
                    RPall = sum(ISI <= RefractoryPeriod)/height(T_);
                    if RPall > 0.3
                        %                         fprintf("data %s\n", kcsv(i))
                        %                         fprintf("----- cluster %d has %.2f spikes within RP, pass -----\n", j, RPall)
                        validChan(2,i) = validChan(2,i)-1;
                        if report == ""
                            rindex = 1;
                            report(rindex,1) = string(kcsv(i));
                            report(rindex,2) = join(string(j));
                            report(rindex,3) = string(RPall);
                            report(rindex,4) = sprintf(">%d%% spikes within %d ms", ...
                                0.3*100,RefractoryPeriod/30000);
                        else
                            rindex = rindex + 1;
                            report(rindex,1) = string(kcsv(i));
                            report(rindex,2) = join(string(j));
                            report(rindex,3) = string(RPall);
                            report(rindex,4) = sprintf(">%d%% spikes within %d ms", ...
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
                if report == ""
                    rindex = 1;
                    report(rindex,1) = obj.fileNames;
                    report(rindex,2) = "";
                    report(rindex,3) = "";
                    report(rindex,4) = sprintf("no valid channel");
                else
                    rindex = rindex + 1;
                    report(rindex,1) = obj.fileNames;
                    report(rindex,2) = "";
                    report(rindex,3) = "";
                    report(rindex,4) = sprintf("no valid channel");
                end
                fprintf("no channel valid\n")
            end
            if ~exist("Tall", "var")
                Tall = [];
            end
            fr = obj.folderName;
            frName = strcat(fr, "ST-", string(LeastFiringCount), ...
                "-", string(RefractoryPeriod/30),".mat");
            if isempty(Tall)
                error("Tall empty?")
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
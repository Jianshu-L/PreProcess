classdef readCSVdebug < handle
    properties
        index = 1
        Date
        dataPath
        folderNames
        folderName
        matName
        csvNames
        validChan
        Tu
        LeastFiringCount = [];
        RefractoryPeriod = [];
        timeLength = [];
    end
    
    methods
        function obj = readCSVdebug(dataPath)
            obj.dataPath = dataPath;
            obj.folderNames = dirFolders(dataPath);
            load('DriverUnit.mat','T');
            obj.Tu = T(T.Date == double(obj.Date),:);
            temp = split(obj.csvNames,{'-', '.'});
            chanNum = temp(:,2);
            validChan = double(chanNum');
            validChan(2,:) = 0;
            obj.validChan = validChan;
        end
        
        function Date = get.Date(obj)
            temp = char(obj.folderName);
            Date = string(temp(1:end-1));
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
        
        function getVar(obj)
            if ~isempty(obj.matName)
                load(strcat(obj.dataPath,"/",obj.folderName,"/",obj.matName),"MetaTags");
                obj.timeLength = MetaTags.DataPoints/30000/3600;
                obj.LeastFiringCount = obj.timeLength*3600;
                obj.RefractoryPeriod = 90; % 3ms
            end
        end
        
        function [report,Tall] = selectWell(obj, i)
            obj.index = i;
            obj.getVar();
            if isempty(obj.LeastFiringCount)
                fprintf("*****no sorting result in %s*****\n",obj.folderName)
                return
            end
            % select well channels
            [Tall, frName, report] = obj.datTofr;
            if ~exist(strcat("debug/results/",obj.folderName),"dir")
                mkdir(strcat("debug/results/",obj.folderName))
            end
            validUnit = unique([obj.Tu.SU{1};obj.Tu.MU{1}]);
            probUnit = setdiff(validUnit,sort(obj.validChan(1,obj.validChan(2,:)~=0)));
            noiseUnit = setdiff(sort(obj.validChan(1,obj.validChan(2,:)~=0)),validUnit);
            if report == ""
                rindex = 1;
                report(rindex,1) = obj.folderName;
                report(rindex,2) = join(string(probUnit'));
                report(rindex,3) = join(string(noiseUnit'));
                report(rindex,4) = sprintf("Probable unit or Noise unit");
            else
                rindex = length(report(:,1)) + 1;
                report(rindex,1) = obj.folderName;
                report(rindex,2) = join(string(probUnit'));
                report(rindex,3) = join(string(noiseUnit'));
                report(rindex,4) = sprintf("Probable unit or Noise unit");
            end
            fprintf("%d cluster valid\nchannel %s valid\nsaving %s\n", ...
                sum(obj.validChan(2,:)), ...
                join(string(sort(obj.validChan(1,obj.validChan(2,:)~=0)))), ...
                frName)
            validChan = obj.validChan; %#ok<NASGU,PROPLC>
            fr = obj.folderName;
            save(strcat("debug/results/",fr,"/", fr,"Report.mat"), "report")
            save(strcat("debug/results/",fr,"/", fr, "ST-valid.mat"), "validChan");
            save(strcat("debug/results/",fr,"/", frName), "Tall");
            %             writetable(Tall, strrep(strcat("Neuron/",fr,"/", frName), "mat", "csv"))
            %             copyfile(strrep(strcat("Neuron/",fr,"/", frName), "mat", "csv"), strcat(FeaturesPath,"/spikes"));
        end
        
        function T = loadcsv(obj, kcsv)
            temp = split(kcsv,{'-', '.'});
            chanNum = temp(2);
            T = readtable(strcat(obj.dataPath, "/", obj.folderName, "/", kcsv));
            T.Channel = repmat(double(chanNum),height(T),1);
        end
        
        
        function [Tall, frName, report] = datTofr(obj)
            report = "";
            Tall = [];
            % for loop
            for i = 1:length(obj.csvNames)
                T = loadcsv(obj, obj.csvNames(i));
                if isempty(T)
                    if report == ""
                        rindex = 1;
                        report(rindex,1) = obj.csvNames(i);
                        report(rindex,2) = "";
                        report(rindex,3) = "";
                        report(rindex,4) = sprintf("hdf5read error");
                    else
                        rindex = rindex + 1;
                        report(rindex,1) = obj.csvNames(i);
                        report(rindex,2) = "";
                        report(rindex,3) = "";
                        report(rindex,4) = sprintf("hdf5read error");
                    end
                    continue
                end
                % cluster firing count
                all_cluster = unique(T.cluster_number);
                fr_cluster = histcounts(T.cluster_number);
                v1_cluster = find(fr_cluster > obj.LeastFiringCount)-1;
                if report == ""
                    rindex = 1;
                    report(rindex,1) = string(obj.csvNames(i));
                    report(rindex,2) = join(string(setdiff(all_cluster,v1_cluster)));
                    bug_cluster = fr_cluster(fr_cluster <= obj.LeastFiringCount);
                    bug_cluster = bug_cluster(bug_cluster ~= 0);
                    report(rindex,3) = join(string(bug_cluster));
                    report(rindex,4) = sprintf("LowFR <%.2f",obj.LeastFiringCount);
                else
                    rindex = rindex + 1;
                    report(rindex,1) = string(obj.csvNames(i));
                    report(rindex,2) = join(string(setdiff(all_cluster,v1_cluster)));
                    bug_cluster = fr_cluster(fr_cluster <= obj.LeastFiringCount);
                    bug_cluster = bug_cluster(bug_cluster ~= 0);
                    report(rindex,3) = join(string(bug_cluster));
                    report(rindex,4) = sprintf("LowFR <%.2f",obj.LeastFiringCount);
                end
                if isempty(v1_cluster)
                    continue
                end
                % inter spike interva distribution
                Tv1 = T(ismember(T.cluster_number,v1_cluster),:);
                k = 0;
                v2_cluster = v1_cluster;
                for j = unique(Tv1.cluster_number)'
                    k = k + 1;
                    Tv2 = Tv1(Tv1.cluster_number == j,:);
                    spike_train = Tv2.time_samples;
                    [Per,pass] = checkST(spike_train);
                    if pass
                        continue
                    else
                        v2_cluster(v2_cluster==j)=[];
                        if report == ""
                            rindex = 1;
                            report(rindex,1) = obj.csvNames(i);
                            report(rindex,2) = join(string(j));
                            report(rindex,3) = string(Per);
                            report(rindex,4) = sprintf("ISI distribution is weird\n");
                        else
                            rindex = rindex + 1;
                            report(rindex,1) = obj.csvNames(i);
                            report(rindex,2) = join(string(j));
                            report(rindex,3) = string(Per);
                            report(rindex,4) = sprintf("ISI distribution is weird\n");
                        end
                    end
                    %                         if RPall > 0
                    %                             if report == ""
                    %                                 rindex = 1;
                    %                                 report(rindex,1) = string(kcsv(i));
                    %                                 report(rindex,2) = join(string(j));
                    %                                 report(rindex,3) = string(RPall);
                    %                                 report(rindex,4) = sprintf(">%d%% spikes within %d ms", ...
                    %                                     0.3*100,RefractoryPeriod/30000);
                    %                             else
                    %                                 rindex = rindex + 1;
                    %                                 report(rindex,1) = string(kcsv(i));
                    %                                 report(rindex,2) = join(string(j));
                    %                                 report(rindex,3) = string(RPall);
                    %                                 report(rindex,4) = sprintf(">%d%% spikes within %d ms", ...
                    %                                     0.3*100,RefractoryPeriod/30000*1000);
                    %                             end
                    %                         end
                end
                Tchan = Tv2(ismember(Tv2.cluster_number,v2_cluster),:);
                if ~exist("Tall", "var")
                    Tall = Tchan;
                else
                    Tall = [Tall;Tchan]; %#ok<AGROW>
                end
                obj.validChan(2,i) = length(v2_cluster);
            end
            if isempty(obj.validChan(1,obj.validChan(2,:)~=0))
                if report == ""
                    rindex = 1;
                    report(rindex,1) = obj.folderName;
                    report(rindex,2) = "";
                    report(rindex,3) = "";
                    report(rindex,4) = sprintf("no valid channel");
                else
                    rindex = rindex + 1;
                    report(rindex,1) = obj.folderName;
                    report(rindex,2) = "";
                    report(rindex,3) = "";
                    report(rindex,4) = sprintf("no valid channel");
                end
                fprintf("no channel valid\n")
            end
            if ~exist("Tall", "var")
                Tall = [];
            end
            frName = strcat(obj.folderName, "ST-", sprintf("%.2f",obj.LeastFiringCount), ...
                "-", string(sum(obj.validChan(2,:))), ".mat");
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
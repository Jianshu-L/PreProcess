classdef readCSV < handle
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
        function obj = readCSV(Monkey,dataPath)
            obj.dataPath = dataPath;
            obj.folderNames = dirFolders(dataPath);
            obj.folderNames = obj.folderNames(contains(obj.folderNames, Monkey));
            temp = split(obj.csvNames,{'-', '.'});
            chanNum = temp(:,2);
            validChan_ = double(chanNum');
            validChan_(2,:) = 0;
            obj.validChan = validChan_;
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
                obj.timeLength = MetaTags.timeLength;
                obj.LeastFiringCount = obj.timeLength*3600;
                obj.RefractoryPeriod = 90; % 3ms
            end
        end
        
        function clearVar(obj)
            validChan_ = obj.validChan;
            validChan_(2,:) = 0;
            obj.validChan = validChan_;
        end
        
        function [report,Tall] = selectWell(obj, i)
            obj.index = i;
            obj.getVar();
            obj.clearVar();
            if isempty(obj.LeastFiringCount)
                fprintf("*****no sorting result in %s*****\n",obj.folderName)
                return
            end
            % select well channels
            [Tall, report] = obj.datTofr;
            if report == "-1"
                return
            end
            frName = strcat(obj.folderName, "ST-", sprintf("%.2f",obj.LeastFiringCount), ...
                "-", string(sum(obj.validChan(2,:))), ".mat");
            fprintf("%d cluster valid\nchannel %s valid\nsaving %s\n", ...
                sum(obj.validChan(2,:)), ...
                join(string(sort(obj.validChan(1,obj.validChan(2,:)~=0)))), ...
                frName)
        end
        
        function saveData(obj, savePath, csvPath, report, Tall)
            frName = strcat(obj.folderName, "ST-", sprintf("%.2f",obj.LeastFiringCount), ...
                "-", string(sum(obj.validChan(2,:))), ".mat");
            validChan = obj.validChan; %#ok<PROPLC>
            fr = obj.folderName;
            if ~exist(strcat(savePath, "/",fr),"dir")
                mkdir(strcat(savePath, "/",fr))
            end
            if ~exist("results/spikes","dir")
                mkdir("results/spikes")
            end
            save(strcat(savePath, "/",fr,"/", fr,"Report.mat"), 'report')
            save(strcat(savePath, "/",fr,"/", fr, "ST-valid.mat"), 'validChan');
            save(strcat(savePath, "/",fr,"/", frName), "Tall", '-v7.3');
            writetable(Tall, strrep(strcat(savePath, "/",fr,"/", frName), "mat", "csv"))
            copyfile(strrep(strcat(savePath, "/",fr,"/", frName), "mat", "csv"), csvPath);
        end
        
        function T = loadcsv(obj, kcsv)
            temp = split(kcsv,{'-', '.'});
            chanNum = temp(2);
            T = readtable(strcat(obj.dataPath, "/", obj.folderName, "/", kcsv));
            T.Channel = repmat(double(chanNum),height(T),1);
        end
        
        
        function [Tall, report] = datTofr(obj)
            report = "";
            Tall = [];
            Trecord = obj.Tu(obj.Tu.Date == double(obj.Date),:);
            validChan_i = unique([Trecord.SU{1};Trecord.MU{1}]);
            if isempty(validChan_i)
                Tall = [];
                report = "-1";
                return
            end
            % for loop
            for i = 1:length(obj.csvNames)
                if ~contains(obj.csvNames(i),string(validChan_i))
                    continue
                end
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
                bug_cluster = fr_cluster(fr_cluster <= obj.LeastFiringCount);
                if ~isempty(bug_cluster)
                    bug_cluster = bug_cluster(bug_cluster ~= 0);
                    if ~isempty(bug_cluster)
                        if report == ""
                            rindex = 1;
                            report(rindex,1) = string(obj.csvNames(i));
                            report(rindex,2) = join(string(setdiff(all_cluster,v1_cluster)));
                            report(rindex,3) = join(string(bug_cluster));
                            report(rindex,4) = sprintf("LowFR <%.2f",obj.LeastFiringCount);
                        else
                            rindex = rindex + 1;
                            report(rindex,1) = string(obj.csvNames(i));
                            report(rindex,2) = join(string(setdiff(all_cluster,v1_cluster)));
                            report(rindex,3) = join(string(bug_cluster));
                            report(rindex,4) = sprintf("LowFR <%.2f",obj.LeastFiringCount);
                        end
                    end
                end
                if isempty(v1_cluster)
                    continue
                end
                Tchan = T(ismember(T.cluster_number,v1_cluster),:);
                %
                if ~exist("Tall", "var")
                    Tall = Tchan;
                else
                    Tall = [Tall;Tchan]; %#ok<AGROW>
                end
                obj.validChan(2,i) = length(v1_cluster);
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
            if ~exist("Tall", "var") || isempty(Tall)
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
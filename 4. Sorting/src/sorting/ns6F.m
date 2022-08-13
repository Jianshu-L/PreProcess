classdef ns6F < handle
    
    properties
        dPath
        fPath
        Monkey
        dFiles % monkey data files name
        dDate % monkey data files date(unique)
        files % neuron data files name
        fDate % neuron data files date(unique)
        datFolders % folders of each neuron data files date(unique)
        archiveFolders % archive folders of each neuron data files date(unique)
    end
    
    methods
        function obj = ns6F(Monkey, dPath ,fPath, savePath, archivePath)
            obj.dPath = dPath;
            obj.fPath = fPath;
            if ~exist(savePath, "dir")
                mkdir(savePath);
            end
            if ~exist(archivePath, "dir")
                mkdir(archivePath);
            end
            obj.Monkey = Monkey;
            [obj.files, obj.dFiles] = obj.dirPath;
            name = split(obj.dFiles, '-');
            if length(name(1,:)) == 1
                name = name';
            end
            dt = datetime(join(name(:,2:4), '-'),'Locale','en_US');
            obj.dDate = string(unique(dt));
            name = char(obj.files);
            obj.fDate = unique(string(name(:,9:16)));
            % select neural data files date from monkey data files date
            dDate_ = string(datetime(obj.dDate, 'InputFormat','dd-MMM-yyyy','Locale','en_US','Format','yyyyMMdd'));
            dt = obj.fDate(contains(obj.fDate,dDate_));
            if ~isempty(dDate_(~contains(dDate_,dt)))
                fprintf("***** date %s no neural data *****\n",dDate_(~contains(dDate_,dt)));
            end
            obj.files = obj.files(contains(obj.files,dDate_));
            obj.fDate = dt;
            obj.datFolders = strcat(savePath, "/", obj.fDate, Monkey);
            obj.archiveFolders = strcat(archivePath, "/", obj.fDate, Monkey);
        end
        
        function [fName,dName] = dirPath(obj)
            % dir Monkey and Neural data files of obj.Monkey
            dName = orderFiles(dirFiles(obj.dPath, "mat"));
            fName =dirFiles(obj.fPath, "ns6");
            if obj.Monkey == 'o'
                dName = dName(contains(dName, "omegaL"));
                fName = fName(~contains(fName,"p"));
            elseif obj.Monkey == 'p'
                dName = dName(contains(dName, "Patamon"));
                fName = fName(contains(fName,"p"));
            end
            if isempty(dName) || isempty(fName)
                error("no correlate data")
            end
        end
        
    end
end

function fileNames = dirFiles(Path, type)
Path = strcat(Path, "/*.", type);
fileNames = dir(Path);
temp = struct2table(fileNames);
index = temp.isdir;
fileNames = string(temp.name);
fileNames = fileNames(~index);
end

function file_list = orderFiles(files)
char_i = split(files,'-');
if length(char_i(1,:)) > 1
    char = join(char_i(:,2:4),'-');
else
    char = join(char_i(2:4),'-');
end
char_trial = datetime(char,'InputFormat','dd-MMM-yyyy','Locale','en_US');
[~, I] = sortrows(char_trial); % sort files by current_round and used_trial
file_list = files(I);
end

classdef ListData < handle
    
    properties
        path
        type
        folder
        fileAll
    end
    
    properties(Transient)
        folderI = 1;
        fileI = 1;
        fileName
        folderName
    end
    
    properties(Dependent)
        filePath
        file
    end
    
    methods
        function obj = ListData(dataPath, dataType)
            %% Get obj.path
            if ~exist('dataType', 'var') || isempty(dataType)
                dataType = 'mat';
            end
            obj.type = dataType;
            if ~exist('dataPath', 'var') || isempty(dataPath)
                obj.path = uigetdir("~/pacman/MonkeyData/data");
            else
                temp = char(dataPath);
                if temp(end) == '/'
                    dataPath = temp(1:end-1);
                end
                data_path = dataPath;
                obj.path = string(data_path);
            end
            %% List obj.path contents
            dirPath = struct2table(dir(obj.path));
            dirPath = dirPath(~startsWith(dirPath.name,"."),:);
            dirPath = dirPath(~(dirPath.name == "$RECYCLE.BIN"),:);
            dirPath = dirPath(~(dirPath.name == "System Volume Information"),:);
            dirPath = dirPath(~(dirPath.name == "bug_data"),:);
            if ~all(dirPath.isdir == 0)
                % nested folder
                % get folder list in the folder_path
                folder_table = dirPath;
                folders = string(folder_table.name(folder_table.isdir)); % the list of folders
                obj.folder = folders;
                obj.fileAll = cell(length(obj.folder),1);
                for folder_position = 1:length(obj.folder)
                    obj.folderI = folder_position;
                    Type = strcat('*', obj.type);
                    file_path = obj.filePath;
                    file_table = struct2table(dir(fullfile(file_path, Type)));
                    files = string(file_table.name); % the list of files
                    if isempty(files)
                        file_list = [];
                        obj.fileAll{folder_position} = file_list;
                        continue
                    end
                    obj.fileAll{folder_position} = files;
                end
                obj.folderI = 1;
            else
                temp = split(obj.path, '/');
                obj.folder = temp(end);
                Type = strcat('*', obj.type);
                file_path = obj.filePath;
                file_table = struct2table(dir(fullfile(file_path, Type)));
                files = string(file_table.name); % the list of files
                obj.fileAll{1} = files;
            end
        end
        
        %% set methods
        function set.fileI(obj, val)
            obj.fileI = val;
        end
        
        function set.folderI(obj, val)
            obj.folderI = val;
        end
        
        %% get methods
        function file = get.file(obj)
            if obj.folderI > length(obj.fileAll)
                error("folderI is larger than length of fileAll")
            end
            file = obj.fileAll{obj.folderI};
        end
        
        function filePath = get.filePath(obj)
            dirPath = struct2table(dir(obj.path));
            dirPath = dirPath(~startsWith(dirPath.name,"."),:);
            dirPath = dirPath(~(dirPath.name == "$RECYCLE.BIN"),:);
            dirPath = dirPath(~(dirPath.name == "System Volume Information"),:);
            dirPath = dirPath(~(dirPath.name == "bug_data"),:);
            if ~all(dirPath.isdir == 0)
                filePath = strcat(obj.path, "/", obj.folderName);
            else
                filePath = obj.path;
            end
        end
        
        function fileName = get.fileName(obj)
            if isempty(obj.file)
                fileName = [];
            elseif obj.fileI > length(obj.file)
                error("index larger than file list length")
            else
                fileName = obj.file(obj.fileI);
            end
        end
        
        function folderName = get.folderName(obj)
            if obj.folderI > length(obj.folder)
                error("index larger than folder list length")
            end
            folderName = obj.folder(obj.folderI);
        end
        
        %% only use if necessary set methods
        function set.fileName(obj, val)
            temp = split(val, {'-', '.'});
            Folder = join(temp(3:6)', '-');
            folderIs = find(contains(obj.folder, Folder));
            for i = 1:length(folderIs)
                obj.folderI = folderIs(i);
                index = find(strcmp(obj.file, val), 1);
                if ~isempty(index)
                    obj.fileI = index;
                    return
                end
            end
            error("no %s file in the file list", val)
        end
        
        function set.folderName(obj, val)
            index = find(strcmp(obj.folder, val), 1);
            if isempty(index)
                error("no %s folder", val)
            end
            obj.folderI = index;
        end
        
    end
end

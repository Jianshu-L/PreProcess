classdef combineBEV < ListData
    
    properties
        BEV
        EL
        index
        bug
    end
    
    methods
        function obj = combineBEV(BEVpath, ELpath, dataPath)
            obj = obj@ListData(dataPath, 'mat');
            obj.BEV = ListData(BEVpath, 'mat');
            obj.EL = ListData(ELpath, 'mat');
        end
        
        function [BEVdata, ELdata] = checkBEV(obj, fileName)
            % check eyelink and bev data
            BEVdata = strcat(obj.BEV.filePath, '/', fileName);
            m1E = repmat(fileName, 1, length(obj.EL.file));
            m2 = repmat(obj.EL.file, 1, 1);
            m12 = sum(strcmp(m1E,m2'),2);
            if all(logical(m12))
                ELdata = strcat(obj.EL.filePath, '/', ...
                    obj.EL.file(logical(sum(strcmp(m1E,m2'),1)')));
            else
                ELdata = [];
            end
        end
        
        function data = combine(obj, BEVdata, ELdata)
            load(BEVdata, 'data');
            Data = data;
            clear data
            elX = ones(height(Data),1)*-1;
            elY = ones(height(Data),1)*-1;
            data_ = table(elX,elY);
            if ~isempty(ELdata)
                load(ELdata, 'eyelink');
                [~, file_order] = obj.order(Data.DayTrial, 1, 2);
                Data = Data(file_order,:);
                name_ = unique(Data.DayTrial);
                %% combine eyelink
                % init varibles
                for fileName = name_'
                    eldata = obj.findEl(eyelink, fileName);
                    if isempty(eldata)
                        error("%s no eyelink data, why?",fileName)
                    end
                    if sum(Data.DayTrial == fileName) ~= length(eldata(:,1))
                        error("*** %s marker length is not match ***\n", fileName)
                    end
                    data_(Data.DayTrial == fileName,1:2) = table(eldata(:,1), eldata(:,2));
                end
            end
            data = [Data,data_];
        end
        
        function data = loadData(obj)
            load(strcat(obj.filePath, '/', obj.fileName), 'data');
            obj.data = data;
        end
        
        function data_ = subsetFile(obj, fileName)
            fprintf("subset %s data from %s\n", fileName, obj.fileName)
            obj.loadData;
            data_ = obj.data(obj.data.DayTrial == fileName,:);
        end
        
        function saveData(~, saveName, data)
            file_ = saveName;
            save(file_, 'data');
        end
        
        function eldata = findEl(~, eyelink, file)
            % got file related eyelink data
            round_now = split(file,'-');
            eyetrial = {eyelink.sample.trial};
            a = textscan(char(eyetrial)','%*5c %f-%f');
            e_index = find(double(round_now(1)) == a{1} & ...
                double(round_now(2)) == a{2});
            if isempty(e_index)
                fprintf("*** %s loss one trial data when recording ***\n", fileName)
                eldata = [-1,-1];
                return
            end
            eldata = eyelink.sample(e_index).timestep;
        end
        
        function [file_list, file_order] = order(~, files, nStart, nEnd)
            % order files by round and trial number in files name
            % Arg:
            %   files: files to sort
            %   "1-1-omegaL-29-Jun-2020.mat"
            %   nStart, nEnd: start and end index of number in files name
            %   1,2
            % Out:
            %   file_list: sorted files
            %   file_order: the order of sorted files
            
            %% sort by round and trial
            file_name = files;
            char_i = split(file_name,{'-','.'},2);
            char_num = double(char_i(:,nStart:nEnd));
            char_trial = char_num(:,1) * 1000 + char_num(:,2);
            [~, I] = sortrows(char_trial); % sort files by current_round and used_trial
            file_list = file_name(I);
            file_order = I;
        end
        
        function trialName = trialFromfile(~, file_name)
            temp = split(file_name, '-');
            trialName = sprintf('%02d-%02d', double(temp(1)), double(temp(2)));
        end
        
        function Direction = TransDirNeural(~, dir)
            %% DO NOT CHANGE THE ORDER. As we have condition that two directions at same time
            direction = ones(length(dir),1)*-1;
            direction(strcmp(dir,"down")) =2;
            direction(strcmp(dir,"right")) = 3;
            direction(strcmp(dir,"up")) = 0;
            direction(strcmp(dir,"left")) = 1;
            %% Change number to string
            direction(end) = [];
            Direction(:,1) = find((direction+1));
            direction(~(direction+1)) = [];
            Direction(:,2) = direction;
        end
    end
    
end

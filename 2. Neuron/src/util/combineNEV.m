classdef combineNEV < ListData
    
    properties
        BEV
        BR
        report = strings(0);
    end
    
    properties(Dependent)
        index = 1; % for report
    end
    
    methods
        function obj = combineNEV(BEVpath, BRpath, dataPath)
            obj = obj@ListData(dataPath, 'mat');
            obj.BEV = ListData(BEVpath, 'mat');
            obj.BR = ListData(BRpath, 'mat');
        end
        
        function set.report(obj, BRreport)
            obj.report = BRreport;
        end
        
        function index = get.index(obj)
            [r,~] = size(obj.report);
            index = r;
        end
        
        function [BEVdata, BRdata] = checkNEV(obj, fileName)
            % check br and bev data
            BEVdata = strcat(obj.BEV.filePath, '/', fileName);
            [~,brFile] = obj.NtoF(obj.BR.file);
            m1B = repmat(fileName, 1, length(brFile));
            m3 = repmat(brFile, 1, 1);
            m13 = sum(strcmp(m1B,m3'),2);
            if all(logical(m13))
                [~,temp] = obj.FtoN(brFile(logical(sum(strcmp(m1B,m3'),1)')));
                BRdata = strcat(obj.BR.filePath, '/', temp);
            else
                BRdata = [];
            end
        end
        
        function [fExist, fName] = NtoF(obj, dName)
            % neuron marker data name to data folder
            % Arg:
            %   dName: neuron data name. "datafile20210311001Marker.mat" or obj.BRdir.fileName
            % Out:
            %   fExist: whether data folder exist
            %   fName: data folder name. "omegaL-11-Mar-2021-1"
            
            name = char(dName);
            if all(contains(dName, '.'))
                temp = split(dName, '.');
                if length(dName) == 1
                    temp = temp';
                end
                name = char(temp(:,1));
            end
            dt = datetime(name(:,9:16), 'InputFormat','yyyyMMdd','Locale','en_US','Format','dd-MMM-yyyy');
            i_ = contains(string(name),"p");
            fName_ = string(zeros(length(dName),1));
            fName_(i_) = strcat('Patamon-', string(dt(i_)));
            fName_(~i_) = strcat('omegaL-', string(dt(~i_)));
            index_ = contains(obj.BEV.file, fName_);
            if sum(index_) == 0
                %                 fprintf("no related behaviour data for %s\n", dName)
                fExist = 0;
                fName = strcat(fName_, '-d');
            else
                fExist = 1;
                fName = obj.BEV.file(index_);
            end
        end
        
        function [fExist, fName] = FtoN(obj, dName)
            % data folder to neuron marker data name
            % Arg:
            %   dName: data folder name. "omegaL-11-Mar-2021-1" or obj.BEVdir.folderName
            % Out:
            %   fExist: whether neuron data exist
            %   fName: neuron name. "datafile20210311001Marker.mat" or "datafile20190910"
            name = split(dName, '-');
            if length(name(1,:)) == 1
                name = name';
            end
            dt = datetime(join(name(:,2:4), '-'), 'InputFormat', 'dd-MMM-yyyy', ...
                'Locale','en_US', 'Format', 'yyyyMMdd');
            if name(:,1) == "omegaL"
                index_ = contains(obj.BR.file,string(dt)) & ~contains(obj.BR.file,"p");
            elseif name(:,1) == "Patamon"
                index_ = contains(obj.BR.file,string(dt)) & contains(obj.BR.file,"p");
            else
                error("%s format is wrong", name(:,1))
            end
            fName_ = strcat('datafile', string(dt));
            if sum(index_) == 0
                %                 fprintf("no related neuron data for %s\n", dName)
                fExist = 0;
                fName = fName_;
            else
                fExist = 1;
                fName = obj.BR.file(index_);
            end
        end
        
        function data = combine(obj, BEVdata, BRdata)
            load(BEVdata, 'data');
            %% combine neuron
            fileNames = unique(data.DayTrial);
            data.BRts = ones(height(data),1)*-1;
            data.JoyTs = ones(height(data),1)*-1;
            data.RewdTs = ones(height(data),1)*-1;
            if isempty(BRdata)
                return
            end
            for fileName = fileNames'
                data_ = data(data.DayTrial == fileName,:);
                [success, timestamp] = checkBRData(obj, BRdata, data_);
                if success
                    data_.BRts = timestamp(:,1);
                    data_.JoyTs = timestamp(:,2);
                    RewdTs = zeros(length(timestamp(:,1)),1);
                    i = find(data_.waterDelay);
                    RewdTs(i) =  ceil(data_.waterDelay(i) * 30000) + data_.BRts(i-1);
                    data_.RewdTs = RewdTs;
                    data.BRts(data.DayTrial == fileName) = data_.BRts;
                    data.JoyTs(data.DayTrial == fileName) = data_.JoyTs;
                    data.RewdTs(data.DayTrial == fileName) = data_.RewdTs;
                else
                    index_ = data.DayTrial == fileName;
                    data.BRts(index_) = ones(sum(index_),1)*-1;
                    data.JoyTs(index_) = ones(sum(index_),1)*-1;
                    data.RewdTs(index_) = ones(sum(index_),1)*-1;
                end
            end
        end
        
        function [success, timestamp] = checkBRData(obj, BRdata, data)
            % check marker and get timestamp
            % Args:
            %   folder: "omegaL-09-Nov-2020-1" or obj.BEV.folderName
            % Outs:
            %   success: whether marker pass all tests
            %   timestamp: indexs that correspond behavior data to neuron data
            
            success = 0;
            timestamp = [];
            index_ = 1;
            fileName = unique(data.DayTrial);
            trialName = obj.trialFromfile(fileName);
            temp = split(fileName,'-');
            folderName = join(temp(3:end),'-');
            % load marker
            BRdata_ = BRdata(index_);
            load(BRdata_, 'Eventobj', 'Frameobj', 'Dirobj');
            % check whether marker contains trial
            while ~any(contains(Eventobj(:,1), trialName))
                index_ = index_ + 1;
                if index_ > length(BRdata)
                    fprintf("*****%s no %s marker *****\n", fileName, trialName)
                    i_ = obj.index+1;
                    obj.report(i_,1) = string(folderName);
                    obj.report(i_,2) = string(trialName);
                    obj.report(i_,3) = "BrMarker Loss One Trial";
                    return
                end
                BRdata_ = BRdata(index_);
                load(BRdata_, 'Eventobj', 'Frameobj', 'Dirobj');
            end
            % subset marker correlates to file
            [Event, Frame, Dir] = obj.subsetData(fileName,Eventobj,Frameobj,Dirobj);
            %% Check the number of events
            data_ = data(data.DayTrial == fileName,:);
            timestamp = nan(height(data_),1);
            if length(Frame) == height(data_) - 2
                frame = 1;
            elseif length(Frame) < height(data_) - 2
                frame = 0;
                if length(Event(:,1)) < 3
                    fprintf('*****%s %s no trial end *****\n', fileName, trialName)
                    i_ = obj.index+1;
                    obj.report(i_,1) = string(folderName);
                    obj.report(i_,2) = string(trialName);
                    obj.report(i_,3) = "BrMarker NoTrialEnd";
                else
                    fprintf('*****%s fail %s number of frame marker:%d data:%d *****\n', ...
                        fileName, trialName, length(Frame), height(data_) - 2)
                    i_ = obj.index+1;
                    obj.report(i_,1) = string(folderName);
                    obj.report(i_,2) = string(trialName);
                    obj.report(i_,3) = "BrMarker FrameNumBug";
                end
            else
                frame = 0;
                fprintf('*****%s fail %s number of frame marker:%d data:%d *****\n', ...
                    fileName, trialName, length(Frame), height(data_) - 2)
                i_ = obj.index+1;
                obj.report(i_,1) = string(folderName);
                obj.report(i_,2) = string(trialName);
                obj.report(i_,3) = "BrMarker FrameNumBug";
            end
            if frame == 1
                timestamp(1) = Event(2,2);
                timestamp(2:(length(Frame(:,2))+1)) = Frame(:,2);
                timestamp(length(Frame(:,2))+2) = Event(3,2);
            end
            %% Check direction obj
            JoyStick = obj.TransDirNeural(data_.JoyStick);
            i_ = JoyStick(:,1);
            JoyStick = JoyStick(:,2);
            if length(JoyStick) == length(Dir(:,1))
                if all(JoyStick == Dir(:,1))
                    dir = 1;
                else
                    dir = 0;
                    fprintf('*****%s fail %s dir marker*****\n', fileName, trialName)
                    i_ = obj.index+1;
                    obj.report(i_,1) = string(folderName);
                    obj.report(i_,2) = string(trialName);
                    obj.report(i_,3) = "BrMarker DirBug";
                end
            else
                dir = 0;
                fprintf('*****%s fail %s number of dir marker:%d data:%d *****\n', ...
                    fileName, trialName, length(Dir(:,1)), length(JoyStick))
                i_ = obj.index+1;
                obj.report(i_,1) = string(folderName);
                obj.report(i_,2) = string(trialName);
                obj.report(i_,3) = "BrMarker DirNumBug";
            end
            if dir && frame
                success = 1;
                timestamp(:,2) = zeros(length(timestamp(:,1)),1);
                timestamp(i_,2) = Dir(:,2);
            end
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
    end
    
    methods(Hidden)
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
        
        function [Event, Frame, Dir, I] = subsetData(obj, fileName, Eventobj, Frameobj, Dirobj)
            % subset marker related to fileName
            if strcmp(fileName,"1-1-omegaL-13-Dec-2020-2")
                Eventobj = Eventobj(2:end,:);
            end
            if strcmp(fileName,"2-1-omegaL-27-Feb-2021-2")
                Eventobj = Eventobj(5:end,:);
            end
            if strcmp(fileName,"1-1-omegaL-22-Feb-2021-2")
                Eventobj = Eventobj(2:end,:);
            end
            trial = obj.trialFromfile(fileName);
            low = find(strcmp(Eventobj(:,1),trial));
            if isempty(low)
                Event = [];
                Frame = [];
                Dir = [];
                I = [];
                return
            end
            up = low + find(strcmp(Eventobj(low:end,1),'Trial End'), 1) - 1;
            if isempty(up)
                Event = Eventobj(low:end, :);
                head = double(Eventobj(low, 2));
                % frame obj
                index_ = Frameobj(:,2) > head;
                Frame = Frameobj(index_, :);
                % direction obj
                index_ = Dirobj(:,2) > head;
                Dir = Dirobj(index_, :);
                I = [head,-1];
            else
                Event = Eventobj(low:up, :);
                head = double(Eventobj(low, 2));
                tail = double(Eventobj(up, 2));
                % frame obj
                index_ = Frameobj(:,2) > head & Frameobj(:,2) < tail;
                Frame = Frameobj(index_, :);
                % direction obj
                index_ = Dirobj(:,2) > head & Dirobj(:,2) < tail;
                Dir = Dirobj(index_, :);
                I = [head,tail];
            end
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

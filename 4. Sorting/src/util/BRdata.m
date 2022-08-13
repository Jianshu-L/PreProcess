classdef BRdata < ListData
    
    properties
        data
        report = strings(0);
    end
    
    properties(Dependent)
        index = 1; % for report
    end
    
    properties(Hidden)
        Event;
        Frame;
        Dir;
        loadSignal = 0;
        upper = 0.0179;
        lower = 0.0156;
        timeInterval = 1;
        SampleRate = 30000;
    end
    
    methods
        function obj = BRdata(BRpath,BRtype)
            obj = obj@ListData(BRpath,BRtype);
            obj.fileAll = {obj.fileAll{1}(contains(obj.fileAll{:}, 'Eve'))};
        end
        
        function set.report(obj, BRreport)
            obj.report = BRreport;
        end
        
        function index = get.index(obj)
            [r,~] = size(obj.report);
            index = r;
        end
        
        function event = loadRawData(obj)
            % load raw event data
            eventF = strcat(obj.path, '/', obj.fileName);
            % fprintf("load raw marker from %s\n", obj.fileName)
            load(eventF, 'event');
            obj.data = event;
        end
        
        function saveData(~, path, Name, Eventobj, Frameobj, Dirobj)
            % read raw event data and save
            Path = path;
            file_ = strcat(Path, '/', Name);
            if exist(file_,'file')
                error("%s exists\n",Name)
            else
                % fprintf("===== save %s =====\n",Name)
                save(file_, 'Eventobj', 'Frameobj', 'Dirobj');
            end
        end
        
        function [Eventobj, Frameobj, Dirobj] = readData(obj)
            % read raw event data
            % Arg:
            %   ndName: raw marker data with path "~/pacman/MonkeyData/NBr_mat/datafile20201110001Eve.mat"
            % Out:
            %   Eventobj
            %   Frameobj
            %   Dirobj
            
            event = obj.loadRawData;
            if isempty(event)
                i_ = obj.index+1;
                obj.report(i_,1) = string(obj.fileName);
                obj.report(i_,2) = "";
                obj.report(i_,3) = "MarkerIsEmpty";
                Eventobj = [];
                Frameobj = [];
                Dirobj = [];
                return
            end
            objE = event(2,:)';
            timestep = event(1,:)';
            %% Event obj
            % Trial and Round Number
            a(:,1) = objE(objE < 10);
            a(:,2) = find(objE < 10);
            if mod(length(a(:,1)),4) ~= 0
                error("something wrong with trial and round marker")
            end
            b = 1:4:length(a(:,1));
            c = string(a(:,1));
            trialTs = timestep(a(4:4:length(a(:,1)),2));
            trial = "";
            for i_ = 1:length(b)
                trial(i_) = strcat(c(b(i_)), c(b(i_)+1), '-', c(b(i_)+2), c(b(i_)+3));
            end
            trial = trial';
            % Event obj and timestep
            condition = [126, 125, 123, 119, 111, 103, 112];
            temp = objE(ismember(objE, condition));
            eventts = timestep(ismember(objE, condition));
            event = string(temp);
            % Trial Start means no picture on the screen
            event(temp == 126,1) = "Trial Start";
            % Game End including Pacman Finish, Pacman Dead and Pacman No Move
            event(temp == 125,1) = "Pacman Finish";
            event(temp == 123,1) = "Pacman Dead";
            event(temp == 119,1) = "Pacman No Move";
            % Key Input including Key Pass and Key Pause
            event(temp == 111,1) = "Key Pass";
            event(temp == 103,1) = "Key Pause";
            % Trial End means no picture on the screen
            event(temp == 112,1) = "Trial End";
            Eventobj = [event; trial];
            EventTs = [eventts; trialTs];
            [~, I] = sort(EventTs);
            Eventobj = Eventobj(I);
            Eventobj(:,2) = string(EventTs(I));
            %% Frame obj
            condition = [31,95,63,127];
            Frameobj = objE(ismember(objE, condition));
            timestepFrame = timestep(ismember(objE, condition));
            Frameobj(:,2) = timestepFrame;
            inter = timestepFrame(2:end) - timestepFrame(1:end-1);
            inter(end+1) = NaN;
            Frameobj(:,3) = inter;
            % fps < 56 or fps > 64
            inter = inter / 30000;
            bugNum = sum(inter > obj.upper | inter < obj.lower);
            index_ = sum(inter > obj.timeInterval);
            bugNum = bugNum-index_;
            if bugNum > 0
                bugFPS = inter((inter > obj.upper | inter < obj.lower) & inter < obj.timeInterval);
                fprintf('%d bug fps in %s\n',bugNum,obj.fileName)
                if any(bugFPS < 1/50)
                    fprintf("*** %s has serious frame bug ***\n", obj.fileName)
                    % fprintf('----------\n')
                    % fprintf("%s\n",obj.fileName);
                    % fprintf('%d timesteps have abnormal interval\n', bugNum)
                end
            end
            %% Direction obj
            conditions = [[28,60,92,124],[26,58,90,122], ...
                [22,54,86,118],[14,46,78,110]];
            Dirobj = objE(ismember(objE, conditions));
            Dirobj(:,2) = timestep(ismember(objE, conditions));
            % Direction obj
            % up
            condition = [28,60,92,124];
            Dirobj(ismember(Dirobj, condition),1) = 0;
            % down
            condition = [26,58,90,122];
            Dirobj(ismember(Dirobj, condition),1) = 2;
            % left
            condition = [22,54,86,118];
            Dirobj(ismember(Dirobj, condition),1) = 1;
            % right
            condition = [14,46,78,110];
            Dirobj(ismember(Dirobj, condition),1) = 3;
            obj.Event = Eventobj;
            obj.Frame = Frameobj;
            obj.Dir = Dirobj;
        end
        
    end
end


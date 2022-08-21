classdef BEVdata < ListData
    
    properties
        data;
    end
    
    properties(Hidden)
        time_cp = datetime('27-May-2019','InputFormat','dd-MMM-yyyy','Locale','en_US');
    end
    
    methods
        function obj = BEVdata(dataPath,dataType)
            obj = obj@ListData(dataPath,dataType);
            folders = obj.folder(contains(obj.folder, '-')); % exclude not data folders
            eF = obj.folder(~contains(obj.folder, folders));
            if ~isempty(eF)
                fprintf("exclude %s folder\n", eF);
            end
            obj.folder = folders;
            if isempty(obj.folder)
                fprintf("*** not any valid folders ***\n")
            else
                obj.order;
            end
        end
        
        function data = loadRawData(obj)
            % load data
            % Arg:
            %   path: file path
            %   file: file name
            eventF = strcat(obj.filePath, '/', obj.fileName);
            load(eventF, 'data');
            obj.data = data;
        end
        
        function [T, rewP] = readDataQL(obj)
            % read raw data and debug
            if isempty(obj.data)
                error("data is empty?")
            else
                if ~isfield(obj.data.ghosts,'dirEnum')
                    obj.data.ghosts.dirEnum = data_process(obj.data.ghosts.dir_x, obj.data.ghosts.dir_y);
                end
            end
            temp = split(obj.folderName, '-');
            time_ = datetime(join(temp(2:4), '-'),'Locale','en_US');
            if time_ <= obj.time_cp
                error("data is too old")
            end
            if obj.data.pacMan.pixel_x(1) == 338 && obj.data.pacMan.pixel_y(1) == 663
                obj.data = obj.Trans(obj.data);
            end
            %% eye, pacman and ghosts position and ghosts mode
            mode = ModeTransfer(obj.data);
            pacMan = [obj.data.pacMan.tile_x', obj.data.pacMan.tile_y'];
            ghost1 = [obj.data.ghosts.tile_x(1,:)', obj.data.ghosts.tile_y(1,:)', mode(1,:)'];
            ghost2 = [obj.data.ghosts.tile_x(2,:)', obj.data.ghosts.tile_y(2,:)', mode(2,:)'];
            JoyStick = TransDir(obj.data.direction.up, obj.data.direction.down, ...
                obj.data.direction.left, obj.data.direction.right);
            T = table(pacMan, ghost1, ghost2, JoyStick);
            %% dots and eners position, 2019.12.1 by ljs
            % save fruits position, 2020.3.7 by ljs
            temp = split(obj.folderName, '-');
            name = split(obj.fileName, '.');
            file_name = strcat(name(1), '-', temp(end));
            rewP = rewardPosition(obj.data,file_name);
        end
        
        function saveDataQL(~, Path, Name, T, rewP)
            % save QL data
            % name = split(obj.fileName, '.');
            % Name = name(1);
            
            HMMfolder = strcat(Path, '/', obj.folderName);
            if ~exist(HMMfolder, 'dir')
                fprintf("create %s\n", HMMfolder)
                mkdir(HMMfolder);
                fprintf('create %s/%s/\n', HMMfolder, "Rewards")
                mkdir(sprintf('%s/%s/', HMMfolder, "Rewards"));
            end
            fprintf('save %s csv\n', Name)
            writetable(T, sprintf('%s/%s.csv', HMMfolder, Name));
            writetable(rewP, sprintf('%s/%s/%s.csv', HMMfolder, "Rewards", Name));
        end
        
        function Data = readData(obj)
            Data = [];
%             fprintf("load raw data from %s\n", obj.folderName)
            for i = 1:length(obj.file)
                obj.fileI = i;
                obj.loadRawData;
                %% read raw data
                if isempty(obj.data)
                    error("data is empty?")
                else
                    if ~isfield(obj.data.ghosts,'dirEnum')
                        obj.data.ghosts.dirEnum = data_process(obj.data.ghosts.dir_x, obj.data.ghosts.dir_y);
                    end
                end
                % pacman and ghosts position, ghosts mode, Joystick
                [waterTS,waterStatus,waterDelay] = setDOTimeDelay(obj.data);
                [T, rewP] = readDataQL(obj);
                dirEnum = obj.data.pacMan.dirEnum;
                pDir = TransDirEnum(dirEnum);
                pacManP = [obj.data.pacMan.pixel_x', obj.data.pacMan.pixel_y'];
                mode1R = obj.data.ghosts.mode(1,:);
                mode2R = obj.data.ghosts.mode(2,:);
                scared1 = obj.data.ghosts.scared(1,:);
                scared2 = obj.data.ghosts.scared(2,:);
                ghost1P = [obj.data.ghosts.pixel_x(1,:)', ...
                    obj.data.ghosts.pixel_y(1,:)'];
                g1Dir = TransDirEnum(obj.data.ghosts.dirEnum(1,:));
                ghost2P = [obj.data.ghosts.pixel_x(2,:)', ...
                    obj.data.ghosts.pixel_y(2,:)'];
                g2Dir = TransDirEnum(obj.data.ghosts.dirEnum(2,:));
                Tpixel = table(pacManP, pDir', obj.data.pacMan.frames', ...
                    ghost1P, g1Dir', mode1R', scared1', obj.data.ghosts.frames(1,:)', ...
                    ghost2P, g2Dir', mode2R', scared2', obj.data.ghosts.frames(2,:)');
                T2 = splitvars(Tpixel);
                T2.Properties.VariableNames = [ ...
                    "ppX", "ppY", "pDir", "pFrame", ...
                    "g1pX", "g1pY", "g1Dir", "g1ModeR", "g1Scared", "g1Frame", ...
                    "g2pX", "g2pY", "g2Dir", "g2ModeR", "g2Scared", "g2Frame"];
                %% postprocess
                Step = unique(rewP.Step);
                if length(Step) == height(T) - 1
                    Step(end+1) = Step(end) + 1; %#ok<AGROW>
                end
                DayTrial = repmat(unique(rewP.DayTrial),length(Step),1);
                Map = string(obj.data.gameMap.currentTiles');
                Reward = table(Step, DayTrial, Map);
                T.Step = Step;
                T2.Step = T.Step;
                T2 = join(T,T2);
                data_ = join(Reward,T2);
                Joystick = string(data_.JoyStick);
                Joystick(data_.JoyStick == 0) = "";
                Joystick(data_.JoyStick == 1) = "up";
                Joystick(data_.JoyStick == 2) = "down";
                Joystick(data_.JoyStick == 3) = "left";
                Joystick(data_.JoyStick == 4) = "right";
                data_.JoyStick = Joystick;
                if ~isempty(waterTS)
                    data_.waterTS = waterTS;
                    data_.waterStatus = waterStatus;
                    data_.waterDelay = waterDelay;
                else
                    data_.waterTS = repmat("",height(T2),1);
                    data_.waterStatus = repmat("",height(T2),1);
                    data_.waterDelay = repmat("",height(T2),1);
                end
                if isempty(Data)
                    Data = data_;
                else
                    Data = [Data;data_]; %#ok<AGROW>
                end
            end
        end
        
        function saveData(~, path, Name, data)
            % read raw data and save per folder
            Path = path;
            file_ = strcat(Path, '/', Name);
            if exist(file_,'file')
                error("%s exists, pass\n", Name)
            else
                save(file_, 'data');
%                 fprintf("===== save %s =====\n", Name)
            end
        end
        
        function order(obj)
            %% List obj.path contents
            obj.folder = obj.orderFolder(obj.folder,2,4);
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
                [file_list,~] = obj.orderFile(files, 1,2);
                obj.fileAll{folder_position} = file_list;
            end
            obj.folderI = 1;
        end
        
        function [file_list, file_order] = orderFile(~, files, nStart, nEnd)
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
            char_num = str2double(char_i(:,nStart:nEnd));
            char_trial = char_num(:,1) * 1000 + char_num(:,2);
            [~, I] = sortrows(char_trial); % sort files by current_round and used_trial
            file_list = file_name(I);
            file_order = I;
        end
        
        function [folder_list, folder_order] = orderFolder(~, folders, dStart, dEnd)
            % order folders by date in folder name
            % Arg:
            %   folders: folders to sort
            %   "omegaL-01-Dec-2020-1"
            %   dStart, dEnd: start and end index of date in folder name
            %   2,4
            % Out:
            %   folder_list: sorted folders
            %   folder_order: the order of sorted folders
            
            %% sort by date
            char_i = split(folders,'-');
            if length(char_i(1,:)) > 1
                char = join(char_i(:,dStart:dEnd),'-');
            else
                char = join(char_i(dStart:dEnd),'-');
            end
            char = datetime(char,'InputFormat','dd-MMM-yyyy','Locale','en_US');
            [~, I] = sortrows(char); % sort folders by current_round and used_trial
            folder_list = folders(I);
            folder_order = I;
        end
        
        function copywell(obj, wellNum, path)
            % copy well data to path
            % Arg:
            %   wellNum: data with trials number less than wellNum are well
            %   path: save path for well data
            
            index = obj.folderI;
            %% copy data
            for i = 1:length(obj.folder)
                obj.folderI = i;
                folder_name = strcat(path,'/',obj.folder(i));
%                 fprintf('folder = %s\n',obj.folder(i))
                if exist(folder_name, 'dir') == 7
%                     fprintf('pass, %s is already exist\n', folder_name)
%                     fprintf('***************\n')
                    continue
                end
                mkdir(folder_name);
%                 fprintf('create data Folder %s \n', folder_name);
                dirPath = dir(obj.path);
                if isfolder(strcat(obj.path, '/', dirPath(3).name))
                    files = strcat(obj.path, "/", obj.folder(i), "/",  ...
                        obj.file);
                else
                    files = strcat(obj.path, "/", obj.file);
                end
                fileList = obj.choose_PerWell_range(files, 1, wellNum);
                if isempty(fileList)
                    fprintf('pass, no well data in the folder %s\n', obj.folderName)
                    fprintf('***************\n')
                    rmdir(folder_name);
                    continue
                end
                for j = 1:length(fileList)
                    copyfile(strcat(obj.filePath, "/", fileList(j)), ...
                        folder_name)
                end
            end
            obj.folderI = index;
        end
        
        function tile = PtoT(~, x, y)
            % tile <=> pixel
            tile.x = floor(x/25) + 1;
            tile.y = floor(y/25) + 1;
        end

        function pixel = TtoP(~, x, y)
            % pixel <=> tile
            pixel.x = (x-1)*25 + floor(25/2);
            pixel.y = (y-1)*25 + floor(25/2);
        end
        
        function newData = Trans(~,oldData)
            newData = oldData;
            %% midTile bug
            newData.pacMan.pixel_x = oldData.pacMan.pixel_x - 1;
            newData.pacMan.pixel_y = oldData.pacMan.pixel_y - 1;
            newData.ghosts.pixel_x = oldData.ghosts.pixel_x - 1;
            newData.ghosts.pixel_y = oldData.ghosts.pixel_y - 1;
            %% Tunnel bug
            newData.pacMan.pixel_x(newData.pacMan.pixel_x == -26) = -25;
            newData.ghosts.pixel_x(newData.ghosts.pixel_x == -26) = -25;
            %% Tile bug
            newData.pacMan.tile_x = floor(newData.pacMan.pixel_x/25) + 1;
            newData.pacMan.tile_y = floor(newData.pacMan.pixel_y/25) + 1;
            newData.ghosts.tile_x = floor(newData.ghosts.pixel_x/25) + 1;
            newData.ghosts.tile_y = floor(newData.ghosts.pixel_y/25) + 1;
        end
    end
    
    methods(Hidden)
        function file_list = choose_PerWell_range(~, files, trial_low, trial_up)
            % list well data in files
            % Arg:
            %   files: data file name with file path
            %   trial_low: data with trials number larger than trial_low are well
            %   trial_up: data with trials number smaller than trial_up are well
            
            if nargin == 1
                trial_low = 1;
                trial_up = 10;
            end
            
            j = 0;
            file_name = split(files,'/');
            if length(file_name(1,:)) > 1
                file_name = file_name(:,end);
            else
                file_name = file_name(end);
            end
            if file_name == ""
                file_list = [];
                return
            end
            char = zeros(length(file_name),1);
            trial_num = zeros(length(file_name),1);
            k = 0;
            %% choose well data
            for i = 1:length(file_name)
                load(files(i), 'data');
                if length(data.direction.up) <= 2 %#ok<PROPLC>
%                     warning('%s is bug data\n', file_name(i))
                    if k == 0
                        k = i;
                    else
                        error("has more than one empty data")
                    end
                end
                char_i = split(file_name(i),'-')';
                j = j + 1;
                if i < length(file_name)
                    char_j = split(file_name(i+1),'-')';
                    if char_j(1) ~= char_i(1) || char_j(4) ~= char_i(4)...
                            || char_j(5) ~= char_i(5)
                        trial_num(i) = char_i(2);
                        if trial_num(i) >= trial_low && trial_num(i) <= trial_up
                            if trial_num(i) == j
                                if isempty(data) %#ok<PROPLC>
%                                     warning('%s is not success data\n', file_name(i))
                                    j = 0;
                                    continue
                                end
                                if checkSuccess(data) %#ok<PROPLC>
                                    char((i+1-trial_num(i)):i) = 1;
                                    if k ~= 0
                                        char(k) = 0;
                                    end
                                else
%                                     warning('%s is not success data\n', file_name(i))
                                end
                            else
                                error('%s has gap in the data sequence\n', file_name(i))
                            end
                        end
                        j = 0;
                    end
                else
                    trial_num(i) = char_i(2);
                    if trial_num(i) >= trial_low && trial_num(i) <= trial_up
                        if trial_num(i) == j
                            if isempty(data) %#ok<PROPLC>
%                                 warning('%s is not success data\n', file_name(i))
                                continue
                            end
                            if checkSuccess(data) %#ok<PROPLC>
                                char((i+1-trial_num(i)):i) = 1;
                            else
%                                 warning('%s is not success data\n', file_name(i))
                            end
                        else
                            error('%s has gap in the data sequence\n', file_name(i))
                        end
                        j = 0;
                    end
                end
            end
            file_list = file_name(logical(char));
        end
    end
end

function success = checkSuccess(data)
if data.gameMap.totalDots(end) == 0
    success = 1;
elseif data.gameMap.totalDots(end) == 1
    pp = (data.pacMan.tile_y(end)-1)*28+data.pacMan.tile_x(end);
    dp = data.gameMap.currentTiles(:,end);
    distance = find(dp=='.')-pp;
    if any(distance == [-1, 1, -28, 28])
        success = 1;
    else
        success = 0;
    end
else
    success = 0;
end
end

function dirEnum = data_process(dir_x, dir_y)
DIR_UP = 0;
DIR_RIGHT = 3;
DIR_DOWN = 2;
DIR_LEFT = 1;
dirEnum = ones(2, length(dir_x)) * 8;
for i = 1:length(dir_x)
    for j = 1:2
        
        if (dir_x(j,i) == 0 && dir_y(j,i) == -1)
            dirEnum(j,i) = DIR_UP;
        elseif (dir_x(j,i) == 1 && dir_y(j,i) == 0)
            dirEnum(j,i) = DIR_RIGHT;
        elseif (dir_x(j,i) == 0 && dir_y(j,i) == 1)
            dirEnum(j,i) = DIR_DOWN;
        elseif (dir_x(j,i) == -1 && dir_y(j,i) == 0)
            dirEnum(j,i) = DIR_LEFT;
        else
            dirEnum(j,i) = 4;
        end
    end
end
end

function mode = ModeTransfer(data)

% mode = 0: ghosts are outside home
% mode = 1: ghosts are being eaten
% mode = 2: ghosts are going home after being eaten
% mode = 3: ghosts are just outside the door and will enter the home after
% being eaten
% mode = 4: ghosts are at the original position and will go outside home
% mode = 5: ghosts are going outside home
g1 = data.ghosts.mode(1,:);
g2 = data.ghosts.mode(2,:);
%% flash
i_ = floor((data.energizer.duration-data.energizer.count)./data.energizer.flashInterval);
%% chasing or corner
dx = data.pacMan.tile_x - (data.ghosts.tile_x(2,:) + data.ghosts.dir_x(2,:));
dy = data.pacMan.tile_y - (data.ghosts.tile_y(2,:) + data.ghosts.dir_y(2,:));
dist = dx.*dx+dy.*dy;
g1_new = g1;
g2_new = g2;

g1_new(data.ghosts.scared(1,:) == 0 & (g1 == 0 | g1 == 4 | g1 == 5)) = 1; % chasing pacman
g1_new(g1 == 1 | g1 == 2 | g1 == 3) = 3; % dead ghosts (include ghosts are being eaten)
g1_new(i_ > 2*data.energizer.flashes-1 & data.ghosts.scared(1,:) == 1) = 4; % scared ghosts
g1_new(i_ <= 2*data.energizer.flashes-1 & data.ghosts.scared(1,:) == 1) = 5; % flash scared ghosts

g2_new(dist >= 64 & data.ghosts.scared(2,:) == 0 & ...
    (g2 == 0 | g2 == 4 | g2 == 5)) = 1; % chasing pacman
g2_new(dist < 64 & data.ghosts.scared(2,:) == 0 & ...
    (g2 == 0 | g2 == 4 | g2 == 5)) = 2; % going corner
g2_new(g2 == 1 | g2 == 2 | g2 == 3) = 3; % dead ghosts (include ghosts are being eaten)
g2_new(i_ > 2*data.energizer.flashes-1 & data.ghosts.scared(2,:) == 1) = 4; % scared ghosts
g2_new(i_ <= 2*data.energizer.flashes-1 & data.ghosts.scared(2,:) == 1) = 5; % flash scared ghosts

mode = [g1_new;g2_new];
end

function direction = TransDir(up, down, left, right)
%% DO NOT CHANGE THE ORDER. As we have condition that two directions at same time
direction = zeros(length(up),1);
direction(down == 1) = 2;
direction(right == 1) = 4;
direction(up == 1) = 1;
direction(left == 1) = 3;

end

function rewP = rewardPosition(data,fileName)

ts = 1:length(data.direction.up);

%% Get reward position
% dotsX is the position of all dots in dotsY data
[dotsX, dotsY] = find(data.gameMap.currentTiles == '.');
dots_p = [positionTile_dots(dotsX),dotsY];
% eners position
[enersX, enersY] = find(data.gameMap.currentTiles == 'o');
eners_p = [positionTile_dots(enersX),enersY];
% fruits position and type
fruits = ['A' ; 'O' ; 'M' ; 'C' ; 'S'];
[pos,type] = ismember(data.gameMap.currentTiles,fruits);
[fruitsX,fruitsY] = find(pos);
[~,~,typeIndex] = find(type);
fruits_p = [positionTile_dots(fruitsX),fruitsY];
fruitT = fruits(unique(typeIndex));

%% create Table
[X,Y,Reward,Step] = CreateTable(ts, dots_p, eners_p, fruits_p, fruitT);
DayTrial = repmat(fileName, length(X), 1);
rewP = table(X, Y, Reward, DayTrial, Step);

    function dots_p = positionTile_dots(index)
        pos_x= rem(index,28);
        pos_y = fix(index/28)+1;
        fix_p = find(pos_x == 0);
        if any(pos_x == 0)
            pos_x(fix_p) = 28;
            pos_y(fix_p) = fix(index(fix_p)/28);
        end
        dots_p = [];
        dots_p(:,1) = pos_x;
        dots_p(:,2) = pos_y;
    end

    function [X,Y,Reward,Step] = CreateTable(ts, dots_p, eners_p, fruits_p, fruitT)
        %% init vars
        X = zeros(69*length(ts),1);
        Y = zeros(69*length(ts),1);
        Reward = zeros(69*length(ts),1);
        Step = zeros(69*length(ts),1);
        j = 1; % the position in the table
        %% find the index of first dot in every timestep
        cout = conv(dots_p(:,3),[1,-1]);
        index = find(cout == 1);
        for i = 1:length(index)
            %% the position and reward value of every rewards.
            % dots
            if i ~= length(index)
                dots = dots_p(index(i):(index(i+1)-1),1:2);
            else
                dots = dots_p(index(i):end,1:2);
            end
            dotsI = ones(1,length(dots(:,2)))';
            % eners
            eners = eners_p(eners_p(:,3) == i,1:2);
            enersI = ones(1,length(eners(:,2)))' * 2;
            % fruits
            fruits_ = fruits_p(fruits_p(:,3) == i,1:2);
            switch fruitT
                case 'C'
                    fruitsI = ones(1,length(fruits_(:,2)))' * 3;
                case 'S'
                    fruitsI = ones(1,length(fruits_(:,2)))' * 4;
                case 'O'
                    fruitsI = ones(1,length(fruits_(:,2)))' * 5;
                case 'A'
                    fruitsI = ones(1,length(fruits_(:,2)))' * 6;
                case 'M'
                    fruitsI = ones(1,length(fruits_(:,2)))' * 7;
                otherwise
                    fruitsI = ones(1,length(fruits_(:,2)))' * -1;
            end
            x = [dots(:,1);eners(:,1);fruits_(:,1)];
            y = [dots(:,2);eners(:,2);fruits_(:,2)];
            reward = [dotsI;enersI;fruitsI];
            step = repmat(i, length(x), 1);
            X(j:length(x)+j-1,1) = x;
            Y(j:length(x)+j-1,1) = y;
            Reward(j:length(x)+j-1,1) = reward;
            Step(j:length(x)+j-1,1) = step;
            j = length(x)+j;
        end
        X(X == 0) = [];
        Y(Y == 0) = [];
        Reward(Reward == 0) = [];
        Step(Step == 0) = [];
    end
end

function pDir = TransDirEnum(dirEnum)
pDir = string(1:length(dirEnum));
pDir(dirEnum == -1) = "";
pDir(dirEnum == 0) = "up";
pDir(dirEnum == 2) = "down";
pDir(dirEnum == 1) = "left";
pDir(dirEnum == 3) = "right";
end

function [waterTS,waterStatus,waterDelay] = setDOTimeDelay(data)
% when reward_round diff larger than zero, "last timestep marker" + "last
% timestep JScheckTimeCost" + "last timestep DataSaveCost" + "this timestep
% rewardCost" = "this timestep setDO real time"
if isfield(data, 'reward')
    data.rewd.reward = data.reward;
end
rewdDiff = data.rewd.reward(2:end) - data.rewd.reward(1:end-1);
if isempty(find(rewdDiff, 1))
%     fprintf("got no dot in the trial\n")
    waterTS = zeros(length(data.rewd.reward),1);
    waterStatus = zeros(length(data.rewd.reward),1);
    waterDelay = zeros(length(data.rewd.reward),1);
    return
end
OpenTs = find(rewdDiff)+1;
if any(OpenTs <= 3)
    error("setDO(4,1) happened at first 3 timestep")
end
if ~isfield(data.time,"datasavingCost")
    waterTS = [];
    waterStatus = [];
    waterDelay = [];
    return
end
OpenTimeDelay = data.time.datasavingCost(OpenTs)+ ...
    data.time.JSCheckCost(OpenTs)+ ...
    data.time.rewardCost(OpenTs);
CloseTs = OpenTs+rewdDiff(OpenTs-1)-1;
if any(CloseTs > (length(rewdDiff)+1))
    CloseTs(CloseTs > (length(rewdDiff)+1)) = length(rewdDiff)+1;
%     fprintf("game over but reward not finish\n")
end
CloseTimeDelay = data.time.datasavingCost(CloseTs)+ ...
    data.time.JSCheckCost(CloseTs)+ ...
    data.time.rewardCost(CloseTs);
% handle special condition
ts_ = OpenTs(2:end) - OpenTs(1:end-1);
diff_ = data.rewd.reward(OpenTs) - data.rewd.reward(OpenTs-1);
ts_(end+1) = CloseTs(end);
if any(diff_ > ts_)
    bugTS = diff_ > ts_;
    if sum(bugTS) == 1
        CloseTs(find(bugTS)+1) = OpenTs(bugTS)+diff_(bugTS)+diff_(find(bugTS)+1)-1;
        CloseTimeDelay = data.time.datasavingCost(CloseTs)+ ...
            data.time.JSCheckCost(CloseTs)+ ...
            data.time.rewardCost(CloseTs);
    else
        error("two reward are very close")
    end
end
%%
waterTS = zeros(length(data.rewd.reward),1);
waterDelay = zeros(length(data.rewd.reward),1);
waterStatus = zeros(length(data.rewd.reward),1);
for j = 1:length(OpenTs)
    waterTS(OpenTs(j):CloseTs(j)) = 1;
end
waterStatus(OpenTs,1) = 1;
waterStatus(CloseTs,1) = 2;
waterDelay(OpenTs) = OpenTimeDelay;
waterDelay(CloseTs) = CloseTimeDelay;
end

classdef ELdata < ListData
    
    properties
        data
    end
    
    methods
        function obj = ELdata(ELpath,ELtype)
            obj = obj@ListData(ELpath,ELtype);
        end
        
        function B = loadRawData(obj)
            % load raw data
            eventF = strcat(obj.filePath, '/', obj.fileName);
            % fprintf("load raw marker from %s\n", obj.fileName)
            % read asc file
            [fid,errorMSG] = fopen(eventF);
            if fid == -1
                error("%s",errorMSG)
            end
            %% load whole eyelink data
            B = textscan(fid,'%s','Delimiter','\n');
            B = B{1};
            obj.data = B;
            fclose(fid);
        end
        
        function saveData(~, path, Name, eyelink)
            % read raw event data and save
            Path = path;
            file_ = strcat(Path, '/', Name);
            if exist(file_,'file')
                error("%s exists\n",Name)
            else
                % fprintf("===== save %s =====\n",Name)
                save(file_, 'eyelink');
            end
        end
        
        function [eyelink,probName] = readData(obj)
            % read raw event marker
            % Out:
            %   eyelink: eyelink data
            %   probName: the times of revalidation failing
            B = obj.loadRawData;
            file = obj.fileName;
            %% split data and msg from the data
            [Data,msg,Sacc,Fix,END] = obj.readASC(B,file);
            if isempty(Data) || isempty(END)
                eyelink = [];
                fprintf("***** %s no eyelink data\n",file)
                return
            end
            %% check if all data are processed
            t_m = Data(2:end,1) - Data(1:(end-1),1);
            Num = 1;
            if length(t_m(t_m ~= 1)) ~= (length(END) - 1)
                Num = 2;
                if length(t_m(t_m ~= 2)) ~= (length(END) - 1)
                    Num = 4;
                    if length(t_m(t_m ~= 4)) ~= (length(END) - 1)
                        % fprintf("%s\n", obj.fileName)
                        % fprintf('length(t_m(t_m ~= 1)) ~= (length(END) - 1)\n')
                        eyelink = 0;
                        return
                    end
                end
            end
            %% Pick the timestep we need
            % the trail number
            trial = msg(contains(msg(:,2), 'TRIAL'),2);
            if isempty(trial)
                trial = regexp(msg(:,2),'Trial\d*-\d*','match');
                trial = string(trial(~cellfun(@isempty,trial)));
            end
            % the timestep of 'Frame:%d'
            col_frame = double(msg(contains(msg(:,2), 'Frame:'),1));
            % the timestep of "TrialStart" and "TrialEnd"
            col_mark = [];
            l_ts = length(msg(contains(msg(:,2), 'Trial Start'),1));
            l_te = length(msg(contains(msg(:,2), 'Trial End'),1));
            if l_ts == l_te
                col_mark(:,1) = msg(contains(msg(:,2), 'Trial Start'),1);
                col_mark(:,2) = msg(contains(msg(:,2), 'Trial End'),1);
            else
                if l_ts - l_te == 1
                    % delete last trial eyelink data for no trial end
                    s_ = msg(contains(msg(:,2), 'Trial Start'),1);
                    e_ = msg(contains(msg(:,2), 'Trial End'),1);
                    col_mark(:,1) = s_(1:end-1);
                    col_mark(:,2) = e_;
                    col_frame = col_frame(col_frame < double(s_(end)));
                else
                    error("*** %s: the length of TrialStart %d and TrialEnd %d is different ***\n", ...
                        obj.fileName, l_ts, l_te)
                end
            end
            % the relationship between column number and the timestep
            % the position of the gap
            gap_pos = find(t_m ~= Num);
            if ~isempty(gap_pos)
                % fprintf('the lenght of gap between timestep and column number is %d\n',length(gap_pos))
                % fprintf('Revalidation during experiment fails %d times\n',length(gap_pos))
                probName(1,1) = file;
                probName(1,2) = length(gap_pos);
                probName(1,3) = strcat(obj.filePath, '/', file);
            end
            
            %% create empty struct
            % eyelink = struct('timestep', cell(1, length(col_mark)));
            length_col = 0;
            for i = 1:length(col_mark(:,1))
                % the timestep of frames between every "TrialStart" and "TrialEnd".
                col = col_frame(col_frame > col_mark(i,1) & col_frame < col_mark(i,2));
                if isempty(col) || length(col) == 1
                    % fprintf('%s has no frame\n', trial(i))
                    if length(col) == 1
                        eyelink.sample(i).timestep = repmat([-1,-1,-1,-1],3,1);
                        length_col = length(col) + length_col;
                    end
                    continue
                end
                length_col = length(col) + length_col;
                % check fps > 62.5 or < 52.6
                range_ = 100;
                chazhi = chazhi_timestep(col);
                fps_bug = sum(chazhi > 19 | chazhi < 16);
                if fps_bug > 1
                    bugFPS = chazhi(chazhi > 19 | chazhi < 16);
                    fprintf('%d bug fps in %s in %s\n',fps_bug,trial(i),file)
                    if any(bugFPS > 50)
                        fprintf("*** %s has serious frame bug in %s ***\n", trial(i),file)
                        range_ = bugFPS(bugFPS > 50)+1;
                    end
                end
                % using mean of every frame data
                sample_ts = zeros(length(col)-1,2);
                sample_data = cell(length(col)-1,3);
                col_before = col(1:length(col)-1);
                col_after = col(2:length(col));
                ts = Data(:,1);
                data_ = Data(:,2:4);
                for j = 1:(length(col)-1)
                    if j == 1
                        index = find(ts >= col_before(j) & ts <= col_after(j));
                    else
                        i_ = max(index);
                        tsi = ts(i_+1:i_+range_);
                        index = find(tsi >= col_before(j) & tsi <= col_after(j));
                        index = index + i_;
                    end
                    ts_ = ts(index,1);
                    if all(ts_ >= col_before(j)) && all(ts_ <= col_after(j))
                        sample_ts(j,:) = [min(ts_),max(ts_)];
                    else
                        error('data %s has some problem', file)
                    end
                    sample_data(j,:) = num2cell(data_(index,:),1);
                end
                %% sample data
                a = length(sample_data(:,1));
                timestep = zeros(a+3,4);
                timestep(2:end-2,1:3) = cellfun(@mean, sample_data);
                timestep(2:end-2,4) = chazhi;
                eyelink.sample(i).timestep = timestep;
                %% event data
                if ~isempty(Sacc)
                    sacc_trial = Sacc(Sacc(:,1) >= col(1) & Sacc(:,2) <= col(end),:);
                    sacc_bound = up_low_bound(col,sacc_trial);
                else
                    sacc_trial = [];
                    sacc_bound = [];
                end
                if ~isempty(Fix)
                    fix_trial = Fix(Fix(:,1) >= col(1) & Fix(:,2) <= col(end),:);
                    fix_bound = up_low_bound(col,fix_trial);
                else
                    fix_trial = [];
                    fix_bound = [];
                end
                eyelink.event(i).sacc = sacc_trial;
                eyelink.event(i).sacc_timestep = sacc_bound;
                eyelink.event(i).fix = fix_trial;
                eyelink.event(i).fix_timestep = fix_bound;
            end
            b = cellstr(trial');
            [eyelink.sample.trial] = b{:};
            [eyelink.event.trial] = b{:};
            if length_col ~= length(col_frame)
                fprintf('the length_col ~= length(col_frame)\n')
                error('data %s has some problem', file)
            end
        end
        
    end
    
    methods(Hidden)
        function [data,msg,Sacc,Fix,END] = readASC(~, B, file)
            %% create sample data
            C = char(B(contains(B,'...')));
            if isempty(C)
                % fprintf("***** %s mouse simulation data, pass\n", file)
                data = [];
                msg = [];
                Sacc = [];
                Fix = [];
                END = [];
                return
            end
            data = textscan(C','%f','delimiter', {' ','...'}, ...
                'MultipleDelimsAsOne',true,'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
            data = reshape(data{1},[4,length(data{1})/4])';
            % check length
            a = size(C);
            if length(data(:,1)) ~= a(1)
                warning('length(data) ~= length(file)')
            end
            %% create msg data
            msg = "";
            C = char(B(contains(B,'MSG')));
            data_msg = textscan(C','%f%s','delimiter',{'MSG'},'MultipleDelimsAsOne',true);
            msg(1:length(data_msg{1}),1) = data_msg{1};
            msg(1:length(data_msg{1}),2) = data_msg{2};
            msg = strtrim(msg);
            % check length
            a = size(C);
            if length(msg(:,1)) ~= a(1)
                warning('length(msg) ~= length(file)')
            end
            %% create saccade data
            % C = char(B(contains(B,'ESACC')));
            % example = textscan(C(1,:)','%f','delimiter',{'ESACC',eyeBall}, ...
            %     'MultipleDelimsAsOne',true,'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
            % length_sacc = length(example{1});
            % data_sacc = textscan(C','%f','delimiter',{'ESACC',eyeBall}, ...
            %     'MultipleDelimsAsOne',true,'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
            % Sacc = reshape(data_sacc{1},[length_sacc,length(data_sacc{1})/length_sacc])';
            C = char(B(contains(B,'ESACC')));
            if isempty(C)
                fprintf("***** %s has no sacc data\n", file)
                Sacc = [];
            else
                example = textscan(C(1,9:end)','%f', 'MultipleDelimsAsOne',true, ...
                    'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
                length_sacc = length(example{1});
                data_sacc = textscan(C(:,9:end)','%f', 'MultipleDelimsAsOne',true, ...
                    'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
                Sacc = reshape(data_sacc{1},[length_sacc,length(data_sacc{1})/length_sacc])';
                % check length
                a = size(C);
                if length(Sacc(:,1)) ~= a(1)
                    warning('length(sacc) ~= length(file)')
                end
            end
            %% create fixation data
            C = char(B(contains(B,'EFIX')));
            if isempty(C)
                fprintf("***** %s has no fixation data\n", file)
                Fix = [];
            else
                example = textscan(C(1,9:end)','%f', 'MultipleDelimsAsOne',true, ...
                    'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
                length_fix = length(example{1});
                data_fix = textscan(C(:,9:end)','%f', 'MultipleDelimsAsOne',true, ...
                    'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
                Fix = reshape(data_fix{1},[length_fix,length(data_fix{1})/length_fix])';
                % C = char(B(contains(B,'EFIX')));
                % example = textscan(C(1,:)','%f','delimiter',{'EFIX',eyeBall}, ...
                %     'MultipleDelimsAsOne',true,'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
                % length_fix = length(example{1});
                % data_fix = textscan(C','%f','delimiter',{'EFIX',eyeBall}, ...
                %     'MultipleDelimsAsOne',true,'TreatAsEmpty','.','EmptyValue',0,'ReturnOnError',false);
                % Fix = reshape(data_fix{1},[length_fix,length(data_fix{1})/length_fix])';
                % check length
                a = size(C);
                if length(Fix(:,1)) ~= a(1)
                    warning('length(fix) ~= length(file)')
                end
            end
            %% create END data
            C = char(B(contains(B,'END')));
            if isempty(C)
                END = [];
                return
            end
            END = textscan(C','%s','delimiter',{'END'},'MultipleDelimsAsOne',true,'ReturnOnError',false);
            END = END{1};
            % check length
            a = size(C);
            if length(END(:,1)) ~= a(1)
                warning('length(end) ~= length(file)')
            end
        end
    end
end

function chazhi = chazhi_timestep(timestep)
a = 1:(length(timestep)-1);
b = a + 1;
chazhi = timestep(b) - timestep(a) + 1;
end

function bound = up_low_bound(col,event_trial)
bound = zeros(length(event_trial(:,1)),2);
a = (col-event_trial(:,1)');
b = a < 0;
a(b) = Inf;
[~,bound(:,1)] = min(a,[],1);
a = (event_trial(:,2)' - col);
b = a < 0;
a(b) = Inf;
[~,bound(:,2)] = min(a,[],1);
bound(:,2) = bound(:,2) + 1;
end
classdef DriverScrewsP < handle
    
    properties
        index
        Path
        fileNames
        Date
        Pos = []
    end
    
    properties(Dependent)
        fileName
    end
    
    methods
        function obj = DriverScrewsP(Path)
            obj.Path = Path;
            obj.fileNames = dirFiles(obj.Path,"xlsx");
            obj.index = 1;
        end
        
        function fileName = get.fileName(obj)
            fileName = obj.fileNames(obj.index);
        end
        
        function Date = get.Date(obj)
            temp = split(obj.fileName,[" ","."]);
            Date = double(temp(end-1));
        end
        
        function Date = getDate(obj)
            temp = split(obj.fileNames,[" ","."]);
            Date = double(temp(:,4));
        end
        
        function T = readDepth(obj)
            Date = []; %#ok<*PROP>
            chanNum = [];
            Depth = [];
            for i = 1:length(obj.fileNames)
                obj.index = i;
                [~,~,CL] = obj.readXLSX;
                Date_ = repmat(obj.Date,128,1);
                chanNum_ = (1:128)';
                Date = [Date;Date_]; %#ok<*AGROW>
                chanNum = [chanNum;chanNum_];
                Depth = [Depth;CL];
            end
            T = table(Date, chanNum, Depth);
        end
        
        function T = readScrews(obj)
            Date = [];
            chanNum = [];
            Screws = [];
            for i = 1:length(obj.fileNames)
                obj.index = i;
                if i == 1
                    [~,~,CL] = obj.readXLSX;
                    CL1 = zeros(128,1);
                    CL2 = CL;
                else
                    CL1 = CL;
                    [~,~,CL] = obj.readXLSX;
                    CL2 = CL;
                end
                Screws_ = CL2-CL1;
                Date_ = repmat(obj.Date,128,1);
                chanNum_ = (1:128)';
                Date = [Date;Date_];
                chanNum = [chanNum;chanNum_];
                Screws = [Screws;Screws_];
            end
            T = table(Date, chanNum, Screws);
        end
        
        function T = SUorMU(obj)
            SU = [];
            MU = [];
            Date = [];
            for i = 1:length(obj.fileNames)
                obj.index = i;
                [SU_,MU_,~] = readXLSX(obj);
                SU{i} = SU_;
                MU{i} = MU_;
                Date(i) = obj.Date;
            end
            Date = Date';
            SU = SU';
            MU = MU';
            T = table(Date,SU,MU);
        end
        
        function pos = getPos(~,T)
            S = string(T{5:16,19:30});
            Index = 1;
            pos = zeros(3,1);
            for r = 1:12
                for c = 1:12
                    if S(r,c) ~= ""
                        pos(1,Index) = r;
                        pos(2,Index) = c;
                        pos(3,Index) = S(r,c);
                        Index = Index+1;
                    end
                end
            end
        end
        
        function [SUf,MUf,CL] = readXLSX(obj)
            T = readtable(strcat(obj.Path,"/",obj.fileName),'ReadVariableNames',false);
            SU = string(split(T{19,13},[","," "]));
            MU = string(split(T{20,13},[","," "]));
            if ~isempty(T{21,13}{1})
                wMU = string(split(T{21,13},[","," "]));
                MU = [MU;wMU];
            end
            if isempty(obj.Pos)
                pos = obj.getPos(T);
            else
                pos = obj.Pos;
            end
            S = string(T{5:16,4:15});
            CL = zeros(128,1);
            for i = 1:length(pos(1,:))
                Index = pos(3,i);
                CL(Index) = double(S(pos(1,i),pos(2,i)));
            end
            % handle SU
            SUf = "";
            try
                CL(double(SU)); %#ok<NOEFF>
                SUf = SU;
            catch
                for i_ = 1:length(SU)
                    if SU(i_) == ""
                        continue
                    end
                    SUf_ = SU(i_);
                    if contains(SUf_,"(")
                        SUf_i = char(SUf_);
                        SUf_i(find(SUf_i=='('):end) = '';
                        SUf_i = string(SUf_i);
                    else
                        SUf_i = SUf_;
                    end
                    if i_ == 1
                        SUf = SUf_i;
                    else
                        SUf = [SUf;SUf_i];
                    end
                end
            end
            fprintf("%d SU: %s\n", obj.Date, join(SU'," "))
            SUf = double(SUf);
            SUf(isnan(SUf)) = [];
            if isempty(SUf)
                fprintf("%d SU: \n", obj.Date)
            else
                fprintf("%d SU: %s\n", obj.Date, join(string(SUf)'," "))
            end
            % handle MU
            MUf = "";
            try
                CL(double(MU)); %#ok<NOEFF>
                MUf = MU;
            catch
                for i_ = 1:length(MU)
                    if MU(i_) == ""
                        continue
                    end
                    MUf_ = MU(i_);
                    if contains(MUf_,"(")
                        MUf_i = char(MUf_);
                        MUf_i(find(MUf_i=='('):end) = '';
                        MUf_i = string(MUf_i);
                    else
                        MUf_i = MUf_;
                    end
                    if i_ == 1
                        MUf = MUf_i;
                    else
                        MUf = [MUf;MUf_i];
                    end
                end
            end
            fprintf("%d MU: %s\n", obj.Date, join(MU'," "))
            MUf = double(MUf);
            MUf(isnan(MUf)) = [];
            if isempty(MUf)
                fprintf("%d SU: \n", obj.Date)
            else
                fprintf("%d MU: %s\n", obj.Date, join(string(MUf)'," "))
            end
        end
    end
end
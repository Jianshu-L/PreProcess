classdef DriverScrews < handle
    
    properties
        index
        Path
        fileNames
        Date
    end
    
    properties(Dependent)
        fileName
    end
    
    methods
        function obj = DriverScrews(Path)
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
                Date_ = repmat(obj.Date,160,1);
                chanNum_ = (1:160)';
                Date = [Date;Date_];
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
                    CL1 = zeros(160,1);
                    CL2 = CL;
                else
                    CL1 = CL;
                    [~,~,CL] = obj.readXLSX;
                    CL2 = CL;
                end
                Screws_ = CL2-CL1;
                Date_ = repmat(obj.Date,160,1);
                chanNum_ = (1:160)';
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
        
        function [SU,MU,CL] = readXLSX(obj)
            T = readtable(strcat(obj.Path,"/",obj.fileName),'ReadVariableNames',false);
            SU = string(split(T{21,13},[","," "]));
            MU = string(split(T{22,13},[","," "]));
            S = string(T{5:18,4:18});
            S = strrep(S," ","+");
            S = strrep(S,"±2","");
            CL = zeros(160,1);
            Index = 160;
            for c = 1:15
                for r = 1:14
                    if S(10,6) == ""
                        S(10,6) = 56;
                    end
                    if S(r,c) ~= ""
                        CL(Index) = eval(S(r,c));
                        Index = Index-1;
                    end
                end
            end
            % handle SU
            SUf = [];
            try
                CL(double(SU)); %#ok<*NOEFF>
                SUf = double(SU);
                SU = SUf;
            catch
                for i_ = 1:length(SU)
                    SUf_ = split(SU(i_),"，");
                    SUf_ = split(SUf_,"&");
                    for SUf__ = SUf_'
                        if contains(SUf__,"(")
                            SUf_i = char(SUf__);
                            SUf_i(find(SUf_i=='('):end) = '';
                            SUf_i = string(SUf_i);
                        else
                            SUf_i = SUf__;
                        end
                        SUf = [SUf;SUf_i]; %#ok<*AGROW>
                    end
                end
                SU = double(SUf);
                SU(isnan(SU)) = [];
            end
            SUp = string(SU);
            if ~isstring(SUf)
                SUf = string(SUf);
            end
            if isempty(SUp)
                SUp = SUf;
            end
            fprintf("%d SU: %s\n", obj.Date, join(SUf'," "))
            fprintf("%d SU: %s\n", obj.Date, join(SUp'," "))
            % handle MU
            MUf = [];
            try
                CL(double(MU));
                MUf = double(MU);
                MU = MUf;
            catch
                for i_ = 1:length(MU)
                    MUf_ = split(MU(i_),"，");
                    MUf_ = split(MUf_,"&");
                    for MUf__ = MUf_'
                        if contains(MUf__,"(")
                            MUf_i = char(MUf__);
                            MUf_i(find(MUf_i=='('):end) = '';
                            MUf_i = string(MUf_i);
                        else
                            MUf_i = MUf__;
                        end
                        MUf = [MUf;MUf_i];
                    end
                end
                MU = double(MUf);
                MU(isnan(MU)) = [];
            end
            MUp = string(MU);
            if ~isstring(MUf)
                MUf = string(MUf);
            end
            if isempty(MUp)
                MUp = MUf;
            end
            fprintf("%d MU: %s\n", obj.Date, join(MUf'," "))
            fprintf("%d MU: %s\n", obj.Date, join(MUp'," "))
            switch obj.Date
                case 20201120
                    MU = [114;115;117;129;132];
                case 20201121
                    MU = [30;114;115;129];
                case 20210101
                    MU = [29;114;133;137];
                case 20201218
                    SU = [100;117;130;132;139];
                case 20201225
                    SU = [70;110;112];
            end
        end
    end
end
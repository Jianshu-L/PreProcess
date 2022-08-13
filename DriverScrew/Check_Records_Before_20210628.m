%% read total screws until 20210628, and check with 20210628 depth
% read 20210628 depth
addpath(genpath("src"))
Path = "data/ScrewsRecord/driver screw";
obj = DriverScrews(Path);
obj.fileNames = obj.fileNames(contains(obj.fileNames,"20210628"));
T = obj.readDepth;
excelDepth = T.Depth(1:142);
obj = DriverScrews(Path);
obj.fileNames = obj.fileNames(1);
T_fs = obj.readDepth;
% total screws
T = readtable("data/ScrewsRecord/driver screw records current big.xlsx",'ReadVariableNames',false);
S = string(T{3:168,2:142});
Index = 1;
screw = [];
row = 166;
for col = 1:141
    if S(row,col) == ""
        continue
    end
    screw(Index) = S(row,col); %#ok<SAGROW>
    Index = Index + 1;
end
Screws = [0;0;0;screw'];
% fix already known bug
excelDepth(114) = excelDepth(114) - 0.5;
Screws(115) = Screws(115) + 0.25;
Screws(117) = Screws(117) - 0.5;
Screws(125) = Screws(125) - 0.5;
Screws(127) = Screws(127) - 0.5;
% compare
depth_628 = Screws + T_fs.Depth(1:142);
bugChan = find(depth_628~=excelDepth);

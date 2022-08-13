%% read total screws until 20210701, and check with 20210701 depth
% read 20210628 depth
addpath(genpath("src"))
Path = "data/ScrewsRecord/patamon screws";
obj = DriverScrewsP(Path);
obj.fileNames = obj.fileNames(contains(obj.fileNames,"20210701"));
T = obj.readDepth;
excelDepth = T.Depth';
% total screws
bigTable = "data/ScrewsRecord/PatamonBig/driver screw records current.xlsx";
T = readtable(bigTable,'ReadVariableNames',false);
S = string(T{3:53,2:129});
Index = 1;
Screws = [];
row = 51;
for col = 1:128
    if S(row,col) == ""
        continue
    end
    Screws(Index) = double(S(row,col)); %#ok<SAGROW>
    Index = Index + 1;
end
% fix already known bug
excelDepth(14) = excelDepth(14) + 0.25;
% compare
depth_701 = Screws;
bugChan = find(depth_701~=excelDepth);

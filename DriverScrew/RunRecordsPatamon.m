%% Read big table
addpath(genpath("src"))
bigTable = "data/ScrewsRecord/PatamonBig/driver screw records current.xlsx";
Tb = readBigTablePatamon(bigTable);
% convert big table to depth and screws
T = Patamon_bigT_to_depth_and_screws(Tb);
%% read records after 20210701
Path = "data/ScrewsRecord/patamon screws";
obj = DriverScrewsP(Path);
index = find(contains(obj.fileNames,"20210701"));
obj.fileNames = obj.fileNames(index+1:end);
T_depth = obj.readDepth;
T_screws = obj.readScrews;
T_last = T(end-128+1:end,:);
Screws = T_screws.Screws;
Screws(1:128) = Screws(1:128) - T_last.Depth;
T_new = T_depth;
T_new.Screws = Screws;
%% combine two table
T = [T;T_new];
writetable(T,sprintf("DriverRecordPatamon-%s.csv",date));
save(sprintf("DriverRecordPatamon-%s.mat",date),"T");
rmpath(genpath("src"))
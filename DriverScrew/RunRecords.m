%% Read big table
addpath(genpath("src"))
Tb = readBigTable("data/ScrewsRecord/driver screw records current big.xlsx");
% fix some bugs of big table
Tb(Tb.Date == 20210617 & Tb.chanNum == 115,3) = {1.25};
Tb(Tb.Date == 20210616 & Tb.chanNum == 117,3) = {1.75};
Tb(Tb.Date == 20210616 & Tb.chanNum == 125,3) = {8};
Tb(Tb.Date == 20210616 & Tb.chanNum == 127,3) = {7.5};
% convert big table to depth and screws
T = bigT_to_depth_and_screws(Tb);
%% read records after 20210628
Path = "data/ScrewsRecord/driver screw";
obj = DriverScrews(Path);
index = find(contains(obj.fileNames,"20210628"));
obj.fileNames = obj.fileNames(index+1:end);
T_depth = obj.readDepth;
T_screws = obj.readScrews;
T_last = T(end-160+1:end,:);
Screws = T_screws.Screws;
Screws(1:160) = Screws(1:160) - T_last.Depth;
T_new = T_depth;
T_new.Screws = Screws;
%% combine two table
T = [T;T_new];
writetable(T,sprintf("DriverRecord-%s.csv",date));
save(sprintf("DriverRecord-%s.mat",date),"T");
rmpath(genpath("src"))
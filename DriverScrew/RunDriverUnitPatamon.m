addpath(genpath("src"))
Path = "data/ScrewsRecord/patamon screws";
obj = DriverScrewsP(Path);
%% Read all driver screw records with SU or MU
T = obj.SUorMU;
save(sprintf("DriverUnitPatamon-%s.mat",date),"T");
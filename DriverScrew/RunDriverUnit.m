addpath(genpath("src"))
Path = "data/ScrewsRecord/driver screw";
obj = DriverScrews(Path);
%% Read all driver screw records with SU or MU
T = obj.SUorMU;
save(sprintf("DriverUnit-%s.mat",date),"T");
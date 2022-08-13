addpath(genpath("src"))
Path = "data/ScrewsRecord/driver screw";
obj = DriverScrews(Path);
obj.fileNames = obj.fileNames(1);
T = obj.readDepth;
save("FirstSpike.mat","T");
rmpath(genpath("src"))
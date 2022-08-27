function wellPath = selectWell(dataPath)
%% path variable
wellPath = strcat(dataPath,"/wellData");
if ~exist(wellPath, "dir")
    mkdir(wellPath)
end
%% Select well data from all behaviour data
% copy well
fprintf("=====copy data=====\n")
obj = BEVdata(dataPath,'mat');
obj.copywell(10,wellPath);
end
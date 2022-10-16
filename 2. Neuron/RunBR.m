function RunBR(BEVpath, BRpath)
%% default input
if nargin == 0
    BEVpath = "../results/data";
    BRpath = "../data";
end
BEVpath = strrep(BEVpath,"\","/");
BRpath = strrep(BRpath,"\","/");
%% translate data
addpath(genpath("src"));
% create diary
diaryName = sprintf("ppBRDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% main
BRreport = translateNEV(BRpath);
rmpath(genpath("src"));
diary off
%% combine data
addpath(genpath("src"));
% create diary
diaryName = sprintf("combineDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% main loop
NEVreport = strings(0);
BRpath = "../results/Neuron";
NEVreport_ = combineData(BEVpath, BRpath);
if isempty(NEVreport)
    NEVreport = NEVreport_;
else
    NEVreport = [NEVreport;NEVreport_];
end
rmpath(genpath("src"));
diary off
end

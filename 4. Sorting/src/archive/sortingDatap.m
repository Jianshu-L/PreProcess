function report = sortingDatap(Monkey, fPath, RPath, archivePath)
dPath = strcat(RPath, "/data/data"); % translate and combine folder
Path = strcat(RPath, "/sorting");
FeaturesPath = strcat(RPath, "/features/data"); % features folder
savePath =  "/media/pacman/DataBackup/Sorting/test";
report = [];
%% sorting all files
obj = Br2Fr(Monkey, dPath ,fPath, savePath, archivePath);
% create diary
diaryName = sprintf("sortingDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% sorting main loop
fprintf("=====sorting NS6=====\n")
% for i = 1:length(obj.nsF.dDate)
obj.index = 3;
[PRM,csvNames,Channel_,folderName] = ppS(obj);
parfor i_ = 1:length(PRM)
    doKlustap(PRM,obj,folderName, Channel_, csvNames, i_)
end
%     t1 = GetSecs();
%     obj.archiveDat;
%     t2 = GetSecs();
%     Artime = t2 - t1;
%     fprintf("open one day NS6 cost %.2f hours\n", NS6time/3600);
%     fprintf("archive cost %.2f minutes\n", Artime/60);
% end
%% selecting valid channels
% create diary
diaryName = sprintf("selectingDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% selecting main loop
fprintf("=====selecting NS6=====\n")
for i = 1:length(obj.nsF.dDate)
    obj.index = i;
    % calculate LeastFiringCount
    MetaTags = obj.loadTags;
    obj.timeLength = MetaTags.DataPoints/30000/3600;
    LeastFiringCount = 20000;
    % select well channels
    [validChan, Tall, fr, frName] = obj.selectWell(LeastFiringCount); %#ok<ASGLU>
    if ~exist(strcat("Neuron/",fr),"dir")
        mkdir(strcat("Neuron/",fr))
    end
    fprintf("saving %s\n", frName)
    report = obj.report;
    save(strcat("Neuron/",fr,"/", fr,"Report.mat"), "report")
    save(strcat("Neuron/",fr,"/", fr, "ST-valid.mat"), "validChan");
    save(strcat("Neuron/",fr,"/", frName), "Tall");
    writetable(Tall, strrep(strcat("Neuron/",fr,"/", frName), "mat", "csv"))
    copyfile(strrep(strcat("Neuron/",fr,"/", frName), "mat", "csv"), strcat(FeaturesPath,"/spikes"));
end
fprintf("===== END =====\n")
diary off
end

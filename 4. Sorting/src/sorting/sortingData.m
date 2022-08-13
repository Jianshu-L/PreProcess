function sortingData(Monkey, dPath, fPath, savePath, archivePath)
%% sorting all files
obj = Br2Fr(Monkey, dPath ,fPath, savePath, archivePath);
% create diary
diaryName = sprintf("sortingDiary-%s", date);
eval(sprintf("diary %s",diaryName));
diary on
% sorting main loop
for i = 1:length(obj.nsF.dDate)
    obj.index = i;
    try
        [Sort,~] = checkProgress(obj);
        if Sort
            fprintf("=====sorting NS6=====\n")
            t1 = GetSecs();
            [csvNames, PRM, Channel] = obj.readingNS6;
            parfor i_ = 1:length(PRM)
                doKlusta(obj, obj.datFolder, csvNames, PRM, Channel, i_)
            end
            t2 = GetSecs();
            NS6time = t2 - t1;
            fprintf("open one day NS6 cost %.2f hours\n", NS6time/3600);
            obj.deleteDat;
            %             fprintf("archive dat %s\n", obj.folder)
            %             t1 = GetSecs();
            %             obj.archiveDat;
            %             t2 = GetSecs();
            %             Artime = t2 - t1;
            %             fprintf("archive cost %.2f minutes\n", Artime/60);
        end
        %         if Archive
        %             fprintf("=====archive dat %s=====\n", obj.folder)
        %             t1 = GetSecs();
        %             obj.archiveDat;
        %             t2 = GetSecs();
        %             Artime = t2 - t1;
        %             fprintf("archive cost %.2f minutes\n", Artime/60);
        %         end
    catch ME
        fprintf("*******%s*******\n",ME.message)
    end
end
end

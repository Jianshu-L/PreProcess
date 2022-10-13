function toCSV(dataPath, savePath)
%% init variables
if ~exist(savePath, "dir")
    mkdir(savePath)
end
obj = ListData(dataPath, 'mat');
files = obj.file;
fileNames = strcat(obj.path,"/", obj.file);
csvNames = strcat(savePath, "/", obj.file);
%% main loop
fprintf("=====save as csv for python=====\n")
parfor i = 1:length(fileNames)
    file_name = files(i);
    file_i = fileNames(i);
    csv_i = csvNames(i);
%     if exist(strrep(csv_i,'mat', 'csv'),"file") && exist(strrep(csv_i,'.mat', '-R.csv'),"file")
%         continue
%     end
    try
        data = readFiles(file_i,file_name);
        % save as csv
        writetable(data, strrep(csv_i,'.mat', '.csv'))
    catch ME
        fprintf("*******%s*******\n",ME.message)
    end
end
end

function data = readFiles(file_i,file_name)
    load(file_i, "data");
    data.file_name = repmat(replace(file_name,".mat",""),height(data),1);
%     [dotsX, dotsY] = find(char(data.Map)' == '.');
%     dotsList = cell(height(data),1);
%     dotsList(unique(dotsY)) = splitapply(@(x1){double(x1)},dotsX,findgroups(dotsY));
%     data.beans = dotsList;
%     [dotsX, dotsY] = find(char(data.Map)' == 'o');
%     dotsList = cell(height(data),1);
%     dotsList(unique(dotsY)) = splitapply(@(x1){double(x1)},dotsX,findgroups(dotsY));
%     data.energizers = dotsList;
    %% fix [14,20] & [15,20] bug
    g1 = data.ghost1(:,1:2);
    g2 = data.ghost2(:,1:2);
    data.ghost1(sum(g1 == [14,20],2) == 2,2) = 19;
    data.ghost2(sum(g2 == [14,20],2) == 2,2) = 19;
    g1 = data.ghost1(:,1:2);
    g2 = data.ghost2(:,1:2);
    data.ghost1(sum(g1 == [15,20],2) == 2,2) = 19;
    data.ghost2(sum(g2 == [15,20],2) == 2,2) = 19;
end
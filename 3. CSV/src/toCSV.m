function toCSV(dataPath, savePath)
%% init variables
if ~exist(savePath, "dir")
    mkdir(savePath)
end
obj = ListData(dataPath, 'mat');
fileNames = strcat(obj.path,"/", obj.file);
csvNames = strcat(savePath, "/", obj.file);
%% main loop
fprintf("=====save as csv for python=====\n")
parfor i = 1:length(fileNames)
    file_i = fileNames(i);
    csv_i = csvNames(i);
%     if exist(strrep(csv_i,'mat', 'csv'),"file") && exist(strrep(csv_i,'.mat', '-R.csv'),"file")
%         continue
%     end
    try
        [data,rewP] = readFiles(file_i);
        Map = table(data.Map);
        writetable(Map,strrep(csv_i,".mat","-M.csv"));
        writetable(data, strrep(csv_i,'.mat', '.csv'))
        writetable(rewP, strrep(csv_i,'.mat', '-R.csv'))
    catch ME
        fprintf("*******%s*******\n",ME.message)
    end
end
end

function [data,rewP] = readFiles(file_i)
load(file_i, "data");
[data,rewP] = Mat2Csv(data); %#ok<NODEF>
end
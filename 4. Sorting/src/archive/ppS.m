function [PRM,csvNames,Channel_,folderName] = ppS(obj)
dirExist = checkExist(obj, "csv");
Channels_ = obj.Channels(~dirExist);
if isempty(Channels_)
    dirExist = obj.checkExist("archive");
    if dirExist
        csvNames = [];
    else
        csvNames = dirFiles(obj.datFolder,"csv");
    end
    return
end
fileName = obj.fileNames;
folderName = obj.datFolder;
if ~exist(folderName,"dir")
    mkdir(folderName)
end
if ~isempty(Channels_)
    fprintf("====================\n")
    fprintf("%s\n",obj.folder)
    dirExist = checkExist(obj, "csv");
    if sum(dirExist) == 0
        fprintf("saving\n")
        obj.brTodat(fileName, folderName, Channels_);
    end
    fprintf("sorting\n")
    [PRM, csvNames] = createPRM(folderName);
    Channel_ = dirFolders(folderName);
else
    csvNames = [];
    return
end
end

function [PRM, csvNames] = createPRM(folder)
csvNames = strcat(folder,"/klusta-",dirFolders(folder),".csv");
allData = strcat(folder, "/", dirFolders(folder));
Str = fileread('1_Omega.prm');
PRM = repmat("", 1,length(allData));
% DatFiles = repmat("", 1,length(allData));
for index = 1:length(allData)
    fileName = dir(strcat(allData(index),"/*.dat"));
    filename = string(fileName.name);
    fileName = strcat(allData(index), "/", filename);
    % index = 1;
    prmName = strrep(fileName,'.dat', '.prm');
    datName = strrep(fileName, '.dat', '');
    PRM(index) = prmName;
    %     DatFiles(index) = strrep(fileName, '.dat', '.kwik');
    fid = fopen(prmName, 'w');
    fprintf(fid,'experiment_name = "%s"\n',datName);
    fwrite(fid, Str, 'char');
    fclose(fid);
end
end

function fileNames = dirFolders(Path)
fileNames = dir(Path);
if isempty(fileNames)
    fileNames = [];
    return
end
dirPath = struct2table(fileNames);
dirPath = dirPath(~(dirPath.name == "." | dirPath.name == ".."),:);
index = dirPath.isdir;
fileNames = string(dirPath.name);
fileNames = fileNames(index);
end

function fileNames = dirFiles(Path, type)
Path = strcat(Path, "/*.", type);
fileNames = dir(Path);
temp = struct2table(fileNames);
index = temp.isdir;
fileNames = string(temp.name);
fileNames = fileNames(~index);
end
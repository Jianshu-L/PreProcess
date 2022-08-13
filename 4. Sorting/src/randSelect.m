function folder_names = randSelect(Path)
if nargin == 0
    Path = "~/pacman/preProcess/sorting/debug/data/archive";
end
folderNames = dirFolders(Path);
folderNames = strrep(folderNames,"o","");
folderNames = double(folderNames);
L1_folder = folderNames(folderNames<20210201);
L1_folder = L1_folder([1,randperm(length(L1_folder),4)]);
L2_folder = folderNames(folderNames>=20210201 & folderNames<=20211101);
L2_folder = L2_folder(randperm(length(L2_folder),5));
L3_folder = folderNames(folderNames>20211101);
L3_folder = L3_folder(randperm(length(L3_folder),5));
folder_names = sort([L1_folder;L2_folder;L3_folder]);
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
% 
% for i = 1:15
%     copyfile(strcat("~/pacman/preProcess/sorting/debug/data/archive/",string(folder_names(i)),"o"),strcat(Path,"/",string(folder_names(i)),"o"));
% end
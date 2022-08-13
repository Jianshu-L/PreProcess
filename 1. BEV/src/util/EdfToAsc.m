function EdfToAsc(path)
if ~exist("path", "var")
    path = "/home/pacman/code20170121/Patamon";
end
path = strrep(path,"\","/");
folders = struct2table(dir(path));
folders = string(folders.name(3:end));
path_ = path;
files = struct2table(dir("*.asc"));
files = string(files.name);
parfor i = 1:length(folders)
    path = strcat(path_, '/', folders(i));
    file = dir(strcat(path, "/*.edf"));
    File = split(path, '/');
    file_ = strcat(path, "/", file.name);
    File_ = strcat(File(end), '.edf');
    if isempty(file) || sum(contains(files, strrep(File_, "edf", "asc")))
%         fprintf("pass %s\n", folders(i))
        continue
    end
    [status,msg] = copyfile(file_, File_);  
    if ~status
        fprintf("%s\n",msg)
    end
%     system(sprintf("edf2asc %s", File_));
end

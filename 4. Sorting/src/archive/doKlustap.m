function doKlustap(PRM,obj,folderName, Channel_, csvNames, i)

prmname = PRM(i);
if ~exist(csvNames(i),"file")
    fprintf("sorting %s\n", prmname)
    [status,cmdout] = unix(sprintf("klusta %s --overwrite --output-dir ./", prmname));
    if status
        error(cmdout)
    end
end
obj.kwik2csv(folderName, Channel_(i), csvNames(i));
end
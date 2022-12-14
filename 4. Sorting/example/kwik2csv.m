function kwik2csv(Path,chan,csvName)
file = dir(strcat(Path, "/", chan, "/*.kwik"));
file = strcat(file.folder, "/", file.name);
try
    time_samples = hdf5read(file, '/channel_groups/0/spikes/time_samples'); %#ok<HDFR>
    cluster_number = hdf5read(file, '/channel_groups/0/spikes/clusters/main'); %#ok<HDFR>
catch
    time_samples = [];
    cluster_number = [];
end
T = table(time_samples,cluster_number);
writetable(T, csvName);
end
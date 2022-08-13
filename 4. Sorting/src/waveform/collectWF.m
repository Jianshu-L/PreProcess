function collectWF(csvName,savePath,T)
temp = split(csvName,"-");
Results = [];
for chan = unique(T.Channel)'
    fileName = strcat(temp(1),"-",string(chan));
    T_ = T(T.Channel == chan,:);
    fileNames = repmat(fileName,length(unique(T_.cluster_number)),1);
    cluster_id = unique(T_.cluster_number);
    Blank = zeros(length(cluster_id),1);
    load(sprintf('%s/wf_%d.mat',savePath,chan),"wfM");
    waveform = num2cell(wfM,2);
    Result = table(fileNames,cluster_id,Blank,waveform);
    Results = [Results;Result]; %#ok<AGROW>
end
save("waveform.mat","Results");
end
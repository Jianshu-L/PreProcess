function spike_train = getSTfromMat(T, channel)
T_ = T(T.Channel == channel,:);
spike_train = {};
k = 1;
for i = unique(T_.cluster_number)'
    spike_train{k} = T_.time_samples(T_.cluster_number == i); %#ok<AGROW>
    k = k + 1;
end
end
function plot_ACG(savePath, T)
chanNum = unique(T.Channel);
parfor i = 1:length(chanNum)
    main_plot(savePath,T,i,chanNum);
end
end

function main_plot(savePath,T,i,chanNum)
chanNum_ = chanNum(i);
T_ = T(T.Channel == chanNum_,:);
Num = unique(T_.cluster_number);
spike_train = getSTfromMat(T, chanNum_);
% plot
for i = 1:length(spike_train)
    figure('visible','off');
    st = transST(spike_train{i});
    [c,lags] = xcorr(st,50,'coeff');
    c(51) = 0;
    stem(lags,c,'Marker','none','DisplayName',sprintf("cluster: %d", Num(i)));
    legend
    title(sprintf("channel: %d",chanNum_))
    saveas(gcf,sprintf('%s/PNG/Ch%d_%d_ACG.png',savePath,chanNum_,Num(i)))
end
end

function st = transST(spike_train)
spike_train = floor(spike_train/(30000/1000)); % 1ms
st = zeros(max(spike_train)-min(spike_train)+1,1);
st(spike_train-min(spike_train)+1) = 1;
end
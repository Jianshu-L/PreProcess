function plot_ISI(savePath,T)
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
    ISI = diff(spike_train{i});
    binWidth = 30;
    figure('visible','off');
%     figure;
    ISI_SU = ISI(ISI < 10000);
    h = histogram(ISI_SU,'binWidth',binWidth,'DisplayName',sprintf("cluster: %d", Num(i)));
    legend;
    title(sprintf("channel: %d",chanNum_))
    saveas(gcf,sprintf('%s/PNG/Ch%d_%d_ISI.png',savePath,chanNum_,Num(i)))
end
end
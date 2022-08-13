function plot_wf(ns6Names, savePath, T)
%% init variables
if ~exist(savePath, "dir")
    mkdir(savePath);
end
if ~exist(strcat(savePath,"/PNG"), "dir")
    mkdir(strcat(savePath,"/PNG"));
end
clear NS6
Done = 0;
%% main loop
for chan = 1:160
    if mod(chan,32) == 1
        % open ns6
        clear datIall
        for fi = 1:length(ns6Names)
            fprintf("open %s: %d:%d\n",ns6Names(fi),chan,chan+31)
            openNSx(char(ns6Names(fi)),'uv',char(sprintf('c:%d:%d',chan,chan+31)))
            if fi == 1
                datIall = int16(NS6.Data);
            else
                datIall = [datIall,int16(NS6.Data)]; %#ok<AGROW>
            end
        end
        clear NS6
        Done = Done+1;
    end
    datI = datIall(chan-32*(Done-1),:);
    if ~any(chan == unique(T.Channel))
        continue
    end
    fprintf("%d,%d\n",chan,chan-32*(Done-1));
    fprintf("dataIall length: %d\n", length(datIall(:,1)));
    % get waveform of every cluster
    T_ = T(T.Channel == chan,:);
    j = 0;
    wfM = zeros(length(unique(T_.cluster_number)),48);
    Num = zeros(1,length(unique(T_.cluster_number)));
    for num = unique(T_.cluster_number)'
        j = j+1;
        spikesT = T_.time_samples(T_.cluster_number == num);
        waveform = zeros(length(spikesT),48);
        parfor i = 1:length(spikesT)
            waveform(i,:) = getWF(spikesT, datI, i)
        end
        wfM(j,:) = mean(waveform,1);
        Num(j) = num;
    end
    save(sprintf("%s/wf_%d.mat",savePath,chan),"wfM");
    % save png
    if isempty(min(wfM(wfM<0)))
        lb = 20;
    else
        lb = min(wfM(wfM<0))-20;
    end
    if isempty(max(wfM(wfM>0)))
        hb = 20;
    else
        hb = max(wfM(wfM>0))+20;
    end
    figure('visible','off');
    for i = 1:length(Num)
        wfM_ = wfM(i,:);
        plot(wfM_,'DisplayName',sprintf("cluster: %d", Num(i)))
        hold on
        axis([0,48,lb,hb])
    end
    legend
    title(sprintf("channel: %d",chan))
    saveas(gcf,sprintf('%s/PNG/Ch%d.png',savePath,chan))
end
end

function waveform = getWF(spikesT, datI, i)
waveform = datI(spikesT(i)-16:spikesT(i)+31);
end

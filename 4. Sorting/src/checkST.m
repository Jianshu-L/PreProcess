function [Per,pass] = checkST(spike_train)
pass = 1;
ISI = diff(spike_train);
ISI_SU = ISI(ISI < 30000);
% h = histogram(ISI_SU,'binWidth',30);
hValues = histcounts(ISI_SU,'binWidth',30);
% check mid-frequence noise
x = floor(length(hValues)/2);
[~,I] = max(hValues);
if I > x
    Per = -1;
    pass = 0;
    return
end
hDiff = hValues(I:x)-hValues(I+1:x+1);
dayu = find(hDiff>0);
xiaoyu = find(hDiff<0);
xyDiff = xiaoyu(2:end)-xiaoyu(1:end-1);
dyDiff = dayu(2:end)-dayu(1:end-1);
Per = (sum(xyDiff == 2) + sum(dyDiff == 2))/(length(xyDiff)+length(dyDiff));
if Per > 0.8
    pass = 0;
end
% % check refractory period
% RefractoryPeriod = 30000/1000*9;%9ms
% RPall = sum(ISI <= RefractoryPeriod)/length(spike_train);
% st = transST(spike_train);
% [c,lags] = xcorr(st,50,'coeff');
% c(51) = 0;
% stem(lags,c,'Marker','none');
function [pass,Per] = checkISI(ISI)
h = plotISI(ISI);
hValues = h.Values;
x = floor(length(hValues)/2);
[~,I] = max(hValues);
if I > 10
    pass = 0;
    Per = -1;
    return
end
hDiff = hValues(I:x)-hValues(I+1:x+1);
dayu = find(hDiff>0);
xiaoyu = find(hDiff<0);
xyDiff = xiaoyu(2:end)-xiaoyu(1:end-1);
dyDiff = dayu(2:end)-dayu(1:end-1);
Per = (sum(xyDiff == 2) + sum(dyDiff == 2))/(length(xyDiff)+length(dyDiff));
if Per > 0.8
    % mid-frequence noise
    pass = 0;
    return
end
pass = 1;
end
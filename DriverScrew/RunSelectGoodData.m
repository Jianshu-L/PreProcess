addpath(genpath("src"))
load("results/DriverUnit.mat","T");
Date = zeros(height(T),1);
for i = 1:height(T)
    T_ = T(i,:);
    if length(T_.SU{1}) >= 8 && (length(T_.SU{1})+length(T_.MU{1})) >= 20
        Date(i) = T_.Date;
    end
end
Date(Date == 0) = [];
T = table(Date);
writetable(T,sprintf("GoodDate-%s.csv",date));
function results = bigT_to_depth_and_screws(Tb)
Path = "data/ScrewsRecord/driver screw";
obj = DriverScrews(Path);
load("results/FirstSpike.mat","T");
first_spike = T; 
date_ = first_spike.Date;
chanNum_ = first_spike.chanNum;
chanNum_i = chanNum_;
screw_ = first_spike.Depth;
depth_ = screw_;
depth_i = depth_;
loop = obj.getDate;
date_loop = loop(2:find(loop == 20210628))';
for date_i = date_loop
    T_i = Tb(Tb.Date==date_i,:);
    screw_i = zeros(160,1);
    if isempty(T_i)
        date_ = [date_;repmat(date_i,160,1)]; %#ok<*AGROW>
        chanNum_ = [chanNum_;chanNum_i];
        screw_ = [screw_;screw_i];
        depth_ = [depth_;depth_i];
    else
        date_ = [date_;repmat(date_i,160,1)];
        chanNum_ = [chanNum_;chanNum_i];
        screw_i(T_i.chanNum) = T_i.Screws;
        screw_ = [screw_;screw_i];
        fprintf("%s screws %s\n", ...
            join(string(T_i.chanNum')," "), num2str(T_i.Screws','%.2f '))
        depth_i = depth_i + screw_i;
        depth_ = [depth_;depth_i];
    end
end
Date = date_;
chanNum = chanNum_;
Depth = depth_;
Screws = screw_;
results = table(Date,chanNum,Depth,Screws);
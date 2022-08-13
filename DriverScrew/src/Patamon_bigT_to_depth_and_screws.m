function results = Patamon_bigT_to_depth_and_screws(Tb)
Path = "data/ScrewsRecord/patamon screws";
% create loop
obj = DriverScrewsP(Path);
loop = obj.getDate;
date_loop = loop(1:find(loop == 20210701))';
date_ = [];
chanNum_ = [];
screw_ = [];
depth_ = [];
chanNum_i = (1:128)';
depth_i = zeros(128,1);
for date_i = date_loop
    T_i = Tb(Tb.Date==date_i,:);
    screw_i = zeros(128,1);
    if isempty(T_i)
        date_ = [date_;repmat(date_i,128,1)]; %#ok<*AGROW>
        chanNum_ = [chanNum_;chanNum_i];
        screw_ = [screw_;screw_i];
        depth_ = [depth_;depth_i];
    else
        date_ = [date_;repmat(date_i,128,1)];
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
end
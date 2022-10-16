function map_info = map_data(map)
% map = unique(data.Map);
% map = map(~contains(map,"."));
mapCol = 28; % xrange
mapRow = 36; % yrange
map = reshape(char(map),mapCol,mapRow)';
xrange = length(map(1,:));
yrange = length(map(:,1));
% 从墙开始计算，方便计算转移概率矩阵
map_info = zeros(xrange*yrange,12);

%% index all the path and wall
ct = 1;
for i = 1:xrange
    for j = 1:yrange
        map_info(ct,1) = i;
        map_info(ct,2) = j;
        if map(j,i) ~= ' '
            map_info(ct,3) = 1;
        else
            map_info(ct,3) = 0;
        end
        ct = ct+1;
    end
end

for ct = find(map_info(:,3) == 0)'
    x = map_info(ct,1);
    y = map_info(ct,2);
    counter = 0;
    %% handle tunnel situation
    if any(x == [1,mapCol]) && y == 18
        % left
        map_info(ct,9) = x-1;
        map_info(ct,10) = y;
        % right
        map_info(ct,11) = x+1;
        map_info(ct,12) = y;
        counter = 2;
        map_info(ct,4) = counter;
        continue
    end
    %% normal
    if map(y-1,x) == ' '	%up
        map_info(ct,5) = x;
        map_info(ct,6) = y-1;
        counter = counter + 1;
    end
    if map(y+1,x) == ' '	%down
        map_info(ct,7) = x;
        map_info(ct,8) = y+1;
        counter = counter + 1;
    end
    if map(y,x-1) == ' '	%left
        map_info(ct,9) = x-1;
        map_info(ct,10) = y;
        counter = counter + 1;
    end
    if map(y,x+1) == ' '	%right
        map_info(ct,11) = x+1;
        map_info(ct,12) = y;
        counter = counter + 1;
    end
    map_info(ct,4) = counter;
end
%% handle tunnel situation
map_info(end+1,:) = [0,18,0,2,0,0,0,0,-1,18,1,18];
map_info(end+1,:) = [-1,18,0,2,0,0,0,0,30,18,0,18];
map_info(end+1,:) = [29,18,0,2,0,0,0,0,28,18,30,18];
map_info(end+1,:) = [30,18,0,2,0,0,0,0,29,18,-1,18];
end
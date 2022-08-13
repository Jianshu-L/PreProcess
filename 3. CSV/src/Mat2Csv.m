function [data,rewP] = Mat2Csv(data)
%% fix [14,20] & [15,20] bug
g1 = data.ghost1(:,1:2);
g2 = data.ghost2(:,1:2);
data.ghost1(sum(g1 == [14,20],2) == 2,2) = 19;
data.ghost2(sum(g2 == [14,20],2) == 2,2) = 19;
g1 = data.ghost1(:,1:2);
g2 = data.ghost2(:,1:2);
data.ghost1(sum(g1 == [15,20],2) == 2,2) = 19;
data.ghost2(sum(g2 == [15,20],2) == 2,2) = 19;
%%
rewP = rewardPosition(data,unique(data.DayTrial));
end

function rewP = rewardPosition(data,fileName)
%% order fileName
char_i = split(fileName,{'-','.'},2);
char_num = str2double(char_i(:,1:2));
char_trial = char_num(:,1) * 1000 + char_num(:,2);
[~, I] = sortrows(char_trial); % sort files by current_round and used_trial
fileName = fileName(I);
rewP = [];
for i = 1:length(fileName)
    data_ = data(data.DayTrial == fileName(i), :);
    if contains(char(data_.Map(end)), '.') || contains(char(data_.Map(end)), 'o')
        ts = 1:size(data_,1);
    else
        ts = 1:(size(data_,1)-1);
    end
    Map_ = char(data_.Map)';
    %% Get reward position
    % dotsX is the position of all dots in dotsY data
    [dotsX, dotsY] = find(Map_ == '.');
    dots_p = [positionTile_dots(dotsX),dotsY];
    % eners position
    [enersX, enersY] = find(Map_ == 'o');
    eners_p = [positionTile_dots(enersX),enersY];
    % fruits position and type
    fruits = ['A' ; 'O' ; 'M' ; 'C' ; 'S'];
    [pos,type] = ismember(Map_,fruits);
    [fruitsX,fruitsY] = find(pos);
    [~,~,typeIndex] = find(type);
    fruits_p = [positionTile_dots(fruitsX),fruitsY];
    fruitT = fruits(unique(typeIndex));
    %% create Table
    [X,Y,Reward,Step] = CreateTable(ts, dots_p, eners_p, fruits_p, fruitT);
    DayTrial = repmat(fileName(i), length(Step), 1);
    if isempty(rewP)
        rewP = table(X, Y, Reward, DayTrial, Step);
    else
        rewP = [rewP;table(X, Y, Reward, DayTrial, Step)]; %#ok<AGROW>
    end
end
end

function dots_p = positionTile_dots(index)
pos_x= rem(index,28);
pos_y = fix(index/28)+1;
fix_p = find(pos_x == 0);
if any(pos_x == 0)
    pos_x(fix_p) = 28;
    pos_y(fix_p) = fix(index(fix_p)/28);
end
dots_p = [];
dots_p(:,1) = pos_x;
dots_p(:,2) = pos_y;
end

function [X,Y,Reward,Step] = CreateTable(ts, dots_p, eners_p, fruits_p, fruitT)
%% init vars
X = zeros(69*length(ts),1);
Y = zeros(69*length(ts),1);
Reward = zeros(69*length(ts),1);
Step = zeros(69*length(ts),1);
j = 1; % the position in the table
%% find the index of first dot in every timestep
cout = conv(dots_p(:,3),[1,-1]);
index = find(cout == 1);
if isempty(eners_p)
    Length = dots_p(max(index),3);
    
else
    Length = max(dots_p(max(index),3), eners_p(end,3));
end
if  Length ~= length(ts)
    error("length is not equal")
end
for i = 1:length(index)
    %% the position and reward value of every rewards.
    % dots
    if i ~= length(index)
        dots = dots_p(index(i):(index(i+1)-1),1:2);
    else
        dots = dots_p(index(i):end,1:2);
    end
    dotsI = ones(1,length(dots(:,2)))';
    % eners
    eners = eners_p(eners_p(:,3) == i,1:2);
    enersI = ones(1,length(eners(:,2)))' * 2;
    % fruits
    fruits = fruits_p(fruits_p(:,3) == i,1:2);
    switch fruitT
        case 'C'
            fruitsI = ones(1,length(fruits(:,2)))' * 3;
        case 'S'
            fruitsI = ones(1,length(fruits(:,2)))' * 4;
        case 'O'
            fruitsI = ones(1,length(fruits(:,2)))' * 5;
        case 'A'
            fruitsI = ones(1,length(fruits(:,2)))' * 6;
        case 'M'
            fruitsI = ones(1,length(fruits(:,2)))' * 7;
        otherwise
            fruitsI = ones(1,length(fruits(:,2)))' * -1;
    end
    x = [dots(:,1);eners(:,1);fruits(:,1)];
    y = [dots(:,2);eners(:,2);fruits(:,2)];
    reward = [dotsI;enersI;fruitsI];
    step = repmat(i, length(x), 1);
    X(j:length(x)+j-1,1) = x;
    Y(j:length(x)+j-1,1) = y;
    Reward(j:length(x)+j-1,1) = reward;
    Step(j:length(x)+j-1,1) = step;
    j = length(x)+j;
end
X(X == 0) = [];
Y(Y == 0) = [];
Reward(Reward == 0) = [];
Step(Step == 0) = [];
end
function result = readBigTable(csvFile)
T = readtable(csvFile,'ReadVariableNames',false);
S = string(T{3:168,2:142});
Index = 1;
Date = [];
chanNum = [];
Screw = [];
for row = 1:165
    for col = 1:141
        if S(row,col) == "" || S(row,col) == 'L'
            continue
        end
        Screw(Index) = S(row,col); %#ok<*AGROW>
        Date(Index) = double(string(T{row+2,1}));
        chanNum(Index) = double(string(T{1,col+1}));
        Index = Index + 1;
    end
end
Date = Date';
chanNum = chanNum';
Screws = Screw';
result = table(Date,chanNum,Screws);
end
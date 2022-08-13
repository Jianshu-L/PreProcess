function result = readBigTablePatamon(csvFile)
T = readtable(csvFile,'ReadVariableNames',false);
S = string(T{3:53,2:129});
Index = 1;
Date = [];
chanNum = [];
Screws = [];
for row = 1:50
    for col = 1:128
        if S(row,col) == ""
            continue
        end
        Screws(Index) = double(S(row,col)); %#ok<*AGROW>
        Date(Index) = double(string(T{row+2,1}));
        chanNum(Index) = double(string(T{1,col+1}));
        Index = Index + 1;
    end
end
Date = Date';
chanNum = chanNum';
Screws = Screws';
result = table(Date,chanNum,Screws);
end
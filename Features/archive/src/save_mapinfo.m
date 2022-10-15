function T = save_mapinfo(map_info)
output = {'Pos1' 'Pos2' 'iswall' 'NextNum' 'UpX' 'UpY' 'DownX' 'DownY' ...
    'LeftX' 'LeftY' 'RightX' 'RightY'}';
T= cell2table(num2cell(map_info),'VariableNames',output);
writetable(T, "map_info.csv");
end
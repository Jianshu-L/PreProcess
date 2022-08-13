function [fName,dDate] = FtoN(dName)
% data folder to neuron marker data name
% Arg:
%   dName: data folder name. "omegaL-11-Mar-2021-1" 
% Out:
%   fName: neuron name. "datafile20210311"
%   dDate: date time. "20210226"


name = split(dName, '-');
if length(name(1,:)) == 1
    name = name';
end
dt = datetime(join(name(:,2:4), '-'), 'InputFormat', 'dd-MMM-yyyy', ...
    'Locale','en_US', 'Format', 'yyyyMMdd');
dDate = unique(dt);
fName = strcat('datafile', string(dDate));
end
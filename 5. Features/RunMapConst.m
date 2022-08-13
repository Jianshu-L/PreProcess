addpath(genpath("src"));
map = [ ...
    '____________________________' ...
    '____________________________' ...
    '____________________________' ...
    '||||||||||||||||||||||||||||' ...
    '|            ||            |' ...
    '| |||| ||||| || ||||| |||| |' ...
    '| |||| ||||| || ||||| |||| |' ...
    '| |||| ||||| || ||||| |||| |' ...
    '|                          |' ...
    '| |||| || |||||||| || |||| |' ...
    '| |||| || |||||||| || |||| |' ...
    '|      ||    ||    ||      |' ...
    '|||||| ||||| || ||||| ||||||' ...
    '_____| ||||| || ||||| |_____' ...
    '_____| ||          || |_____' ...
    '_____| || |||  ||| || |_____' ...
    '|||||| || |      | || ||||||' ...
    '          |      |          ' ...
    '|||||| || |      | || ||||||' ...
    '_____| || |||||||| || |_____' ...
    '_____| ||          || |_____' ...
    '_____| || |||||||| || |_____' ...
    '|||||| || |||||||| || ||||||' ...
    '|            ||            |' ...
    '| |||| ||||| || ||||| |||| |' ...
    '| |||| ||||| || ||||| |||| |' ...
    '| ||||                |||| |' ...
    '| |||| || |||||||| || |||| |' ...
    '| |||| || |||||||| || |||| |' ...
    '|      ||    ||    ||      |' ...
    '| |||||||||| || |||||||||| |' ...
    '| |||||||||| || |||||||||| |' ...
    '|                          |' ...
    '||||||||||||||||||||||||||||' ...
    '____________________________' ...
    '____________________________'];
map_info = map_data(map);
T = save_mapinfo(map_info);
rmpath(genpath("src"));

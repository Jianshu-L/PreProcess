
# Code description
## RunMapConst.m:
* Output is map_info.csv

## create_adjacent_map.py
* Input:  "results/constants/map_info.csv"
* Output: "adjacent_map.pickle".

## create_dij_distance_map.py
* Input:  "results/constants/adjacent_map.pickle
* Output: "dij_distance_map.pickle"

## extract_behaviour_features.py
* Input: "results/constants/adjacent_map.pickle", "results/constants/dij_distance_map.pickle" and behaviour data "data/Omega" or "data/Patamon"
* Output: features data 

**caution**: the Map in pickle data should be equal to the "map" in RunMapConst.m

# Data description
default value: inf_val = 100

[2] **PG_normal_(left/right/up/down)**: Pacman四个相邻位置和normal ghost之间的最近距离。若某个相邻位置不存在或者normal ghost不存在，则距离为inf_val。

[3] **PG_scared_(left/right/up/down)**: Pacman四个相邻位置和scared ghost之间的最近距离。若某个相邻位置不存在或者normal ghost不存在，则距离为inf_val。

[4] **PG1_(left/right/up/down)**: Pacman四个相邻位置和Blinky之间的距离。若某个相邻位置不存在，则距离为inf_val。

[5] **PG2_(left/right/up/down)**: Pacman四个相邻位置和Clyde之间的距离。若某个相邻位置不存在，则距离为inf_val。

[6] **PE_(left/right/up/down)**: Pacman四个相邻位置和energizer之间的最近距离。若某个相邻位置不存在或没有energizer，则距离为inf_val。

[7] **PF_(left/right/up/down)**: Pacman四个相邻位置和fruit之间的最近距离。若某个相邻位置不存在或没有fruit，则距离为inf_val。

[8] **beans_(left/right/up/down)**: Pacman四个相邻位置10步之内的豆子数量。

[9] **beans_within_10**: Pacman10步之内的豆子数量。

[10] **beans_between_5and10**: Pacman附近5~10步之内的豆子数量。

[11] **beans_beyond_10**: Pacman10步之外的豆子数量。

[12] **beans_num**: 盘面剩余的豆子数量。

[13] **beans_diff**: 重生位置10步以内的豆子数减去Pacman当前位置10步之内的豆子数。

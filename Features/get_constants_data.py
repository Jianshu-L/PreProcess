from create_constant import create_map_info, create_adjacent_map, create_dij_istance_map

with open("map.txt", "r") as file:
    Map = file.read().replace("\n","")
map_info = create_map_info(Map)
map_info.to_csv("map_info.csv")
# create adjacent_map
T = create_adjacent_map(map_info)
T.to_csv("adjacent_map.csv")
df = create_dij_istance_map(T)
df.to_csv("dij_distance_map.csv")
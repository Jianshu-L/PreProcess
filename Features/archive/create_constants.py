import pandas as pd
import numpy as np
import networkx as nx

def get_relative_dir(pos_1,pos_2):
    res = tuple(map(lambda i, j: j - i, pos_1, pos_2))
    if res[0] == 0 and res[0] > 0:
        return ['down']
    if res[0] == 0 and res[0] < 0:
        return ['up']
    if res[0] > 0 and res[1] == 0:
        return ['right']
    if res[0] < 0 and res[1] == 0:
        return ['left']
    if res[0] > 0 and res[1] > 0:
        return ['right', 'down']
    if res[0] > 0 and res[1] < 0:
        return ['right', 'up']
    if res[0] < 0 and res[1] > 0:
        return ['left', 'down']
    if res[0] < 0 and res[1] < 0:
        return ['left', 'up']

def tuple_list(l):
    return [tuple(a) for a in l]

if __name__ == "__main__":
    # create_adjacent_map
    MAP_INFO = pd.read_csv("map_info.csv")
    MAP_INFO = MAP_INFO.loc[MAP_INFO.iswall == 0].reset_index()
    data = dict({"pos": tuple_list(MAP_INFO[["Pos1","Pos2"]].values),
                "left": tuple_list(MAP_INFO[["LeftX","LeftY"]].values),
                "right": tuple_list(MAP_INFO[["RightX","RightY"]].values),
                "up": tuple_list(MAP_INFO[["UpX","UpY"]].values),
                "down": tuple_list(MAP_INFO[["DownX","DownY"]].values)})
    for key, value in data.items():
        for index,i in enumerate(value):
            if i == (0,0):
                data[key][index] = np.nan
    T = pd.DataFrame(data)
    T.to_pickle("adjacent_map.pickle")

    # create dij_distance_map
    G = nx.Graph()
    G.add_nodes_from(T.pos)
    for i in range(0,T.shape[0]):
        k = T.pos[i]
        G.add_edges_from(([(k,t) for t in T.iloc[i,1:5].values if t is not np.nan]))
    Tr = {"pos1":[],"pos2":[],"dis":[],"path":[],"relative_dir":[]}
    for Source in T.pos:
        for Target in T.pos:
            if Source == Target:
                continue
            Tr['pos1'].append(Source)
            Tr['pos2'].append(Target)
            Tr['dis'].append(nx.shortest_path_length(G,Source,Target))
            Tr['path'].append([x for x in nx.all_shortest_paths(G,Source,Target)])
            Tr['relative_dir'].append(get_relative_dir(Source,Target))
    pos1 = Tr.get("pos1")
    pos2 = Tr.get("pos2")
    dis = Tr.get("dis")
    path = Tr.get("path")
    relative_dir = Tr.get("relative_dir")
    df = pd.DataFrame({"pos1":pos1,"pos2":pos2,"dis":dis,"path":path,"relative_dir":relative_dir})
    df.to_pickle("dij_distance_map.pickle")

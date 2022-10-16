from util.DataProcess import DataTool
import numpy as np
from itertools import filterfalse, repeat, product
from more_itertools import collapse
import pandas as pd
import networkx as nx

def checkAround(Pos, Pos_tile):
     counter = 0
     list_pos = [0,0,0,0,0,0,0,0]
     # handle tunnel
     if Pos[1] == -2:
          return [2,0,0,0,0,30,Pos[0]+1,Pos[1]+1+1,Pos[0]+1]
     if Pos[1] == 29:
          return [2,0,0,0,0,Pos[1]-1+1,Pos[0]+1,-1,Pos[0]+1]
     if (Pos[0],Pos[1]+1) in Pos_tile:
          # right
          list_pos[6] = Pos[1]+1+1
          list_pos[7] = Pos[0]+1
          counter += 1
     if (Pos[0],Pos[1]-1) in Pos_tile:
          # left
          list_pos[4] = Pos[1]-1+1
          list_pos[5] = Pos[0]+1
          counter += 1
     if (Pos[0]+1,Pos[1]) in Pos_tile:
          # down
          list_pos[2] = Pos[1]+1
          list_pos[3] = Pos[0]+1+1
          counter += 1
     if (Pos[0]-1,Pos[1]) in Pos_tile:
          # up
          list_pos[0] = Pos[1]+1
          list_pos[1] = Pos[0]-1+1
          counter += 1
     return [counter]+list_pos

def create_map_info(Map):
     dataFrame = DataTool()
     Pos_tunnel = [(17,-1),(17,-2),(17,28),(17,29)]
     Pos_tile = list(map(dataFrame.ItoP,filterfalse(lambda x: Map[x] != " ", range(0,1008))))+Pos_tunnel
     Pos_wall = list(map(dataFrame.ItoP,filterfalse(lambda x: Map[x] == " ", range(0,1008))))
     iswall = [0] * len(Pos_tile) + [1] * len(Pos_wall)
     list_pos = list(map(checkAround,Pos_tile, repeat(Pos_tile, len(Pos_tile))))
     df_pos = pd.DataFrame(Pos_tile+Pos_wall, columns=['Pos2', 'Pos1'])
     list_empty = [[0,0,0,0,0,0,0,0,0]]*len(Pos_wall)
     df_list = pd.DataFrame(list_pos+list_empty, \
                         columns=['NextNum','UpX','UpY','DownX','DownY','LeftX','LeftY','RightX','RightY'])
     df_pos["Pos2"] = df_pos["Pos2"]+1
     df_pos["Pos1"] = df_pos["Pos1"]+1
     df_pos["iswall"] = iswall
     df = df_pos.join(df_list)
     map_info = df.loc[:,['Pos1', 'Pos2', 'iswall', \
                         'NextNum', 'UpX', 'UpY', 'DownX','DownY', 'LeftX', 'LeftY', 'RightX', 'RightY']]
     return map_info

def tuple_list(l):
    return [tuple(a) for a in l]

def create_adjacent_map(MAP_INFO):
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
    return T

def get_relative_dir(pos1,pos2):
    res = tuple(map(lambda i, j: j - i, pos1, pos2))
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

def create_dij_istance_map(T):
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
    return df
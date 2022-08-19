# %%
import h5py
import numpy as np
import pandas as pd
import os
from util import transMap,getDir,transDir,sqvz_zip,showMap,ModeTransfer
Path = "data/pilot7-04-Aug-2022-1"
fileNames = os.listdir(Path)

# %%
# with h5py.File(f"{Path}/{fileName}", 'r') as file:
#     data = file['data']
#     print(data.keys())
#     print(data['gameMap'].keys())

# %%
dataFrame = pd.DataFrame()
for fileName in fileNames:
    if not fileName.endswith(".mat"):
        continue
    with h5py.File(f"{Path}/{fileName}", 'r') as file:
        data = file['data']
        pacMan_x = data['pacMan']['tile_x'][:]
        pacMan_y = data['pacMan']['tile_y'][:]
        ghosts_x = data['ghosts']['tile_x'][:]
        ghosts_y = data['ghosts']['tile_y'][:]
        up = data['direction']['up'][:]
        down = data['direction']['down'][:]
        right = data['direction']['right'][:]
        left = data['direction']['left'][:]
        dirEnum = np.int8(data['pacMan']['dirEnum'][:])
        Map = data['gameMap']['currentTiles'][:]
        ifsacred1,ifsacred2,ifsacred3,ifsacred4 = ModeTransfer(data)
    data = dict({'DayTrial': fileName[0:-4],
             'Step': range(0,len(up)),
             'pacManPos': sqvz_zip(pacMan_x,pacMan_y), 
             'ghost1Pos': sqvz_zip(ghosts_x[:,0],ghosts_y[:,0]),
             'ghost2Pos': sqvz_zip(ghosts_x[:,1],ghosts_y[:,1]),
             'ghost3Pos': sqvz_zip(ghosts_x[:,2],ghosts_y[:,2]),
             'ghost4Pos': sqvz_zip(ghosts_x[:,3],ghosts_y[:,3]),
             'ifscared1': ifsacred1,
             'ifscared2': ifsacred2,
             'ifscared3': ifsacred3,
             'ifscared4': ifsacred4,
             'pacman_dir': transDir(dirEnum),
             'JoyStick': getDir(up, down, right, left),
             'Map': transMap(Map)})
    df = pd.DataFrame(data)
    dataFrame = pd.concat([dataFrame,df],ignore_index=True)
dataFrame.to_csv("pilot7-04-Aug-2022-1.csv")

# %%
map_i = dataFrame.loc[0,"Map"]
map_i = np.reshape(map_i,(36,29))
showMap(map_i)
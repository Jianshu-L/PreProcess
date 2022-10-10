#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import pandas as pd
import numpy as np
import pickle as pkl
import sys
sys.path.append("./")
from datetime import datetime


# In[2]:


def transData(df, dfR):
    data = dict({"pacmanPos": tuple_list(df[["pacMan_1","pacMan_2"]].values),
                 "ghost1Pos": tuple_list(df[["ghost1_1","ghost1_2"]].values),
                 "ghost2Pos": tuple_list(df[["ghost2_1","ghost2_2"]].values),
                 "ifscared1": df["ghost1_3"].values,
                 "ifscared2": df["ghost2_3"].values,
                 "pacman_dir": df["pDir"].values,
                 "JoyStick": df["JoyStick"].values
                })
    Bev = pd.DataFrame.from_dict(data)
    dataFrame = pd.concat([df[['DayTrial','Step']],Bev],axis=1)
    bIndex = [findIndex(df['Map'][i], ".") for i in range(0,df.shape[0])]
    beans = [ItoP(Index) for Index in bIndex]
    bIndex = [findIndex(df['Map'][i], "o") for i in range(0,df.shape[0])]
    energizers = [ItoP(Index) for Index in bIndex]
    data = dict({"beans": beans,
                "energizers": energizers})
    Rewd = pd.DataFrame.from_dict(data)
    dataFrame = pd.concat([dataFrame,Rewd],axis=1)
    F = dfR.loc[dfR.Reward.isin(range(3,8))]
    Fruits = F.groupby(["DayTrial", "Step"]).apply(lambda x: list(zip(x.X,x.Y))).rename("fruitPos").reset_index()
    Ft = F.groupby(["DayTrial", "Step"]).apply(lambda x: x.Reward).rename("fruitType").reset_index().drop(columns = "level_2")
    dataFrame = pd.merge(dataFrame, Fruits, on=["DayTrial", "Step"], how="left")
    dataFrame = pd.merge(dataFrame, Ft, on=["DayTrial", "Step"], how="left")
    dfS = df.loc[:, df.columns.values[list([0,1])+list(range(28,df.columns.values.shape[0]))]]
    dataFrame = pd.merge(dataFrame, dfS,on=["DayTrial", "Step"], how="left")
    return dataFrame


# In[3]:


def tuple_list(l):
    return [tuple(a) for a in l]


# In[4]:


def findIndex(mylist, substring):
    if substring in mylist:
        return [i for i, s in enumerate(mylist) if substring in s]
    else:
        return list()


# In[5]:


def findTrue(mylist):
    return [i for i, x in enumerate(mylist) if x]


# In[6]:


def ItoP(Index):
    i_ = np.array(Index)+1
    pos_x = i_ % 28
    pos_y = i_ // 28
    pos_y[pos_x != 0] = pos_y[pos_x != 0] + 1
    pos_x[pos_x == 0] = 28
    return [tuple([pos_x[i],pos_y[i]]) for i in range(0,len(pos_x))]


# In[8]:


rawPath = "results/csv/"
dataPath = "results/Omega/"
if not os.path.exists(dataPath):
    os.makedirs(dataPath)
for filename in os.listdir(rawPath):
    if filename.startswith("Omega") and not filename.endswith("R.csv"):
        if os.path.exists(dataPath+filename.replace(".csv", ".pickle")):
            continue
        try:
            # transform data for python user and save it
            df=pd.read_csv(rawPath + filename)
            dfR=pd.read_csv(rawPath + filename.replace(".csv", "-R.csv"))
            dataFrame = transData(df, dfR)
            waterStatus = pd.Series(np.zeros(dataFrame.shape[0]),name="waterStatus",dtype="int64")
            closeTs = np.where(dataFrame.waterStatus == 2)[0]
            openTs = np.where(dataFrame.waterStatus == 1)[0]
            # fix waterStatus bug
            k = 0
            while len(closeTs) != len(openTs):
                k += 1
                bugI = min(np.where((closeTs[range(0,min(len(closeTs),len(openTs)))]-
                                     openTs[range(0,min(len(closeTs),len(openTs)))])<0)[0])
                if dataFrame.loc[closeTs[bugI]+1,"Step"] == 1:
                    closeTs = np.delete(closeTs,bugI)
                elif all(dataFrame.loc[openTs[bugI-1]:closeTs[bugI],"waterTS"]==1):
                    closeTs = np.delete(closeTs,bugI-1)
                else:
                    raise Exception("waterStatus: length is not equal")
                if k == 100:
                    raise Exception("waterStatus: length is not equal")
            waterStatus[closeTs] = 2
            waterStatus[openTs] = 1
            dataFrame.waterStatus=waterStatus
            print("save " + filename.replace(".csv", ".pickle"))
            dataFrame.to_pickle(dataPath+filename.replace(".csv", ".pickle"))
        except:
            print("something wrong with %s" % filename)
            print("**********")
            continue


# In[ ]:

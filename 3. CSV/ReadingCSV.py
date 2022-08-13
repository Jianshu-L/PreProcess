#!/usr/bin/env python
# coding: utf-8

# In[1]:


#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import pandas as pd
import numpy as np
import pickle as pkl
import sys
import multiprocessing
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


# In[7]:


def toPkl(arguments):
    dataname,rewardname,mapname,rawPath = arguments
    # transform data for python user and save it
    df = pd.read_csv(rawPath + dataname)
    dfR = pd.read_csv(rawPath + rewardname)
    dfM = pd.read_csv(rawPath + mapname)
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
    if dfM.shape[0] != dataFrame.shape[0]:
        raise Exception("Map: length is not equal")
    dataFrame["Map"] = dfM
    print("save " + dataname.replace(".csv", ".pickle"))
    dataFrame.to_csv(dataPath+dataname)
    dataFrame.to_pickle(dataPath+dataname.replace(".csv", ".pickle"))
    return


# In[8]:

if __name__ == '__main__':
    # "/mnt/e/data_2021/3. CSV/results/csv/"
    rawPath = sys.argv[1]
    dataPath = "results/"
    if not os.path.exists(dataPath):
        os.makedirs(dataPath)
    filenames = os.listdir(rawPath)
    datanames = [filename for filename in filenames
                if not filename.endswith("R.csv") and not filename.endswith("M.csv")
                and not filename in [dataname.replace("pickle","csv") for dataname in os.listdir(dataPath)]]
    if len(datanames) > 0:
        datanames.sort()
        rewardnames = [dataname.replace(".csv", "-R.csv") for dataname in datanames]
        mapnames = [dataname.replace(".csv", "-M.csv") for dataname in datanames]
        rawPaths = list([rawPath]) * len(datanames)
        arguments = zip(datanames,rewardnames,mapnames,rawPaths)
        # main loop
        pool_obj = multiprocessing.Pool()
        pool_obj.map(toPkl,arguments)
        # for argument in arguments:
        #     toPkl(argument)


    # In[9]:

    print("process test code")
    def checkHeigth(arguments):
        fileName,Size,dataPath = arguments
        try:
            df = pd.read_pickle(dataPath+fileName)
        except:
            print("error load data "+fileName)
            return
        if df.shape[0] != Size:
            print(fileName + " length not equal")
        return

    fileNames = os.listdir(dataPath)
    fileNames.sort()
    fileNames = [fileName for fileName in fileNames if fileName.endswith("pickle")]
    test_size = pd.read_csv("test/dataSize.csv")
    test_size["fileNames"] = test_size["fileNames"].str.replace("mat", "pickle")
    size_list = test_size.loc[[name_ in fileNames for name_ in test_size["fileNames"]],"Height"].values.tolist()
    dataPaths_ = list([dataPath]) * len(fileNames)
    arguments = zip(fileNames,size_list,dataPaths_)
    # main loop
    # pool_obj = multiprocessing.Pool()
    # pool_obj.map(checkHeigth,arguments)
    for argument in arguments:
        checkHeigth(argument)
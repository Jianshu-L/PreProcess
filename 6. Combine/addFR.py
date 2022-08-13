#!/usr/bin/env python
# coding: utf-8

# In[9]:


import os
import pandas as pd
import math
import numpy as np
import pickle as pkl
import sys
sys.path.append("./")
from sklearn import preprocessing
from datetime import datetime


# In[10]:


from src.DataProvider import DataProvider
from src.DataHelper import DataHelper


# In[11]:


def calFR(df_, df2, window):
    x_ = int(window*30000/2)
    intervals = df_.apply(lambda x: list(range(x - x_, x + x_ + 1))).explode().reset_index()
    res = intervals.reset_index().merge(
        df2.reset_index(), left_on=df_.name, right_on="time_samples"
    ).rename(columns={"index_x": "binIndex", "index_y": "df2Index"})
    res["neuron_number"] = (
        "Ch" + res.Channel.astype(str) + "_" + res.cluster_number.astype(str)
    )
    final_results = res.pivot_table(
        columns="neuron_number",
        index="binIndex",
        values="cluster_number",
        aggfunc="count",
    ).reset_index()
#     print(final_results.shape)
    final_results["joinI"] = final_results.binIndex
    return final_results


# In[12]:


def sliceDF(df,step):
    index = list()
    num = math.floor(df.shape[0] / step)
    for i in range(num):
        index.append(range(i*step,(i+1)*step))
        if i+1 == num:
            index.append(range((i+1)*step,df.shape[0]))
    return index


# In[13]:


def mergeFR(df, spikes):
    df["i"] = df.index
    dfS = pd.merge(df, spikes, left_on="i",right_on="binIndex",how="outer")
    dfS.binIndex = dfS.i
    del dfS['i']
    return dfS


# In[14]:


rawPath = "/mnt/e/data_2021/sorting/results/spikes"
dataPath = "/mnt/e/data_2021/data"
dataFrame = DataProvider(dataPath,'pickle')
helper = DataHelper()


# In[8]:


for loops in dataFrame:
    df = dataFrame.df
    if dataFrame.fileName.split("-")[0] == "Patamon":
        Monkey = "p"
    else:
        Monkey = "o"
    fileName = [fileName for fileName in np.array(os.listdir(rawPath))\
                if int(fileName[0:8]) == (str(helper.DStoDD(helper.getDate(dataFrame.fileName))) + Monkey)] # get related neuron data
    if not fileName:
        print(f"no {dataFrame.fileName}")
        print("==========")
        continue
    else:
        print(f"load {fileName[0]}")
        df2 = pd.read_csv(f"{rawPath}/{fileName[0]}")
    # Pixel FR
    df_ = df.reset_index(drop=True)
    index = sliceDF(df_,100000)
    if index == []:
        final_results = pd.DataFrame()
        dft = df_.BRts
        result = calFR(dft, df2, 1/60)
        final_results = pd.concat([final_results,result])
    else:  
        final_results = pd.DataFrame()
        for i in index:
            dfTile = df_.iloc[i,:]
            dft = dfTile.BRts
            result = calFR(dft, df2, 1/60)
            final_results = pd.concat([final_results,result])
    Flip = mergeFR(df_, final_results)
    if Flip.shape[0] == df.shape[0]:
        print(Flip.shape)
        print("save "+dataFrame.fileName.replace(".csv", "pFlip.csv"))
        Flip.to_csv(dataFrame.fileName.replace(".csv", "pFlip.csv"))
        print("==========")
    else:
        ValueError: print("Oops!  Shape is not equal")





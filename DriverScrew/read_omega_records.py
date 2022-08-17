import pandas as pd
from src.DataProvider import DataProvider
import numpy as np
import csv
import os

def fixTypo(DataFrame):
    df = DataFrame.copy()
    df.loc[(DataFrame.Date == 20211026) & (DataFrame.chanNum == 25),"Depth"] = 89
    df.loc[(DataFrame.Date == 20211026) & (DataFrame.chanNum == 25),"Screws"] = -0.5
    df.loc[(DataFrame.Date == 20211027) & (DataFrame.chanNum == 25),"Screws"] = 0
    df.loc[(DataFrame.Date == 20211026) & (DataFrame.chanNum == 24),"Depth"] = 71
    df.loc[(DataFrame.Date == 20211026) & (DataFrame.chanNum == 24),"Screws"] = -0.5
    df.loc[(DataFrame.Date == 20211027) & (DataFrame.chanNum == 24),"Screws"] = 0
    df.loc[(DataFrame.Date == 20211026) & (DataFrame.chanNum == 100),"Depth"] = 83.25
    df.loc[(DataFrame.Date == 20211026) & (DataFrame.chanNum == 100),"Screws"] = -1
    df.loc[(DataFrame.Date == 20211027) & (DataFrame.chanNum == 100),"Screws"] = 0
    df.loc[(DataFrame.Date == 20210720) & (DataFrame.chanNum == 132),"Depth"] = 105.75
    df.loc[(DataFrame.Date == 20210720) & (DataFrame.chanNum == 132),"Screws"] = -0.25
    df.loc[(DataFrame.Date == 20210721) & (DataFrame.chanNum == 132),"Screws"] = 0
    df.loc[(DataFrame.Date == 20210921) & (DataFrame.chanNum == 140),"Depth"] = 64
    df.loc[(DataFrame.Date == 20210921) & (DataFrame.chanNum == 140),"Screws"] = -5.5
    df.loc[(DataFrame.Date == 20210922) & (DataFrame.chanNum == 140),"Screws"] = 0
    df.loc[(DataFrame.Date == 20210921) & (DataFrame.chanNum == 142),"Depth"] = 65
    df.loc[(DataFrame.Date == 20210921) & (DataFrame.chanNum == 142),"Screws"] = -0.75
    df.loc[(DataFrame.Date == 20210922) & (DataFrame.chanNum == 142),"Screws"] = 0
    return df

def findBA(record_i, BrainArea):
    BA_ = BrainArea.loc[BrainArea.Channel == record_i.chanNum].reset_index(drop=True)
    if BA_.empty:
        return 'Undefined'
    for index_,Range_ in enumerate(BA_.Range):
        if record_i.Depth in Range_:
            break
    return BA_.BA[index_]

## get valid depth
if __name__ == '__main__':
    ## Read brain area
    BrainArea = pd.read_csv("data/BrainDepthOmega.csv")
    BrainArea['Range'] = [np.arange(BrainArea.loc[i,'Start'],BrainArea.loc[i,'End']+0.25,0.25) for i in range(0,BrainArea.shape[0])]
    # BrainArea.to_pickle("BrainDepth.pkl")

    ## fix Omega records after 20210628
    Records = pd.read_csv("results/DriverRecord.csv")
    DataFrame = fixTypo(Records)

    ## only valid channels
    validChannels = [4,5,6,7,8,9,13,14,15,16,24,25,26,27,28,29,30,31,
                    32,33,34,36,37,38,40,44,45,48,49,50,52,58,61,63,64,
                    65,70,81,83,85,88,94,
                    97,100,105,110,112,114,115,117,125,
                    127,128,129,130,132,133,134,136,137,139,140,142]
    DriverRecord = DataFrame.loc[[chanNum_ in validChannels for chanNum_ in DataFrame.chanNum]].reset_index(drop=True)
    DriverRecord['BrainArea'] = DriverRecord.apply(lambda x: findBA(x,BrainArea),axis = 1)
    DriverRecord.to_pickle("DriverRecord.pkl")

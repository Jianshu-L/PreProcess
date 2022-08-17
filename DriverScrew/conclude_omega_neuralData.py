#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
import numpy as np
from src.DataProvider import DataProvider
import sys

# In[2]:

if __name__ == '__main__':
    dataPath = sys.argv[1]
    ## Read brain area
    DataFrame = DataProvider(dataPath)
    DriverRecord = pd.read_pickle("results/DriverRecord.pkl")
    df = pd.DataFrame(set(DriverRecord.BrainArea),columns=['BrainArea'])


    # In[3]:


    ## handle first index
    DataFrame.next()
    df_t = DataFrame.getDepth(DriverRecord)
    df_t['count'] = df_t['chanNum'].map(DataFrame.getChanCount())
    temp_i = df_t.pivot_table(index=["BrainArea"],values=["count"],aggfunc='sum').reset_index()
    temp_j = df_t.pivot_table(index=["BrainArea"],values=["chanNum"],aggfunc='count').reset_index()
    temp = temp_i.copy()
    chans = temp_j.copy()
    ## main loop
    for loop in DataFrame:
        df = DataFrame.getDepth(DriverRecord)
        df['count'] = df['chanNum'].map(DataFrame.getChanCount())
        temp_i = df.pivot_table(index=["BrainArea"],values=["count"],aggfunc='sum').reset_index()
        temp_j = df.pivot_table(index=["BrainArea"],values=["chanNum"],aggfunc='count').reset_index()
        temp = pd.merge(temp, temp_i, on='BrainArea',how='outer')
        chans = pd.merge(chans, temp_j, on='BrainArea',how='outer')
    ## calculate
    results = pd.DataFrame({'BrainArea':temp.BrainArea,
                            'totalDays':temp.shape[1]-1,
                            'validDays':temp.shape[1]-1-temp.isna().sum(axis=1),
                            'validChans':chans.iloc[:,1:].sum(axis=1),
                            'validUnits':temp.iloc[:,1:].sum(axis=1)})
    results['per']=results.validDays/results.totalDays


    # In[4]:
    results.to_pickle("DriverConclude.pkl")

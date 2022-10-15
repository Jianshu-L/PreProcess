#!/usr/bin/env python
# coding: utf-8

# In[9]:


from src.DataProvider import DataProvider
from src.DataFeatures import DataFeatures
import os


# In[2]:


features = DataFeatures()


# In[7]:


dfo = DataProvider("data/Omega")
for loop in dfo:
    trial = dfo.df
    debug = 1
    while debug:
        try:
            behaviour_features = features.extractFeatures(trial)
            debug = 0
        except Exception as inst:
            bugPos = inst.args[0]
            print(bugPos)
            trial = dfo.deleteBugRound(trial,bugPos)
            print("**********")
    behaviour_features.to_pickle(dfp.fileName.replace(".pickle","-F.pickle"))


# In[8]:


dfo = DataProvider("data/Patamon")
for loop in dfo:
    trial = dfo.df
    debug = 1
    while debug:
        try:
            behaviour_features = features.extractFeatures(trial)
            debug = 0
        except Exception as inst:
            bugPos = inst.args[0]
            print(bugPos)
            trial = dfo.deleteBugRound(trial,bugPos)
            print("**********")
    behaviour_features.to_pickle(dfp.fileName.replace(".pickle","-F.pickle"))


# In[ ]:





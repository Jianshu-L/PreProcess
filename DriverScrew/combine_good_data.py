#!/usr/bin/env python
# coding: utf-8

# In[1]:
from src.DataProvider import DataProvider
from src.DataHelper import DataHelper
import pandas as pd
import numpy as np
import sys
helper = DataHelper()

if __name__ == "__main__":
    # dataPath = "data/Data/"
    dataPath = sys.argv[1]
    print(f"dataPath = {dataPath}")
    dataFrame = DataProvider(dataPath)
    dataframe = pd.DataFrame()
    GoodDate = np.squeeze(pd.read_csv("results/GoodDate.csv").values.tolist())
    for loop in dataFrame:
        Name = dataFrame.fileName.replace(".csv","")
        if helper.DStoDD(dataFrame.getDate()) in GoodDate:
            print(f"append")
            dataframe = dataframe.append(dataFrame.df)
    dataframe.to_pickle("20210810Good.pkl")
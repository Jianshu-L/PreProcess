import sys
import pandas as pd
from src.DataProvider import DataProvider
import numpy as np
import csv

## get valid depth
if __name__ == '__main__':
    # dataPath = "/mnt/d/data/data_2021/combine"
    dataPath = sys.argv[1]
    dataFrame = DataProvider(dataPath)
    Records = pd.read_csv("results/DriverRecord.csv")
    valid_depth = pd.DataFrame()
    # read unit depth of every record day
    for loop in dataFrame:
        valid_depth = valid_depth.append(dataFrame.getDepth(Records))
    d = {'channel': 'depth'}
    for channel in np.sort(valid_depth.chanNum.unique()):
        df_c = valid_depth.loc[valid_depth.chanNum == channel]
        depth_c = np.sort(df_c.Depth.unique()).tolist()
        d[channel] = depth_c
    # save as csv
    new_path = open("validDepthOmega.csv", "w")
    z = csv.writer(new_path)
    for new_k, new_v in d.items():
        z.writerow([new_k, new_v])
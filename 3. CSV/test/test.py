import sys
import os
import shutil
import pandas as pd
import numpy as np
import pickle as pkl
import multiprocessing


# test part
def checkHeigth(arguments):
    fileName,Size,dataPath = arguments
    try:
        df = pd.read_pickle(dataPath+fileName)
    except:
        print("error load data "+fileName)
        shutil.copyfile(dataPath+fileName, "./"+fileName)
        return
    if df.shape[0] != Size:
        print(fileName + " length not equal")
    return

if __name__ == '__main__':
    # "../results/Omega/"
    dataPath = sys.argv[1]
    fileNames = os.listdir(dataPath)
    fileNames.sort()
    test_size = pd.read_csv("dataSize.csv")
    test_size["fileNames"] = test_size["fileNames"].str.replace("mat", "pickle")
    size_list = test_size.loc[[name_ in fileNames for name_ in test_size["fileNames"]],"Height"].values.tolist()
    dataPaths = list([dataPath]) * len(fileNames)
    arguments = zip(fileNames,size_list,dataPaths)
    # main loop
    pool_obj = multiprocessing.Pool()
    pool_obj.map(checkHeigth,arguments)

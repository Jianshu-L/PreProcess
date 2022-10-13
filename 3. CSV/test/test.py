
import sys
import os
import shutil
import multiprocessing
import pandas as pd



# test part
def checkHeigth(arg):
    fileName,Size,data_path = arg
    try:
        df = pd.read_pickle(data_path+fileName)
    except IOError:
        print("error load data "+fileName)
        shutil.copyfile(data_path+fileName, "./"+fileName)
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

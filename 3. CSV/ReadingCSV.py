import os
import sys
import multiprocessing
import pandas as pd
import numpy as np


def transData(df):
    bIndex = [findIndex(df['Map'][i], ".") for i in range(0,df.shape[0])]
    eIndex = [findIndex(df['Map'][i], "o") for i in range(0,df.shape[0])]
    data = dict({   "DayTrial": df['DayTrial'].values,
                    "Step": df['Step'].values,
                    "pacmanPos": df[["pacMan_1","pacMan_2"]].itertuples(index=False, name=None),
                    "ghost1Pos": df[["ghost1_1","ghost1_2"]].itertuples(index=False, name=None),
                    "ghost2Pos": df[["ghost2_1","ghost2_2"]].itertuples(index=False, name=None),
                    "ifscared1": df["ghost1_3"].values,
                    "ifscared2": df["ghost2_3"].values,
                    "pacman_dir": df["pDir"].values,
                    "JoyStick": df["JoyStick"].values,
                    "beans": [ItoP(Index) for Index in bIndex],
                    "energizers": [ItoP(Index) for Index in eIndex],
                    "fruitPos": [get_fruit_pos(df['Map'][i]) for i in range(0,df.shape[0])],
                    "fruitType": [get_fruit_type(df['Map'][i]) for i in range(0,df.shape[0])],
                })
    df_info = df.iloc[:,np.where(df.columns.values == 'ppX')[0][0]:]
    df_info["Map"] = df["Map"]
    return pd.DataFrame(data).join(df_info)

def tuple_list(l):
    return [tuple(a) for a in l]

def findIndex(mylist, substring):
    if substring in mylist:
        return [i for i, s in enumerate(mylist) if substring in s]
    else:
        return list()

def findTrue(mylist):
    return [i for i, x in enumerate(mylist) if x]

def ItoP(Index):
    i_ = np.array(Index)+1
    pos_x = i_ % 28
    pos_y = i_ // 28
    pos_y[pos_x != 0] = pos_y[pos_x != 0] + 1
    pos_x[pos_x == 0] = 28
    return [tuple([pos_x[i],pos_y[i]]) for i in range(0,len(pos_x))]

def get_fruit_type(Map):
    fruitType = np.nan
    ft = [f_i for f_i in ["A","S","M","O","C"] if f_i in Map]
    if "C" in ft:
        fruitType = 3
    if "S" in ft:
        fruitType = 4
    if "O" in ft:
        fruitType = 5
    if "A" in ft:
        fruitType = 6
    if "M" in ft:
        fruitType = 7
    return fruitType

def get_fruit_pos(Map):
    fruitPos = np.nan
    for f_i in ["A","S","M","O","C"]:
        if not findIndex(Map,f_i):
            continue
        fruitPos = ItoP(findIndex(Map,f_i))
    return fruitPos

def checkHeigth(arguments):
    fileName,Size,dataPath = arguments
    try:
        df = pd.read_pickle(dataPath+fileName)
    except:
        print(f"error load data {fileName}")
        return
    if df.shape[0] != Size:
        print(f"length not equal {fileName}")
    return

def check_variable_names(arg):
    fileName,Size,data_path = arg
    names = np.array(['DayTrial', 'Step', 'pacmanPos', 'ghost1Pos', 'ghost2Pos',
                'ifscared1', 'ifscared2', 'pacman_dir', 'JoyStick', 'beans',
                'energizers', 'fruitPos', 'fruitType', 'ppX', 'ppY', 'pDir',
                'pFrame', 'g1pX', 'g1pY', 'g1Dir', 'g1ModeR', 'g1Scared',
                'g1Frame', 'g2pX', 'g2pY', 'g2Dir', 'g2ModeR', 'g2Scared',
                'g2Frame', 'waterTS', 'waterStatus', 'waterDelay', 'elX', 'elY',
                'BRts', 'JoyTs', 'RewdTs', 'file_name', 'Map'])
    try:
        df = pd.read_pickle(data_path+fileName)
    except IOError:
        print(f"error load data {fileName}")
        return
    if len(df.columns.values) != len(names):
        print(f"***** {fileName} variables length not equal *****")
        return []
    if not all(df.columns.values == names):
        print(f"***** {fileName} variables names not equal *****")
        return []
    return names

def toPkl(arguments):
    dataname,dataPath,Type = arguments
    if Type not in ["csv", "pickle"]:
        raise ValueError(f"Type should be csv or pickle, not {Type}")
    # transform data for python user and save it
    df = pd.read_csv(rawPath + dataname)
    dataFrame = transData(df)
    if "waterStatus" in dataFrame.columns.values:
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
    if Type == "csv":
        print("save " + dataname)
        dataFrame.to_csv(dataPath + dataname)
    elif Type == "pickle":
        print("save " + dataname.replace(".csv", ".pickle"))
        dataFrame.to_pickle(dataPath + dataname.replace(".csv", ".pickle"))
    return

def run_script(rawPath, Type, dataPath):    
    if not os.path.exists(dataPath):
        os.makedirs(dataPath)
    filenames = os.listdir(rawPath)
    datanames = [filename for filename in filenames 
                if filename.endswith("csv") and not filename in [dataname.replace("pickle","csv") \
                                     for dataname in os.listdir(dataPath)]]
    if len(datanames) > 0:
        datanames.sort()
        dataPaths = list([dataPath]) * len(datanames)
        Types = [Type] * len(datanames)
        arguments = zip(datanames,dataPaths,Types)
        # parallell computing for loop
        # pool_obj = multiprocessing.Pool()
        # pool_obj.map(toPkl,arguments)
        for argument in arguments:
            toPkl(argument)

    print("process test code")
    fileNames = os.listdir(dataPath)
    fileNames.sort()
    fileNames = [fileName for fileName in fileNames if fileName.endswith("pickle")]
    test_size = pd.read_csv("test/dataSize.csv")
    test_size["fileNames"] = test_size["fileNames"].str.replace("mat", "pickle")
    size_list = test_size.loc[[name_ in fileNames for name_ in test_size["fileNames"]],\
                               "Height"].values.tolist()
    dataPaths_ = list([dataPath]) * len(fileNames)
    arguments = zip(fileNames,size_list,dataPaths_)
    # main loop
    # pool_obj = multiprocessing.Pool()
    # pool_obj.map(checkHeigth,arguments)
    for argument in arguments:
        checkHeigth(argument)
        names = check_variable_names(argument)
    if len(names) > 0:
        print(f"dataframe columns values: {names}")
    print("finish test")

if __name__ == '__main__':
    if len(sys.argv) == 1:
        rawPath = "../results/csv/"
        Type = "pickle"
        dataPath = "../results/data/"
    else:
        rawPath = sys.argv[1]
        Type = sys.argv[2]
        dataPath = "./"
    
    run_script(rawPath, Type, dataPath)

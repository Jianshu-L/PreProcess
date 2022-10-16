import sys
import os
import math
import pandas as pd
import numpy as np

from util.DataProcess import DataProvider

def cal_fr(bhv_data, spike_train, window):
    _x = int(window*30000/2)
    intervals = bhv_data.apply(lambda x: list(range(x - _x, x + _x + 1))).explode().reset_index()
    res = intervals.reset_index().merge(
        spike_train.reset_index(), left_on=bhv_data.name, right_on="time_samples"
    ).rename(columns={"index_x": "binIndex", "index_y": "df2Index"})
    res["neuron_number"] = (
        "Ch" + res.Channel.astype(str) + "_" + res.cluster_number.astype(str)
    )
    results = res.pivot_table(
        columns="neuron_number",
        index="binIndex",
        values="cluster_number",
        aggfunc="count",
    ).reset_index()
#     print(results.shape)
    results["joinI"] = results.binIndex
    return results

def slice_df(data_frame,step):
    _index = list()
    num = math.floor(data_frame.shape[0] / step)
    for _i in range(num):
        _index.append(range(_i*step,(_i+1)*step))
        if _i+1 == num:
            _index.append(range((_i+1)*step,data_frame.shape[0]))
    return _index


def merge_fr(data_frame, spikes):
    data_frame["i"] = data_frame.index
    df_m = pd.merge(data_frame, spikes, left_on="i",right_on="binIndex",how="outer")
    df_m.binIndex = df_m.i
    del df_m['i']
    return df_m

if __name__ == "__main__":
    if len(sys.argv) == 1:
        RAWPATH = "../data/sorting/results/spikes"
        DATAPATH = "../results/data"
    else:
        RAWPATH = sys.argv[1]
        DATAPATH = sys.argv[2]

    dataFrame = DataProvider(DATAPATH,'pickle')

    for loops in dataFrame:
        df = dataFrame.df
        if dataFrame.fileName.split("-")[0] == "Patamon":
            MONKEY = "p"
        else:
            MONKEY = "o"
        fileName = [fileName for fileName in np.array(os.listdir(RAWPATH))\
                    if str(dataFrame.DStoDD(dataFrame.getDate())) + MONKEY in fileName] # get related neuron data
        if not fileName:
            print(f"no neuron data related to {dataFrame.fileName}")
            print("==========")
            continue
        print(f"load {fileName[0]}")
        df2 = pd.read_csv(f"{RAWPATH}/{fileName[0]}")
        # Pixel FR
        df_ = df.reset_index(drop=True)
        index = slice_df(df_,100000)
        if not index:
            final_results = pd.DataFrame()
            dft = df_.BRts
            result = cal_fr(dft, df2, 1/60)
            final_results = pd.concat([final_results,result])
        else:
            final_results = pd.DataFrame()
            for i in index:
                dfTile = df_.iloc[i,:]
                dft = dfTile.BRts
                result = cal_fr(dft, df2, 1/60)
                final_results = pd.concat([final_results,result])
        Flip = merge_fr(df_, final_results)
        if Flip.shape[0] == df.shape[0]:
            print(Flip.shape)
            # pickle
            pickle_name = dataFrame.fileName.replace(".pickle", "pFlip.pickle")
            print(f"save {pickle_name}")
            Flip.to_pickle(f"../{pickle_name}")
            # csv
            print("save "+dataFrame.fileName.replace(".pickle", "pFlip.csv"))
            Flip.to_csv(dataFrame.fileName.replace(".pickle", "pFlip.csv"))
            print("==========")
        else:
            raise ValueError("Oops!  Shape is not equal")

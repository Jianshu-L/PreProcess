from PreEstimation import preEstimation
from UtilityConvert import infUtilityConvert
from MergeFitting import dynamicStrategyFitting, staticStrategyFitting

import os
import sys
sys.path.append("./Utils")
from FileUtils import readAdjacentMap

if __name__ == '__main__':
    DATAPATH = "../Data/"
    SAVEPATH = "../Data/TestExample/"
    if not os.path.exists(SAVEPATH):
        os.makedirs(SAVEPATH)
    file_name = "omegaL-01-Apr-2021-1pFlip"
    filename_list = [
        f"{DATAPATH}{file_name}.pickle"
    ]
    # pre estimation
    preEstimation(filename_list, SAVEPATH)
    CONSPATH = "../Constants"
    adjacent_data = readAdjacentMap(f"{CONSPATH}/adjacent_map.csv")
    inf_Q_data = infUtilityConvert(f"{SAVEPATH}{file_name}-with_Q.pkl", adjacent_data)
    inf_Q_data.to_pickle(f"{SAVEPATH}/{file_name}-with_Q-inf.pkl")
    # fitting
    config = {
        "filename": f"{SAVEPATH}{file_name}-with_Q.pkl",
        "save_base": SAVEPATH
    }
    dynamicStrategyFitting(config)
    staticStrategyFitting(config)
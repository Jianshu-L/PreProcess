import numpy as np
import pandas as pd

class DataFeatures(object):
    """find data files in datapath and load data."""

    def __init__(self, dataPath="results/constants",reborn_pos = (14, 27),inf_val=100):
        self.reborn_pos = reborn_pos
        self.inf_val = inf_val
        adjacent_data = pd.read_pickle(dataPath + "/adjacent_map.pickle")
        self.adj_data = adjacent_data.set_index('pos').to_dict('index')
        locs_df = pd.read_pickle(dataPath+"/dij_distance_map.pickle")[["pos1", "pos2", "dis"]]
        dict_locs_df = {}
        for each in locs_df.values:
            if each[0] not in dict_locs_df:
                dict_locs_df[each[0]] = {}
            dict_locs_df[each[0]][each[1]] = each[2]
        self.dij = dict_locs_df

    def _adjacentDist(self, pacmanPos, otherPos, type):
        '''
        Pacman某个相邻位置和otherPos的距离
        '''
        adjacent_data = self.adj_data
        locs_df = self.dij
        if np.isnan(adjacent_data[pacmanPos][type]).any():
            return self.inf_val
        # Calculate distance between adjacent and ghostPos
        adjacent = adjacent_data[pacmanPos][type]
        return 0 if adjacent == otherPos else locs_df[adjacent][otherPos]

    def _adjacentBeans(self, pacmanPos, beans, type, distance):
        '''
        Pacman某个相邻位置附近一定距离的豆子总数
        '''
        adjacent_data = self.adj_data
        if np.isnan(adjacent_data[pacmanPos][type]).any():
            return 0
        # Find adjacent positions
        adjacent = adjacent_data[pacmanPos][type]
        # Adjacent beans num
        return self._numBeansRange(adjacent, beans, (0,distance))

    def _numBeansRange(self, Pos, beans, Range):
        '''
        某个位置附近一定范围的豆子总数
        '''
        locs_df = self.dij
        # beans num
        if len(beans) == 0:
            bean_num = 0
        else:
            bean_num = sum((np.array([0 if Pos == each else locs_df[Pos][each] for each in beans]) > Range[0]) &
                           (np.array([0 if Pos == each else locs_df[Pos][each] for each in beans]) <= Range[1]))
        return bean_num

    def _ghostModeDist(self, ifscared1, ifscared2, PG1, PG2, mode):
        if mode == "normal":
            ifscared1 = ifscared1.apply(lambda x: x < 3)
            ifscared2 = ifscared2.apply(lambda x: x < 3)
        elif mode == "scared":
            ifscared1 = ifscared1.apply(lambda x: x > 3)
            ifscared2 = ifscared2.apply(lambda x: x > 3)
        else:
            raise ValueError("Undefined ghost mode {}!".format(mode))
        res = []
        for i in range(ifscared1.shape[0]):
            ind = np.where(np.array([ifscared1[i], ifscared2[i]]) == True)[0]
            res.append(np.min(np.array([PG1[i], PG2[i]])[ind]) if len(ind) > 0 else self.inf_val)
        return pd.Series(res)
    
    def test(self,trial):
        PG1_left = trial[["pacmanPos", "ghost1Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost1Pos, "left"),
            axis=1
        )
        return PG1_left

    def extractFeatures(self, trial):
        # Features for the estimation
        # Pacman-Blinky distance
        PG1_left = trial[["pacmanPos", "ghost1Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost1Pos, "left"),
            axis=1
        )
        PG1_right = trial[["pacmanPos", "ghost1Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost1Pos, "right"),
            axis=1
        )
        PG1_up = trial[["pacmanPos", "ghost1Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost1Pos, "up"),
            axis=1
        )
        PG1_down = trial[["pacmanPos", "ghost1Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost1Pos, "down"),
            axis=1
        )
        # Pacman-Clyde distance
        PG2_left = trial[["pacmanPos", "ghost2Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost2Pos, "left"),
            axis=1
        )
        PG2_right = trial[["pacmanPos", "ghost2Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost2Pos, "right"),
            axis=1
        )
        PG2_up = trial[["pacmanPos", "ghost2Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost2Pos, "up"),
            axis=1
        )
        PG2_down = trial[["pacmanPos", "ghost2Pos"]].apply(
            lambda x: self._adjacentDist(x.pacmanPos, x.ghost2Pos, "down"),
            axis=1
        )
        # Pacman-energizer distance
        PE_left = trial[["pacmanPos", "energizers"]].apply(
            lambda x: self.inf_val if len(x.energizers) == 0
            else np.min(
                [self._adjacentDist(x.pacmanPos, each, "left") for each in x.energizers]),
            axis=1
        )
        PE_right = trial[["pacmanPos", "energizers"]].apply(
            lambda x: self.inf_val if len(x.energizers) == 0
            else np.min(
                [self._adjacentDist(x.pacmanPos, each, "right") for each in x.energizers]),
            axis=1
        )
        PE_up = trial[["pacmanPos", "energizers"]].apply(
            lambda x: self.inf_val if len(x.energizers) == 0
            else np.min([self._adjacentDist(x.pacmanPos, each, "up") for each in x.energizers]),
            axis=1
        )
        PE_down = trial[["pacmanPos", "energizers"]].apply(
            lambda x: self.inf_val if len(x.energizers) == 0
            else np.min(
                [self._adjacentDist(x.pacmanPos, each, "down") for each in x.energizers]),
            axis=1
        )
        # Pacman-fruit distance
        PF_left = trial[["pacmanPos", "fruitPos"]].apply(
            lambda x: self.inf_val if np.isnan(x.fruitPos).any()
            else np.min(
                [self._adjacentDist(x.pacmanPos, each, "left") for each in x.fruitPos]),
            axis=1
        )
        PF_right = trial[["pacmanPos", "fruitPos"]].apply(
            lambda x: self.inf_val if np.isnan(x.fruitPos).any()
            else np.min(
                [self._adjacentDist(x.pacmanPos, each, "right") for each in x.fruitPos]),
            axis=1
        )
        PF_up = trial[["pacmanPos", "fruitPos"]].apply(
            lambda x: self.inf_val if np.isnan(x.fruitPos).any()
            else np.min(
                [self._adjacentDist(x.pacmanPos, each, "up") for each in x.fruitPos]),
            axis=1
        )
        PF_down = trial[["pacmanPos", "fruitPos"]].apply(
            lambda x: self.inf_val if np.isnan(x.fruitPos).any()
            else np.min(
                [self._adjacentDist(x.pacmanPos, each, "down") for each in x.fruitPos]),
            axis=1
        )
        # Pacman四个相邻位置10步内豆子数
        beans_left = trial[["pacmanPos", "beans"]].apply(
            lambda x: self._adjacentBeans(x.pacmanPos, x.beans, "left", 10),
            axis=1
        )
        beans_right = trial[["pacmanPos", "beans"]].apply(
            lambda x: self._adjacentBeans(x.pacmanPos, x.beans, "right", 10),
            axis=1
        )
        beans_up = trial[["pacmanPos", "beans"]].apply(
            lambda x: self._adjacentBeans(x.pacmanPos, x.beans, "up", 10),
            axis=1
        )
        beans_down = trial[["pacmanPos", "beans"]].apply(
            lambda x: self._adjacentBeans(x.pacmanPos, x.beans, "down", 10),
            axis=1
        )
        # Pacman附近5步内豆子数
        beans_5step = trial[["pacmanPos", "beans"]].apply(
            lambda x:
            self._numBeansRange(x.pacmanPos, x.beans, (0,5)),
            axis=1)
        # Pacman附近5~10步内豆子数
        beans_5to10step = trial[["pacmanPos", "beans"]].apply(
            lambda x:
            self._numBeansRange(x.pacmanPos, x.beans, (5,10)),
            axis=1)
        # Pacman附近10步外豆子数
        beans_over_10step = trial[["pacmanPos", "beans"]].apply(
            lambda x:
            self._numBeansRange(x.pacmanPos, x.beans, (10,np.inf)),
            axis=1)
        # 盘面豆子总数
        beans_num = trial[["beans"]].apply(lambda x: len(x.beans),axis=1)
        # 重生位置附近10步豆子数减去Pacman当前位置10步内豆子数
        beans_diff = trial[["pacmanPos", "beans"]].apply(
            lambda x:
            self._numBeansRange(self.reborn_pos, x.beans, (0,10)) -
            self._numBeansRange(x.pacmanPos, x.beans, (0,10)),
            axis=1)
        # create dataFrame
        processed_trial_data = pd.DataFrame(
        data={
            "PG_normal_left": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_left, PG2_left, "normal"),
            "PG_normal_right": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_right, PG2_right, "normal"),
            "PG_normal_up": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_up, PG2_up, "normal"),
            "PG_normal_down": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_down, PG2_down, "normal"),

            "PG_scared_left": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_left, PG2_left, "scared"),
            "PG_scared_right": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_right, PG2_right, "scared"),
            "PG_scared_up": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_up, PG2_up, "scared"),
            "PG_scared_down": self._ghostModeDist(trial.ifscared1, trial.ifscared2, PG1_down, PG2_down, "scared"),

            "PG1_left": PG1_left,
            "PG1_right": PG1_right,
            "PG1_up": PG1_up,
            "PG1_down": PG1_down,

            "PG2_left": PG2_left,
            "PG2_right": PG2_right,
            "PG2_up": PG2_up,
            "PG2_down": PG2_down,

            "PE_left": PE_left,
            "PE_right": PE_right,
            "PE_up": PE_up,
            "PE_down": PE_down,

            "PF_left": PF_left,
            "PF_right": PF_right,
            "PF_up": PF_up,
            "PF_down": PF_down,

            "beans_left": beans_left,
            "beans_right": beans_right,
            "beans_up": beans_up,
            "beans_down": beans_down,

            "beans_within_5": beans_5step,
            "beans_between_5and10": beans_5to10step,
            "beans_beyond_10": beans_over_10step,
            "beans_num": beans_num,
            "beans_diff": beans_diff
            })
        return processed_trial_data

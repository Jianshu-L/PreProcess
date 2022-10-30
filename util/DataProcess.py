import numpy as np
import pandas as pd
import os
import re
from datetime import date, datetime
from itertools import product

class DataTool(object):
    """some tool functions for data"""
    def __init__(self):
        return None

    def loadCSV(self, dataPath, fileName):
        """load csv data and drop Unnamed variable

        Args:
            dataPath (str): 
            fileName (str): 

        Returns:
            DataFrame: 
        """
        df = pd.read_csv(f"{dataPath}/{fileName}")
        if 'Unnamed: 0' in df.columns:
            df = df.drop('Unnamed: 0',axis=1)
        return df

    def ItoP(self, Index, Size=(28,36)):
        """Index to Position

        Args:
            Index (int): 1d position in map
            Size (tuple, optional): shape of Map. Defaults to (28,36).

        Returns:
            tuple: 2d position in map
        """
        return (int(Index // Size[0]),Index % Size[0])

    def PtoI(self, Position, Size=(28,36)):
        """Position to Index

        Args:
            Position (tuple): 2d position in map
            Size (tuple, optional): shape of Map. Defaults to (28,36).

        Returns:
            int: 1d position in map
        """
        return Position[0]*Size[0]+Position[1]


    def TtoS(self, Tile):
        """Tile to Seconds

        Args:
            Tile (int): 

        Returns:
            int: 
        """
        Seconds = Tile*25/60
        return Seconds

    def StoT(self, Seconds):
        """Seconds to Tile

        Args:
            Seconds (int): 

        Returns:
            int: 
        """
        Tiles = Seconds*60/25
        return Tiles

    def _getDate(self, fileName):
        """get Date from fileName

        Args:
            fileName (str): like omegaL-20-Nov-2020-pFlip.csv

        Returns:
            str: 20-Nov-2020
        """
        Date = "-".join(fileName.split("-")[1:4])
        return Date

    def DDtoDS(self, Date):
        """ 20201120 to '20-Nov-2020' """
        date_time = datetime.strptime(str(Date), '%Y%m%d').strftime('%d-%b-%Y')
        return date_time

    def DStoDD(self, Date):
        """ '20-Nov-2020' to 20201120 """
        date_time = int(datetime.strptime(str(Date), '%d-%b-%Y').strftime('%Y%m%d'))
        return date_time

    def getChanNum(self, Unit):
        """read channal numbers from Unit

        Args:
            Unit (str): Ch100_4

        Returns:
            int: 100
        """
        chanNum = int(Unit.split("_")[0][2:])
        return chanNum

    def cleanMap(self, Map):
        """clear elements in the Map, and replace ghost home as path"""
        for s_ in [".","o","A","M","O","C","S","-"]:
            Map = Map.replace(s_," ")
        Map_l = list(Map)
        for i in map(self.PtoI,product(range(16,19),range(11,17))):
            Map_l[i] = " "
        return ''.join(Map_l)

    def showMap(self, map_i):
        """print map in nice format"""
        if isinstance(map_i,str):
            map_i = list(map_i)
        map_i = np.reshape(map_i,(36,28))
        for p in map_i:
            print(''.join(p))

    def calFR(self, dataframe, stimulus_onset, time_window):
        """calculate mean firing rate around stimulus_onset"""
        so = stimulus_onset
        tw = time_window
        pAll = int(tw*60) # convert sec to Step
        # find index within StimulusOnset timeWindow
        Edge = np.linspace(-tw/2,tw/2,int(tw*60))
        Index = so.apply(lambda x: range(x-int(tw/2*60),x+int(tw/2*60))).explode().reset_index()
        Index = Index.drop(Index.index[Index['so']>=dataframe.shape[0]])
        Index_ = Index.iloc[range(0,np.int(Index.shape[0]/pAll)*pAll)]
        # get data by index
        df = dataframe.iloc[Index_['so']].reset_index(drop=True)*60
        df['pIndex'] = np.tile(range(0,pAll),np.int(Index_.shape[0]/pAll))
        # calculate mean firing rate
        dfPSTH = df.pivot_table(
            index="pIndex",
            aggfunc="mean"
        )
        Error = df.pivot_table(
            index="pIndex",
            aggfunc="sem"
        )
        return dfPSTH

class DataProvider(DataTool):

    def __init__(self, dataPath="../results", Type="pickle", iterNum=-1):
        """find data files in datapath and load data, and have some get function to get useful information

        Args:
            dataPath (str, optional): related path of data. Defaults to "../results".
            Type (str, optional): data type, csv or pickle. Defaults to "pickle".
            iterNum (int, optional): the number of data for analysis. Defaults to -1.
        """
        super().__init__()
        self.dataPath = dataPath
        fileNames = np.array(os.listdir(dataPath))
        self.fileNames = [fileName for fileName in fileNames if fileName.endswith(f'.{Type}')]
        self._index = 0
        self._type = Type
        self.iterNum = iterNum

    def __iter__(self):
        """make object iterable"""
        return self

    def __next__(self):
        return self.next()

    def shuffle(self):
        """Randomly shuffles order of fileNames."""
        rng = np.random.RandomState()
        new_order = rng.permutation(len(self.fileNames))
        self.fileNames = self.fileNames[new_order]
        self.reset()

    def next(self):
        """load csv file from all files in dataPath."""
        if self.iterNum < 0:
            self.iterNum = len(self.fileNames)
        if self._index + 1 > self.iterNum:
            self.reset()
            raise StopIteration()
        self.fileName = self.fileNames[self._index]
        df = self._load(self.fileName)
        self.df = df
        self._index += 1

    def _load(self, fileName):
        """load fileName"""
        print("load "+fileName)
        if self._type == "pickle":
            df = pd.read_pickle(f"{self.dataPath}/{fileName}")
            if "Index" not in df.columns:
                df["Index"] = df.index
        else:
            df = self.loadCSV(self.dataPath,fileName)
        return df

    def reset(self):
        """Resets the provider to the initial state to use."""
        self._index = 0
        
    def sortByDate(self):
        my_dates = [self._getDate(fileName) for fileName in self.fileNames]
        Index = sorted(range(len(my_dates)), key=lambda i: datetime.strptime(my_dates[i], "%d-%b-%Y"))
        self.fileNames = [self.fileNames[i] for i in Index]

    def subset_by_round(self,round=1):
        """subset specific round data"""
        print(f"subset round {round} data")
        df = self.df.loc[self.df.DayTrial.str.startswith(f"{round}-")].reset_index()
        self.df = df

    def reset_subset(self):
        """reset subset_by_round"""
        self.df = self.loadCSV(self.fileName)

    def getChan(self):
        """get spikes for every channel"""
        df = self.df
        chanData = df.filter(regex="Ch\d*_").fillna(0) # all channels firing rate
        return chanData

    def getChanCount(self, Unit):
        """get the number of Unit Channel

        Args:
            Unit (string): Ch120_5

        Returns:
            tuple: (Channel_num, num)
        """
        Units = self.getChan().columns.values
        chanNum, counts = np.unique([self.getChanNum(unit) for unit in Units if unit==Unit], return_counts=True)
        return (chanNum,counts)

    def getJSso(self):
        """get Joystick StimulusOnset"""
        df = self.df.copy()
        dfJS = df.dropna(subset = ['JoyStick']).reset_index(drop=True)
        index = dfJS.Index[np.where((
            dfJS.Step[1:-1].to_numpy()-dfJS.Step[0:-2].to_numpy()) != 1)[0]+1].to_numpy()
        StimulusOnset = pd.DataFrame(index,columns=["so"])['so'] # JoyStick event timestamp
        return StimulusOnset

    def getRso(self):
        """get Reward StimulusOnset"""
        df = self.df.copy()
        StimulusOnset = pd.DataFrame(np.where(
            df['waterStatus'] == 1)[0],columns=["so"])['so'] # reward event timestamp
        return StimulusOnset

    def getTso(self):
        """get every tile StimulusOnset"""
        df = self.df
        dfTile = df.iloc[list(range(0,df.shape[0],25)),:].reset_index()
        StimulusOnset = dfTile['index'].rename("so") # tiles
        return StimulusOnset
    
    def getRound(self, gameName):
        """ get '21' from gameName '21-2-omegaL-18-Dec-2020-1' """
        Round = re.findall('[0-9]+',np.array2string(gameName))
        return [Round[i] for i in range(0,len(Round),5)]

    def getDate(self):
        """ get '20-Nov-2020' from fileName 'omegaL-20-Nov-2020-pFlip.csv' """
        return super(DataProvider, self)._getDate(self.fileName)
    
    def getMap(self, print_map=True):
        """get map string in dataframe"""
        Map = np.unique(self.df.Map.apply(self.cleanMap))
        if len(Map) == 1:
            Map = Map[0]
        if print_map:
            self.showMap(Map)
        return Map

    def getDepth(self, Records):
        """get units depth from Records"""
        chanNum_i = self.getChanNum()
        date_i = self.DStoDD(self.getDate())
        index = (Records.Date == date_i) & [Records.chanNum[i] in chanNum_i for i in Records.index]
        valid_depth = Records.loc[index,["Date","chanNum","Depth","BrainArea"]].reset_index(drop=True)
        return valid_depth
    
    def deleteBugRound(self, dataFrame, bugPos=(16,10)):
        """delete whole round if any(pacmanPos in bugPos)"""
        Round = self.getRound(dataFrame.loc[dataFrame["pacmanPos"] == bugPos,"DayTrial"].unique()) 
        if len(Round) == 0:
            return dataFrame
        else:
            print(f"round {Round[0]} of {self.fileName} has pacman position in wall")
            dataFrame = dataFrame.drop(np.where(dataFrame.DayTrial.str.startswith(Round[0]))[0])
            return dataFrame.reset_index(drop = True)  

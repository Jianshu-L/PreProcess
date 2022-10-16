每个文件夹中的Run开头的代码，仅作为代码库的一个实例，并不适用新的数据。对于新的数据，请阅读每个文件夹的readme，使用下面的function和object参考Run代码重新编写
# Introduction
 - translateBev: 预处理原始行为数据，储存在results/BEVdata中。使用了BEVdata类

 - translateEl: 预处理原始眼动数据，储存在results/Eyelink中。使用了ELdata类


 - combineData: 合并处理后的眼动数据和行为数据，储存在results/data中。使用了combineBEV类

# Code description
## translateBev
    预处理原始行为数据,储存在results/BEVdata中

    Args:
        BEVpath: 原始行为数据所在的文件夹

    Returns:
        位于"results/BEVdata"的mat数据

## translateEl
    预处理原始眼动数据，储存在results/Eyelink中

    Args:
        elPath: 原始眼动数据所在的文件夹

    Returns:
        位于"results/Eyelink"的mat数据
        mouseData: 关于bug眼动数据的说明

## combineData
    合并处理后的眼动数据和行为数据，储存在results/data中

    Args:
        BEVpath: 处理后的行为数据所在的文件夹，默认"../results/BEVdata/"
        ELpath: 处理后的眼动数据所在的文件夹，默认"../results/Eyelink/"

    Returns:
        位于"results/data"的mat数据
        mouseData: 关于bug眼动数据的说明

# Data description(Output)

## Behaviour data(results/BEVdata)
no elX and elY Data

## Eyelink data(results/Eyelink)
#### Sample
* timestep: The first two columns are eye position data (x,y) of every "Step" in pixel, top left is (0,0). Third column is pupil size reported as pupil area. The last column is used for frame bug detect.
* trial: 'TRIAL 1-1'
#### Event
* sacc_timestep and fix_timestep: The "Step" of the first and last sample in the saccade or fixation
* fix: all data related with fixation event. 4-5 columns is (x,y) position.
* sacc: all data related with saccade event. 4-7 columns is Start and End (x,y) position.
* trial: 'TRIAL 1-1'

## Combined data(results/data)

* Step: steps of every trial
* DayTrial: "2-1-Omega-01-Aug-2019-2". Omega behaviour data on 2019-08-01, first trial of second game
* Map: character ascii of map
* pacMan: (14,27), x and y position in tile, (0,0) is top left
* ghost1 & ghost2: (14,18,1), x and y position in tile, the third one is ghost mode
* ghost mode:

  1 chasing pacman

  2 going corner

  3 dead ghosts (include ghosts are being eaten)

  4 scared ghosts

  5 flash scared ghosts

* JoyStick: joystick direction. ("up","down","right","left","")

* ppX,ppY,pDir,pFrame,g1pX,g1pY,g1Dir,g1ModeR,g1Scared,g1Frame: game information of pacman and ghost, such as position in pixel, direction, raw mode, whether scared, frame for painting mouth or feet

* waterTS, waterStatus, waterDelay: exact time of setDO(4,1) and setDO(4,0). You can treat them as reward giving marker.

* elX, elY: eye position data from "Sample". Missing data is filled with (-1,-1)

## Well data(data/wellData)
Selecting the data as well data that monkey tried less than 10 times to complete the game(eating all dots).

## Report
* ppELDiary: print frame bug information when translating eyelink data
* combineDiary: print missing data when combine behaviour data and eyelink data
* mouseData.mat: contains eyelink data names of mouse simulation data, bug data and missing data

# RunBEV
pre-process raw behaviour data and eyelink data. Default input is bevPath=data/Behaviour, elPath=data/Eyelink

* translate Behaviour data: 提取10个run以内吃完所有豆子的game("data/wellData")，debug一些数据问题(newData = Trans(~,oldData))，读取所有重要的game information以及subjects' input并储存在"savePath"

* translate Eyelink data: reading eyelink information and marker from .asc(saving in "savePath"), return mouseData(report of eyelink data)

* combine data: combine behaviour data and eyelink data. If eyelink data is missing, filled with (-1,-1). return combineDiary and update mouseData
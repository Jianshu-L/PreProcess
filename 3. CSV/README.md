# Code Description
## toCSV
    将所有mat格式的table数据储存成3个csv文件

    Args:
        dataPath: 1. Bev或者2. Neuron输出的形如Detron-02-Aug-2022-3.mat数据文件所在的文件夹
        savePath: 输出csv所在的文件夹

    Returns:
        位于savePath的三个csv数据
        Detron-02-Aug-2022-3.csv
        Detron-02-Aug-2022-3-M.csv
        Detron-02-Aug-2022-3-R.csv

## ReadingCSV.py
    convert three csv data to pickle or csv for python users

    Args:
        rawPath: toCSV输出的3个csv数据文件所在的文件夹(如果是windows下的路径格式，可能会产生bug)
        type: "pickle" or "csv" for output format

    Returns:
        Detron-02-Aug-2022-3.csv or Detron-02-Aug-2022-3.pickle

## 2. ReadingCSVo2019.py
convert Omega data(before 2020.11.16) to csv
* Input: rawPath="results/csv/"
* Output: dataPath="results/Omega/"

# Data Description

## CSV Data(results/csv)
it contains .csv, -R.csv data, -M.csv data

-R.csv: x position, y position and reward: 1 dots, 2 big dots, 3 cherry, 4 strawberry, 5 orange, 6 apple, 7 melon
-M.csv: game map data

## format pickle data(results/Omega or results/Patamon)
change position as tuple, save as pickle for python users
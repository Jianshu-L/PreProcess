# Code Description
## toCSV
    将所有mat格式的table数据储存成3个csv文件

    Args:
        dataPath: 需要转换成csv的数据文件所在的文件夹，默认"../results/data_neuron/"
        savePath: 储存csv的文件夹

    Returns:
        位于savePath的三个csv数据

## ReadingCSV.py
    convert three csv data to pickle or csv for python users, save in current folder

    Args:
        rawPath: toCSV输出的3个csv数据文件所在的文件夹，默认"../results/data_neuron/"(如果是windows下的路径格式，可能会产生bug)
        type: "pickle" or "csv" for output format

    Returns:
        csv data or pickle data in current folder

## 2. ReadingCSVo2019.py
convert Omega data(before 2020.11.16) to csv
* Input: rawPath="results/csv/"
* Output: dataPath="results/Omega/"

# Data Description

## CSV Data(results/csv)
it contains .csv, -R.csv data, -M.csv data

-R.csv: x position, y position and reward: 1 dots, 2 big dots, 3 cherry, 4 strawberry, 5 orange, 6 apple, 7 melon
-M.csv: game map data

## format pickle data or csv data
change position as tuple, save as pickle or csv for python users
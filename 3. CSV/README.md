# Code Description
## RunCSV
* Input: bevPath="data/data"
* Outpu: csv data in savePath="results/csv"

## 2. ReadingCSVo.py
convert Omega data(after 2020.11.16) to csv
* Input: rawPath="results/csv/"
* Output: dataPath="results/Omega/"

## 2. ReadingCSVo2019.py
convert Omega data(before 2020.11.16) to csv
* Input: rawPath="results/csv/"
* Output: dataPath="results/Omega/"

## 2. ReadingCSVp.py
convert Patamon data to csv
* Input: rawPath="results/csv/"
* Output: dataPath="results/Patamon/"

# Data Description

## CSV Data(results/csv)
it contains .csv and -R.csv data.

-R.csv: x position, y position and reward: 1 dots, 2 big dots, 3 cherry, 4 strawberry, 5 orange, 6 apple, 7 melon

## format pickle data(results/Omega or results/Patamon)
change position as tuple, save as pickle for python users

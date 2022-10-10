# Code Description
## toCSV
    将所有mat格式的数据转成csv格式(fix [14,20] & [15,20] bug)

    Args:
        dataPath: 需要转换成csv的数据文件所在的文件夹，默认"../results/data_neuron/"
        
        savePath: 储存csv的文件夹

    Returns:
        位于savePath的csv数据

## ReadingCSV.py
    convert csv data to pickle or csv for python users, save in current folder

    Args:
        rawPath: toCSV输出的csv数据文件所在的文件夹，最好使用相对路径，默认"../results/csv/"(如果是windows下的路径格式，可能会产生bug)

        type: "pickle" or "csv" for output format

        dataPath: output folder of csv data or pickle data, default "../results/data/"

    Returns:
        csv data or pickle data in dataPath

# Data Description

## format pickle data or csv data
- game information: `DayTrial`, `Step`, `file_name`, `Map`

- positions in tuple: `pacmanPos`, `ghost1Pos`, `ghost2Pos`, `beans`, `energizers`, `fruitPos`
 
-  ghosts mode: `ifscared1`, `ifscared2`

- direction: `pacman_dir`, `JoyStick`
- `fruitType`:  3 cherry, 4 strawberry, 5 orange, 6 apple, 7 melon

- raw information: `ppX`, `ppY`, `pDir`,`pFrame`, `g1pX`, `g1pY`, `g1Dir`, `g1ModeR`, `g1Scared`,`g1Frame`, `g2pX`, `g2pY`, `g2Dir`, `g2ModeR`, `g2Scared`,`g2Frame`

- marker and timestamp: `waterTS`, `waterStatus`, `waterDelay`,`BRts`, `JoyTs`, `RewdTs`

- eye positions: `elX`, `elY`



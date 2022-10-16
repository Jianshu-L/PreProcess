# Introduction
- translateNEV: 预处理神经元marker数据，储存在results/Neuron中。包含函数nev2mat和BRdata类

- combineData: 合并处理后的神经元marker数据和BEVpath中的数据，储存在results/data_neuron中。包含combineNEV类

# Code description

##  translateNEV
    预处理NEV中的marker数据,储存在"results/Neuron"中

    Args:
        dataPath: NEV数据所在的文件夹

    Returns:
        位于"results/Neuron"的BR marker data (mat)
        BRreport: 关于bug marker的说明

## combineData
    合并BR marker data和BEVpath中的数据，储存在results/data_neuron中

    Args:
        BEVpath: 处理后的行为数据所在的文件夹，默认"../results/data/"
        BRpath: BR marker data所在的文件夹，默认"../results/Neuron/"

    Returns:
        位于"results/data_neuron"的mat数据
        NEVreport: 关于合并过程中出现bug的Marker数据的说明

# Data description

## BR Eve marker path("dataPath"/Eve)
save nev as mat for fast reading next time

    % Trial Start means no picture on the screen
    event(MarkerNum == 126,1) = "Trial Start";
    % Game End including Pacman Finish, Pacman Dead and Pacman No Move
    event(MarkerNum == 125,1) = "Pacman Finish";
    event(MarkerNum == 123,1) = "Pacman Dead";
    event(MarkerNum == 119,1) = "Pacman No Move";
    % Key Input including Key Pass and Key Pause
    event(MarkerNum == 111,1) = "Key Pass";
    event(MarkerNum == 103,1) = "Key Pause";
    % Trial End means no picture on the screen
    event(MarkerNum == 112,1) = "Trial End";
    % Frame marker
    MarkerNum = [31,95,63,127];
    % up
    MarkerNum = [28,60,92,124];
    % down
    MarkerNum = [26,58,90,122];
    % left
    MarkerNum = [22,54,86,118];
    % right
    MarkerNum = [14,46,78,110];

## BR marker data(results/Neuron)
    Dirobj: the neuron timestamp of every Joystick movement

    Eventobj: the neuron timestamp of events, such as trial start, pacman dead, etc.

    Frameobj: the neuron timestamp of every frames(the interval between two frames is 1/60 seconds). The third column is "Sampling_Rate x Time_Interval"

## Combined data(results/data_neuron)

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

* BRts, JoyTs, RewdTs: the neuron timestamp when flipping, joystick moving and water valve opening

## Report
* ppBRDiary: print frame bug information when translating neuron marker.
* combineDiary: print missing and wrong marker when combine neuron marker data. Usually there's nothing we can do about it， just filled them with -1.
* BRreport.mat: contains neuron marker file names when marker of whole day is missing. You can try finding raw data for these marker.

# RunBR
pre-process raw neuron marker data

* translateNEV: translate Neuron data, reading neuron marker from .nev(in "dataPath"), saving as .mat in archivePath for fast reading next time, reading and translate marker(saving in savePath), return BRreport(report of neuron marker).

* combine data: combine behaviour data and neuron marker data. If marker data is missing, filled with (-1,-1). return NEVreport and update BRreport
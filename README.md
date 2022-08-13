# Reading Raw Data:
拷贝Pacman实验的行为数据至1. BEV/data/Behaviour, asc眼动数据至1. BEV/data/Eyelink
运行Run.m预处理原始数据：
* RunBEV.m(translate and combine behaviour & eyelink data)

  put "1. BEV/results/data" to "2. Neuron/data/data"
* RunBR.m(translate neural marker and combine with previous data)

  put "2. Neuron/results/data" to "3. Csv/data/data"
* RunCSV.m(convert behaviour data from .mat to .csv)
* ReadingCSV.py(format csv data, save as pickle)

  put "2. Neuron/results/data" to "4. Sorting/data/BEVdata"
* RunSorting.m(using klusta to sort raw neural data)
* RunSelecting.m(select valid units based on "driver Screws Records" with spike train and waveform)

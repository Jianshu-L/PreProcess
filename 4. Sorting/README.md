# Code Description
## RunSorting.m
using klusta to sort raw neural data(.ns6)
* Input: fPath = ns6 files path

  dataPath="data/BEVdata" behaviour data
* Output: savePath="results/BRdata/NS6/data" sorting results

    archivePath = archive path

## RunSelecting.m
select valid units, with channel number based on SU and MU in "driver Screws Records" and cluster based on LeastFiringCount(one spike/second)
* Input: dataPath="results/BRdata/NS6/data" sorting results
* Output: savePath="results/Neuron" spike train data

    csvPath = "results/spikes" csv format

## RunWaveform.m
output valid units average waveform, autocorrelogram, inter-spike interval
* Input: ns6Path = ns6 files path

* Output: savePath = results/waveform, waveform, ACG and ISI result path

# Data description

* sorting results(results/BRdata/NS6/data)

* spike train data(results/Neuron)

* spike train data in csv format(results/spikes)

* waveform, ACG and ISI results(results/waveform)

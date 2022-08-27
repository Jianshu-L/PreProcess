## 注意，请使用英文版本的matlab，并在设置中将Datetime format的Locale改为en_US
# PreProcess Raw Data
每个文件夹中的Run开头的代码，仅作为代码库的一个实例，并不适用新的数据。对于新的数据，请阅读每个文件夹的readme，使用下面的function和object参考Run代码重新编写

## 1. BEV
 - translateBev: 预处理原始行为数据，储存在results/BEVdata中。使用了BEVdata类

 - translateEl: 预处理原始眼动数据，储存在results/Eyelink中。使用了ELdata类


 - combineData: 合并处理后的眼动数据和行为数据，储存在results/data中。使用了combineBEV类

 ## 2. Neuron
  - translateNEV: 预处理神经元marker数据，储存在results/Neuron中。包含函数nev2mat和BRdata类

  - combineData: 合并处理后的神经元marker数据和BEVpath中的数据，储存在results/data_neuron中。包含combineNEV类

  ## 3. CSV
   - toCSV: 将所有mat格式的table数据储存成3个csv文件。包含函数Mat2Csv

   - ReadingCSV.py: convert three csv data to pickle or csv for python users, save in current folder

   ## TODO 整理合并spikeTrain与处理后的data的代码，并完成readme

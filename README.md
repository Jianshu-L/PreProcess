## 注意，请使用英文版本的matlab，并在设置中将Datetime format的Locale改为en_US
# PreProcess Raw Data
如果使用默认文件路径，可以直接运行`RunAll.py`完成预处理步骤1-3，猴子数据放在`data/MONKEY`下，眼动数据asc放在`data/Eyelink`下

需要[install matlab engine for python](https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html)

并加载`util`包:  `"pip install -e ."`

## 1. BEV
预处理原始行为数据和眼动数据，合并处理后的眼动数据和行为数据，储存在“results/data”中。

 ## 2. Neuron
预处理神经元marker数据，合并处理后的神经元marker数据与"1. BEV"生成的数据，储存在“results/data_neuron”中。

  ## 3. CSV
将“results/data_neuron”中mat数据转成csv，并将csv数据转换成适合python使用的数据格式(tuple), 储存在“results/data”中

  ## 4. Sorting
   TODO

  ## 5. Combine 
合并sorting数据，储存在当前文件夹“../”下



# Hierarchical Decision-making Model
## Features
- get_constants_data.py: get constants 
  - map_info.csv
  - adjacent_map.csv
  - dij_distance_map.csv

## Analysis
- Run.py: hierarchical decision-making model fitting

        Args:
            DATAPATH: combine结果所在的文件夹，默认"../"
            
            SAVEPATH: 输出文件所在的文件夹，默认"../TestExample/"

        Returns:
            pickle data in SAVEPATH

## TODO DriverScrew和sorting写好readme

import matlab.engine
from util.csv_to_pkl import run_script

if __name__ == '__main__':
    eng = matlab.engine.start_matlab()
    eng.script(nargout=0)
    rawPath = "results/csv/"
    Type = "pickle"
    dataPath = "results/data/"
    run_script(rawPath, Type, dataPath)
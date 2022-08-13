import numpy as np

def showMap(map_i):
    """show what map looks like"""
    for p in map_i:
        print(''.join(p))
    # [''.join(p) for p in map_i]

def transMap(map):
    """transform unicode map to string"""
    Map = list()
    for i in range(0,map.shape[0]):
        Map.append([chr(p) for p in map[i,:]])
    return Map
    
def getDir(up, down, right, left):
    """get direction from 4d value"""
    Dir = list()
    for i in range(0,len(up)):
        if up[i]:
            Dir.append('up')
        elif down[i]:
            Dir.append('down')
        elif left[i]:
            Dir.append('left')
        elif right[i]:
            Dir.append('right')
        else:
            Dir.append('')

    if len(Dir) != len(up):
        raise ValueError('Length of new list is not equal with original data')
    else:
        return Dir

def transDir(dirEnum):
    """trans 1d values to direction"""
    pacman_dir = list()
    for dir in dirEnum:
        if dir == -1:
            pacman_dir.append('')
        elif dir == 0:
            pacman_dir.append('up')
        elif dir == 1:
            pacman_dir.append('left')
        elif dir == 2:
            pacman_dir.append('down')
        elif dir == 3:
            pacman_dir.append('right')
        else:
            raise ValueError("wrong dirEnum value")
    return pacman_dir

def sqvz_zip(x,y):
    return zip(np.squeeze(np.int8(x)),np.squeeze(np.int8(y)))

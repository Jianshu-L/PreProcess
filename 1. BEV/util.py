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

def ModeTransfer(data):
    """
    # mode = 0: ghosts are outside home
    # mode = 1: ghosts are being eaten
    # mode = 2: ghosts are going home after being eaten
    # mode = 3: ghosts are just outside the door and will enter the home after
    # being eaten
    # mode = 4: ghosts are at the original position and will go outside home
    # mode = 5: ghosts are going outside home
    """
    g1 = data['ghosts']['mode'][:,0]
    g2 = data['ghosts']['mode'][:,1]
    g3 = data['ghosts']['mode'][:,2]
    g4 = data['ghosts']['mode'][:,3]
    g1_new = g1
    g2_new = g2
    g3_new = g3
    g4_new = g4
    # flash parameter
    i_ = np.floor((data['energizer']['duration'][:]-data['energizer']['count'][:])/ \
        data['energizer']['flashInterval'][:])
    # chasing or corner parameter
    dx = np.squeeze(data['pacMan']['tile_x'][:]) - (data['ghosts']['tile_x'][:,2] + data['ghosts']['dir_x'][:,2])
    dy = np.squeeze(data['pacMan']['tile_y'][:]) - (data['ghosts']['tile_y'][:,2] + data['ghosts']['dir_y'][:,2])
    dist = dx*dx+dy*dy

    index = np.array([g1_i == 0 or g1_i == 4 or g1_i == 5 for g1_i in g1])
    g1_new[data['ghosts']['scared'][:,0] == 0 & index] = 1 # chasing pacman
    index = np.array([g1_i == 1 or g1_i == 2 or g1_i == 3 for g1_i in g1])
    g1_new[index] = 3; # dead ghosts (include ghosts are being eaten)
    g1_new[np.squeeze(i_ > 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,0] == 1)] = 4; # scared ghosts
    g1_new[np.squeeze(i_ <= 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,0] == 1)] = 5; # flash scared ghosts

    index = np.array([g2_i == 0 or g2_i == 4 or g2_i == 5 for g2_i in g2])
    g2_new[dist >= 64 & (data['ghosts']['scared'][:,1] == 0) & index] = 1; # chasing pacman
    g2_new[dist < 64 & (data['ghosts']['scared'][:,1] == 0) & index] = 2; # going corner
    index = np.array([g2_i == 1 or g2_i == 2 or g2_i == 3 for g2_i in g2])
    g2_new[index] = 3; # dead ghosts (include ghosts are being eaten)
    g2_new[np.squeeze(i_ > 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,1] == 1)] = 4; # scared ghosts
    g2_new[np.squeeze(i_ <= 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,1] == 1)] = 5; # flash scared ghosts

    index = np.array([g3_i == 0 or g3_i == 4 or g3_i == 5 for g3_i in g3])
    g3_new[data['ghosts']['scared'][:,2] == 0 & index] = 1 # chasing pacman
    index = np.array([g3_i == 1 or g3_i == 2 or g3_i == 3 for g3_i in g3])
    g3_new[index] = 3; # dead ghosts (include ghosts are being eaten)
    g3_new[np.squeeze(i_ > 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,2] == 1)] = 4; # scared ghosts
    g3_new[np.squeeze(i_ <= 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,2] == 1)] = 5; # flash scared ghosts
    
    index = np.array([g4_i == 0 or g4_i == 4 or g4_i == 5 for g4_i in g4])
    g4_new[data['ghosts']['scared'][:,3] == 0 & index] = 1 # chasing pacman
    index = np.array([g4_i == 1 or g4_i == 2 or g4_i == 3 for g4_i in g4])
    g4_new[index] = 3; # dead ghosts (include ghosts are being eaten)
    g4_new[np.squeeze(i_ > 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,3] == 1)] = 4; # scared ghosts
    g4_new[np.squeeze(i_ <= 2*data['energizer']['flashes'][:]-1) & (data['ghosts']['scared'][:,3] == 1)] = 5; # flash scared ghosts

    return np.int8(g1_new), np.int8(g2_new), np.int8(g3_new), np.int8(g4_new)

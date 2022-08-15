function mode = ModeTransfer(data)
% mode = 0: ghosts are outside home
% mode = 1: ghosts are being eaten
% mode = 2: ghosts are going home after being eaten
% mode = 3: ghosts are just outside the door and will enter the home after
% being eaten
% mode = 4: ghosts are at the original position and will go outside home
% mode = 5: ghosts are going outside home
g1 = data.ghosts.mode(1,:);
g2 = data.ghosts.mode(2,:);
g3 = data.ghosts.mode(3,:);
g4 = data.ghosts.mode(4,:);

%% flash
i_ = floor((data.energizer.duration-data.energizer.count)./data.energizer.flashInterval);
%% chasing or corner
dx = data.pacMan.tile_x - (data.ghosts.tile_x(2,:) + data.ghosts.dir_x(2,:));
dy = data.pacMan.tile_y - (data.ghosts.tile_y(2,:) + data.ghosts.dir_y(2,:));
dist = dx.*dx+dy.*dy;
g1_new = g1;
g2_new = g2;
g3_new = g3;
g4_new = g4;

g1_new(data.ghosts.scared(1,:) == 0 & (g1 == 0 | g1 == 4 | g1 == 5)) = 1; % chasing pacman
g1_new(g1 == 1 | g1 == 2 | g1 == 3) = 3; % dead ghosts (include ghosts are being eaten)
g1_new(i_ > 2*data.energizer.flashes-1 & data.ghosts.scared(1,:) == 1) = 4; % scared ghosts
g1_new(i_ <= 2*data.energizer.flashes-1 & data.ghosts.scared(1,:) == 1) = 5; % flash scared ghosts

g2_new(dist >= 64 & data.ghosts.scared(2,:) == 0 & ...
    (g2 == 0 | g2 == 4 | g2 == 5)) = 1; % chasing pacman
g2_new(dist < 64 & data.ghosts.scared(2,:) == 0 & ...
    (g2 == 0 | g2 == 4 | g2 == 5)) = 2; % going corner
g2_new(g2 == 1 | g2 == 2 | g2 == 3) = 3; % dead ghosts (include ghosts are being eaten)
g2_new(i_ > 2*data.energizer.flashes-1 & data.ghosts.scared(2,:) == 1) = 4; % scared ghosts
g2_new(i_ <= 2*data.energizer.flashes-1 & data.ghosts.scared(2,:) == 1) = 5; % flash scared ghosts

g3_new(data.ghosts.scared(3,:) == 0 & (g3 == 0 | g3 == 4 | g3 == 5)) = 1; % chasing pacman
g3_new(g3 == 1 | g3 == 2 | g3 == 3) = 3; % dead ghosts (include ghosts are being eaten)
g3_new(i_ > 2*data.energizer.flashes-1 & data.ghosts.scared(3,:) == 1) = 4; % scared ghosts
g3_new(i_ <= 2*data.energizer.flashes-1 & data.ghosts.scared(3,:) == 1) = 5; % flash scared ghosts

g4_new(data.ghosts.scared(4,:) == 0 & (g4 == 0 | g4 == 4 | g4 == 5)) = 1; % chasing pacman
g4_new(g4 == 1 | g4 == 2 | g4 == 3) = 3; % dead ghosts (include ghosts are being eaten)
g4_new(i_ > 2*data.energizer.flashes-1 & data.ghosts.scared(4,:) == 1) = 4; % scared ghosts
g4_new(i_ <= 2*data.energizer.flashes-1 & data.ghosts.scared(4,:) == 1) = 5; % flash scared ghosts

mode = [g1_new;g2_new;g3_new;g4_new];
end
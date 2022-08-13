addpath(genpath("src"))
validChannels = PCB_Patamon;
for i = validChannels
    chanNum = i;
    name = char(sprintf("Chan%d", chanNum));
    EI = repmat(chanNum,200,1);
    ET = 1:200;
    ppI = CreateFiducialFileP(EI,ET); % channel 1 down 30 screws
    ppI(:,5) = ppI(:,5)*1000 + ET';
    fid = fopen([name '.fcsv'],'w');
    fprintf(fid,'# Markups fiducial file version = 4.11 \n');
    fprintf(fid,'# CoordinateSystem = RAS\n');
    fprintf(fid,'# columns = id,x,y,z,ow,ox,oy,oz,vis,sel,lock,label,desc,associatedNodeID \n');
    fprintf(fid,'id_%i,%f,%f,%f,0,0,0,1,1,0,1,%d,electrode%i \r\n',ppI');
    fclose(fid);
end
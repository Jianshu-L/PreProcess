function ppI = CreateFiducialFileO(EI,ET)
%   [status] = CreateFiducialFile(et,es,z,name)
%   CreateFiducialFile - Create Slicer Fiducial File for GMR microdrive.
%   9/16/2020   
%
%   This function calculates the x,y,z coordinates of the electrode tips 
%   based on the intial position of the microdrive and the 
%   amount of travel for each electrode.  The points are 
%   saved to a .fcsv file that can be opened in 3D Slicer.  
%
%% Input variables
load('data/GMR_InputVariables_O.mat', 'ES', 'unitZ');
%   ELECTRODE_STARTS is a numchannels x 3 array specifiying the x,y,z
%   starting coordinates of each electrode tip.  Get this from the GMR
%   MicrodriveSpecs excel file on the Electrode Starts sheet.
es = zeros(157,3);
es(161-(1:157),:) = ES;
%   TRAVEL_DIRECTION_UNIT_VECTOR is a unit vector specifing the diection of
%   travel for all electrodes.  Get this from the GMR
%   MicrodriveSpecs excel file on the Electrode Starts sheet.
z = unitZ;
%   ELECTRODE_INDEX is a 1 x numchannels array specifing which electrode
%   has moved.
%   ELECTRODE_TRAVEL is a 1 x numchannels array specifing how far each
%   electrode has moved in number of turns.  1 turn each .125mm.
%%
% convert turns to mm
et = ET/8;
% calculate electrode tip
pp = es(unique(EI),:) + et'*z;
ppI = [EI pp EI EI];
end
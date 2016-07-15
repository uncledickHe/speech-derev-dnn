%MAKERATEMAP_C: A C implementation of MPC's makeRateMap matlab code
%--------------------------------------------------
%  ratemap = makeRateMap_c(x,fs,lowcf,highcf,numchans,frameshift,ti,compression)
% 
%  x           input signal
%  fs          sampling frequency in Hz (8000)
%  lowcf       centre frequency of lowest filter in Hz (50)
%  highcf      centre frequency of highest filter in Hz (3500)
%  numchans    number of channels in filterbank (32)
%  frameshift  interval between successive frames in ms (10)
%  ti          temporal integration in ms (8)
%  compression type of compression ['cuberoot','log','none'] ('cuberoot')
%
%  e.g. ratemap = makeRateMap_c(x,8000,50,3850,32,10);
%
%
%  You should compile makeRateMap_c.c before using it.
%  In Matlab command line, type: mex makeRateMap_c.c
%
%  For more detail on this implementation, see
%  http://www.dcs.shef.ac.uk/~ning/resources/ratemap/
%
%  Ning Ma, University of Sheffield
%  n.ma@dcs.shef.ac.uk, 08 Dec 2005
%

function wav2ratemap ( wavfn, outfn, outfmt )
%WAV2RATEMAP ( WAVFN, OUTFN, OUTFMT )
%
% Generate the ratemap representation from the wav file "wavfn".
% The ratemap is saved as outfn.
%
% outfmt -- output file format. 'htk' for HTK format and 'raw'
%           for a raw format (numChannels x numFrames) in float.
%           Default is 'htk'
%
%
% The script requires the MEX C routine "makeRateMap_c" to 
% generate ratemaps. The C source code is included and should 
% be compiled for the first time you use this routine:
%     -- type "mex makeRateMap_c.c" in Matlab.
%
% More information about "makeRateMap_c" can be found at:
% http://www.dcs.shef.ac.uk/~ning/resources/ratemap/
%
% The script can save the ratemap representations in either
% a raw format or the HTK format. Variables defining data 
% paths should be modified accordingly.
%
% Ning Ma, University of Sheffield
% n.ma@dcs.shef.ac.uk, 25 Feb 2008

if nargin < 2
   error('Dataset name required');
end

if nargin < 3
   outfmt = 'htk';
end

NCHANS = 64;
FTRTYPE = strcat('rate', num2str(NCHANS));
LOWCF = 50; % in Hz
HIGHCF = 8000; % Hz
FRAMESHIFT = 10; % in ms
TI = 8; % in ms
COMPRESSION = 'log';

fprintf('%s ==> %s (%s format)\n', wavfn, outfn, outfmt);

if ~exist(wavfn, 'file')
   error(sprintf('Unable to access wav file: %s', wavfn));
end

[x,fs] = wavread(wavfn);
% Scale data range back as before the wavread normalisation
x = x .* 32768;

ratemap = makeRateMap_c(x, fs, LOWCF, HIGHCF, NCHANS, FRAMESHIFT, TI, COMPRESSION);
% Scale ratemap to log10 from 20*log10
ratemap = ratemap ./ 20;

if strcmpi ( outfmt, 'htk' )
   % Save ratemap in the HTK format
   save_ratemap_HTK(ratemap, outfn, FRAMESHIFT);
else
   % Or in raw format
   save_ratemap(ratemap, outfn);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-- Save ratemap in raw format
function save_ratemap ( ratemap, fn )

fid = fopen(fn, 'w');
fwrite(fid, ratemap, 'float32');
fclose(fid);

%-- Save ratemap in HTK format
% In big-endian byte order as an HTK tradition
function save_ratemap_HTK ( ratemap, fn, frmShift )

[nchans, nfrms] = size(ratemap);

fid = fopen(fn, 'w', 'ieee-be');

% Write an HTK header
fwrite(fid, nfrms, 'int32');
fwrite(fid, frmShift*1e4, 'int32');
fwrite(fid, nchans*4, 'int16');
fwrite(fid, 9, 'int16'); % kind code for USER

% Write actual data
fwrite(fid, ratemap, 'float32');

fclose(fid);


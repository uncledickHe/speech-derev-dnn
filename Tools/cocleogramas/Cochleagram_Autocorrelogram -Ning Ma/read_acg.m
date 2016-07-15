function [allacg] = read_acg ( file, byteorder )
%READ_ACG  read a binary ACG data file 
%[allacg ] = read_acg ( file, byteorder );
%
%  file          binary ACG data file
%  byteorder     byte order 'b' or 'l' ( default - 'b' )
%
%  allacg        ACG data ( numChans x maxDelay x numFrames )
%
%To plot the ACG in frame 40 as a 2D graph:
%  imagesc(allacg(:,:,40));
%  axis xy;
%
%Ning Ma, University of Sheffield
%n.ma@dcs.shef.ac.uk, 01 Dec 2006

if nargin < 2
   byteorder = 'l';
end
fid = fopen ( file, 'r', byteorder );
if fid < 0
   error ( sprintf ( 'Unable to open file %s', file ) );
end

maxdelay = fread ( fid, 1, 'int32' );
nchans = fread ( fid, 1, 'int32' );
nframes = fread ( fid, 1, 'int32' );


if nchans < 1 || nchans > 1000 || maxdelay < 1 || maxdelay > 2000 || nframes < 1
   fclose ( fid );
   error ( 'Invalid ACG data header' );
end

allacg = zeros(nchans, maxdelay, nframes);
for i=1:nframes
   allacg(:,:,i) = fread ( fid, [maxdelay, nchans], 'float' )';
end

fclose ( fid );

% % To plot the ACG in frame 40 as a 2D graph 
% imagesc(allacg(:,:,40));
% axis xy;

%end

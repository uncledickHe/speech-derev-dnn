%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Short-Time Fourier Transform            %
%               with MATLAB Implementation             %
%                                                      %
% Author: M.Sc. Eng. Hristo Zhivomirov       12/21/13  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stft, f, t] = stft(x, wlen, hlen, nfft, fs)

% function: [stft, f, t] = stft(x, wlen, h, nfft, fs)
% x - signal in the time domain
% wlen - length of the hamming window (recomended to be power of 2)
% hlen - hop size (recomended to be power of 2)
% nfft - number of FFT points (recomended to be power of 2)
% fs - sampling frequency, Hz
% f - frequency vector, Hz
% t - time vector, s
% stft - STFT matrix (only unique points, time across columns, freq across rows)

% represent x as column-vector if it is not
if size(x, 2) > 1
    x = x';
end

% length of the signal
xlen = length(x);

% form a periodic hamming window
win = hamming(wlen, 'periodic');

% form the stft matrix
rown = ceil((1+nfft)/2);            % calculate the total number of rows
coln = 1+fix((xlen-wlen)/hlen);        % calculate the total number of columns
stft = zeros(rown, coln);           % form the stft matrix

% initialize the indexes
indx = 0;
col = 1;

% perform STFT
while indx + wlen <= xlen
    % windowing
    xw = x(indx+1:indx+wlen).*win;
    
    % FFT
    X = fft(xw, nfft);
    
    % update the stft matrix
    stft(:, col) = X(1:rown);
    
    % update the indexes
    indx = indx + hlen;
    col = col + 1;
end

% calculate the time and frequency vectors
t = (wlen/2:hlen:wlen/2+(coln-1)*hlen)/fs;
f = (0:rown-1)*fs/nfft;

end
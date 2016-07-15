% load clean speech signal and room impulse response function, all sampled
% at 16 kHz
% load sig and im
load 'data/sample';

% generate reverberant speech
im = reshape(im,length(im),1);
rev = fftfilt(im,sig);

% inverse filter
[inv, com_im1]  = inverse_filter(rev, im); 

% spectral subtraction
derev = spec_sub_derev(inv,16000);

% output as wav files
wavwrite(sig/(max(abs(sig)))*0.95,16000,'wav/org.wav');
wavwrite(rev/(max(abs(rev)))*0.95,16000,'wav/rev.wav');
wavwrite(inv/(max(abs(inv)))*0.95,16000,'wav/inv.wav');
wavwrite(derev/(max(abs(derev)))*0.95,16000,'wav/derev.wav');
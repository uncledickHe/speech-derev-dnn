function ener = ener_by_frame(sig,fs)

if nargin == 1,
    N = 512; hop = 128;
else
    N = 0.032*fs; hop = N/4;
end

num_frame = 1+ floor((length(sig)-N)/hop);
ener = zeros(num_frame,1);
win=0.5*hamming(N+1)/1.08;win(end)=[]; win = win/sum(win);

for is=1:num_frame
   idx=(1:N)+(is-1)*hop;
   ener(is) = sum((sig(idx).*win).^2);
end
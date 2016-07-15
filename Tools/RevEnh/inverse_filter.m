% Inverse filtering
% [inverse filtered speech, equalized room impulse response] =
% inverse_filter(reverberant speech, room impulse response)
function [derev, com_im] = inverse_filter(sig, im1)

Fs = 16000;

% LP residue
res = lp_res_window(sig);

M = 1024; mu = 3e-9; N = 512; 

H = ones(2*M,1); 
L = Fs*20;
res = [zeros(400,1);res(1:L-400)];

derev = zeros(size(res));
x_block = zeros(2*M,floor(length(res)/M)-1);
delta_block = zeros(2*M,floor(length(res)/M)-1);
f = zeros(length(res),1); pad = zeros(M,1);
kur = zeros(floor(length(res)/N)-2,1);
com_im = zeros(length(im1)+2*M,1);
for iter=1:1000,
	recon_res = zeros(size(res));
	
	for n=1:length(res)/M-1,
		x_block(:,n) = fft([res(M*(n-1)+1:M*n);pad]);
		recon_res(M*(n-1)+1:M*(n+1)) = recon_res(M*(n-1)+1:M*(n+1)) + ...
			real(ifft(x_block(:,n).*H));
	end
	
	for n=2:length(res)/N-1,
		tmp = recon_res(N*(n-1)+1:N*n);
		tmp2 = tmp.*tmp;
		E_y2 = mean(tmp2);
		E_y4 = mean(tmp2.*tmp2);
		f(N*(n-1)+1:N*n) = 4*(E_y2*tmp2-E_y4).*tmp/(E_y2^3);
		kur(n-1) = kurtosis(tmp);
	end
	for n=1:length(res)/M-1,
		tmp = fft(f(M*(n-1)+1:M*(n+1)));
		delta_block(:,n) = tmp.*conj(x_block(:,n));
	end
	delta = mu*mean(delta_block,2);
	disp(['iter = ', num2str(iter)]);
	H = H + delta; 
	H(1) = 0; 
	tmp =real(ifft(H)); H = fft([tmp(1:M);pad]); H = H/norm(H);
end
for n=1:length(res)/M-1,
	derev(M*(n-1)+1:M*(n+1)) = derev(M*(n-1)+1:M*(n+1)) + ...
		real(ifft((fft([sig(M*(n-1)+1:M*n);pad]).* H)));
end
for n=1:length(im1)/M,
	com_im(M*(n-1)+1:M*(n+1)) = com_im(M*(n-1)+1:M*(n+1)) + ...
		real(ifft((fft([im1(M*(n-1)+1:M*n);pad]).* H)));
end
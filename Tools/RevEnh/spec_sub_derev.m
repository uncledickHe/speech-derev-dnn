function ss = spec_sub_derev(s,fs)

po=[0.04 0.1 0.032 1.5 0.08 400 4 4 1.5 0.02 4].';
sub_coef = 0.32; 
delay = 7;
thr1 = 0.0316;

silence = identify_silence(s,fs);

ns=length(s);
ts=1/fs;
ss=zeros(ns,1);

ni=pow2(nextpow2(fs*po(3)/po(8)));
ti=ni/fs;
nw=ni*po(8);
nf=1+floor((ns-nw)/ni);

win=0.5*hamming(nw+1)/1.08;win(end)=[];

x = zeros(nf,1+nw/2);
x2 = zeros(nf,1+nw/2);

for is=1:nf
   idx=(1:nw)+(is-1)*ni;
   x(is,:)=rfft(s(idx).*win)';
   x2(is,:)=x(is,:).*conj(x(is,:));
   x2(is,find(x2(is,:)<eps)) = eps;
end

x_noise2 = zeros(size(x2));

win_time = raylpdf(0:17,4)'; win_time = win_time/sum(win_time);

for i=1:size(x2,2),
    x2_tmp = conv(x2(:,i),win_time);
    x2_tmp(1:4) = []; x2_tmp(end-12:end) = [];
    x_noise2(:,i) = x2_tmp;
end

for is=1:nf
   idx=(1:nw)+(is-1)*ni;
   % noise
   if is > delay,
       pn=sub_coef*x_noise2(is-delay,:)';
   else
       pn=zeros(1+nw/2,1);
   end
   
   q=max(thr1,1-sqrt(pn./(x2(is,:)')));
   switch silence(is)
       case 0
           ss(idx)=ss(idx)+irfft(x(is,:)'.*q);
       case 1
           ss(idx)=ss(idx)+irfft(x(is,:)'*thr1); % -30dB off 0.0316
       case 2
           ss(idx)=ss(idx)+irfft(x(is,:)'.*q);
   end
end



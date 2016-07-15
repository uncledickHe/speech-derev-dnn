clear all
fRange = [50, 8000];
x=wavread('pianotrump.wav');
Fs=16000;
time = (length(x)-1)/Fs;
gf = gammatoneFast(x,128,fRange);%Construct the cochleagram use Gammatone filterbank
cg = cochleagram(gf);
d = 2;

Tau=0:7;           % Defines tau shifts
Phi=0:32;          % Defines phi shifts
maxiter = 50;     % Defines number of iterations
%[W, H, cost] = is_nmf2D_em(cg,maxiter,d,Tau,Phi);% the SAGE algorithm
[W, H, cost] = is_nmf2D_mu(cg,maxiter,d,Tau,Phi);% the MU algorithm
for idx = 1:d
    Rec(:,:,idx) = isp_nmf2d_rec(W, H, Tau,Phi, idx);
end
for k = 1:size(Rec,3)
    mask = logical(Rec(:,:,k)==max(Rec,[],3));
    r(k,:) = synthesisFast(x,mask,fRange);
    r(k,:) = r(k,:)./max(abs(r(k,:)));
%     wavwrite(r,Fs,sprintf([wavfile, '%d.wav'], k));
end

figure
subplot(311),plot(x);
xlabel('Samples');
ylabel('Amplitude');
title('Mixture');
subplot(312),plot(r(1,:));
xlabel('Samples');
ylabel('Amplitude');
title('Estimated source one');
subplot(313),plot(r(2,:));
xlabel('Samples');
ylabel('Amplitude');
title('Estimated source two');
sound(r(1,:),Fs);
sound(r(2,:),Fs);
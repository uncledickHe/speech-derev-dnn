function silence = identify_silence(sig,fs)

% normalized sig
sig = sig./max(abs(sig));

sub = spec_sub_derev_clean(sig,fs);

ener_inv = ener_by_frame(sig,fs);
ener = ener_by_frame(sub,fs);

silence = zeros(size(ener));
for i=1:length(silence),
    if ener_inv(i)<0.0125, 
        if ener_inv(i)/ener(i)>5, 
            silence(i) = 1;
        end
    end
end

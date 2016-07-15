function Rec = convreccomp(W, H, Phi, Tau, comp)
% Rec = 0;
% for c = comp
%     Rec = Rec+conv2(squeeze(shiftdim(H(c,:,:),1))',squeeze(W(:,c,:)));
% end
% Rec = [zeros(Tau(1),size(H,2)); ...
%     zeros(size(W,1)-Tau(1),Phi(1)),Rec(1:end-Tau(end), 1:end-Phi(end))];
% 

Rec = 0;
for tau = 1:length(Tau)
    for phi = 1:length(Phi)
         WW = [zeros(Tau(tau),length(comp)); W(1:end-Tau(tau),comp,phi)];
         HH = [zeros(length(comp),Phi(phi)), H(comp,1:end-Phi(phi),tau)];
         Rec = Rec+WW*HH;
    end
end

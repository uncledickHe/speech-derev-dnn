function Rec1= convreccomp1(W, H,Phi, Tau, comp)

Rec1 = 0;
for tau = 1:length(Tau)
    for phi = 1:length(Phi)
         WW = [zeros(Tau(tau),length(comp)); W(1:end-Tau(tau),comp,phi)];
         HH = [zeros(length(comp),Phi(phi)), H(comp,1:end-Phi(phi),tau)];

        
         Rec1 = Rec1+WW*HH;

    end
end
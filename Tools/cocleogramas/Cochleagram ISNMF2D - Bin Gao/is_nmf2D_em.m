function [W, H, cost] = is_nmf2D_em(V,n_iter,d,Tau,Phi)

% Itakura-Saito NMF2D with SAGE
%
% [W, H, cost] = is_nmf_em(V, n_iter,d,Tau,Phi)
%
% Inputs:
%   - V: positive matrix data
%   - n_iter: number of iterations
%   - d: number of components
%   - Defines tau shifts
%   - Defines phi shifts
%
% Outputs :
%   - W and H
%
%
%
%   - cost : IS divergence though iterations
%
% If you use this code please cite this paper
%
% Bin Gao, W.L. Woo and S.S. Dlay, ¡°Unsupervised Single Channel Separation of Non-Stationary
% Signals using Gammatone Filterbank and Itakura-Saito Nonnegative Matrix Two-Dimensional Factorizations,¡±
% IEEE Transactions on Circuits and Systems I, vol. 60, no. 3, pp. 662-675, 2013.
% Copyright 2014  Bin Gao
% This software is distributed under the terms of the GNU Public License
% version 3 (http://www.gnu.org/licenses/gpl.txt)
% Report bugs to Bin Gao
% bin_gao -at- uestc.edu.cn
% Checked 28/05/14

W =abs(randn(size(V,1),d,length(Tau)))+ ones(size(V,1),d,length(Tau));
H =abs(randn(d,size(V,2),length(Phi)))+ ones(d,size(V,2),length(Phi));
% W = normalizeW(W);
[F,N] = size(V);
K = size(W,2);

cost = zeros(1,n_iter);

% Compute data approximate
V_ap =isp_nmf2d_rec(W,H,Tau,Phi,1:d);

% Compute initial cost value
cost(1) = sum(V(:)./V_ap(:) - log(V(:)./V_ap(:))) - F*N;

for iter=2:n_iter
H_old=H;
W_old=W;
    for k=1:K

        % Power of component C_k %
        PowC_k = isp_nmf2d_rec1(W, H, Tau,Phi, k);

        % Power of residual
        PowR_k = V_ap - PowC_k;

        % Wiener gain
        G_k = PowC_k ./ V_ap;

        % Posterior power of component C_k %
        V_k = G_k .* (G_k .* V + PowR_k);
        Hx = zeros(size(H));
        Hy = zeros(size(H));
        for tau = 1:length(Tau)   
           for phi = 1:length(Phi)
        % Update row k of H
               Hx(k, 1:end-Tau(tau), phi) = Hx(k, 1:end-Tau(tau), phi) + ...
                        W(1:end-Phi(phi), k, tau)'*(V_k(1+Phi(phi):end,1+Tau(tau):end).*PowC_k(1+Phi(phi):end,1+Tau(tau):end).^-2);
               Hy(k,1:end-Tau(tau),phi) = Hy(k,1:end-Tau(tau),phi) + ...
                        W(1:end-Phi(phi), k, tau)'*PowC_k(1+Phi(phi):end,1+Tau(tau):end).^-1;          
           end
        end
        grad = Hx(k,:,:)./(Hy(k,:,:)+eps);
        scale = sqrt(sum(sum(W(:,k,:).^2,1),3));
        H(k,:,:) =H_old(k,:,:).*grad;
        H(k,:,:)=H(k,:,:)*scale;
         
        Wx = zeros(size(W));
        Wy = zeros(size(W));
        for phi = 1:length(Phi)
            for tau = 1:length(Tau)  
        % Update column k of W        
                 Wx(1:end-Phi(phi), k , tau) = Wx(1:end-Phi(phi), k , tau) + ...
                      (V_k(1+Phi(phi):end, 1+Tau(tau):end).*PowC_k(1+Phi(phi):end, 1+Tau(tau):end).^-2)*H(k, 1:end-Tau(tau), phi)';
                 Wy(1:end-Phi(phi), k , tau) = Wy(1:end-Phi(phi), k , tau) + ...
                      PowC_k(1+Phi(phi):end, 1+Tau(tau):end).^-1*H(k, 1:end-Tau(tau), phi)';     
            end
        end
        grad = Wx(:,k,:)./(Wy(:,k,:)+eps);
        W(:,k,:)=W_old(:,k,:).*grad;
        scale = sqrt(sum(sum(W(:,k,:).^2,1),3));
        W(:,k,:) = W(:,k,:)/scale;
        % Update data approximate
        V_ap = PowR_k + isp_nmf2d_rec1(W, H,  Tau,Phi, k);
    end %k
    % Compute cost value
    cost(iter) = sum(V(:)./V_ap(:) - log(V(:)./V_ap(:))) - F*N;
end
function W = normalizeW(W)
Q(1,:,1) = sqrt(sum(sum(W.^2,1),3));
W = W./repmat(Q+eps,[size(W,1),1,size(W,3)]);

function [W, H, cost] = is_nmf2D_mu(V, n_iter,d,Tau,Phi)

% Itakura-Saito NMF2D with multiplicative updates
%
% [W, H, cost] = is_nmf_mu(V, n_iter,d,Tau,Phi)
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
[F,N] = size(V);

cost = zeros(1,n_iter);

% Compute data approximate
V_ap = isp_nmf2d_rec(W,H,Tau,Phi,1:d);
Rec=V_ap;
% Compute initial cost value
cost(1) = sum(V(:)./V_ap(:) - log(V(:)./V_ap(:))) - F*N;

for iter = 2:n_iter
    H_old=H;
    W_old=W;
    Wx = zeros(size(W));
    Wy = zeros(size(W));
    for phi = 1:length(Phi)
        for tau = 1:length(Tau)
            Wx(1:end-Phi(phi), : , tau) = Wx(1:end-Phi(phi), : , tau) + ...
                (V(1+Phi(phi):end, 1+Tau(tau):end).*Rec(1+Phi(phi):end, 1+Tau(tau):end).^-2)*H(:, 1:end-Tau(tau), phi)';
            Wy(1:end-Phi(phi), : , tau) = Wy(1:end-Phi(phi), : , tau) + ...
                Rec(1+Phi(phi):end, 1+Tau(tau):end).^-1*H(:, 1:end-Tau(tau), phi)';
        end
    end
    tx = sum(sum(Wy.*W,1),3);
    ty = sum(sum(Wx.*W,1),3);
    Wx = Wx + repmat(tx,[size(W,1),1,size(W,3)]).*W;
    Wy = Wy + repmat(ty,[size(W,1),1,size(W,3)]).*W;
    grad = Wx./(Wy+eps);
    W = W_old.*grad;
    V_ap =isp_nmf2d_rec(W,H,Tau,Phi,1:d);
    Rec=V_ap;
    Hx = zeros(size(H));
    Hy = zeros(size(H));
    for tau = 1:length(Tau)
        for phi = 1:length(Phi)
            Hx(:, 1:end-Tau(tau), phi) = Hx(:, 1:end-Tau(tau), phi) + ...
                W(1:end-Phi(phi), :, tau)'*(V(1+Phi(phi):end,1+Tau(tau):end).*Rec(1+Phi(phi):end,1+Tau(tau):end).^-2);
            Hy(:,1:end-Tau(tau),phi) = Hy(:,1:end-Tau(tau),phi) + ...
                W(1:end-Phi(phi), :, tau)'*Rec(1+Phi(phi):end,1+Tau(tau):end).^-1;
        end
    end
    grad = Hx./(Hy+eps);
    H = H_old.*grad;
    V_ap =isp_nmf2d_rec(W,H,Tau,Phi,1:d);
    Rec=V_ap;
    % Norm-2 normalization
    scale = sqrt(sum(sum(W.^2,1),3));
    W = W./repmat(scale+eps,[size(W,1),1,size(W,3)]);    
    H = H .* repmat(scale',[1,size(H,2),size(H,3)]);    
    % Compute cost value
    cost(iter) = sum(V(:)./V_ap(:) - log(V(:)./V_ap(:))) - F*N;
    
end


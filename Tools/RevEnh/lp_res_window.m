function res = lp_res_window(s)

% res = lp_res_window(s)
% Compute the lp residue of signal s window by window

M = 512; order = 10; % for 16k 10

res = zeros(length(s),1);
s = [zeros(order,1);s];
for frame=1:length(s)/M,
	a = lpc(s(M*(frame-1)+1+order:M*frame+order),order);
	res_tmp = filter(real(a),1,s(M*(frame-1)+1:M*frame+order));
	res(M*(frame-1)+1:M*frame)=res_tmp(order+1:end);
end
res = real([zeros(order,1);res]);
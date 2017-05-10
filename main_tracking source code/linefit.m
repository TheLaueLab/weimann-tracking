function [a, C] = linefit(data)
%input as column vector
%------------------------------
x = data(:,1); y = data(:,2);
g = 1 ./ data(:,3).^2; Sg = sum(g);
Sgx = sum(g.*x); Sgx2 = sum(g.*x.^2);
Det = Sg*Sgx2 - Sgx^2; b = [sum(g.*y); sum(g.*y.*x)];
C = [Sgx2, -Sgx; -Sgx, Sg]/Det; a = C*b;
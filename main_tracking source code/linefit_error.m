%------------------------------------------------------------------------
% MATLAB program 4.1: linear fit (correlated and uncorrelated)
% Input matrix [x,y,error_y]
% Output a(1)=offset, a(2) slope of fit
% err_a corresponding errors
% ------------------------------------------------------------
function [a, err_a] = linefit_error(data)
x=data(:,1);
y=data(:,2);
sig=data(:,3);
xm = 0;
data = [x-xm y sig];
[a C] = linefit(data); sig1 = sqrt(C(1,1));
sig2 = sqrt(C(2,2)); rho = C(1,2)/(sig1*sig2);
x0 = 10; fx0 = a(1) + a(2)*(x0-xm);
d = [1; x0-xm]; sigf = sqrt(d'*C*d);
simple = sqrt(sig1^2 + sig2^2*(x0-xm)^2);
[err_a] = [sig1 sig2]';

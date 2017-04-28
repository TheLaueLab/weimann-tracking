function [param_out]= plot_hist_jump1(jump_all,interactive,dt,param_guess)

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function plots the histogram, fits 1 PDF to the histogram data and plots the
% results
% Written: Laura Weimann
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initial parameters, D(1), D(2)
param_guess(1) = param_guess(1);
param_guess(2) = 1;

t=dt;
jump_all = jump_all/1000; % unit in um
%Calculates the optimal bin size
%bin=sshist(jump_all);
bin=sqrt(length(jump_all));
[yhist,xhist]=hist(jump_all,bin);
%plot histogram
[a,b]=stairs(xhist-0.5*(xhist(2)-xhist(1)),yhist./sum(yhist));

if interactive == 1
figure();subplot(2,1,1); plot(a,b);
%ylim([0 1.1])
end

% FIT of single
opt = optimset ('TolX',1e-10,'TolFun',1e-10);

D=lsqnonlin(@(D) D(2)*a./(2*D(1)*t).*exp(-a.^2./(4*D(1)*t)) -b,[param_guess],[0,0],[0.5,1.5],opt);

param = D;

if interactive == 1
%%%Plot Fit result
a_fit = min(a):0.01:max(a);
g1=param(2)*a_fit./(2*param(1)*t).*exp(-a_fit.^2./(4*param(1)*t)); 
g1_fit_for_stats = param(2)*a./(2*param(1)*t).*exp(-a.^2./(4*param(1)*t));
hold all;
plot(a_fit,g1);

%%%Integrate function
syms x;
f = param(2)*x/(2*param(1)*t)*exp(-x^2/(4*param(1)*t));
param(2)=double(int(f, x, min(a), max(a)));

legend('Histogram of Distribution','Fit',2);
title(['D_1 = ', Print_two_digits(param(1)), ' {\mu}m^2*s^{-1}']);
ylabel('Frequency','fontsize',12,'fontweight','b')
xlabel('Displacement [um]','fontsize',12,'fontweight','b')
hold off; 

residual = b - g1_fit_for_stats;

subplot(2,1,2);plot(a,residual)
hold on;
plot(a_fit,zeros(length(a_fit),1)')
ylabel('Residual','fontsize',12,'fontweight','b')
xlabel('Displacement [um]','fontsize',12,'fontweight','b')

param_out = param(1);
end


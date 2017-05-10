function [param]=plot_hist_jump2(jump_all,~,dt,param_guess)

t=dt;
jump_all = jump_all/1000; % unit in um
interactive = 1;
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

%FIT of Sum
opt = optimset ('TolX',1e-10,'TolFun',1e-10);

D=lsqnonlin(@(D) D(2)*a./(2*D(1)*t).*exp(-a.^2./(4*D(1)*t)) + D(4)*a./(2*D(3)*t).*exp(-a.^2./(4*D(3)*t))-b,[param_guess],[0,0,0,0],[0.5,0.5,0.1,0.5],opt);

param = D;


if interactive == 1
%%Plot Fit result
a_fit = min(a):0.001:max(a);
g1=param(2)*a_fit./(2*param(1)*t).*exp(-a_fit.^2./(4*param(1)*t));
g2=param(4)*a_fit./(2*param(3)*t).*exp(-a_fit.^2./(4*param(3)*t));
fit = g1 + g2;

g1_fit_for_stats = param(2)*a./(2*param(1)*t).*exp(-a.^2./(4*param(1)*t));
g2_fit_for_stats = param(4)*a./(2*param(3)*t).*exp(-a.^2./(4*param(3)*t));
fit_for_stats = g1_fit_for_stats + g2_fit_for_stats;
hold all;
plot(a_fit,g1);
plot(a_fit,g2);
plot(a_fit,fit);

%%%Integrate function
syms x;
f = param(2)*x/(2*param(1)*t)*exp(-x^2/(4*param(1)*t));
i1=double(int(f, x, 0, Inf));
f = param(4)*x/(2*param(3)*t)*exp(-x^2/(4*param(3)*t));
i2=double(int(f, x, 0, Inf));

param(5) = i2/i1;
param(6) = param(4)/param(2);

fraction_1 = param(2)/(param(2)+param(4));
param(5) = param(4);
param(4) = param(2);
param(1) = param(1);
param(2) = param(3);
param(3) = fraction_1;

legend('Histogram of Distribution','Fit',2);
title(['D_1 = ', Print_two_digits(param(1)), ' {\mu}m^2*s^{-1}', ', f_1 = ', Print_two_digits(param(3)), ', D_2 = ', Print_two_digits(param(2)), ' {\mu}m^2*s^{-1}']);
ylabel('Frequency','fontsize',12,'fontweight','b')
xlabel('Displacement [um]','fontsize',12,'fontweight','b')
hold off;

residual = b - fit_for_stats;

subplot(2,1,2);plot(a,residual)
hold on;
plot(a_fit,zeros(length(a_fit),1)')
ylabel('Residual','fontsize',12,'fontweight','b')
xlabel('Displacement [um]','fontsize',12,'fontweight','b')


end

end

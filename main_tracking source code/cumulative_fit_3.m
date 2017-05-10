function [ param_out,shift ] = cumulative_fit_3( jump_all,dt,param_guess,ndir,multStacks,parameters )

t=dt;
jump_all = jump_all/1000; % unit in um
%sort jump distances
x = sort (jump_all);
y = 1:1:length(x);
y = y/max(y);

figure();subplot(2,1,1);plot(x,y)

% %%%FIT of triple
opt = optimset ('TolX',1e-10,'TolFun',1e-10);
D=lsqnonlin(@(D) D(2)*(1-exp(-x.^2/(4*D(1)*t))) +  D(4)*(1-exp(-x.^2/(4*D(3)*t))) + D(6)*(1-exp(-x.^2/(4*D(5)*t)))-y,[param_guess],[0,0,0,0,0,0],[1.5,1,0.1,1,0.1,1],opt);
param = D;

%%%Plot Fit result
g1 = param(2)*(1-exp(-x.^2/(4*param(1)*t)));  
g2 = param(4)*(1-exp(-x.^2/(4*param(3)*t))); 
g3 = param(6)*(1-exp(-x.^2/(4*param(5)*t))); 
fit = g1 + g2 + g3; 
hold all;
plot(x,g1);
plot(x,g2);
plot(x,g3);
plot(x,fit);

fraction_1 = param(2)/(param(2)+param(4)+param(6));
fraction_2 = param(4)/(param(2)+param(4)+param(6));
fraction_3 = param(6)/(param(2)+param(4)+param(6));
D_1 = param(1);
D_2 = param(3);
D_3 = param(5);

legend('Histogramm of Distribution','Fit',2);
title(['D_1 = ', Print_two_digits(param(1)), ' {\mu}m^2*s^{-1}', ', f_1 = ', Print_two_digits(fraction_1), ', D_2 = ', Print_two_digits(param(3)), ' {\mu}m^2*s^{-1}', ', f_2 = ', Print_two_digits(fraction_2), ', D_3 = ',Print_two_digits(param(5)), ' {\mu}m^2*s^{-1}']);
xlabel('Displacement [um]','fontsize',12,'fontweight','b')
ylabel('Frequency','fontsize',12,'fontweight','b')

%write diffusion coefficients into excel (make sure the expected
%coefficient number is known beforehand

Columns = ['A','G','M','S','Y'];
    
diffCoeff = [param(1),fraction_1, param(3), fraction_2, param(5)];
whichXLrow = strcat(Columns(ndir),num2str(multStacks));
disp (whichXLrow);
xlswrite(strcat(parameters.exp_name,'/Diffusion3.xlsx'),diffCoeff,1,whichXLrow);

hold off; 

%calculate fit statistics
residual = y - fit;
square_about_mean = y - mean(y);
SSE = sum(residual.^2);
SST = sum(square_about_mean.^2);
R_square = 1 - SSE/SST;
fit_statistics(1) = SSE;
fit_statistics(2) = R_square;

subplot(2,1,2);plot(x,residual)
hold on;
plot(x,zeros(length(x),1)')
ylabel('Residual','fontsize',12,'fontweight','b')
xlabel('Displacement [um]','fontsize',12,'fontweight','b')

param_out = [D_1,fraction_1,D_2,fraction_2,D_3,fraction_3];

end
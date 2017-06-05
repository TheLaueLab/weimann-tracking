function [ param_out,shift ] = cumulative_fit_2( jump_all,dt,param_guess,ndir,out_row,parameters)
  jump_all = jump_all/1000; % unit in um
  t=dt;
  %%sort jump distances
  x = sort (jump_all);
  y = 1:1:length(x);
  y = y/max(y);

  figure();subplot(2,1,1);plot(x,y)

  %%FIT of single
  opt = optimset ('TolX',1e-10,'TolFun',1e-10);
  D=lsqnonlin(@(D) D(2)*(1-exp(-x.^2/(4*D(1)*t))) +  D(4)*(1-exp(-x.^2/(4*D(3)*t)))-y,[param_guess],[0,0,0,0],[1.5,1,0.1,1],opt);

  param = D;

  %%Plot Fit result
  g1 = param(2)*(1-exp(-x.^2/(4*param(1)*t)));
  g2 = param(4)*(1-exp(-x.^2/(4*param(3)*t)));
  fit = g1 + g2;
  hold all;
  plot(x,g1);
  plot(x,g2);
  plot(x,fit);

  fraction_1 = param(2)/(param(2)+param(4));
  param(5) = param(4);
  param(4) = param(2);
  param(1) = param(1);
  param(2) = param(3);
  param(3) = fraction_1;

  %%write diffusion coefficients into excel (make sure the expected
  %%coefficient number is known beforehand

  Columns = ['A','E','I','M','Q','U','Y'];

  diffCoeff = [param(1),param(3), param(2)];
  whichXLrow = strcat(Columns(ndir),num2str(out_row));
  disp (whichXLrow);
  xlswrite(strcat(parameters.exp_name,'/Diffusion2.xlsx'),diffCoeff,1,whichXLrow);

  %%calculate fit statistics
  residual = y - fit;
  square_about_mean = y - mean(y);
  SSE = sum(residual.^2);
  SST = sum(square_about_mean.^2);
  R_square = 1 - SSE/SST;
  fit_statistics(1) = SSE;
  fit_statistics(2) = R_square;
  shift=residual(length(g1));

  param_out = [param(1),fraction_1,param(2),1-fraction_1];
end

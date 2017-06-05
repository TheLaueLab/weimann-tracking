function [ param_out,shift ] = cumulative_fit_1( jump_all,dt,param_guess,ndir,out_row,parameters )
  jump_all = jump_all/1000; % unit in um
  t=dt;
  %%sort jump distances
  x = sort (jump_all);
  y = 1:1:length(x);

  y = y/max(y);

  figure();subplot(2,1,1);plot(x,y)

  %%initial parameters, D(1), D(2)
  param_guess(1) = param_guess(1);
  param_guess(2) = 1;

  %%FIT of single
  opt = optimset ('TolX',1e-10,'TolFun',1e-10);
  D=lsqnonlin(@(D) D(2)*(1-exp(-x.^2/(4*D(1)*t))) -y,[param_guess],[0,0],[1.5,1.5],opt);

  param = D;

  %%Plot Fit result
  g1=param(2)*(1-exp(-x.^2/(4*param(1)*dt)));
  hold all;
  plot(x,g1);

  %%write diffusion coefficients into excel (make sure the expected
  %%coefficient number is known beforehand

  Columns = ['A','C','E','G','I','K','M','O','Q'];

  diffCoeff = param(1);
  whichXLrow = strcat(Columns(ndir),num2str(out_row));
  disp (whichXLrow);
  xlswrite(strcat(parameters.exp_name,'/Diffusion.xlsx'),diffCoeff,1,whichXLrow);

  %%calculate fit statistics
  residual = y - g1;
  square_about_mean = y - mean(y);
  SSE = sum(residual.^2);
  SST = sum(square_about_mean.^2);
  R_square = 1 - SSE/SST;
  fit_statistics(1) = SSE;
  fit_statistics(2) = R_square;
  shift=residual(length(g1));

  param_out = param(1);
end

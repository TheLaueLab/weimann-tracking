function [grad_total,offset_total] = get_and_plot_ensemble(matrix_msd,parameters,save_name)

t_max_step=parameters.t_max_step;
t_n_fit = parameters.t_n_fit;
n_fit = parameters.n_fit;

%se_total is the standard error of the mean (SEM), the standard deviation of the sample-mean's estimate of a population mean
for t = 1:parameters.step
    temp = matrix_msd(:,t);
    temp = temp(temp>0);
    msd_total(t) = mean(temp);
    se_total(t) = std(temp)/sqrt(length(temp));
end

%a weighted fit is done
data = [t_n_fit', msd_total(1:n_fit)', se_total(1:n_fit)' ];
[a, err_a] = linefit_error(data);
offset = a(1);
err_offset = err_a(1);
grad = a(2);
err_grad = err_a(2);

grad_total = [grad err_grad];
offset_total = [offset err_offset];

fit = grad_total(1)*t_max_step + offset_total(1);


figure('numbertitle','off','Name','Average MSD');

errorbar(t_max_step,msd_total,se_total,'bo');

hold on

plot(t_max_step,fit,'r');

xlabel('Time (s)')
ylabel('MSD ({\mu}m^2)')
y=ylim;
x=xlim;
x_pos = (x(1) + 0.05*(x(2)-x(1)));
y_pos = (y(1) + 0.9*(y(2)-y(1)));
text_string = strcat(num2str(grad_total(1)/4), ' {\mu}m^2s^-^1');
text_string2 = strcat('(',num2str(grad_total(1)/4),'+-',num2str(grad_total(2)/4),')','t',' + ','(',num2str(offset_total(1)),'+-',num2str(offset_total(2)),')');
text(x_pos,y_pos, sprintf('Diffusion coefficient = %s, Fit = %s', text_string,text_string2));
saveas(gcf,strcat(save_name,'MSD_mean.fig'))

hold off

grad_total = grad_total/4;
offset_total = offset_total/4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function reads in .dat files of identified trajectories and analyses
% the diffusional behaviour of the particles by means of an MSD and a JD
% analysis
% designed by Laura Weimann
% 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 


function [results] = msd_jd_analysis(parameters,param_guess1,param_guess2,param_guess3,results,setup,multStacks)



directory = strcat(parameters.exp_name,'/','spot detection Results');
[list_dir,folders] = get_folders_folders('all',directory);


max_step = parameters.step; 
n_fit = parameters.n_fit;       
plot_average = 1;  %Plots average of D over tracks if set to 1

threshold_tracklength = parameters.threshold_tracklength;  %defines minimum length of track to be taken into account





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate MSD for each track
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Alex:Changed this so it analyses each input tiff stack seperately and
%saves results in separate folders
for ndir = 1:size(list_dir,2), %loop over all folders which contain keyword
    
    dt = parameters.time(ndir)/1000;
    
    parameters.t_max_step = [1:max_step].*dt;
    parameters.t_n_fit = [1:n_fit].*dt;
    
    track_numbers = [];
    msd=[];
    se=[];
    grad=[];
    offset=[];
    track_lengths=[];
    jump_all=[];
    count = 1;
    ncells=0;

    
    
    current_folder = folders{ndir};
    current_directory = list_dir{ndir}; %'spot detection Results\test_TL_2\Results_tracking'
    
    for ndirndir = 1:size(current_directory,2)
    ncells=ncells+1;
    current_directory_directory = current_directory{ndirndir};  
    %current_folder_folder = current_folder{ndirndir};
    
    [tracks,tracksname] = load_tracks(current_directory_directory);
    Ltracks = size(tracks,2);
    track_numbers=[track_numbers Ltracks];
    
 
    for ntrack = 1:Ltracks,      

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The program passes each track to get_msd, which calculates the msd, the
        % standard error in the msd for that track, and fits the first n_fit points 
        % of the msd curve, giving msd = gradient x time + offset. And gradient in
        % 2 dimensions equals 4D
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        current_track = tracks{ntrack};
    
        %%%%if it starts at t=1, the first frame, delete first frame, since
        %%%%the time difference between the first two frames is different
        %%%%because of the camera read out time
        if current_track(1,1)==1
            current_track(1,:)=[];
        end  

        t_temp = current_track(:,1);
        t = t_temp-t_temp(1)+1;
        x = current_track(:,2);
        y = current_track(:,3);

        %only tracks longer than threshold value are analysed
        if length(x) >= threshold_tracklength;

        
        [msd_temp,se_temp,grad_temp,err_grad_temp,offset_temp] = get_msd(t,x,y,parameters,ndir);
       
        jump = get_jump3(t,x,y,parameters);

        jump_all = [ jump_all jump ];
        
        grad(count)= grad_temp;
        err_grad(count) = err_grad_temp;
        offset(count) = offset_temp;
        msd{count} = msd_temp; %final msd values
        se{count} = se_temp;   
         
        matrix(count,:) = [length(x),grad(count)./4];
        track_lengths = [ track_lengths length(x)];
        count = count +1;
        
        end
    end
    end  

%final diffusion coefficients are calculated

diff = grad./4;
index = isnan(diff);
diff(index)=-100;
diff = diff(diff~=-100);
err_diff(index)=-100;
err_diff = err_diff(err_diff~=-100);
offset(index)=-100;
offset = offset(offset~=-100);
track_lengths(index)=-100;
track_lengths = track_lengths(track_lengths~=-100);

d_mean_value = mean(diff');
n_tracks = length(diff);
%makes sense if we assume that we always measure the same D
err_d_mean_value = std(diff')/size(diff,2);

[save_name_MSD,save_name_JD]= make_directoryMSD(parameters,current_folder);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We next calculate the average values for the msd and diffusion
% coefficients
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

matrix_msd = zeros (count-1,max_step);
for irow = 1:count-1
    temp = msd{irow};
    for icol = 1:length(temp)
    matrix_msd(irow,icol)=temp(icol);
    end
end

matrix_se = zeros (count-1,max_step);
for irow = 1:count-1
    temp = se{irow};
    for icol = 1:length(temp)
    matrix_se(irow,icol)=temp(icol);
    end
end
    
if parameters.bool_D==1
    parameters.max_step=size(matrix_msd,2);
    parameters.t_max_step = [1:parameters.max_step].*dt;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finally we plot the average MSD curve
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if plot_average == 1
[grad_ensemble] = get_and_plot_ensemble(matrix_msd,parameters,save_name_MSD);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Finally we plot and save the histogram of the diffusion coefficients 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure('numbertitle','off','Name','Histogram');
[N,X]=hist(diff,sqrt(length(diff)));
bar(X, N./sum(N), 1);
ntracks_final=num2str(length(diff));
n_cells=num2str(ncells);
mean_value=num2str(d_mean_value);
err_mean_value=num2str(err_d_mean_value);
title(['#Tracks = ',ntracks_final, ', #Cells = ',n_cells, ', <D> = (', mean_value, ' +- ',err_mean_value,' {\mu}m^2*s^{-1}' ]);
ylabel('Frequency')
xlabel('D ({\mu}m^2*s^{-1})')
saveas(gcf,strcat(save_name_MSD,'MSD_Histogram.fig'))

figure('numbertitle','off','Name','Histogram_log');
diff_log = diff;
diff_log = diff_log(diff_log > 0);
diff_log=log10(diff_log);
[N,X]=hist(diff_log,sqrt(length(diff_log)));
bar(X, N./sum(N), 1);
n_cells=num2str(ncells);
mu_log = mean(diff_log);
sigma_log_2 = sum((diff_log - mu_log).^2)/length(diff_log);
Exp_value_log = (mu_log+1/2*sigma_log_2);
Exp_value = 10^(mu_log+1/2*sigma_log_2);
Exp_value_log=num2str(Exp_value_log);
Exp_value=num2str(Exp_value);
title(['#Tracks = ',ntracks_final, ', #Cells = ',n_cells, ', <log_D> = ', Exp_value_log , ', <D>=', Exp_value, '{\mu}m^2*s^{-1}' ]);
xlim([-7 1])
ylim([0 0.15])
ylabel('Frequency')
xlabel('log(D ({\mu}m^2*s^{-1}))')
saveas(gcf,strcat(save_name_MSD,'MSD_Histogram_log.fig'))


        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We determine the positional accuracy using the intercept of the MSD plot
% and plot the results in a histogram
% MSD = 4sigma^2 + 4Dt --> offset = 4*sigma^2
% sigma denoting localization precision, i.e. the standard deviation in a data set of positions
% from consecutive images of a single immobile molecule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
offset = sqrt(offset.^2);
sigma = sqrt(offset/4)*1000;
%Histogram of all std deviations
mean_std=mean(sigma);
figure(), hist(sigma);
stitle = sprintf ( 'The mean localisation precision based on %s analysed fluorophores (using MSD intercept) is %f +- %f nm'  , num2str(length(sigma)), mean_std, std(sigma));
title(stitle,'fontsize',12,'fontweight','b');
ylabel('Frequency','fontsize',12,'fontweight','b');
xlabel('Standard deviation [nm]','fontsize',12,'fontweight','b');
saveas(gcf,strcat(save_name_MSD,'Histogram of all std deviations'));


%SCATTERPLOT

figure, plot(track_lengths,sigma,'o');
title('Scatterplot','fontsize',12,'fontweight','b');
ylabel('Standard deviation [nm]','fontsize',12,'fontweight','b');
xlabel('Track length [frames]','fontsize',12,'fontweight','b');
saveas(gcf,strcat(save_name_MSD,'Scatterplot'));
        
        
%SCATTERPLOT

figure, plot(track_lengths,diff,'o');
title('Scatterplot 2','fontsize',12,'fontweight','b');
ylabel('Diffusion Coefficient [{\mu}m^2*s^{-1}]','fontsize',12,'fontweight','b');
xlabel('Track length [frames]','fontsize',12,'fontweight','b');
saveas(gcf,strcat(save_name_MSD,'Scatterplot2'));    



%JD Analysis plots

D_JD_2pop = [];
D_JD_3pop = [];

f_JD_1pop = 1;
f_JD_2pop = [];
f_JD_3pop = [];

plot_hist_jump1(jump_all,1,dt.*parameters.JD,param_guess1);
saveas(gcf,strcat(save_name_JD,'Histogram_fit1')); 
[param] = cumulative_fit_1( jump_all,dt.*parameters.JD,param_guess1,ndir,multStacks );
saveas(gcf,strcat(save_name_JD,'Cumulative_fit1'));

D_JD_1pop = param(1);

if parameters.number_populations > 1
    
plot_hist_jump2(jump_all,1,dt.*parameters.JD,param_guess2);
saveas(gcf,strcat(save_name_JD,'Histogram_fit2')); 
[param] = cumulative_fit_2(jump_all,dt.*parameters.JD,param_guess2,ndir,multStacks);
saveas(gcf,strcat(save_name_JD,'Cumulative_fit2')); 

D_JD_2pop = [param(1) param(3)];
f_JD_2pop = [param(2) param(4)];

end

if parameters.number_populations > 2
    
[param] = cumulative_fit_3( jump_all,dt.*parameters.JD,param_guess3,ndir,multStacks );
saveas(gcf,strcat(save_name_JD,'Cumulative_fit3'))

D_JD_3pop = [param(1) param(3) param(5)];
f_JD_3pop = [param(2) param(4) param(6)];

end

results.D_JD_1pop = D_JD_1pop;
results.f_JD_1pop = f_JD_1pop;
results.D_JD_2pop = D_JD_2pop;
results.f_JD_2pop = f_JD_2pop;
results.D_JD_3pop = D_JD_3pop;
results.f_JD_3pop = f_JD_3pop;
results.jump_distances = jump_all;
results.D_MSD = d_mean_value;
results.D_ensemble = grad_ensemble(1);
results.diff_coefficients = diff;
results.n_cell = ncells;
results.n_tracks = n_tracks;

%save files

savefile = strcat(parameters.exp_name,'/','Results.mat');
save(savefile, 'setup','parameters','results');
end
 









    



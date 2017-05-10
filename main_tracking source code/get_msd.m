function [msd_temp,se_temp,grad,err_grad,offset,err_offset] = get_msd(time,x,y,parameters,ndir)

%considers t datapoints, where t is given by max_step
%if track too short, step=track_length-1

length_track = size(x,1);
max_step = parameters.step;
pixel_size = parameters.PixelSize/1000;  
bool_D = parameters.bool_D;
dt = parameters.time(ndir)/1000; %in [s]
msd_temp = [];
se_temp = [];

if bool_D==1
    step = round(length_track/4);
    if step < 3
        step = 3;
    end
else
  if length_track<=max_step
    step = length_track-1;
  else
    step = max_step;
  end
end

%%%take blinking into account
%%%calculating new time and new x,y arrays, creating a -1000 if frame is missing

j=1;
k=1;
t_t=1:time(length(time));

for i=1:length(t_t)
    if time(j)==t_t(i)
        time_new(i)=i;
        x_new(i)=x(k);
        y_new(i)=y(k);
        j=j+1;
        k=k+1;
    else
        time_new(i)=-1000;
        x_new(i)=-1000;
        y_new(i)=-1000;
    end
end

length_track=length_track + length(find(time_new==-1));
t_step = [1:step].*dt;

for t = 1:step,
    
    

    xs = x_new(1:length_track-t);
    ys = y_new(1:length_track-t);
    xd = x_new(t+1:length_track);
    yd = y_new(t+1:length_track);

    d = ((xd - xs).^2 + (yd - ys).^2).*(pixel_size).^2;
    %d=sqrt(d);
    %exclude all empty frames labelled with 1000 from analysis
    %the idea is here, that the differences between real spots will never
    %reach (500*pixel_size)^2, since the size of the image is given as 512*256 
    d = d(d<(500*pixel_size)^2);
    msd_temp(:,t) = mean(d);


%better way according to Qian et al.
K = length_track - t + 1;
variance(:,t) = msd_temp(:,t)*msd_temp(:,t)*(4*t^2*K + 2*K +t -t^3)/(6*t*K^2);
se_temp(:,t) = sqrt(variance(:,t));

end

% weighted fit
data = [t_step', msd_temp', se_temp' ];
[a, err_a] = linefit_error(data);
offset = a(1);
err_offset = err_a(1);
grad = a(2);
err_grad = err_a(2);


% plot
if parameters.show_single_MSD_plots == 1
figure(), errorbar(data(:,1), data(:,2), data(:,3), 'ro')
hold on;
plot(data(:,1),a(2)*data(:,1) + a(1))
y_=ylim;
x_=xlim;
x_pos = (x_(1) + 0.05*(x_(2)-x_(1)));
y_pos = (y_(1) + 0.9*(y_(2)-y_(1)));
%text_string = strcat(num2str(results.av_diff), '{\mu}m^2s^-^1');
text_string2 = strcat('(',num2str(grad),' +- ',num2str(err_grad),')','t',' + ', '(',num2str(offset),' +- ',num2str(err_offset),')' );
text(x_pos,y_pos, sprintf(' Fit = %s', text_string2));
hold off;
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variance  and error  are calculated according to the formulas derived
% in Qian et al.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% 
% variance(k,1) = ((msd(k,1).*msd(k,1)).*(2*k*k+1))./(3*k*(mnpt - k + 1)); 
% std_var(k,1) = sqrt(variance(k,1));



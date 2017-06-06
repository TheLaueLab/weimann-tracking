%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function connects identified particles to trajectories
% designed by Laura Weimann
% 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [results] = get_tracks(parameters,setup)
  %%define input for track function
  param.mem=parameters.memory;
  param.dim=2;
  param.good=parameters.minLength;
  param.quiet=1;

  stack_directory_cell = setup.directory;
  Mean_Tracklength_allcells=[];
  Tracklength_allcells=[];
  mean_SNR_raw_track_allcells = [];
  trackdensity_per_cell_allcells = [];

  number_stack = length(stack_directory_cell);

  %%loop over all stacks
  for stack_count=1:number_stack
    %%clear all var1iables except of those specified after except
    clearvars -except setup folders number_stack stack_directory* trackdensity_per_cell_allcells Mean_Tracklength_allcells Tracklength_allcells blink_freq_Hertz_all intensity_track_allcells mean_pp_distance_allcells param exp_time parameters stack_count save_dir_all exp_name withvideo_simulation fraction_fully_reconstructed_tracks_allcells mean_SNR_raw_track_allcells

    clear Tracks info4Tracks Results* newY_cell filtered_image* length_tracks I result* im
    folders = stack_directory_cell{stack_count};
    %%h1=waitbar(0, counter);
    mean_SNR_raw_track_all = [];

    fName = folders;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now we read in the filtered Images and create a directory to save  %
    % the results                                                        %
    % I is a 3d matrix, (image_height, image_weight, nImage)             %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    [I,~,save_dir] = get_images('',fName,'');

    T = setup.K(stack_count);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Now we gonna read in the Results from the detection function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    file2 = strcat(folders, '/', 'files4tracking.mat');
    load(file2);

    %%Now we gonna create a matrix in a form which is suited for the function track
    %%based on crockers code
    Results_final=[];

    for t=1:T
      clear Temp;
      if isempty(xyIfilIrawSNRfilSNRraw{t})==1
        xyIfilIrawSNRfilSNRraw{t} = [ 0 0 0 0 0 0];
      end
      Temp = xyIfilIrawSNRfilSNRraw{t};
      Temp = Temp(:,1:2);
      if ~isempty(Temp)
        if Temp(1) ~=0
          Temp(:,3)=t;
          Temp=Temp';
          Results_final=[Results_final Temp];
        end
      end
    end

    Results_final=Results_final';

    length_tracks = [];
    %%applying of track funtion
    if ~isempty(Results_final)
      result_tracks=track(Results_final,parameters.max_step,param);

      if ~isempty(result_tracks)
        %%add I raw, SNR fil, SNR raw to result_tracks
        i_result_tracks = length(find(result_tracks(result_tracks(:,1)~=0)));
        result_tracks = result_tracks(1:i_result_tracks,:);
        for i=1:i_result_tracks
          a=result_tracks(i,:);
          tt=xyIfilIrawSNRfilSNRraw{a(3)};
          ll=find(tt==a(1));
          temp=tt(ll,:);
          result_tracks_SNR_temp=[a,temp(4:6)];
          result_tracks_SNR(i,:)=result_tracks_SNR_temp;
        end

        ntrack = 1;
        figure();

        for nt=1:result_tracks((size(result_tracks,1)-1),4)
          clear temp a
          a=find((result_tracks(:,4)==nt));

          if length(a) > param.good
            temp=result_tracks(a,3);
            %%save frame number, x,y position, I raw, SNR fil, SNR raw
            temp(:,2:6)=result_tracks_SNR(a,[1,2,5,6,7]);

            %%Calculate mean intensity of track
            SNR_raw_track = temp(:,6);
            mean_SNR_raw_track = mean(SNR_raw_track);

            order4track = num2str(ntrack, '%3d');
            filename = strcat(save_dir,'/track_', order4track, '.dat');
            dlmwrite(filename,temp,'newline','pc');
            length_tracks(ntrack)=length(a);
            %%Plot ensemble of tracks
            drawTest_all(temp, setup, ntrack,parameters, stack_count)
            mean_SNR_raw_track_all = [mean_SNR_raw_track_all mean_SNR_raw_track'];
            ntrack = ntrack +1;
          end
        end

        set(gca,'YDir','reverse')
        title(['Trajectory Ensemble']);
        fName_hist_all = strcat(save_dir,'/','Trajectory Ensemble.fig');
        saveas(gcf,fName_hist_all)
      end
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %                            CONTROL PLOTS                            %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %%calculate mean spot density
    number_tracks = sum(length_tracks);
    Pixelsize = parameters.PixelSize/1000; %[um]
    Image_area = setup.M(stack_count)*setup.N(stack_count)*(Pixelsize)^2;
    density_per_cell = number_tracks/T;
    density_perframe = density_per_cell/Image_area;

    %%plot histogram of track length for each cell
    figure(),hist(length_tracks);
    title(['#Tracks = ',num2str(length(length_tracks)), ', mean length = ',num2str(mean(length_tracks)), ', track density = ' num2str(round( density_perframe*1000)/1000),' per um^2', ' / ', num2str(round( density_per_cell*1000)/1000),' tracks per frame']);
    fName_hist_all = strcat(save_dir,'/','Histogram_tracklength.fig');
    ylabel('Frequency','fontsize',12,'fontweight','b')
    xlabel('track length [frames]','fontsize',12,'fontweight','b')
    saveas(gcf,fName_hist_all)

    savefile = strcat(parameters.exp_name,'/','Tracklength.mat');
    save(savefile,'length_tracks','-v7.3');

    %%plot histogram of mean track intensities
    if isempty(mean_SNR_raw_track_all) ~= 1
      figure(),hist(mean_SNR_raw_track_all,sqrt(length(mean_SNR_raw_track_all )))
      title(['cell = ',num2str(stack_count), ', # tracks = ',num2str( length(mean_SNR_raw_track_all ))]);
      fName_hist_all = strcat(save_dir,'/','Histogram_SNR_raw.fig');
      ylabel('Frequency','fontsize',12,'fontweight','b')
      xlabel('Mean SNR raw per track','fontsize',12,'fontweight','b')
      saveas(gcf,fName_hist_all)
    end

    %%make videos
    if parameters.withvideo == 1
      figure();
      makeavi64bit_real_data(parameters,I,T,save_dir)
    end

    mean_SNR_raw_track_allcells = [mean_SNR_raw_track_allcells mean(mean_SNR_raw_track_all)];
    Mean_Tracklength_allcells = [Mean_Tracklength_allcells mean(length_tracks)];
    Tracklength_allcells=[Tracklength_allcells length_tracks];
    trackdensity_per_cell_allcells = [trackdensity_per_cell_allcells density_perframe ];

    close all
  end

  results.meanSNRrawpertrack = mean_SNR_raw_track_allcells;
  results.meantracklength = Mean_Tracklength_allcells;
  results.ntracks = length(length_tracks);

  save_dir = strcat(parameters.exp_name,'/','spot detection Results');

  figure(),plot(1:1:number_stack,trackdensity_per_cell_allcells,'--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',10)
  title(['All cells, Track density per cell over cell per um^2']);
  fName_hist_all = strcat(save_dir,'/','Trackdensity.fig');
  if max(trackdensity_per_cell_allcells) > 0
    ylim([0 max(trackdensity_per_cell_allcells)])
  end
  ylabel('Trackdensity per cell','fontsize',12,'fontweight','b')
  xlabel('Cell index','fontsize',12,'fontweight','b')
  saveas(gcf,fName_hist_all)

  figure(),plot(1:1:number_stack,Mean_Tracklength_allcells,'--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',10)
  title(['All cells, Mean track length over cell']);
  fName_hist_all = strcat(save_dir,'/','Tracklength.fig');
  if max(Mean_Tracklength_allcells) > 0
    ylim([0 max(Mean_Tracklength_allcells)])
  end
  ylabel('Mean track length','fontsize',12,'fontweight','b')
  xlabel('Cell index','fontsize',12,'fontweight','b')
  saveas(gcf,fName_hist_all)

  figure(),plot(1:1:number_stack,mean_SNR_raw_track_allcells,'--rs','LineWidth',2,...
                'MarkerEdgeColor','k',...
                'MarkerFaceColor','g',...
                'MarkerSize',10)
  title(['All cells, mean SNR per track over cell']);
  fName_hist_all = strcat(save_dir,'/','SNR_pertrack.fig');
  if max(Mean_Tracklength_allcells) > 0
    ylim([0 max(Mean_Tracklength_allcells)])
  end
  ylabel('mean SNR raw','fontsize',12,'fontweight','b')
  xlabel('Cell index','fontsize',12,'fontweight','b')
  saveas(gcf,fName_hist_all)

  savefile = strcat(parameters.exp_name,'/','Results.mat');
  save(savefile, 'setup','parameters','results', '-v7.3');

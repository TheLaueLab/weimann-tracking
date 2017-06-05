%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function reads in image stacks and identifies spots
% designed by Laura Weimann
% 2012
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [setup_all]=spot_detection(parameters,stack_directory)
  stack_directory_cell{1} = stack_directory;

  interactive = parameters.interactive;
  number_stack_input = parameters.number_stack_input;
  file_type = '.tif';
  exp_name = parameters.exp_name;
  keyword = parameters.keyword;
  P = 0;

  for iii = 1:length(stack_directory_cell)
    stack_directory = stack_directory_cell{iii};

    [stack_files] = get_stacks(stack_directory,file_type,keyword);


    if number_stack_input == 'all'
      number_stack = length(stack_files);
      K = number_stack;
    else
      K = number_stack_input;
    end

    threshold_final_allcells = [];
    number_frames_per_cell = [];
    mean_pp_distance_all = [];
    SNR_first_frame_all = [];
    SNR_raw_first_frame_all = [];
    SNR_mean_first_frame_all = [];
    number_spots_after_initialth_all_cell = [];
    number_spots_after_SNRth_all_cell = [];
    T_all = [];
    W_all = [];
    H_all = [];

    %%loop over all stacks found with the keyword
    for stack_count=1:K;
      %%read in data
      fName = stack_files{stack_count};
      [I, setup.directory, save_dir] = getFluorescentImages_batch(stack_directory, fName, exp_name, interactive, parameters.startt, parameters.endt);

      %%setup_cell.directory{stack_count} = setup.directory;
      save_dir_cell{stack_count} = save_dir;

      clear Tracks info4Tracks Results* newY_cell filtered_image* length_tracks result* im

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now we read in the Images and create a directory to save the       %
% results (save_dir = strcat('Results\',exp_name,'\',directory);)    %
% I is a 3d matrix, (image_height, image_weight, nImage)             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      [H,W,T] = size(I);

      setup.M = H;
      setup.N = W;
      setup.K = T;


      %% Now we find potential spots in all image frames
      if interactive == 0
        counter_spots = strcat('Finding spots in video ', '',num2str(stack_count), ' of ', '',num2str(K));
      else
        counter_spots = strcat('Interactive Mode, Analysing cell', '',num2str(stack_count), ' of ', '',num2str(K));
      end
      h=waitbar(0, counter_spots);
      number_spots_after_initialth_all = [];
      SNR_raw_final = [];
      SNR_final = [];
      MaxI_final = [];
      MaxI_raw_final = [];
      number_spots_after_SNRth_all = [];

      for t=1:setup.K,
        filtered_image = bpass(I(:,:,t),parameters.lnoise,parameters.lobject);
        filtered_image_cell(:,:,t)=filtered_image;
      end

      %%calculate mean and std for whole video
      results.mean_stack = (mean(filtered_image_cell(:)));
      results.std_stack  = (std((filtered_image_cell(:))));
      threshold_d_peaks = results.mean_stack + parameters.initialthreshold*results.std_stack;

      %%in interactive mode, only the first frame is analysed
      if interactive == 1
        T = 1;
      end

      mean_pp_distance = [];
      SNR_raw_first_frame = [];
      SNR_first_frame = [];

      for t=1:T,
        filtered_image = filtered_image_cell(:,:,t);
        filtered_image(filtered_image<0)=0;

        %%this function detects spots
        [c_peaks_threshold, ~, ~, c_peaks] = automatic_detection(filtered_image, I(:, :, t), stack_count, threshold_d_peaks, parameters.max_spot_size, parameters.SNR, parameters.pkfnd_sz, parameters.cntrd_sz, parameters.interactive);

        if c_peaks_threshold==0,                      %no spots are found
          %%Alex: changed this to check if it is zero rather than isempty since isempty didn't work and program crashed when there were no spots detected
          xyIfilIrawSNRfilSNRraw{t} = [];
          number_spots_after_initialth_all = [number_spots_after_initialth_all,0];
          %%Alex: added the number_spots... variables to keep counting even if c_peaks_threshold is zero so that the plot at line 217 worked.
          number_spots_after_SNRth_all = [number_spots_after_SNRth_all ,0];
        else
          xyIfilIrawSNRfilSNRraw{t} = [c_peaks_threshold(:, 1:2),c_peaks_threshold(:, 3),c_peaks_threshold(:,5),c_peaks_threshold(:,6),c_peaks_threshold(:,7)];
          SNR_raw_final = [ SNR_raw_final xyIfilIrawSNRfilSNRraw{t}(:,6)'];
          SNR_final = [ SNR_final xyIfilIrawSNRfilSNRraw{t}(:,5)' ];
          MaxI_final = [ MaxI_final xyIfilIrawSNRfilSNRraw{t}(:,3)' ];
          MaxI_raw_final = [ MaxI_raw_final xyIfilIrawSNRfilSNRraw{t}(:,4)' ];
          number_spots_after_initialth_all = [number_spots_after_initialth_all,size(c_peaks,1)];
          number_spots_after_SNRth_all = [number_spots_after_SNRth_all ,size(c_peaks_threshold,1)];
        end

        if interactive == 0
          %%save results
          clear temp
          temp=xyIfilIrawSNRfilSNRraw{t};
          order4image = num2str(t, '%3d');
          filename = strcat(save_dir,'/coordinates_', order4image, '.dat');
          dlmwrite(filename,temp,'newline','pc');
        end
        waitbar(t/T,h)
      end

      close(h)

      if interactive == 0
        %%make TIFF/save coordinates in matlab file if not in interactive mode
        make_tiff(strcat(save_dir,'/raw_image.tif'),I,T)
        savefile4tracking = strcat(save_dir,'/','files4tracking.mat');
        save(savefile4tracking, 'xyIfilIrawSNRfilSNRraw', '-v7.3')
      end

      %%calculate mean density
      mean_number_spots_per_image = length(SNR_raw_final)/T;
      Image_area = H*W*(parameters.PixelSize)^2;
      density = mean_number_spots_per_image/Image_area;
      density_per_cell = mean_number_spots_per_image;

      %%plot and save control figures per cell
      if interactive == 0
        figure(),hist(MaxI_raw_final,sqrt(length(SNR_raw_final)))
        title(['cell = ',num2str(stack_count), ', # frames = ',num2str(T),', # spots = ',num2str(length(SNR_raw_final)), ', mean max I = ',num2str(round(mean(MaxI_raw_final)*1000)/1000),', density = ',num2str(round(density*1000)/1000),'per um^2', ' / ', num2str(round( density_per_cell*1000)/1000),' per cell']);
        fName_hist_all = strcat(save_dir,'/','Max_I_raw_Histogram.fig');
        ylabel('Frequency','fontsize',12,'fontweight','b')
        xlabel('max Intensity raw data','fontsize',12,'fontweight','b')
        saveas(gcf,fName_hist_all)

        figure(),hist(MaxI_final,sqrt(length(SNR_raw_final)))
        title(['cell = ',num2str(stack_count), ', # frames = ',num2str(T),', # spots = ',num2str(length(MaxI_final)), ', mean SNR = ',num2str(round(mean(MaxI_final)*1000)/1000)]);
        fName_hist_all = strcat(save_dir,'/','Max_I_Histogram.fig');
        ylabel('Frequency','fontsize',12,'fontweight','b')
        xlabel('raw SNR','fontsize',12,'fontweight','b')
        saveas(gcf,fName_hist_all)

        figure(),hist(SNR_raw_final,sqrt(length(SNR_raw_final)))
        title(['cell = ',num2str(stack_count), ', # frames = ',num2str(T),', # spots = ',num2str(length(SNR_raw_final)), ', mean SNR = ',num2str(round(mean(SNR_raw_final)*1000)/1000)]);
        fName_hist_all = strcat(save_dir,'/','SNR_raw_Histogram.fig');
        ylabel('Frequency','fontsize',12,'fontweight','b')
        xlabel('raw SNR','fontsize',12,'fontweight','b')
        saveas(gcf,fName_hist_all)

        figure(),hist(SNR_final,sqrt(length(SNR_final )))
        title(['cell = ',num2str(stack_count), ', # frames = ',num2str(T),', # spots = ',num2str( length(SNR_raw_final )), ', mean SNR = ',num2str(round(mean(SNR_final)*1000)/1000)]);
        fName_hist_all = strcat(save_dir,'/','SNR_Histogram.fig');
        ylabel('Frequency','fontsize',12,'fontweight','b')
        xlabel('SNR','fontsize',12,'fontweight','b')
        saveas(gcf,fName_hist_all)

        figure(),plot(1:T,number_spots_after_initialth_all)
        title(['cell = ',num2str(stack_count), ', # spots found after applying initial threshold']);
        fName_hist_all = strcat(save_dir,'/','number_spots_initial.fig');
        ylabel('# spots','fontsize',12,'fontweight','b')
        xlabel('Image frame','fontsize',12,'fontweight','b')
        saveas(gcf,fName_hist_all)

        figure(),plot(1:T,number_spots_after_SNRth_all)
        title(['cell = ',num2str(stack_count), ', # spots found after applying SNR threshold']);
        fName_hist_all = strcat(save_dir,'/','number_spots_SNR.fig');
        ylabel('# spots','fontsize',12,'fontweight','b')
        xlabel('Image frame','fontsize',12,'fontweight','b')
        saveas(gcf,fName_hist_all)
      end

      %% for plotting histogram below
      number_frames_per_cell = [ number_frames_per_cell P];

      %%concentate arrays up
      threshold_final_allcells = [ threshold_final_allcells threshold_d_peaks];
      number_spots_after_initialth_all_cell = [number_spots_after_initialth_all_cell sum(number_spots_after_initialth_all)];
      number_spots_after_SNRth_all_cell = [number_spots_after_SNRth_all_cell sum(number_spots_after_SNRth_all)];
      T_all = [T_all T ];
      W_all = [W_all W ];
      H_all = [H_all H ];

      if parameters.interactive == 0
        close all
      end

    end
  end
  setup_all.M = H_all;
  setup_all.N = W_all;
  setup_all.K = T_all;
  setup_all.density = mean_pp_distance_all;
  setup_all.directory = save_dir_cell;
  setup_all.SNR=SNR_first_frame_all;
  setup_all.SNR_raw=SNR_raw_first_frame_all;
  setup_all.SNR_mean=SNR_mean_first_frame_all;
  setup_all.spots_initial_th = number_spots_after_initialth_all_cell;
  setup_all.spots_second_th = number_spots_after_SNRth_all_cell;
  setup_all.threshold = threshold_final_allcells;
  setup_all.stack_directory = stack_directory;

  if interactive == 0
    savefile = strcat(parameters.exp_name,'/','Results.mat');
    save(savefile, 'setup', 'parameters', '-v7.3');
  end

  if interactive == 0 && K > 1
    save_dir = strcat(parameters.exp_name,'/','spot detection Results');

    y = threshold_final_allcells;
    figure(),plot(1:1:length(number_frames_per_cell),y,'--rs','LineWidth',2,...
                  'MarkerEdgeColor','k',...
                  'MarkerFaceColor','g',...
                  'MarkerSize',10)
    title(['Threshold used to identify spots over cell: ',num2str(mean(y)),' +- ', num2str(std(y)), ' [a.u.]']);
    fName_hist_all = strcat(save_dir,'/','threshold.fig');
    ylim([0 max(y)])
    ylabel('total threshold [a.u.]','fontsize',12,'fontweight','b')
    xlabel('Video index','fontsize',12,'fontweight','b')
    saveas(gcf,fName_hist_all)
  end
end

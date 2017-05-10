function [im]=plot_spots_on_image(image,spots,stack_count,color_map)

        figure(),imagesc(image); %truesize; %set(gcf,'Position',position),
        colormap(color_map);

        title(['cell = ',num2str(stack_count), ', frame: ' ,num2str(1), ', after applying size and SNR threshold ', num2str(length(spots)), ' spots found']);
        hold on; %grid off;  %set gcf current figure handle
        %%plot local maxima found by d_peaks on filtered image
        plot(spots(:,2),spots(:,1),'gx');
        hold on
        for i=1:size(spots,1)
        text(spots(i,2)+4,spots(i,1),strcat('SNR fil: ', num2str(round(spots(i,6))),', SNR raw: ',num2str(round(spots(i,7)))),'LineWidth',2,'BackgroundColor',[.7 .9 .7],'HorizontalAlignment','left')
        end
        hold on
        %plot_circle(spots(:,2),spots(:,1),spots(:,4));
        im=1;

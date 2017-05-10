function show_image(image,spots,stack_count,color_map)

        figure(),imagesc(image); truesize; %set(gcf,'Position',position),
        colormap(color_map);
        hold on;
        plot(spots(:,2),spots(:,1),'rx');
        hold off
        title(['cell = ',num2str(stack_count), ', frame: ' ,num2str(1), ', after applying initial threshold ', num2str(length(spots)), ' spots found']);
        hold on; %grid off;  %set gcf current figure handle

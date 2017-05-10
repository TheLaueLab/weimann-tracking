function [I, directory,save_name] = getFluorescentImages_batch(stack_directory,fName,~,exp_name,interactive,parameters)

file = strcat(stack_directory, '/', fName);

    [im, nImage] = tiffread2(file);


    %if only parts of the image should be read
    if parameters.endt == 0
        T_end = nImage;
    else
        T_end = parameters.endt;
        nImage = T_end;
    end

        T_start = parameters.startt;
        nImage = nImage + 1 - T_start;


    I = zeros(im(1).height, im(1).width, nImage);

    [dir, ext] = strread(fName,'%s%s','delimiter','.');

    directory = dir{1};
    h=waitbar(0, 'Data loading...');

    t_in = 1;
    for t=T_start:T_end,
        I(:, :, t_in) = double(im(t).data);
        t_in = t_in + 1;
        waitbar(t/length(im), h);
    end

    close(h);

    if interactive == 0
        directory_name = strcat(exp_name,'/','spot detection Results','/',directory,'_0');
        if isdir(directory_name)~=1,
            mkdir(directory_name);
            save_name = directory_name;
        else
            count = 1;
            indicator = 1;
            directory_name = strcat(exp_name,'/','spot detection Results','/',directory,'_');
            while indicator ==1,
                if isdir(strcat(directory_name,num2str(count)))==1,
                    count = count + 1;
                 else
                    save_directory = strcat(directory_name,num2str(count));
                    mkdir(save_directory);
                    save_name = save_directory;
                    indicator = 0;
                end
             end
        end

    else
        save_name = strcat(exp_name,'/','spot detection Results','/',directory,'_interactive');
    end

end

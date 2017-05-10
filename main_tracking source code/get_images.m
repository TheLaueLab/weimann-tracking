function [I, directory,save_name] = get_images(stack_directory,fName,~)

file = strcat(fName, '/', 'raw_image.tif');

    [im, nImage] = tiffread2(file);
    I = zeros(im(1).height, im(1).width, nImage);

    [dir, ext] = strread(fName,'%s%s','delimiter','.');

    directory = dir{1};
    h=waitbar(0, 'Loading Images...');

    for t=1:nImage,
        I(:, :, t) = double(im(t).data);
        waitbar(t/length(im), h);
    end

    close(h);

    directory_name = strcat(stack_directory, fName, '/','Results_tracking');

    if isdir(directory_name)~=1,
    mkdir(directory_name);
    save_name = directory_name;
    else
    count = 1;
    indicator = 1;
    while indicator ==1,
        if isdir(strcat(directory_name,'_',num2str(count)))==1,
            count = count + 1;
        else
            save_directory = strcat(directory_name,'_',num2str(count));
            mkdir(save_directory);
            save_name = save_directory;
            indicator = 0;
        end
    end
    end
end

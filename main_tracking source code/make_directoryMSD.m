function [save_name_MSD,save_name_JD]= make_directoryMSD(parameters,newFolder)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This first part creates a directory for saving the data. The program will
% not overwrite existing folders, but will instead create a new version
% with a numbered suffix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
directory_name = strcat(parameters.exp_name,'/','MSD Analysis Results/',newFolder,'/');%Alex: Added newFolder variable to save each stack analysed in a different folder

if isdir(directory_name)~=1,
    mkdir(directory_name);
    save_name_MSD = strcat(directory_name);
else
    count = 1;
    indicator = 1;
    while indicator ==1,       
        if isdir(strcat(directory_name,'_',num2str(count)))==1,
            count = count + 1;
        else
            save_directory = strcat(directory_name,'_',num2str(count),'/');
            mkdir(save_directory);
            save_name_MSD = strcat(directory_name,'_',num2str(count),'/');
            indicator = 0;
        end
    end
end       

directory_name = strcat(parameters.exp_name,'/','JD Analysis Results/',newFolder,'/');

if isdir(directory_name)~=1,
    mkdir(directory_name);
    save_name_JD = strcat(directory_name);
else
    count = 1;
    indicator = 1;
    while indicator ==1,       
        if isdir(strcat(directory_name,'_',num2str(count)))==1,
            count = count + 1;
        else
            save_directory = strcat(directory_name,'_',num2str(count),'/');
            mkdir(save_directory);
            save_name_JD = strcat(directory_name,'_',num2str(count),'/');
            indicator = 0;
        end
    end
end     




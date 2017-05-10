function [list_dir,folders] = get_folders_withdirectory(keyword,current_directory)

d = dir(current_directory);

ii = 1;

if strcmp(keyword, 'all')== 1
    for n = 3:length(d),
        folders{ii} = d(n).name;
            list_dir{ii} = strcat(current_directory,'/',d(n).name);
            ii = ii + 1;
    end
else

for n = 3:length(d),

    if d(n).isdir == 1,

        a = d(n).name;
        if findstr(a,keyword) >= 1 || findstr('all',keyword) >= 1,
            folders{ii} = d(n).name;
            list_dir{ii} = strcat(current_directory,'/',d(n).name);
            ii = ii + 1;

        end

    end

end
end
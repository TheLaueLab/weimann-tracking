function [tracks,tracksname] = load_tracks(current_directory)

f = dir(current_directory);
count = 1;
tracks = [];

for n3=1:length(f),

    fName= f(n3).name;
    istrack = findstr(fName,'track_');
    isdat = findstr(fName,'dat');

    if (istrack >= 1)
        bool1=1;
    else
        bool1=0;
    end

    if (isdat >= 1)
        bool2=1;
    else
        bool2=0;
    end

    if (bool1 == 1) && (bool2 == 1)

        tracks{count} = dlmread(strcat(current_directory,'/',fName));
        tracksname{count} = fName;
        count = count + 1;
    end

end
if count==1
    tracksname = strcat(fName, '_empty');
end

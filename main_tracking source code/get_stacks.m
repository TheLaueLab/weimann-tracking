function [stack_files] = get_stacks(directory,file_type,keyword)

d = dir(directory);

count=1;

for n=3:length(d),

    name = d(n).name;
    isstk= findstr(name,file_type);
    iskeyword = findstr(name,keyword);

    if (length(isstk) >= 1) && (length(iskeyword) >= 1)

            stack_files{count} = name;
            count = count + 1;

    end

end

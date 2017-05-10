function [ f_out ] = Print_two_digits( f_in )

f_temp = round(f_in*100)/100;

f_temp = sprintf('%0.2f',f_temp);

f_out = f_temp;

end


function [jump] = get_jump3(time,x,y,parameters)

for i=1:length(x)-parameters.JD
    
    if time(i)-time(i+parameters.JD)==-parameters.JD
        
        jump(i) = sqrt(((x(i) - x(i+parameters.JD)).^2 + (y(i) - y(i+parameters.JD)).^2));
        jump(i) = jump(i) * parameters.PixelSize;
    else
        jump(i) = 0;
    end
    
    jump=jump(jump~=0);
end
    


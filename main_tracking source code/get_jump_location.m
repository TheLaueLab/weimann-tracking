function [jump_all,NumMolecules] = get_jump_location(TrackIndex,allTracks,NumTracks,parameters, eXes, whYs)

jump_all = [];
NumMolecules = 0;


for ntrack = 1:length(TrackIndex)
    current_track = allTracks{TrackIndex(ntrack)};
    
    %%%%if it starts at t=1, the first frame, delete first frame, since
    %%%%the time difference between the first two frames is different
    %%%%because of the camera read out time
    if current_track(1,1)==1
        current_track(1,:)=[];
    end  

    t_temp = current_track(:,1);
    time = t_temp-t_temp(1)+1;
    x = current_track(:,2);
    y = current_track(:,3);
    TrackCounted = 0;
    
    for i=1:length(x)-parameters.JD

        if time(i)-time(i+parameters.JD)==-parameters.JD
            if (sqrt((eXes - x(i)).^2 + (whYs - y(i)).^2))<=parameters.heatmapRadius

                jump(i) = sqrt(((x(i) - x(i+parameters.JD)).^2 + (y(i) - y(i+parameters.JD)).^2));
                jump(i) = (jump(i) * parameters.PixelSize)./parameters.JD;
                if TrackCounted == 0
                    NumMolecules = NumMolecules + 1;
                    TrackCounted = 1;
                end
            else
                jump(i) = 0;

            end
        else
            jump(i) = 0;
        end

        jump=jump(jump~=0);
    end

        
    
    jump_all = [jump_all jump];
    
end
end
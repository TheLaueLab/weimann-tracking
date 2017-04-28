function [ TotalJumps,MeanJD,Molecules ] = Heatmaps( whYs, eXes, All_TracksY, All_TracksX, All_TracksT, parameters )

TotalJumps = 0;
jump = zeros(length(All_TracksT));
Molecules = 0;
TrackCounted = 0;
i=1;

for count = 1:length(All_TracksT)
    if All_TracksT(count) ~= -1 && All_TracksT(count+1) ~= -1
        if All_TracksT ~= 1
            if (sqrt((eXes - All_TracksX(count)).^2 + (whYs - All_TracksY(count)).^2))<=parameters.heatmapRadius
                 jump(i) = sqrt(((All_TracksX(count) - All_TracksX(count+1)).^2 + (All_TracksY(count) - All_TracksY(count+1)).^2));
                 jump(i) = jump(i) * parameters.PixelSize;
                 i = i+1;
                 TotalJumps = TotalJumps+1;
                 if TrackCounted == 0
                    Molecules = Molecules+1;
                    TrackCounted = 1;
                 end
            end
        end
    else
        TrackCounted = 0;
        
    end
end


jump=jump(jump~=0);

if sum(jump) == 0;
    MeanJD = 0;
else
    MeanJD = mean(jump); 
end

        
end


function [ mean_pp_distance min_pp_distance nn] = get_mean_pp_distance( matrix_coordinates )

     for n_frame = 1:size(matrix_coordinates,3)

         temp = matrix_coordinates(:,:,n_frame);
         x =  temp(:,1);
         y =  temp(:,2);

     for i = 1 : size(temp,1)
         x0 = temp(i,1);
         y0 = temp(i,2);

         d = sqrt(((x - x0).^2 + (y - y0).^2));
         d = d(d~=0);
         nn(i,n_frame) = min(d);
     end
     end

     mean_pp_distance = mean(mean(nn));
     min_pp_distance = min(min(nn));



end

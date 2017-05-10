function [c_peaks_threshold,filtered_image,d_peaks,c_peaks]=automatic_detection(filtered_image,raw_image,parameters,stack_count,threshold_d_peaks)

%parameters that determine detection
p_maximum_size=parameters.max_spot_size;
p_SNR=parameters.SNR;
pkfnd_sz = parameters.pkfnd_sz;
cntrd_sz = parameters.cntrd_sz;

%If interactive is set to 1, only the first frame and the last frames are analysed and some
%control plots are presented

    %find centroid
    d_peaks=pkfnd(filtered_image, threshold_d_peaks, pkfnd_sz);

    if size(d_peaks,1)>0
    %here the first argument defines the image to which cntrd is applied and should always be the filtered image
    %the second argument of cntrd_laura defines the image for which the SNR
    %is calculated, if its the raw data, the SNR of the raw data is
    %calculated
    [c_peaks]=cntrd_adapted(filtered_image,raw_image,d_peaks,cntrd_sz,0);
    %apply SNR/size threshold on filtered data
    c_peaks_threshold=zeros(length(c_peaks),7);
    jj=1;
    for j=1:size(c_peaks,1)
        p1=c_peaks(j,6);
        p2=c_peaks(j,4);
        if p1 > p_SNR && sqrt(p2) < p_maximum_size
           c_peaks_threshold(jj,:)=c_peaks(j,:);
           jj=jj+1;
        end
    end
    c_peaks_threshold = c_peaks_threshold(1:jj-1,:);

    if size(c_peaks_threshold,1)>0

    % optional plot of SNR on images
    if parameters.interactive == 1

     show_image(raw_image,c_peaks,stack_count,'hot');
     show_image(filtered_image,c_peaks,stack_count,'hot');
     plot_spots_on_image(raw_image,c_peaks_threshold,stack_count,'hot');


    pause(2)

    end
    else
        c_peaks_threshold = 0;
        c_peaks = 0;
    end

    else
        c_peaks_threshold = 0;
        c_peaks = 0;
    end

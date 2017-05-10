function make_tiff(filename,video,nImage)

imwrite(uint16(video(:,:,1)),filename,'compression','none');

if nImage>1,

    for t = 2:nImage,

        imwrite(uint16(video(:,:,t)),filename,'compression','none','writemode','append');

    end

end
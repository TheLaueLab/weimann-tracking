function [out]=cntrd_adapted(im,im_original,mx,sz,interactive)

%Here, areas to calculate SNR (spot area and background area) need to be
%defined. The spot area is defined as circular region around the centroid,
%with the radius of this area defined by the centroid function out(:,4).
%(Laura Weimann).
%The background area is chosen by default to be window around the
%spot with diameter 2*(sz+2). All pixels which belong to neighbouring spots 
%are declined for analysis. 


% OUT:  a N x 7 array containing, x, y and brightness for each centroid 
%           out(:,1) is the x-coordinates
%           out(:,2) is the y-coordinates
%           out(:,3) is the max_brightness of filtered image
%           out(:,4) is the square of the radius of gyration
%           out(:,5) is the max_brightness of raw image
%           out(:,6) is the SNR of filtered image
%           out(:,7) is the SNR of raw image




%Adapted from
% out=cntrd(im,mx,sz,interactive)
% 
% PURPOSE:  calculates the centroid of bright spots to sub-pixel accuracy.
%  Inspired by Grier & Crocker's feature for IDL, but greatly simplified and optimized
%  for matlab
% 
% INPUT:
% im: image to process, particle should be bright spots on dark background with little noise
%   ofen an bandpass filtered brightfield image or a nice fluorescent image
%
% mx: locations of local maxima to pixel-level accuracy from pkfnd.m
%
% sz: diamter of the window over which to average to calculate the centroid.  
%     should be big enough
%     to capture the whole particle but not so big that it captures others.  
%     if initial guess of center (from pkfnd) is far from the centroid, the
%     window will need to be larger than the particle size.  RECCOMMENDED
%     size is the long lengthscale used in bpass plus 2.
%     
%
% interactive:  OPTIONAL INPUT set this variable to one and it will show you the image used to calculate  
%    each centroid, the pixel-level peak and the centroid
%
% NOTE:
%  - if pkfnd, and cntrd return more then one location per particle then
%  you should try to filter your input more carefully.  If you still get
%  more than one peak for particle, use the optional sz parameter in pkfnd
%  - If you want sub-pixel accuracy, you need to have a lot of pixels in your window (sz>>1). 
%    To check for pixel bias, plot a histogram of the fractional parts of the resulting locations
%  - It is HIGHLY recommended to run in interactive mode to adjust the parameters before you
%    analyze a bunch of images.
%
% OUTPUT:  a N x 4 array containing, x, y and brightness for each feature
%           out(:,1) is the x-coordinates
%           out(:,2) is the y-coordinates
%           out(:,3) is the max_brightness
%           out(:,4) is the sqare of the radius of gyration
%
% CREATED: Eric R. Dufresne, Yale University, Feb 4 2005
%  5/2005 inputs diamter instead of radius
%  Modifications:
%  D.B. (6/05) Added code from imdist/dist to make this stand alone.
%  ERD (6/05) Increased frame of reject locations around edge to 1.5*sz
%  ERD 6/2005  By popular demand, 1. altered input to be formatted in x,y
%  space instead of row, column space  2. added forth column of output,
%  rg^2
%  ERD 8/05  Outputs had been shifted by [0.5,0.5] pixels.  No more!
%  ERD 8/24/05  Woops!  That last one was a red herring.  The real problem
%  is the "ringing" from the output of bpass.  I fixed bpass (see note),
%  and no longer need this kludge.  Also, made it quite nice if mx=[];
%  ERD 6/06  Added size and brightness output ot interactive mode.  Also 
%   fixed bug in calculation of rg^2
%  JWM 6/07  Small corrections to documentation 


if nargin==3
   interactive=0; 
end

if sz/2 == floor(sz/2)
warning('sz must be odd, like bpass');
end

if isempty(mx)
    warning('there were no positions inputted into cntrd. check your pkfnd theshold')
    out=[];
    return;
end


r=(sz+1)/2;
%create mask - window around trial location over which to calculate the centroid
m = 2*r + 1;
x = 1:(m) ;
cent = (m-1)/2+1;
x2 = (x-cent).^2;
dst=zeros(m,m);
for i=1:m
    dst(i,:)=sqrt((i-cent)^2+x2);
end


ind=find(dst < r);

msk=zeros([2*r+1,2*r+1]);
msk(ind)=1.0;
%msk=circshift(msk,[-r,-r]);

dst2=msk.*(dst.^2);
ndst2=sum(sum(dst2));

[nr,nc]=size(im);
%remove all potential locations within distance 2*sz from edges of image
ind=find(mx(:,2) > 1.5*2*sz & mx(:,2) < nr-1.5*2*sz);
mx=mx(ind,:);
ind=find(mx(:,1) > 1.5*2*sz & mx(:,1) < nc-1.5*2*sz);
mx=mx(ind,:);

[nmx,crap] = size(mx);

%inside of the window, assign an x and y coordinate for each pixel
Xx=zeros(2*r+1,2*r+1);
for i=1:2*r+1
    Xx(i,:)=(1:2*r+1);
end
Yy=Xx';



pts=[];


    %calculate background value for I(:,:,t)

    %get background value to define threshold, here, I take
    %areas from all 4 image corners and average
    region4background = 20;
    temp4Background1 = im_original(1:region4background,1:region4background);
    temp4Background2 = im_original((size(im_original,1)-region4background):size(im_original,1)-1,1:region4background);
    temp4Background3 = im_original(1:region4background,(size(im_original,2)-region4background):size(im_original,2)-1);    
    temp4Background4 = im_original((size(im_original,1)-region4background):size(im_original,1)-1,(size(im_original,2)-region4background):size(im_original,2)-1);    
    
    Background_4 = [temp4Background1(:) temp4Background2(:) temp4Background3(:) temp4Background4(:)];
    Background = Background_4(:);
    Background = Background(Background>0);
    mean4BN = mean(Background);
    std4BN = std(Background);
    
    %same for filtered data
    region4background = 20;
    temp4Background1 = im(1:region4background,1:region4background);
    temp4Background2 = im((size(im,1)-region4background):size(im,1)-1,1:region4background);
    temp4Background3 = im(1:region4background,(size(im,2)-region4background):size(im,2)-1);    
    temp4Background4 = im((size(im,1)-region4background):size(im,1)-1,(size(im,2)-region4background):size(im,2)-1);    
    
    Background_4_fil = [temp4Background1(:) temp4Background2(:) temp4Background3(:) temp4Background4(:)];
    Background_fil = Background_4_fil(:);
    Background_fil = Background_fil(Background_fil>0);
    mean4BN_fil = mean(Background_fil);
    std4BN_fil = std(Background_fil);    
    
    %threshold = mean4BN_fil + parameters.fix_threshold*std4BN_fil;



[M,N]=size(im);
msk_total=ones(M,N);
mask_centroid_positions=ones(M,N);
%[Xx,Yy]=meshgrid(x*dx,y*dx);
%loop through all of the candidate positions
for i=1:nmx
    %create a small working array around each candidate location, and apply the window function

    tmp=msk.*im((mx(i,2)-r:mx(i,2)+r),(mx(i,1)-r:mx(i,1)+r));
    tmp_raw=msk.*im_original((mx(i,2)-r:mx(i,2)+r),(mx(i,1)-r:mx(i,1)+r));
    %x_cm=sum(sum(Xx.*I))./sum(I(:));
    %y_cm=sum(sum(Yy.*I))./sum(I(:));
    %calculate the total brightness
     norm=sum(sum(tmp));
     max_intensity=max(max(tmp));
     max_intensity_raw=max(max(tmp_raw));
%     %calculate the weigthed average x location
     xavg=sum(sum(Xx.*tmp))./norm;
%     %calculate the weighted average y location
     yavg=sum(sum(Yy.*tmp))./norm;
%     %calculate the radius of gyration^2
%     %rg=(sum(sum(tmp.*dst2))/ndst2);
      rg=(sum(sum(tmp.*dst2))/norm);
    
     %calculate SNR (not local, use global background)
     SNR=(max_intensity-mean4BN_fil)/(sqrt(std4BN_fil^2));
     SNR_raw=(max_intensity_raw-mean4BN)/(sqrt(std4BN^2));  
      
    %concatenate it up
    %pts=[pts,[mx(i,1)+xavg-r,mx(i,2)+yavg-r,norm,rg]'];
    %pts=[pts,[x_cm/dx,y_cm/dx]'];
    pts=[pts,[mx(i,1)+xavg-r-1,mx(i,2)+yavg-r-1,max_intensity,rg,max_intensity_raw,SNR,SNR_raw]'];
    
    %OPTIONAL plot things up if you're in interactive mode
    if interactive==1
     imagesc(im)
     axis image
     hold on;
     plot(mx(i,1)+xavg-r-1,mx(i,2)+yavg-r-1,'x','Color','red')
     plot(mx(i,1)+xavg-r-1,mx(i,2)+yavg-r-1,'o','Color','red')
     plot(mx(i,1),mx(i,2),'.')
     hold off
     %title(['brightness ',num2str(norm),' size ',num2str(sqrt(rg))])
     pause(1)
    end
end

out=pts';
out(:,1:2) = out(:,2:-1:1);


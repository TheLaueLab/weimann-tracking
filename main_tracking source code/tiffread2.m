function [stack, img_read] = tiffread2(filename, img_first, img_last)
% tiffread2, version 3.0
%
% [stack, nbImages] = tiffread;
% [stack, nbImages] = tiffread(filename);
% [stack, nbImages] = tiffread(filename, imageIndex);
% [stack, nbImages] = tiffread(filename, firstImageIndex, lastImageIndex);
%
% Kai Wohlfahrt
% kjw53 (at) cam.ac.uk

  tif = Tiff(filename, 'r');

  if (nargin == 1)
    n = 1;
    while (~tif.lastDirectory())
      n = n + 1;
      tif.nextDirectory();
    end
    frames = 1 : n;
  elseif (nargin == 2)
    frames = img_first : img_first;
  else
    frames = img_first : img_last;
  end

  img_read = numel(frames);
  tif = Tiff(filename, 'r');
  w = tif.getTag('ImageWidth');
  h = tif.getTag('ImageLength'); % Docs say should be 'ImageHeight'
  bits = tif.getTag('BitsPerSample');

  meta = struct('filename', filename, 'width', w, 'height', h, ...
                'bits', bits, 'data', zeros(w, h));
  stack = repmat(meta, 1, img_read);

  for i = frames
    tif.setDirectory(i);
    stack(i).data(:,:) = read(tif);
  end
end

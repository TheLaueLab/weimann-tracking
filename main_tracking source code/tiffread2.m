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

  info = imfinfo(filename);

  if (nargin == 1)
    frames = 1:numel(info);
  elseif (nargin == 2)
    frames = img_first : img_first;
  else
    frames = img_first : img_last;
  end

  img_read = numel(frames);
  w = info(1).Width;
  h = info(1).Height;
  bits = info(1).BitDepth;

  meta = struct('filename', filename, 'width', w, 'height', h, ...
                'bits', bits, 'data', zeros(w, h));
  stack = repmat(meta, 1, 1000);

  for i = frames
    stack(i).data(:,:) = imread(filename, i, 'Info', info);
  end
end

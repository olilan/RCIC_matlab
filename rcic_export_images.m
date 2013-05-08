function rcic_export_images(datafile, img_dir, img_array)
% function rcic_export_images(datafile, img_dir, img_array)
%
% Loads an image array resulting from the function rcic_generate_stimuli and
% exports the rendered images as bmp-files to disk.
%
% ex.call: rcic_export_images('rcicdata.mat', 'stimuli', 'stim');
%
% ----------------------------------------------------------------------------
% Copyright (C) 2013, Oliver Langner and Ron Dotsch
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the Eclipse Public License as published by
% the Eclipse Foundation, version 1.0.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% Eclipse Public License for more details.
%
% You should have received a copy of the Eclipse Public License
% along with this program.  If not, see
% http://www.eclipse.org/legal/epl-v10.html
% ----------------------------------------------------------------------------

%check, if directory exists
if ~exist(img_dir, 'dir'), mkdir(img_dir); end

%load image array
img = struct2cell(load(datafile, img_array));
img = img{1};

for c = 1 : length(img) %loop over image containers
    
    %get number of images
    nrI = size(img{c}.img, 3);
    
    for n = 1 : nrI %loop over images
        
        %write image as bmp and with stored name to stimdir
        imwrite(img{c}.img(:,:,n), fullfile(img_dir, img{c}.name{n}), 'bmp');
    end
end
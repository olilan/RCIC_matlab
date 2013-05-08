function img_norm = norm_gsimage_lm(img, d_mean, d_max, varargin)
% function img_norm = norm_gsimage_lm(img, d_mean, d_max, [maskl], [bgcol])
%
% Normalizes the intensity-distribution of a grayscale-image. To be
% normalized image area can be defined by the logical mask "maskl". Normalizes
% that area to an intensity distribution with mean="d_mean" and
% range= -"d_max" to +"d_max". Leaves area outside mask either untouched or
% replaces it by color bgcol.
%
% ex. call: img_norm = norm_gsimage_lm(img, 128, 127, maskl, 10);
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

%look for provided parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch length(varargin)
    case 0
        %default mask=whole image; no bgcol
        maskl = [];
        bgcol = NaN;
    case 1
        %take mask from input; no bgcol
        maskl = varargin{1};
        bgcol = NaN;
    case 2
        %take mask and bgcol from input
        maskl = varargin{1};
        bgcol = varargin{2};
end

%get the area neede for normalizing
if isempty(maskl)
    tmp = img(:);
else
    tmp = img(maskl);
end

%compute intensity-mean and -range for area defined by maskl %%%%%%%%%%%%%%%%%

%get mean
img_mean = mean(tmp);

%get maximum range of intensities
img_range = max(abs(tmp - img_mean));

%transform intensity and range to scale_mean and scale_max %%%%%%%%%%%%%%%%%%%

%mean = 0 max/min = 1/-1
img_norm = (img - img_mean) ./ img_range;

%mean = d_mean; max/min = d_max/-d_max
img_norm = (img_norm .* d_max) + d_mean;

%deal with parts outside the masked area %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~(isnan(bgcol)), img_norm(~maskl) = bgcol; end

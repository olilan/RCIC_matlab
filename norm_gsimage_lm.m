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

%look for provided parameters
switch length(varargin)
    case 0
        %default mask=whole image; no bgcol
        maskl = true(size(img));
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

%compute intensity-mean and -range for area defined by maskl %%%%%%%%%%%%%%%%%

img_mean = mean(img(maskl));
if (numel(img_mean) > 1), img_mean = mean(img_mean); end
img_range = max(abs(img(maskl) - img_mean));

%transform intensity and range to scale_mean and scale_max %%%%%%%%%%%%%%%%%%%

%mean = 0 max/min = 1/-1
img_norm = (img - img_mean) ./ img_range;

%mean = d_mean; max/min = d_max/-d_max
img_norm = (img_norm .* d_max) + d_mean;

%deal with parts outside the masked area %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if (isnan(bgcol))
    %restore original image-parts
    img_norm(~maskl) = img(~maskl);
else
    %give background outside mask color bgcol
    img_norm(~maskl) = bgcol;
end
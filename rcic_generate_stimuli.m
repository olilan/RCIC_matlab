function rcic_generate_stimuli(nrS, blur, symm, seed, prefix)
% function rcic_generate_stimuli(nrS, blur, symm, seed, prefix)
%
% The function generates noisy image following the Mangini and Biederman
% method. Will ask the user for base face images, then generates noisy
% stimuli for each base face image and stores them in a folder also chosen
% by the user. For each stimulus, two images are generated, ones with the
% sinusoid noise added, and once with the inverted sinusoid noise added.
%
% Input:
%        nrS          number of stimuli to generate for each base face
%        blur         should we blur base face?
%        symm         when true, will generate negative images in addition to
%                     originals
%        seed         seed value used by random generator for making the
%                     random sinusoid contrasts
%        prefix       prefix for stimulus names
%
% example call: rcic_generate_stimuli(100, 0, 1, 100477, 'teststim');

%noise weight
nWeight = .5;

%check seed input %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Using seed: %i\n', seed);

%get sinusoids %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Load sinusoids...');

try
    %load sinusoids from stimulus file
    sinusoids = struct2array(load('rcic_stimuli.mat', 'sinusoids'));
    indices = struct2array(load('rcic_stimuli.mat', 'sinIdx'));
    loadedFromFile = 1;
    
catch
    %generate sinusoids and indices
    [sinusoids, indices] = rcic_make_sinusoids([512 512]);
    loadedFromFile = 0;
end

fprintf('Done!\n');

%get number of unique sinusoid parameters
nrInd = length(unique(indices));

%get base face image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make kernel for image blurring
kernel = fspecial('gaussian', 10, 10);

%ask user for base face
[bname, bpath] = uigetfile(...
    '*.jpg',...
    'Pick Base Face Image');

fprintf('Loading base face image...');

%load base face
bf = imread(fullfile(bpath, bname), 'jpg');

%make grayscale if necessary
if (size(bf, 3) > 1), bf = rgb2gray(bf); end

%change to double
bf = double(bf)

if (blur)
    %blur base face
    bf = imfilter(bf, kernel);
end

%scale to range 0-1
bf = (bf - min(bf(:))) / (max(bf(:)) - min(bf(:)));

fprintf('Done!\n');

%get mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ask user for base face
[mname, mpath] = uigetfile(...
    '*.jpg',...
    'Pick Mask Image');

if (mname == 0) %user picked no mask
    
    %mask is whole image
    mask = true(512);
    
else
    
    %load mask image
    mask = imread(fullfile(mpath, mname), 'jpg');
    %???
    mask = mask > 30;
end

%generate random contrasts for all stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Generate random contrast weights...');

%start random stream
rstr = RandStream.create('mt19937ar', 'seed', seed);
RandStream.setDefaultStream(rstr);

%generate needed number of random contrast values (range -1 to 1); columns
%are trials, rows are sinusoid indices
contrast = (rand(nrInd, nrS) - .5) * 2;

fprintf('Done!\n');

%save stimulus data to file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get target directory
targdir = uigetdir(bpath, 'Pick stimulus directory');

%save stimulus file
if ~loadedFromFile
    
    % rename vars to match analysis
    sinIdx = indices;
    img = bf;
    
    %save data
    save(fullfile(targdir, 'rcic_stimuli.mat'), 'contrast', 'sinIdx',...
        'sinusoids', 'img', 'mask');
end

%generate noise stimuli %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fprintf('Generating %d stimuli for base face %s...', nrS, bname);

%make waitbar
wbh = waitbar(0, bname);
drawnow;

for n = 1 : nrS %loop over number of trials
    
    if (symm)
        
        %generate stimulus images with original and inverted noise
        [orig, invert] = rcic_make_noisy_stimuli(bf, contrast(:, n),...
            nWeight, sinusoids, indices, 2);        
    else
        
        %generate stimulus images with original and inverted noise
        [orig] = rcic_make_noisy_stimulus(bf, contrast(:, n),...
            nWeight, sinusoids, indices, 2);    
    end
    
    %make filename for first file
    fname = sprintf('%s_%s_%d_%03.0f_0.jpg',...
        prefix, bname(1:end-4), seed, n);
    
    %normalize and write orig image
    orig = norm_gsimage_lm(orig, 128, 127, mask);
    imwrite(uint8(orig), fullfile(targdir, fname), 'jpg');
    
    if (symm)
        
        %make filename for second file
        fname = sprintf('%s_%s_%d_%03.0f_1.jpg',...
            prefix, bname(1:end-4), seed, n);
        
        %normalize and write invert image
        invert = norm_gsimage_lm(invert, 128, 127, mask);
        imwrite(uint8(invert), fullfile(targdir, fname), 'jpg');
    end
    
    %update waitbar
    waitbar(n / nrS, wbh);
end

%close waitbar
close(wbh);

fprintf('Done!\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stim1, stim2] = rcic_make_noisy_stimuli(img, contrast,...
    nWeight, sinusoids, indices, scaling)
% function [stim1, stim2] = rcic_make_noisy_stimulus(img, contrast,...
%                                    nWeight, sinusoids, indices, scaling)
%
% The function takes a base face image and generates stimuli with overlayed
% sinusoid noise. "sinusoids" and "indices" were generated by the function
% rcic_anx_make_sinusoids.m. nWeight is the weighting of the noise in the
% final images.

%get weighted sinusoid mixture
sinW = mean(sinusoids .* contrast(indices), 3);

if (scaling == 1)
    
    %scale noise to 0-1 range
    sinW = (sinW - min(sinW(:))) / (max(sinW(:)) - min(sinW(:)));
    
else
    
    %scale noise constant from -.3/.3 to 0/1
    sinW = (sinW + .3) / .6;
end

%combine noise and image
stim1 = (1 - nWeight) * img + nWeight * sinW;

%combine inverted noise and image
stim2 = (1 - nWeight) * img + nWeight * (1 - sinW);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [stim1] = rcic_make_noisy_stimulus(img, contrast, nWeight,...
    sinusoids, indices, scaling)
% function [stim1] = rcic_make_noisy_stimulus(img, contrast,...
%                             nWeight, sinusoids, indices, scaling)
%
% The function takes a base face image and generates stimuli with overlayed
% sinusoid noise. "sinusoids" and "indices" were generated by the function
% rcic_anx_make_sinusoids.m. nWeight is the weighting of the noise in the
% final images.

%get weighted sinusoid mixture
sinW = mean(sinusoids .* contrast(indices), 3);

if (scaling == 1)
    
    %scale noise to 0-1 range
    sinW = (sinW - min(sinW(:))) / (max(sinW(:)) - min(sinW(:)));
    
else
    
    %scale noise constant from -.3/.3 to 0/1
    sinW = (sinW + .3) / .6;
end

%combine noise and image
stim1 = (1 - nWeight) * img + nWeight * sinW;
